# Description:
#   Utilities that kinda sorta make my job easier.

module.exports = (robot) ->
  robot.respond /backfill$/i, (msg) ->
    robot.brain.data.viewers ?= {}
    for user of robot.brain.data.users
      robot.brain.data['viewers'][user] ?= {}
      robot.brain.data['viewers'][user]['name'] = user
    robot.brain.save()

  robot.respond /undo$/i, (msg) ->
    for user of robot.brain.data.users
      delete robot.brain.data['viewers']

  # The below are all administrative commands of some sort.
  robot.respond /reset roles$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      for viewer in robot.brain.data.viewers
        delete viewer['roles']
      msg.send "Viewer roles have been manually reset."
      return
    msg.send "I'm sorry #{msg.envelope.user.name}. You're not Bryan, so you can't run this."
