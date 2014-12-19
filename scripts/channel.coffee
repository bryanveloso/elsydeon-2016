# Description:
#   Tell the chatters about the channel!
#
# Commands:
#  hubot population - Responds with the total number of unique usernames.
#  hubot gems - Tell people about the lovely team that is the Hidden Gems.
#  hubot schedule - Tell the viewers about your schedule.

CronJob = require('cron').CronJob
moment = require 'moment'
path = require('path')

# API Endpoints.
BROADCAST_API = "http://avalonstar.tv/api/broadcasts/"
TWITCH_STREAM = "https://api.twitch.tv/kraken/streams/avalonstar"
TWITCH_CHANNEL = "https://api.twitch.tv/kraken/channels/avalonstar"

filename = path.basename(module.filename, path.extname(module.filename))

module.exports = (robot) ->
  robot.enter (msg) ->
    # Use TWITCHCLIENT 3.
    robot.adapter.command 'twitchclient', '3'

    # Hit <https://api.twitch.tv/kraken/streams/avalonstar>, looking to see if
    # we're live every five seconds or so.
    monitor = new CronJob('*/30 * * * * *', () ->
      casual = robot.brain.get 'casualEpisode'
      number = robot.brain.get 'currentEpisode'
      # Casual streams don't have an episode number, so there should be no need
      # to go through the normal monitoring process to set things.
      robot.logger.debug "#{filename}: The stream has been marked as casual. Internal monitoring functions deactivated." if casual?
      unless casual?
        robot.http(TWITCH_STREAM).get() (err, res, body) ->
          robot.logger.error "Whoops, we ran into an error: #{err}" if err?
          console.log '------>' + body + '<-----'
          response = JSON.parse body

          if !err and response.hasOwnProperty 'stream'  # https://github.com/justintv/Twitch-API/issues/274
            # If we're live, grab the current episode number from the Avalonstar
            # API. Then set it as the `currentEpisode` key for use later.
            if response.stream?
              robot.logger.debug "#{filename}: Checking <streams/avalonstar>: `stream` exists, we're live."
              unless number?
                robot.http(BROADCAST_API).get() (err, res, body) ->
                  robot.logger.debug "#{filename}: We're live, let's check our API for the episode number."

                  episode = JSON.parse(body)[0]
                  robot.brain.set 'currentEpisode', episode.number
    )
    monitor.start()

  # Start the current episode.
  robot.respond /start$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin'])
      number = robot.brain.get 'currentEpisode'
      now = moment()

      if number?
        robot.brain.set 'startTime', now
        robot.logger.info "#{filename}: Episode #{number} started at #{now.format()}."
        return msg.send "Hey everybody! It's time for episode #{number}!"
      else
        return msg.send "Can't start an episode without being live, Bryan."

  # End the current episode.
  robot.respond /end$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin'])
      number = robot.brain.get 'currentEpisode'
      now = moment()

      if number?
        robot.brain.remove 'startTime'
        robot.brain.remove 'currentEpisode' # a.k.a. "number"
        robot.logger.info "#{filename}: Episode #{number} ended at #{now.format()}."
        return msg.send "Episode #{number} has ended. Hope you enjoyed the cast! Remember to look for the highlights (http://www.twitch.tv/avalonstar/profile)!"
      else
        return msg.send "Can't end an episode that hasn't started, Bryan."

  # Return the current episode.
  robot.respond /episode$/i, (msg) ->
    casual = robot.brain.get 'casualEpisode'
    episode = robot.brain.get 'currentEpisode'
    username = msg.envelope.user.name
    if casual?
      msg.send "Hey #{username}, this is a casual episode of Avalonstar. No number!"
      return
    else if episode?
      msg.send "Hey #{username}, you're watching Avalonstar ##{episode}."
      return
    else
      msg.send "Hey #{username}, Avalonstar isn't currently... live... why don't you check out the lovely highlights?"

  # Mark the stream as a filthy casual.
  robot.respond /casual start$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      key = 'casualEpisode'
      casual = robot.brain.get key
      unless casual?
        robot.brain.set key, true
        msg.send "Got it Bryan. The stream has been marked as casual."
        return

      # If the stream is marked as casual, you can't do it again.
      msg.send "Sorry Bryan. The stream has already been marked as casual. You filthy casual."
      return

    # You're not me? GTFO. D:
    msg.send "I'm sorry #{msg.envelope.user.name}. Only Bryan can mark the stream as casual."

  # Remove the casual mark. Clean yourself of the filth.
  robot.respond /casual end$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      key = 'casualEpisode'
      casual = robot.brain.get key
      if casual?
        robot.brain.remove key
        msg.send "This episode is no longer marked as casual. You should give it an episode number, Bryan."
        return

      # Can't set a broadcast as casual if we never set it. o_o;
      msg.send "Sorry Bryan. You can't end a casual broadcast if you never set it. Silly."

    # You're not me? GTFO. D:
    msg.send "I'm sorry #{msg.envelope.user.name}. Only Bryan can cleanse the stream of casual filth."

  # Self explanatory, get how long this episode's been live.
  robot.respond /uptime$/i, (msg) ->
    started = robot.brain.get 'startTime'
    if started?
      since = started.fromNow true
      msg.send "Bryan's been streaming for #{since}."
      return

    # Welp, we need to have started in order to know how long we've been going.
    msg.send "I'm sorry #{msg.envelope.user.name}, we need to be live in order to know how long we've been going."

  # The below are all flat commands (simply text, etc).
  robot.respond /blind$/i, (msg) ->
    msg.send "This is a blind run! No tips, tricks, or spoilers unless Bryan explicitly asks. Everybody gets one warning and each subsequent violation will earn yourself a purge."

  robot.respond /gems$/i, (msg) ->
    since = moment([2014, 7, 13, 21]).fromNow()
    msg.send "Follow Bryan's amazing teammates on the Hidden Gems (http://twitch.tv/team/gems). Bryan was inducted into the Hidden Gems #{since}."

  robot.respond /(bot|code|oss)$/i, (msg) ->
    msg.send "Interested in the code that powers this channel? You can find it all on GitHub! Overlays: http://github.com/bryanveloso/avalonstar-tv • Bot: http://github.com/bryanveloso/elsydeon • Chat: http://github.com/bryanveloso/avalonstar-live"
    msg.send "All code is provided for eductional purposes only and all designs are -owned- by Bryan. If you steal them and we're coming after you."

  robot.respond /visitors$/i, (msg) ->
    count = Object.keys(robot.brain.data.users).length
    msg.send "#{count} people have visited Avalonstar."

  # The below are all administrative commands of some sort.
  robot.respond /reset roles$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      for viewer in robot.brain.data.viewers
        delete viewer['roles']
      msg.send "Viewer roles have been manually reset."
      return
    msg.send "I'm sorry #{msg.envelope.user.name}. You're not Bryan, so you can't run this."
