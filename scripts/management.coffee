# Description:
#   Manage aspects of the channel, like users.
#
# Commands:
#  hubot <> -

module.exports = (robot) ->
  robot.respond /remove user (.*)$/i, (msg) ->
    username = msg.match[1]
    console.log 'before', robot.brain.data['users'][username]
    delete robot.brain.data['users'][username]
    console.log 'after', robot.brain.data['users'][username]
    msg.send "I took care of #{username} for you, #{msg.user.name}."
