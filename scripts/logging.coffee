# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  robot.respond /users$/i, (msg) ->
    msg.send robot.brain.data.users.toString()

  # Fired when any user enters the room.
  robot.enter (response) ->
    console.log response

  # Fired when any user leaves the room.
  robot.leave (response) ->
    console.log response

  # General message listening.
  robot.hear /(.*)$/i, (msg) ->
    if msg.envelope.user.name isnt 'jtv'
      data = JSON.stringify({
        from: msg.envelope.user.name,
        message: msg.envelope.message.text
      })
      # robot.http("http://api.avalonstar.tv/messages")
      #   .post(data) (err, res, body) ->
      #     if err
      #       console.log "Shit happened."
      #       return
      #     console.log "Response: #{body}"

      console.log msg.envelope
      # console.log "from: " + msg.envelope.user.name
      # console.log "message: " + msg.envelope.message.text

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
      robot.http("http://api.avalonstar.tv/viewers")
        .post(data) (err, res, body) ->
          if err
            console.log "Shit happened."
            return
          console.log "Response: #{body}"

      # console.log "username: " + msg.match[1]
      # console.log "emotes: " + msg.match[2]

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR ([a-zA-Z0-9_]*) (#[A-Z0-9]{6})/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      data = JSON.stringify({
        handle: msg.match[1],
        color: msg.match[2]
      })
      robot.http("http://api.avalonstar.tv/viewers")
        .post(data) (err, res, body) ->
          if err
            console.log "Shit happened."
            return
          console.log "Response: #{body}"

      # console.log "username: " + msg.match[1]
      # console.log "color: " + msg.match[2]
