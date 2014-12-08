# Description:
#   Functionality around specific games.
#
# Commands:
#   hubot defeated <boss> - Records the name of a boss defeated.
#   hubot deathnote - Show all the bosses defeated for the current game.

CronJob = require('cron').CronJob
Firebase = require 'firebase'
firebase = new Firebase 'https://avalonstar.firebaseio.com/'

module.exports = (robot) ->
  # Run a cron job every five seconds to get the game currently being played.
  # This will be stored in a variable for use in the different commands.
  job = new CronJob('*/10 * * * * *', () ->
    robot.http("https://api.twitch.tv/kraken/channels/avalonstar")
      .get() (err, res, body) ->
        key = 'currentGame'
        streamer = JSON.parse(body)
        robot.brain.set key, streamer.game
        unless streamer.game is robot.brain.get key
          robot.logger.debug "The current game is: #{robot.brain.get key}"
        return
  )
  # job.start()

  robot.respond /game$/i, (msg) ->
    msg.send "Bryan's currently playing #{robot.brain.get 'currentGame'}."

  robot.respond /defeated ([a-zA-Z_ ]*)$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      boss = msg.match[1]
      game = robot.brain.get 'currentGame'
      if game?
        # If we have a game, grab the boss count.
        count = firebase.child("games/#{game}/boss_count")
        total = count + 1

        # Now that we've incremented the count use that number as the key
        # for the boss that was defeated.
        json = {}
        json[total] = boss
        bosses = firebase.child("games/#{game}/bosses")
        bosses.update json, (error) ->
          console.log "defeated: #{error}"
        count.set total, (error) ->
          console.log "bossCount: #{error}"
        msg.send "#{boss} has been defeated! gibeOops//"

      # Let's get outta here.
      return

    # No duplicates pls.
    msg.send "Sorry #{msg.envelope.user.name}. In the interest of preventing duplicates, only a successful Bryan may run this command."

  robot.respond /deathnote$/i, (msg) ->
    game = robot.brain.get 'currentGame'
    bosses = firebase.child("games/#{game}/bosses")
    bosses.once 'value', (snapshot) ->
      if snapshot.val()
        list = snapshot.val().join(', ')
        msg.send "Bryan's beaten the following bosses in #{game} (in order): #{list}"
      else
        msg.send "Sorry #{msg.envelope.user.name}, there isn't a recorded boss list for #{game}."
