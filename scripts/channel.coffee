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

    # Reset Hubot's autosave interval to 60s instead of 5.
    # This is to prevent unnecessary reloading of old data. :(
    robot.brain.resetSaveInterval 60

  robot.respond /population$/i, (msg) ->
    count = Object.keys(robot.brain.data.users).length
    msg.send "#{count} people have visited Avalonstar."

  robot.respond /schedule$/i, (msg) ->
    msg.send "Follow Bryan (https://twitter.com/bryanveloso) for exact times!"

  # Listen to every message. If we have a new user, add them to the list.
  robot.adapter.bot.addListener 'message', (from, to, message) ->
    if user isnt 'jtv' and robot.brain.data.viewers[from]?
      robot.brain.data.viewers[from] =
        'name': from
        'pk': Object.keys(robot.brain.data.users).length - 1  # Zero indexed.
      robot.brain.data.save()
      msg.send "Greetings #{from} and welcome to Avalonstar!"

  robot.respond /reset roles$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user,'admin')
      for viewer in robot.brain.data.viewers
        delete viewer['roles']
      msg.send "Viewer roles have been manually reset."
      return
    msg.send "I'm sorry #{msg.envelope.user.name}. You're not Bryan, so you can't run this."

  # TODO: Create a command that monitors the API for when the channel goes live.
  # <https://api.twitch.tv/kraken/streams/avalonstar>

  # TODO: Create a command that monitors the API for when the channel signs off.
  # <https://api.twitch.tv/kraken/streams/avalonstar>
