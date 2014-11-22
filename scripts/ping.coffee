# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot ping - Reply with pong
#   hubot echo <text> - Reply back with <text>
#   hubot time - Reply with current time
#   hubot die - End hubot process

module.exports = (robot) ->
  robot.respond /PING|BEER$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
      msg.send "PONG"

  robot.respond /ADAPTER$/i, (msg) ->
    msg.send robot.adapterName

  robot.respond /ECHO (.*)$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
      msg.send msg.match[1]

  robot.respond /TIME$/i, (msg) ->
    msg.send "Server time is: #{new Date()}"

  robot.respond /DIE$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin'])
      msg.send "Goodbye, cruel world."
      process.exit 0

