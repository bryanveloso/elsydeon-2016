# Description:
#   Functionality around logging to the Avalonstar(tv) API.

Pusher = require 'pusher'

pusher = new Pusher
  appId: process.env['PUSHER_APP_ID']
  key: process.env['PUSHER_API_KEY']
  secret: process.env['PUSHER_SECRET']

pushMessage = (message, viewer, userdata, is_emote) ->
  json =
    'emote': is_emote
    'message': message
    'roles': roles = if viewer.roles? then userdata.roles.concat viewer.roles else userdata.roles
    'timestamp': new Date()
    'username': viewer.name

  pusher.trigger 'chat', 'message', json, null, (error, request, response) ->
    if error
      robot.logger.debug "Pusher ran into an error: #{error}"

module.exports = (robot) ->
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
    log_response strings...

  robot.Response.prototype.reply = (strings...) ->
    response_orig.reply.call @, strings...
    log_response strings...

  # If the user emotes, set json.emote to true.
  robot.adapter.bot.addListener 'action', (from, to, message) ->
    unless from is 'jtv'
      viewer = robot.brain.userForName from
      userdata = robot.brain.data.viewers[from]

      # Send the dictionary to Pusher.
      pushMessage message, viewer, userdata, true

  # Listen for general messages.
  robot.adapter.bot.addListener 'message', (from, to, message) ->
    unless from is 'jtv'
      viewer = robot.brain.userForName from
      userdata = robot.brain.data.viewers[from]

      # Send the dictionary to Pusher.
      pushMessage message, viewer, userdata, false

      # Check if a user exists.
      # robot.http('http://api.avalonstar.tv/v1/viewers/#{pk}')
      #   .get() (err, res, body) ->
      #     console.log res.statusCode
      #     # Did we not get a 200? Time to create the user.
      #     data = JSON.stringify({ id: pk, username: userdata['name'] })
      #     robot.http('http://api.avalonstar.tv/v1/viewers')
      #       .post(data) (err, res, body) ->
      #         console.log "Response: #{body}"

      # Send that data off to the API.
      # data = JSON.stringify({
      #   from: userdata['pk'],
      #   message: msg.envelope.message.text
      # })
      # robot.http("http://api.avalonstar.tv/messages")
      #   .post(data) (err, res, body) ->
      #     console.log "Response: #{body}"

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
      robot.brain.data['viewers'][viewer.name]['emotes'] = msg.match[2]
      robot.brain.save()

      # For debugging purposes.
      robot.logger.debug msg.match[1] + " has these emotes: " + msg.match[2]

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR ([a-zA-Z0-9_]*) (#[A-Z0-9]{6})/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]
      robot.brain.data['viewers'][viewer.name]['color'] = msg.match[2]
      robot.brain.save()

      # For debugging purposes.
      robot.logger.debug msg.match[1] + " has uses this color: " + msg.match[2]
