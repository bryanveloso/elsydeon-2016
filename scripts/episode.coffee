# Description:
#   Functionality related to episode management.

cooldown = require 'on-cooldown'
CronJob = require('cron').CronJob
moment = require 'moment'
path = require 'path'

# API Endpoints.
BROADCAST_API = "http://avalonstar.tv/api/broadcasts/"
TWITCH_STREAM = "https://api.twitch.tv/kraken/streams/avalonstar"
TWITCH_CHANNEL = "https://api.twitch.tv/kraken/channels/avalonstar"

filename = path.basename(module.filename, path.extname(module.filename))

module.exports = (robot) ->
  robot.enter (msg) ->
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
          if !err and body.hasOwnProperty 'stream'  # https://github.com/justintv/Twitch-API/issues/274
            # If we're live, grab the current episode number from the Avalonstar
            # API. Then set it as the `currentEpisode` key for use later.
            if body.stream?
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
      return

    # You're not me? GTFO. D:
    msg.send "I'm sorry #{msg.envelope.user.name}. Only Bryan can cleanse the stream of casual filth."

  # Uptime!
  robot.respond /uptime$/i, (msg) ->
    robot.http("https://nightdev.com/hosted/uptime.php?channel=avalonstar").get() (err, res, body) ->
      msg.send "Avalonstar has been live for #{body}."

  # Self explanatory, get how long this episode's been live.
  # robot.respond /uptime$/i, (msg) ->
  #   started = robot.brain.get 'startTime'
  #   if started?
  #     since = started.fromNow true
  #     msg.send "Bryan's been streaming for #{since}."
  #     return

  #   # Welp, we need to have started in order to know how long we've been going.
  #   msg.send "I'm sorry #{msg.envelope.user.name}, we need to be live in order to know how long we've been going."
