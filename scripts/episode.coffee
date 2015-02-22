# Description:
#   Functionality related to episode management.

CronJob = require('cron').CronJob

path = require 'path'
filename = path.basename(module.filename, path.extname(module.filename))

module.exports = (robot) ->
  robot.enter (msg) ->
    # Hit <http://avalonstar.tv/live/status/>.
    monitor = new CronJob('00 */2 * * * *', () ->
      robot.http('http://avalonstar.tv/live/status/').get() (err, res, body) ->
        status = JSON.parse(body)
        robot.brain.set 'live', status.is_live
        if status.is_episodic
          robot.brain.set 'episode', status.number
          robot.logger.debug "#{filename}: #{status.number} saved to `currentEpisode`."
          return
        else
          if robot.brain.get 'episode'
            robot.brain.remove 'episode'
            robot.logger.debug "#{filename}: `currentEpisode` value removed."
          return
    )
    monitor.start()

  # Return the current episode.
  robot.respond /episode$/i, (msg) ->
    is_live = robot.brain.get 'live'
    episode = robot.brain.get 'episode'

    if live and episode?
      msg.send "You're watching Avalonstar ##{episode}."
      return
    else if live and !episode?
      msg.send "This is a casual episode of Avalonstar. No number!"
      return
    else
      msg.send "Avalonstar isn't currently... live... why don't you check out the lovely highlights?"

  # Uptime!
  robot.respond /uptime$/i, (msg) ->
    robot.http("https://nightdev.com/hosted/uptime.php?channel=avalonstar").get() (err, res, body) ->
      msg.send "Avalonstar has been live for #{body}."
