# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  # .*?\s?SPECIALUSER (.*)\s(.*)
  robot.hear /(.*)$/i, (msg) ->
    console.log msg.match
    console.log msg.envelope



# Robot should hear EMOTESET.
# Robot should hear regular messages.
# Robot should hear USERCOLOR.
# ROBOT should hear SPECIALUSER.

  # robot.hear /(DU+)/i, (msg) ->
  #   msg.send "gibeDu DU DU DU gibeDu"
