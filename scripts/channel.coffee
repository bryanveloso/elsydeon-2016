# Description:
#   Tell the chatters about the channel!
#
# Commands:
#  hubot schedule - Tell the viewers about your schedule.

module.exports = (robot) ->
  robot.respond /schedule$/i, (msg) ->
    msg.send "Schedule: 6PM-11PM (most Mondays, Wednesdays, Fridays) / 1PM (variable on Weekends). Follow Bryan (https://twitter.com/bryanveloso) for exact times!"
