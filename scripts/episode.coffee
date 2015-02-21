# Description:
#   Functionality related to episode management.

cooldown = require 'on-cooldown'
CronJob = require('cron').CronJob
moment = require 'moment'
path = require 'path'

# API Endpoints.
BROADCAST_API = "http://avalonstar.tv/api/broadcasts/"
TWITCH_STREAM = "https://api.twitch.tv/kraken/streams/brotatoe"
TWITCH_CHANNEL = "https://api.twitch.tv/kraken/channels/avalonstar"

filename = path.basename(module.filename, path.extname(module.filename))

module.exports = (robot) ->
  robot.enter (msg) ->
    # Hit <https://api.twitch.tv/kraken/streams/avalonstar>.
    monitor = new CronJob('00 */2 * * * *', () ->
      robot.http(TWITCH_STREAM)
        .header('Accept', 'application/vnd.twitchtv.v3+json')
        .get() (err, res, body) ->
          robot.logger.error "Whoops, we ran into an error: #{err}" if err?
          # Let's use the stream's title to determine if a stream is "casual"
          # or not. The current way we determine this is as follows:
          #
          #   - A☆###: A numbered episode.
          #   - A☆1XX (or anything else): A casual episode.
          #
          eregex = /^A\u2606\d{3}/
          stream = JSON.parse(body).stream
          robot.logger.debug stream
          robot.logger.debug stream.title
          if stream.title.match eregex
            # We have an episode!
            robot.logger.debug "#{filename}: Checking <streams/avalonstar>: `stream` exists, we're live."
            robot.http(BROADCAST_API).get() (err, res, body) ->
              robot.logger.debug "#{filename}: We're live, let's check our API for the episode number."

              episode = JSON.parse(body)[0]
              robot.brain.set 'currentEpisode', episode.number
              return
          else
            # Looks like it's casusal.
            # TODO: Something with this later.
            robot.brain.remove 'currentEpisode'
            robot.logger.debug 'Whoops, didn\'t work.'
            return
    )
    monitor.start()

  # Return the current episode.
  robot.respond /episode$/i, (msg) ->
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
