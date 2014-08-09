# Description:
#   Functionality around logging to the Avalonstar(tv) API.

Firebase = require 'firebase'
Pusher = require 'pusher'

firebase = new Firebase 'https://avalonstar.firebaseio.com/'
pusher = new Pusher
  appId: process.env['PUSHER_APP_ID']
  key: process.env['PUSHER_API_KEY']
  secret: process.env['PUSHER_SECRET']

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
        episode = robot.brain.get('currentEpisode')
        if episode?
          viewers.child(username).child('broadcasts').push robot.brain.get('currentEpisode')

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
      'timestamp': new Date()
      'username': ircdata.name

    # Firebase. Testing this out.
    messages = firebase.child('messages')
    messages.push json

    # Pusher.
    pusher.trigger 'chat', 'message', json, null, (error, request, response) ->
      if error
        robot.logger.debug "Pusher ran into an error: #{error}"

  if robot.adapter.bot?
    # If the user emotes, set json.emote to true.
    robot.adapter.bot.addListener 'action', (from, to, message) ->
      unless from is 'jtv'
        # Send the dictionary to Pusher.
        pushMessage message, robot.brain.userForName(from), robot.brain.data.viewers[from], true
        handleUser from

    # Listen for general messages.
    robot.adapter.bot.addListener 'message', (from, to, message) ->
      unless from is 'jtv'
        # Send the dictionary to Pusher.
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
      setTimeout ( ->
        pushMessage string, robot.brain.userForName(robot.name), robot.brain.data.viewers[robot.name], false
        handleUser robot.brain.userForName(robot.name)
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
