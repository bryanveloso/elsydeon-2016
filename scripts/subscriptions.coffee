# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  robot.respond /donate ([a-zA-Z0-9_]*)/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin'])
      username = msg.match[1]
      robot.http("http://avalonstar.tv/api/pusher/donation/")
        .post({'username': username}) (err, res, body) ->
          robot.logger.debug "Donation action run for #{username}." if not err

  robot.respond /resubscribe ([a-zA-Z0-9_]*)/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin'])
      username = msg.match[1]
      robot.http("http://avalonstar.tv/api/pusher/resubscription/")
        .post({'username': username}) (err, res, body) ->
          robot.logger.debug "Resubscribe action run for #{username}." if not err

  robot.respond /subscribe ([a-zA-Z0-9_]*)/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin'])
      username = msg.match[1]
      robot.http("http://avalonstar.tv/api/pusher/subscription/")
        .post({'username': username}) (err, res, body) ->
          robot.logger.debug "Subscribe action run for #{username}." if not err

  robot.respond /substreak ([a-zA-Z0-9_]*) (\d{1,2})/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, ['admin'])
      username = msg.match[1]
      robot.http("http://avalonstar.tv/api/pusher/substreak/")
        .post({'username': username}) (err, res, body) ->
          robot.logger.debug "Substreak action run for #{username}." if not err

  # Let's tell everybody about our emotes.
  robot.respond /emotes$/i, (msg) ->
    msg.send "We've got 10 emotes! avalonFOCUS [FOCUS], avalonAWK [AWK], avalonHAI [HAI], avalonSTAR [STAR], avalonNOPE [NOPE], avalonDESK [DESK], avalonEYES [EYES], avalonHUG [HUG], avalonCRY [CRY], and avalonLOVE [LOVE]. They are all the creations of the amazing LadyAsher, [http://twitter.com/asherartistry]."
