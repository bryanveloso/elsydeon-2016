# Description:
#   Tell the chatters about the channel!
#
# Commands:
#  hubot population - Responds with the total number of unique usernames.
#  hubot schedule - Tell the viewers about your schedule.

module.exports = (robot) ->
  robot.enter (msg) ->
    robot.adapter.command 'twitchclient', '3'
    # TODO: Run .mods and process the results.

  # robot.respond /prefill$/i, (msg) ->
  #   pk = 0 # Shell user is first.
  #   for user of robot.brain.data.users
  #     robot.brain.data['users'][user]['pk'] = pk
  #     pk++

  # robot.respond /undo$/i, (msg) ->
  #   for user of robot.brain.data.users
  #     delete robot.brain.data['users'][user]['pk']

  robot.respond /population$/i, (msg) ->
    count = Object.keys(robot.brain.data.users).length
    msg.send "#{count} people have visited Avalonstar."

  robot.respond /schedule$/i, (msg) ->
    msg.send "Follow Bryan (https://twitter.com/bryanveloso) for exact times!"
