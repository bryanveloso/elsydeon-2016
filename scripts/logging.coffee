# Description:
#   Functionality around logging to the Avalonstar(tv) API.

Firebase = require 'firebase'
firebase = new Firebase 'https://avalonstar.firebaseio.com/'

module.exports = (robot) ->
  # Utility methods.
  handleUser = (username) ->
    # The intial creation of users is handled by Endymion, who is set to
    # `TWITCHCLIENT 1` so it can read joins and parts. Therefore we don't have
    # to get creative in order to add users to Firebase (or Hubot's brain.)
    viewers = firebase.child('viewers')
    episode = robot.brain.get 'currentEpisode'
    if episode?
      json = {}
      json[episode] = true
      viewers.child(username).child('episodes').update json, (error) ->
        console.log "hanldeUser: #{error}" if error?

    robot.http("https://api.twitch.tv/kraken/users/#{username}")
      .get() (err, res, body) ->
        viewer = JSON.parse body
        json =
          'display_name': viewer.display_name
        viewers.child(username).update json, (error) ->
          console.log "handleUser: #{error}" if error?

  pushMessage = (message, ircdata, is_emote) ->
    # The meat of the entire operation. Pushes a payload containing a message,
    # emotes, roles, and usernames to Firebase.
    viewers = firebase.child('viewers')
    viewers.child(ircdata.name).once 'value', (snapshot) ->
      firedata = snapshot.val() or []
      ircroles = ircdata.roles or []
      roles = firedata?.roles or []

      json =
        'color': firedata?.color or '#ffffff'
        'display_name': firedata?.display_name or ircdata.name
        'emotes': firedata?.emotes or []
        'is_emote': is_emote
        'message': message
        'roles': roles.concat ircroles
        'timestamp': Firebase.ServerValue.TIMESTAMP
        'username': ircdata.name

      # Firebase. Testing this out.
      messages = firebase.child('messages').push()
      messages.setWithPriority json, ircdata.name, (error) ->
        console.log "pushMessage: #{error}" if error?
      return

  if robot.adapter.bot?
    # If the user emotes, set json.emote to true.
    robot.adapter.bot.addListener 'action', (from, to, message) ->
      unless from is 'jtv'
        # Send the dictionary to Firebase.
        pushMessage message, robot.brain.userForName(from), true
        handleUser from

    # Listen for general messages.
    robot.adapter.bot.addListener 'message', (from, to, message) ->
      unless from is 'jtv'
        # Send the dictionary to Firebase.
        pushMessage message, robot.brain.userForName(from), false
        handleUser from

  # Listening for special users (e.g., turbo, staff, subscribers)
  # Messages can be prefixed by a username (most likely the bot's name).
  # Note: Roles such as moderator do not appear in this method.
  robot.hear /.*?\s?SPECIALUSER ([a-zA-Z0-9_]*) ([a-z]*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      name = msg.match[1]
      userdata = robot.brain.data['viewers'][name]
      userdata['roles'] ?= []

      if msg.match[2] not in userdata['roles']
        userdata['roles'].push msg.match[2]
      robot.brain.save()

      # Save user list to Firebase.
      viewers = firebase.child('viewers')
      viewers.child(name).child('roles').set userdata['roles'], (error) ->
        robot.logger.error "Error in `handleRoles`: #{error}" if error

  # Listening for emoticon sets.
  # Expected value is a list of integers.
  robot.hear /EMOTESET ([a-zA-Z0-9_]*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      emotes = msg.match[2].substring(1).slice(0, -1).split(',')  # Store EMOTESET as an actual list?

      # Save emote list to Firebase.
      viewers = firebase.child('viewers')
      viewers.child(msg.match[1]).child('emotes').set emotes, (error) ->
        console.log "handleEmotes: #{error}" if error?

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR ([a-zA-Z0-9_]*) (#[A-Z0-9]{6})/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      # Save user list to Firebase.
      viewers = firebase.child('viewers')
      viewers.child(msg.match[1]).child('color').set msg.match[2], (error) ->
        robot.logger.error "Error in `handleColor`: #{error}" if error

  # Listening to see if a user gets timed out.
  # Expected value is a username.
  robot.hear /CLEARCHAT ([a-zA-Z0-9_]*)/, (msg) ->
    viewer = msg.match[1]
    messages = firebase.child('messages')

    # CLEARCHAT without a name will clear the entire chat on Twitch web. Do not
    # respect that, lest we purge things that we don't want to purge.
    if viewer
      # Find the last five messages from the user to purge (we don't choose
      # more because a purge will rarely cover that many lines).
      messages.endAt(viewer).limit(10).once 'value', (snapshot) ->
        snapshot.forEach (message) ->
          # Because of Firebase quirks, if it finds less than 5 results for the
          # viewer, it will find similarly spelled results. Let's not purge the
          # wrong viewer please.
          username = message.child('username').val()
          if username is viewer
            robot.logger.debug "\"#{message.child('message').val()}\" by #{username} has been purged."
            message.ref().child('is_purged').set(true)

  # Override send methods in the Response prototype sp that we can log Hubot's
  # own replies. This is kind of evil, but there doesn't appear to be
  # a better way. From: <https://github.com/jenrzzz/hubot-logger/>
  log_response = (strings...) ->
    for string in strings
      setTimeout ( ->
        pushMessage string, robot.brain.userForName(robot.name), false
      ), 250  # Wait 250ms before sending Elsydeon's message. This is a hack until we figure out why we need this.

  response_orig =
    send: robot.Response.prototype.send
    reply: robot.Response.prototype.reply

  robot.Response.prototype.send = (strings...) ->
    response_orig.send.call @, strings...
    log_response strings...

  robot.Response.prototype.reply = (strings...) ->
    response_orig.reply.call @, strings...
    log_response strings...
