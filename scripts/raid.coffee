# Description:
#   Functionality around raids.
#
# Commands:
#   hubot raid <username> - Posts raiding instructions for a specific user.
#   hubot raider <username> - Searches Twitch for <username> and returns a follow message plus last game played.

module.exports = (robot) ->
  robot.respond /raid (.*)/i, (msg) ->
    query = msg.match[1]
    robot.http("https://api.twitch.tv/kraken/channels/#{query}")
      .get() (err, res, body) ->
        streamer = JSON.parse(body)

        if streamer.status == 404
          msg.send "Hey now, can't raid somebody that doesn't exist. Check your spelling."
          return

        instructions = [
          "Alright everybody, hold on to your butts, it's time to raid #{streamer.display_name}! Here are the instructions:",
          "1. The signal: gibeOops/ (don't spoil it)",
          "2. The target: #{streamer.url} (they're currently playing #{streamer.game})",
          "3. The battlecry: THE RAIDS OF AVALON <3 (or any emoticon of your choosing)"
          ]
        for instruction in instructions
          msg.send instruction

  robot.respond /raider (.*)/i, (msg) ->
    query = msg.match[1]
    robot.http("https://api.twitch.tv/kraken/channels/#{query}")
      .get() (err, res, body) ->
        streamer = JSON.parse(body)

        if streamer.status == 404
          msg.send "Sorry #{msg.message.user.name}, #{query} doesn't seem to exist. Check your spelling."
          return

        message = "We've been raided by #{streamer.display_name}! Give them a follow at #{streamer.url}!"
        if streamer.game
          message = "#{message} They've been playing: #{streamer.game}."
        msg.send message
