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
    episode = robot.brain.get('currentEpisode')
    if episode?
      json = {}
      json[episode] = true
      viewers.child(username).child('episodes').set json, (error) ->
        console.log "hanldeUser: #{error}" if !error?
      return

  pushMessage = (message, ircdata, is_emote) ->
    viewers = firebase.child('viewers')
    viewers.child(ircdata.name).once 'value', (snapshot) ->
      twitchdata = snapshot.val() or []
      ircroles = ircdata.roles or []
      twitchroles = twitchdata?.roles or []
      emotes = twitchdata?.emotes or []

      json =
        'color': twitchdata?.color or '#ffffff'
        'emotes': emotes
        'episode': robot.brain.get('currentEpisode')
        'is_emote': is_emote
        'message': message
        'roles': twitchroles.concat ircroles
        'timestamp': Firebase.ServerValue.TIMESTAMP
        'username': ircdata.name

      # Firebase. Testing this out.
      messages = firebase.child('messages')
      messages.push json, (error) ->
        console.log "pushMessage: #{error}"
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
      viewer = robot.brain.userForName msg.match[1]
      userdata = robot.brain.data['viewers'][viewer.name]
      userdata['roles'] ?= []

      if msg.match[2] not in userdata['roles']
        userdata['roles'].push msg.match[2]
      robot.brain.save()

      # Save user list to Firebase.
      viewers = firebase.child('viewers')
      viewers.child(viewer.name).child('roles').set msg.match[2], (error) ->
        console.log "handleRoles: #{error}" if !error?

      # For debugging purposes.
      robot.logger.debug msg.match[1] + " is a " + msg.match[2] + " user."

  # Listening for emoticon sets.
  # Expected value is a list of integers.
  robot.hear /EMOTESET ([a-zA-Z0-9_]*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]
      emotes = msg.match[2].substring(1).slice(0, -1).split(',')  # Store EMOTESET as an actual list?

      # Save emote list to Firebase.
      viewers = firebase.child('viewers')
      viewers.child(viewer.name).child('emotes').set emotes, (error) ->
        console.log "handleEmotes: #{error}" if !error?

      # Try saving the emote list to the robot's brain.
      robot.brain.data['viewers'][viewer.name]['emotes'] = emotes
      robot.brain.save()

      # For debugging purposes.
      robot.logger.debug msg.match[1] + " has these emotes: " + emotes

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR ([a-zA-Z0-9_]*) (#[A-Z0-9]{6})/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]
      color = msg.match[2]

      # Save user list to Firebase.
      viewers = firebase.child('viewers')
      viewers.child(viewer.name).child('color').set color, (error) ->
        console.log "handleColor: #{error}" if !error?

      robot.brain.data['viewers'][viewer.name]['color'] = color
      robot.brain.save()

      # For debugging purposes.
      robot.logger.debug msg.match[1] + " has uses this color: " + msg.match[2]

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
    robot.logger.debug strings...
    log_response strings...

  robot.Response.prototype.reply = (strings...) ->
    response_orig.reply.call @, strings...
    robot.logger.debug strings...
    log_response strings...
