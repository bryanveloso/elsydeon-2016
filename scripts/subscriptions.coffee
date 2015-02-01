# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  # Listening for incoming subscription notifications. :O
  robot.hear /^([a-zA-Z0-9_]*) just subscribed!$/, (msg) ->
    if msg.envelope.user.name is 'twitchnotify'
      # Take the name and push it on through.
      username = msg.match[1]
      robot.logger.debug "#{username} has just subscribed!"

  # Listening for incoming re-subscription notifications.
  robot.hear /^([a-zA-Z0-9_]*) just subscribed! (\d{1,2}) months in a row!$/, (msg) ->
    if msg.envelope.user.name is 'twitchnotify'
      # Take the name and push it on through.
      username = msg.match[1]
      robot.logger.debug "#{username} has just subscribed!"
