# Description:
#   Functionality around logging to the Avalonstar(tv) API.

Firebase = require 'firebase'
firebase = new Firebase 'https://avalonstar.firebaseio.com/'

module.exports = (robot) ->
  # Listening for subscription messages.
  # Expected value is...
  robot.hear /(.*)/, (msg) ->
    if msg.envelope.user.name is 'twitchnotify'
      console.log msg
