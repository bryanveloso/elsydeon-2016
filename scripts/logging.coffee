# Description:
#   Functionality around logging to the Avalonstar(tv) API.

Pusher = require "pusher"

pusher = new Pusher
  appId: process.env['PUSHER_APP_ID']
  key: process.env['PUSHER_API_KEY']
  secret: process.env['PUSHER_SECRET']

module.exports = (robot) ->
  # General message listening.
  robot.hear /(.*)$/i, (msg) ->
    if msg.envelope.user.name isnt 'jtv'
      viewer = robot.brain.userForName msg.envelope.user.name
      userdata = robot.brain.data.viewers[viewer.name]

      # Compose a dictionary to send to Pusher.
      json =
        'message': msg.envelope.message.text
        'roles': roles = if viewer.roles? then userdata.roles.concat viewer.roles else userdata.roles
        'timestamp': new Date()
        'username': msg.envelope.user.name

      # If the user emotes, set json.emote to true.
      robot.adapter.bot.addListener 'action', (from, to, message) ->
        console.log "This is an emote!"
        json.emote = true
        console.log json

      # Send the dictionary to Pusher.
      pusher.trigger 'chat', 'message', json, null, (error, request, response) ->
        if error
          console.log "Pusher ran into an error: #{error}"

      # For debugging purposes.
      console.log msg.envelope.user.name + " (" + userdata.pk + "): " + msg.envelope.message.text

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
      console.log msg.match[1] + " is a " + msg.match[2] + " user."

  # Listening for emoticon sets.
  # Expected value is a list of integers.
  robot.hear /EMOTESET ([a-zA-Z0-9_]*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]
      robot.brain.data['viewers'][viewer.name]['emotes'] = msg.match[2]
      robot.brain.save()

      # For debugging purposes.
      console.log msg.match[1] + " has these emotes: " + msg.match[2]

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR ([a-zA-Z0-9_]*) (#[A-Z0-9]{6})/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]
      robot.brain.data['viewers'][viewer.name]['color'] = msg.match[2]
      robot.brain.save()

      # For debugging purposes.
      console.log msg.match[1] + " has uses this color: " + msg.match[2]
