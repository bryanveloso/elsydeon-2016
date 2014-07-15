# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  robot.hear /(.*)$/i, (msg) ->
    # console.log msg.match
    # console.log msg.envelope

  robot.hear /.*?\s?SPECIALUSER (.*) (.*)/, (msg) ->
    if msg.envelope.user.name is 'jtv'
      console.log msg.match
      console.log "YOU ARE TEH SPECHIAL."

  robot.hear /EMOTESET (.*) (.*)/, (msg) ->
    console.log msg.match
    console.log "WE'VE GOT DEM EMOTES."

  robot.hear /USERCOLOR (.*) (.*)/, (msg) ->
    console.log msg.match
    console.log "I'VE GOT YO COLOR."

# [x] Robot should hear EMOTESET.
# Robot should hear regular messages.
# [x] Robot should hear USERCOLOR.
# [x] ROBOT should hear SPECIALUSER.
