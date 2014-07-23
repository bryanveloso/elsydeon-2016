# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  # General message listening.
  robot.hear /(.*)$/i, (msg) ->
    if msg.envelope.user.name isnt 'jtv'
      viewer = robot.brain.userForName msg.envelope.user.name
      userdata = robot.brain.data['viewers'][viewer.name]
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
      userdata['roles'] = [] if userdata['roles']?
      userdata['roles'].push msg.match[2]

      console.log msg.match[1] + " is a " + msg.match[2]

  # Listening for emoticon sets.
  # Expected value is a list of integers.
  robot.hear /EMOTESET ([a-zA-Z0-9_]*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]
      robot.brain.data['viewers'][viewer.name]['emotes'] = msg.match[2]

      console.log msg.match[1] + " has these emotes: " + msg.match[2]

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR ([a-zA-Z0-9_]*) (#[A-Z0-9]{6})/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      viewer = robot.brain.userForName msg.match[1]
      robot.brain.data['viewers'][viewer.name]['color'] = msg.match[2]

      console.log msg.match[1] + " has uses this color: " + msg.match[2]
