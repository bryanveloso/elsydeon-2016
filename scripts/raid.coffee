# Description:
#   Functionality around raids.
#
# Commands:
#   hubot raid <username> - Posts raiding instructions for a specific user.
#   hubot raider <username> - Searches Twitch for <username> and returns a follow message plus last game played.

cooldown = require 'on-cooldown'
Firebase = require 'firebase'
firebase = new Firebase 'https://avalonstar.firebaseio.com/'

module.exports = (robot) ->
  robot.respond /raid ([a-zA-Z0-9_]*)( saying)?(.*)/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      query = msg.match[1]
      robot.http("https://api.twitch.tv/kraken/channels/#{query}")
        .get() (err, res, body) ->
          streamer = JSON.parse(body)

          if streamer.status == 404
            msg.send "Hey now, can't raid somebody that doesn't exist. Check your spelling."
            return

          message = "THE CRUSADES OF AVALON <3 (or any emoticon of your choosing)"
          if msg.match[2] and msg.match[3]
            message = msg.match[3]

          instructions = [
            "Alright everybody, hold on to your butts, it's time to raid #{streamer.display_name}! Here are the instructions:",
            "The signal: PREPARE TO BE FACED ON. avalonOOPS/ (don't spoil it)",
            "The target: #{streamer.url} (they're currently playing #{streamer.game})",
            "The battlecry: #{message}"
            ]
          for instruction in instructions
            msg.send instruction

          # Let's record this target.
          json =
            'episode': robot.brain.get('currentEpisode')
            'game': streamer.game
            'timestamp': Firebase.ServerValue.TIMESTAMP
            'username': streamer.name
          targets = firebase.child('targets')
          targets.push json, (error) ->
            console.log "raid: #{error}"

      # Let's get outta here.
      return

    # You are not me, you can't run this. D:
    msg.send "Woah there #{msg.envelope.user.name}. Only Bryan can choose a raid target."

  robot.respond /raider ([a-zA-Z0-9_]*)/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
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

          # Let's record this raid.
          # First, add the raid to our general record.
          json =
            'episode': robot.brain.get('currentEpisode')
            'game': streamer.game
            'timestamp': Firebase.ServerValue.TIMESTAMP
            'username': streamer.name
          raids = firebase.child('raids')
          raids.push json, (error) ->
            console.log "raider: #{error}"

          # Secondly, increment the number of times a user has raided.
          # (This count only counts back to raids since episode 50.)
          raider = firebase.child("viewers/#{streamer.name}/raids")
          raider.transaction (raids) ->
            raids + 1

      # Let's get outta here.
      return

    # Do you have a sword? No? Hah.
    msg.send "Halt #{msg.envelope.user.name}. Only those with a sword may glorify a raider."
