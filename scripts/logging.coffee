# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  robot.hear /.*$/i, (msg) ->
    console.log msg.message
    console.log msg.envelope
