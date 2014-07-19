# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  # General message listening.
  robot.hear /(.*)$/i, (msg) ->
    if msg.envelope.user.name isnt 'jtv'
      userdata = robot.brain.userForName(msg.envelope.user.name)
      pk = userdata['pk']
      console.log "This user's pk is: #{pk}"

      # Check if a user exists.
      # robot.http('http://api.avalonstar.tv/v1/viewers/#{pk}')
      #   .get() (err, res, body) ->
      #     console.log res.statusCode
      #     # Did we not get a 200? Time to create the user.
      #     data = JSON.stringify({ id: pk, username: userdata['name'] })
      #     robot.http('http://api.avalonstar.tv/v1/viewers')
      #       .post(data) (err, res, body) ->
      #         if err
      #           console.log "Shit happened."
      #           return
      #         console.log "Response: #{body}"

      # Send that data off to the API.
      # data = JSON.stringify({
      #   from: userdata['pk'],
      #   message: msg.envelope.message.text
      # })
      # robot.http("http://api.avalonstar.tv/messages")
      #   .post(data) (err, res, body) ->
      #     if err
      #       console.log "Shit happened."
      #       return
      #     console.log "Response: #{body}"

      console.log "from: " + msg.envelope.user.name
      console.log "message: " + msg.envelope.message.text

  # Listening for special users (e.g., turbo, staff, subscribers)
  # Messages can be prefixed by a username (most likely the bot's name).
  # Note: Roles such as moderator do not appear in this method.
  robot.hear /.*?\s?SPECIALUSER ([a-zA-Z0-9_]*) ([a-z]*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      data = JSON.stringify({
        handle: msg.match[1],
        isStaff: if msg.match[2] is 'staff' then true else false,
        isTurbo: if msg.match[2] is 'turbo' then true else false,
      })
      # robot.http("http://api.avalonstar.tv/viewers")
      #   .post(data) (err, res, body) ->
      #     if err
      #       console.log "Shit happened."
      #       return
      #     console.log "Response: #{body}"

      console.log "username: " + msg.match[1]
      console.log "status: " + msg.match[2]

  # Listening for emoticon sets.
  # Expected value is a list of integers.
  robot.hear /EMOTESET ([a-zA-Z0-9_]*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      data = JSON.stringify({
        handle: msg.match[1],
        emotes: msg.match[2]
      })
      # robot.http("http://api.avalonstar.tv/viewers")
      #   .post(data) (err, res, body) ->
      #     if err
      #       console.log "Shit happened."
      #       return
      #     console.log "Response: #{body}"

      console.log "username: " + msg.match[1]
      console.log "emotes: " + msg.match[2]

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR ([a-zA-Z0-9_]*) (#[A-Z0-9]{6})/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      data = JSON.stringify({
        handle: msg.match[1],
        color: msg.match[2]
      })
      # robot.http("http://api.avalonstar.tv/viewers")
      #   .post(data) (err, res, body) ->
      #     if err
      #       console.log "Shit happened."
      #       return
      #     console.log "Response: #{body}"

      console.log "username: " + msg.match[1]
      console.log "color: " + msg.match[2]
