# Description:
#   Tell the chatters about the channel!
#
# Commands:
#  hubot population - Responds with the total number of unique usernames.
#  hubot gems - Tell people about the lovely team that is the Hidden Gems.
#  hubot schedule - Tell the viewers about your schedule.

CronJob = require('cron').CronJob
moment = require 'moment'

module.exports = (robot) ->
  robot.enter (msg) ->
    # Use TWITCHCLIENT 3 (need to figure out how to read joins/parts).
    robot.adapter.command 'twitchclient', '3'

    # Hit <https://api.twitch.tv/kraken/streams/avalonstar>, looking to see if
    # we're live every five seconds or so.
    monitor = new CronJob('*/5 * * * * *', () ->
      robot.http("https://api.twitch.tv/kraken/channels/avalonstar")
        .get() (err, res, body) ->
          key = 'currentEpisode'
          stream = JSON.parse(body)

          # Are we live?
          # If we're live, grab the current episode number from the Avalonstar
          # API. Then set it as the `currentEpisode` key for use later.
          if stream
            unless key?
              robot.http("http://avalonstar.tv/api/broadcasts/")
                .get() (err, res, body) ->
                  episode = JSON.parse(body)[0]
                  robot.brain.set key, episode.number

                  # For debugging purposes.
                  robot.logger.debug "Episode #{episode.number} is now live."
                  msg.send "Hey everybody! It's time for episode #{episode.number}!"

          # Not live? Never was live in the first place?
          # Before we delete the key to signify us being offline, make sure
          # we post once more in chat reminding people to check out the
          # episode's highlights! Then delete the key.
          else
            number = robot.brain.get key
            if number
              msg.send "Episode #{number} has ended. Hope you enjoyed the cast! Remember to look for the highlights (http://www.twitch.tv/avalonstar/profile)!"
              robot.brain.remove key
    )
    monitor.start()

  # Start the specified broadcast.
  robot.respond /start episode ([0-9]*)$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      key = 'currentEpisode'
      episode = robot.brain.get(key)
      unless episode?
        robot.brain.set(key, msg.match[1])
        msg.send "Got it Bryan. It's episode #{msg.match[1]} time!"
        return

      # If there's an active episode, we shouldn't be setting one on top of it.
      msg.send "Sorry Bryan. Episode #{episode} is the currently active episode. Can't set another one."
      return

    # You're not me? GTFO. D:
    msg.send "I'm sorry #{msg.envelope.user.name}. Only Bryan can specify the current episode."

  # Return the current episode.
  robot.respond /current episode$/i, (msg) ->
    robot.http("http://avalonstar.tv/api/broadcasts/")
      .get() (err, res, body) ->
        broadcast = JSON.parse(body)[0]
        msg.send "Hey #{msg.envelope.user.name}, you're watching Avalonstar ##{broadcast.number}."

  # End a specific broadcast by deleting the key if:
  #   1) The 'currentEpisode' key is not null.
  #   2) The broadcast number entered matches the key's value.
  robot.respond /end episode ([0-9]*)$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      key = 'currentEpisode'
      episode = robot.brain.get(key)
      if episode and episode is msg.match[1]
        robot.brain.remove(key)
        msg.send "Episode #{msg.match[1]} has ended. Hope you enjoyed the cast! Remember to look for the highlights (http://www.twitch.tv/avalonstar/profile)!"
        return

      # Can't end a broadcast if we've never set one. o_o;
      msg.send "Sorry Bryan. You can't end a broadcast that's never started. Silly."
      return

    # Stop trying to be me, seriously. D:
    msg.send "I'm sorry #{msg.envelope.user.name}. Only Bryan can end the current episode."

  # The below are all flat commands (simply text, etc).
  robot.respond /blind$/i, (msg) ->
    msg.send "This is a blind run! No tips, tricks, or spoilers unless Bryan explicitly asks. Everybody gets one warning and each subsequent violation will earn yourself a purge."

  robot.respond /gems$/i, (msg) ->
    since = moment([2014, 7, 13, 21]).fromNow()
    msg.send "Follow Bryan's amazing teammates on the Hidden Gems (http://twitch.tv/team/gems). Bryan was inducted into the Hidden Gems #{since}."

  robot.respond /visitors$/i, (msg) ->
    count = Object.keys(robot.brain.data.users).length
    msg.send "#{count} people have visited Avalonstar."

  # The below are all administrative commands of some sort.
  # Listen to joins. If we have a new user, add them to the list.
  if robot.adapter.bot?
    robot.adapter.bot.addListener 'join', (channel, who) ->
      if who isnt 'jtv' and not robot.brain.data.viewers[who]
        robot.brain.data.viewers[who] =
          'name': who
        robot.brain.save()

        # For debugging purposes.
        robot.logger.debug "We have new blood: #{who}."

  robot.respond /reset roles$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      for viewer in robot.brain.data.viewers
        delete viewer['roles']
      msg.send "Viewer roles have been manually reset."
      return
    msg.send "I'm sorry #{msg.envelope.user.name}. You're not Bryan, so you can't run this."
