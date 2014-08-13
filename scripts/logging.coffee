# Description:
#   Functionality around logging to the Avalonstar(tv) API.

Firebase = require 'firebase'
firebase = new Firebase 'https://avalonstar.firebaseio.com/'

module.exports = (robot) ->
  # Utility methods.
  handleUser = (username) ->
    # Check if we have a user on Firebase. If not, create it.
    viewers = firebase.child('viewers')
    viewers.child(username).once 'value', (snapshot) ->
      unless snapshot.val()?
        json =
          'username': username
        viewers.child(username).set json
        robot.logger.debug "We have new blood: #{username}."
      else
        # Add the current episode number (if available) to the user's list
        # of viewed broadcasts.
        episode = robot.brain.get('currentEpisode')
        if episode?
          json = {}
          json[episode] = true
          viewers.child(username).child('episodes').set json

  pushMessage = (message, ircdata, twitchdata, is_emote) ->
    ircroles = ircdata.roles or []
    twitchroles = twitchdata.roles or []
    emotes = twitchdata.emotes or []

    json =
      'color': twitchdata.color
      'emotes': emotes
      'episode': robot.brain.get('currentEpisode')
      'is_emote': is_emote
      'message': message
      'roles': twitchroles.concat ircroles
      'timestamp': Firebase.ServerValue.TIMESTAMP
      'username': ircdata.name

    # Firebase. Testing this out.
    messages = firebase.child('messages')
    messages.push json

  if robot.adapter.bot?
    # If the user emotes, set json.emote to true.
    robot.adapter.bot.addListener 'action', (from, to, message) ->
      unless from is 'jtv'
        # Send the dictionary to Firebase.
        pushMessage message, robot.brain.userForName(from), robot.brain.data.viewers[from], true
        handleUser from

    # Listen for general messages.
    robot.adapter.bot.addListener 'message', (from, to, message) ->
      unless from is 'jtv'
        # Send the dictionary to Firebase.
        pushMessage message, robot.brain.userForName(from), robot.brain.data.viewers[from], false
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

      # For debugging purposes.
      robot.logger.debug msg.match[1] + " is a " + msg.match[2] + " user."

  # Listening for emoticon sets.
  # Expected value is a list of integers.
  robot.hear /EMOTESET ([a-zA-Z0-9_]*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]

      # Store EMOTESET as an actual list?
      emotes = msg.match[2].substring(1).slice(0, -1).split(',')
      robot.brain.data['viewers'][viewer.name]['emotes'] = emotes
      robot.brain.save()

      # For debugging purposes.
      robot.logger.debug msg.match[1] + " has these emotes: " + emotes

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR ([a-zA-Z0-9_]*) (#[A-Z0-9]{6})/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]
      robot.brain.data['viewers'][viewer.name]['color'] = msg.match[2]
      robot.brain.save()

      # For debugging purposes.
      robot.logger.debug msg.match[1] + " has uses this color: " + msg.match[2]

  # Override send methods in the Response prototype sp that we can log Hubot's
  # own replies. This is kind of evil, but there doesn't appear to be
  # a better way. From: <https://github.com/jenrzzz/hubot-logger/>
  log_response = (strings...) ->
    for string in strings
        pushMessage string, robot.brain.userForName(robot.name), robot.brain.data.viewers[robot.name], false

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
