# Description:
#   Functionality around raids.
#
# Commands:
#   hubot raider <username> - Searches Twitch for <username> and returns a follow message plus last game played.

module.exports = (robot) ->
  robot.respond /(raider)? (.*)/i, (msg) ->
    query = msg.match[2]
    robot.http("https://api.twitch.tv/kraken/channels/#{query}")
      .get() (err, res, body) ->
        streamer = JSON.parse(body)

        if streamer.status == 404
          msg.send "Sorry #{msg.message.user.name}, #{streamer} doesn't seem to exist."
          return

        msg.send "Everybody give #{streamer.display_name} a follow at #{streamer.url}! They're currently playing: #{streamer.game}."
