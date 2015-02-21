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

  # Let's tell everybody about our emotes.
  robot.respond /emotes$/i, (msg) ->
    msg.send "We've got 8 emotes! avalonOOPS (OOPS), avalonFOCUS (FOCUS), avalonAWK (AWK), avalonHAI (HAI), avalonSTAR (STAR), avalonNOPE (NOPE), avalonDESK (DESK), and avalonPLS (PLS). They are all the creations of the amazing LadyAsher, http://twitter.com/asherartistry."
