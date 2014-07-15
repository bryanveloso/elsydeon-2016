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


# Robot should hear EMOTESET.
# Robot should hear regular messages.
# Robot should hear USERCOLOR.
# ROBOT should hear SPECIALUSER.
