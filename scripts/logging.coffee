# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  # Fired when any user enters the room.
  robot.enter (response) ->
    console.log "user entered... "
    console.log response.envelope

  # Fired when any user leaves the room.
  robot.leave (response) ->
    console.log "user exited... "
    console.log response.envelope

  # General message listening.
  robot.hear /(.*)$/i, (msg) ->
    if msg.envelope.user.name isnt 'jtv'
      user = msg.envelope.user.name
      userdata = robot.brain.data['users'][user]

      # Send that data off to the API.
      data = JSON.stringify({
        from: userdata['pk'],
        message: msg.envelope.message.text
      })
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
