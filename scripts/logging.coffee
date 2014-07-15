# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  # General message listening.
  robot.hear /(.*)$/i, (msg) ->
    if msg.envelope.user.name not 'jtv'
      console.log "message: " + msg.envelope.message.text
      console.log "chatter: " + msg.envelope.user.name

  # Listening for special users (e.g., turbo, staff, subscribers)
  # Messages can be prefixed by a username (most likely the bot's name).
  robot.hear /.*?\s?SPECIALUSER (.*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      console.log "username: " + msg.match[1]
      console.log "status: " + msg.match[2]
      console.log "role: " + msg.envelope.user.roles

  # Listening for emoticon sets.
  # Expected value is a list of integers.
  robot.hear /EMOTESET (.*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      console.log "username: " + msg.match[1]
      console.log "emotes: " + msg.match[2]

  # Listening for a user's color.
  # Expected value is a hex code.
  robot.hear /USERCOLOR (.*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      console.log "username: " + msg.match[1]
      console.log "color: " + msg.match[2]
