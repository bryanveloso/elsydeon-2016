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
    message = "Are you not entertained? If you are, then help us promote the channel:"

    # Get the game I'm currently playing.
    robot.http("https://api.twitch.tv/kraken/channels/avalonstar")
      .get() (err, res, body) ->
        streamer = JSON.parse(body)
        game = if streamer.game then "play #{streamer.game} " else ""
        tweet = "Watching @bryanveloso #{game}on http://avalonstar.tv! Come join me and lurk, chat, or just say hi!"
        tweet = encodeURIComponent(tweet)
        url = "https://twitter.com/intent/tweet?text=#{tweet}&source=clicktotweet"

        # Has this URL been shortened before?
        msg.http("https://api-ssl.bitly.com/v3/link/lookup")
          .query
            access_token: process.env.HUBOT_BITLY_ACCESS_TOKEN
            longUrl: url
            format: "json"
          .get() (err, res, body) ->
            response = JSON.parse body
            if response.data.link_lookup.aggregate_link
              msg.send "#{message} #{response.data.link_lookup.aggregate_link}."
              return

        # After we have our composed URL, send it to bit.ly.
        msg.http("https://api-ssl.bitly.com/v3/shorten")
          .query
            access_token: process.env.HUBOT_BITLY_ACCESS_TOKEN
            longUrl: url
            format: "json"
          .get() (err, res, body) ->
            response = JSON.parse body
            response = if response.status_code is 200 then response.data.url else response.status_txt
            msg.send "#{message} #{response}."

  # Hidden command. gibeOops.
  robot.respond /(DU+)/i, (msg) ->
    msg.send "gibeDu DU DU DU gibeDu"
