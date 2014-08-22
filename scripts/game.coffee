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
  job = new CronJob('*/5 * * * * *', () ->
    robot.http("https://api.twitch.tv/kraken/channels/avalonstar")
      .get() (err, res, body) ->
        key = 'currentGame'
        streamer = JSON.parse(body)
        robot.brain.set key, streamer.game
        robot.logger.debug "The current game is: #{robot.brain.get key}"

        # Now add the game to Firebase if it doesn't already exist.
        games = firebase.child('games')
        games.child(streamer.game).once 'value', (snapshot) ->
          unless snapshot.val()?
            json =
              'name': streamer.game
            games.child(streamer.game).set json, (error) ->
              console.log "addGame: #{error}"
        return
  )
  job.start()

  robot.respond /defeated ([a-zA-Z_]*)$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      boss = match[1]
      game = robot.brain.get 'currentGame'
      if game?
        # If we have a game, record the boss count.
        count = firebase.child("games/#{game}/boss_count")
        count.transaction (count) ->
          count + 1
          total = count

          # Now that we've incremented the count use that number as the key
          # for the boss that was defeated.
          json = {}
          json[total] = boss
          bosses = firebase.child("games/#{game}/bosses")
          bosses.update json, (error) ->
            msg.send "#{boss} has been defeated! gibeOops//" if error?

      # Let's get outta here.
      return

    # No duplicates pls.
    msg.send "Sorry #{msg.envelope.user.name}. In the interest of preventing duplicates, only a successful Bryan may run this command."

  robot.respond /deathnote$/i, (msg) ->
    game = robot.brain.get 'currentGame'
    bosses = firebase.child("games/#{game}/bosses")
    bosses.once 'value', (snapshot) ->
      list = snapshopt.val().join(', ')
      msg.send "Bryan's beaten the following bosses in #{game} (in order): #{list}"
