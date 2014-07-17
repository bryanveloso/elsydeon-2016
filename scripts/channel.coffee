# Description:
#   Tell the chatters about the channel!
#
# Commands:
#  hubot schedule - Tell the viewers about your schedule.

module.exports = (robot) ->
  robot.enter (msg) ->
    robot.adapter.command 'twitchclient', '3'
    # TODO: Run .mods and process the results.

  robot.respond /population$/i, (msg) ->
    count = robot.brain.users.length
    msg.send "#{count} people have visited Avalonstar."

  robot.respond /schedule$/i, (msg) ->
    msg.send "6PM-11PM (most Mondays, Wednesdays, Fridays) / 1PM (variable on Weekends). Follow Bryan (https://twitter.com/bryanveloso) for exact times!"
