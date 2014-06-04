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

  robot.respond /facebook$/i, (msg) ->
    msg.send "https://facebook.com/bryanveloso"

  robot.respond /tweet$/i, (msg) ->
    # Get the game I'm currently playing.
    robot.http("https://api.twitch.tv/kraken/channels/avalonstar")
      .get() (err, res, body) ->
        streamer = JSON.parse(body)
        message = "Watching @bryanveloso play #{streamer.game} on http://avalonstar.tv! Come lurk, chat, or just say hi!"
        message = encodeURIComponent(message)
        url = "https://twitter.com/intent/tweet?text=#{message}&source=clicktotweet"

        # After we have our composed URL, send it to bit.ly.
        msg
          .http("https://api-ssl.bitly.com/v3/shorten")
          .query
            access_token: process.env.HUBOT_BITLY_ACCESS_TOKEN
            longUrl: url
            format: "json"
          .get() (err, res, body) ->
            reponse = JSON.parse body
            msg.send if response.status_code is 200 then response.data.url else response.status_txt
