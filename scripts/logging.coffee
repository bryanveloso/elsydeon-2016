# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  robot.hear /.*$/i, (msg) ->
    console.log msg.match
    console.log msg.envelope
