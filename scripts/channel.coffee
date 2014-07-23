# Description:
#   Tell the chatters about the channel!
#
# Commands:
#  hubot population - Responds with the total number of unique usernames.
#  hubot schedule - Tell the viewers about your schedule.

module.exports = (robot) ->
  robot.enter (msg) ->
    # TODO: Run .mods and process the results.
    # Use TWITCHCLIENT 3 (need to figure out how to read joins/parts).
    robot.adapter.command 'twitchclient', '3'

    # Reset Hubot's autosave interval to 30s instead of 5.
    # This is to prevent unnecessary reloading of old data. :(
    robot.brain.resetSaveInterval 30

  robot.respond /population$/i, (msg) ->
    count = Object.keys(robot.brain.data.users).length
    msg.send "#{count} people have visited Avalonstar."

  robot.respond /schedule$/i, (msg) ->
    msg.send "Follow Bryan (https://twitter.com/bryanveloso) for exact times!"

  # TODO: Create a command that monitors the API for when the channel goes live.
  # <https://api.twitch.tv/kraken/streams/avalonstar>

  # TODO: Create a command that monitors the API for when the channel signs off.
  # <https://api.twitch.tv/kraken/streams/avalonstar>
