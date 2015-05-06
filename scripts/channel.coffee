# Description:
#   Tell the chatters about the channel!
#
# Commands:
#  hubot population - Responds with the total number of unique usernames.
#  hubot gems - Tell people about the lovely team that is the Hidden Gems.
#  hubot schedule - Tell the viewers about your schedule.

moment = require 'moment'

module.exports = (robot) ->
  # Glorify a caster.
  robot.respond /caster ([a-zA-Z0-9_]*)/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
      query = msg.match[1]
      robot.http("https://api.twitch.tv/kraken/channels/#{query}")
        .header('Accept', 'application/vnd.twitchtv.v3+json')
        .get() (err, res, body) ->
          streamer = JSON.parse(body)

          if streamer.status == 404
            msg.send "Sorry #{msg.message.user.name}, #{query} doesn't seem to exist. Check your spelling."
            return

          message = "Since #{streamer.display_name} is pretty cool, you should give them a follow at #{streamer.url}!"
          if streamer.game
            message = "#{message} They've been playing: #{streamer.game}."
          msg.send message

      # Let's get outta here.
      return

    # Do you have a sword? No? Hah.
    msg.send "Halt #{msg.envelope.user.name}. Only those with a sword may glorify a caster."

  # Uptime!
  robot.respond /uptime$/i, (msg) ->
    robot.http("https://nightdev.com/hosted/uptime.php?channel=avalonstar").get() (err, res, body) ->
      msg.send "Avalonstar has been live for #{body}."

  # The teams I'm on and stuff like that.
  robot.respond /teams$/i, (msg) ->
    msg.send "Bryan is a proud member of 2 teams on Twitch: Main Menu [http://twitch.tv/team/mainmenu/], and of course Twitch Staff [http://twitch.tv/team/staff]."

  robot.respond /(mm|mainmenu)$/i, (msg) ->
    since = moment([2015, 0, 9, 9]).fromNow()
    msg.send "Quality content on Twitch you say? Look no further than Main Menu [http://twitch.tv/team/mainmenu/]. Bryan was recruited #{since}."

  robot.respond /(hg|gems)$/i, (msg) ->
    since = moment([2014, 7, 13, 21]).fromNow()
    msg.send "Bryan is a proud graduate of the Hidden Gems, and graduated on January 26th! Want to see the best of what's next? Then you should follow the Hidden Gems [http://twitch.tv/team/gems]."

  # Special responses for cast-related elements.
  robot.respond /birds$/i, (msg) ->
    msg.send "Bloodborne and Birds, Chapter 1 [http://www.twitch.tv/avalonstar/v/3942012] and Chapter 2 [http://www.twitch.tv/avalonstar/v/3951530]."

  # Special responses for events, etc.
  robot.respond /ddr$/i, (msg) ->
    msg.send "Welcome to DDR night! A couple of notes: 1) Bryan doesn't use the mic while dancing, he doesn't want to pant on it. 2) Bryan will address chat after a couple of songs. 3) He has the right to refuse requests. Please don't be salty about it."

  robot.respond /(oh|office|officehours)$/i, (msg) ->
    msg.send "Welcome to Office Hours, a humble attempt at a interview/discussion show. Have questions for Bryan or our guest? Tweet it using the hashtag #ASOH."

  robot.respond /fistbump/i, (msg) ->
    msg.send "Badaladala."

  # The below are all flat commands (simply text, etc).
  robot.respond /(blind|bsg)$/i, (msg) ->
    msg.send "This is a blind run! No tips, tricks, or spoilers unless Bryan explicitly asks. Everybody gets one warning and each subsequent violation will earn yourself a purge."

  robot.respond /(bot|code|oss)$/i, (msg) ->
    msg.send "Interested in the code that powers this channel? You can find it all on GitHub! Overlays: http://github.com/bryanveloso/avalonstar-tv • Bots: http://github.com/bryanveloso/elsydeon and http://github.com/bryanveloso/baymax • Chat: http://github.com/bryanveloso/avalonstar-tv-chat"
    msg.send "All code is provided for eductional purposes only and all designs are -owned- by Bryan. If you steal them and we're coming after you."

  # robot.respond /shirt$/i, (msg) ->
  #   msg.send "We've released our first shirt, \"Avalonstar, A History\", a celebration of what makes Avalonstar, Avalonstar: [http://teespring.com/avalonstar]."
