# Description:
#   Utilities that kinda sorta make my job easier.

module.exports = (robot) ->
  robot.respond /backfill$/i, (msg) ->
    pk = 0 # Shell user is first.
    robot.brain.data.viewers ?= {}
    for user of robot.brain.data.users
      robot.brain.data['viewers'][user] ?= {}
      robot.brain.data['viewers'][user]['name'] = user
      robot.brain.data['viewers'][user]['pk'] = pk
      pk++
    robot.brain.save()

  robot.respond /undo$/i, (msg) ->
    for user of robot.brain.data.users
      delete robot.brain.data['viewers']
