# Description:
#   Social commands surrounding social things.
#
# Commands:
#   hubot twitter - Reply with twitter link
#   hubot facebook - Reply with facebook link
#   hubot tweet - Reply with click-to-tweet link

module.exports = (robot) ->
  robot.respond /twitter$/i, (msg) ->
    msg.send "https://twitter.com/bryanveloso"

module.exports = (robot) ->
  robot.respond /twitter$/i, (msg) ->
    msg.send "https://facebook.com/bryanveloso"
