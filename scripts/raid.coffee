# Description:
#   Functionality around raids.
#
# Commands:
#   hubot raider <username> - Searches Twitch for <username> and returns a follow message plus last game played.

module.exports = (robot) ->
  robot.respond /(raider) (.*)/i, (msg) ->
    query = msg.match[2]
    robot.http("https://api.twitch.tv/kraken/channels/#{query}")
      .get() (err, res, body) ->
        streamer = JSON.parse(body)

        if streamer.status == 404
          msg.send "Sorry #{msg.message.user.name}, #{streamer} doesn't seem to exist."
          return

        message = "We've been raided by #{streamer.display_name}! Give them a follow at #{streamer.url}!"
        if streamer.game
          message = "#{message} They've been playing: #{streamer.game}."
        msg.send message
