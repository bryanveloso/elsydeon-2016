# Description:
#   Manage aspects of the channel, like users.
#
# Commands:
#  hubot <> -

module.exports = (robot) ->
  robot.respond /remove user (\w+)$/i, (msg) ->
    console.log msg
    username = msg.match[1]
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      delete robot.brain.data['users'][username]
      msg.send "I took care of #{username} for you, #{msg.user.name}."
