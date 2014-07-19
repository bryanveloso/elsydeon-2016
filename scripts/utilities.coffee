module.exports = (robot) ->
  robot.respond /backfill$/i, (msg) ->
    pk = 0 # Shell user is first.
    robot.brain.data.viewers = {} unless robot.brain.data.viewers?
    for user of robot.brain.data.users
      robot.brain.data['viewers'][user] = {} unless robot.brain.data.viewers.user?
      robot.brain.data['viewers'][user]['name'] = user
      robot.brain.data['viewers'][user]['pk'] = pk
      pk++
    robot.brain.save()

  robot.respond /apifill$/i, (msg) ->
    for user of robot.brain.data.users
      userdata = robot.brain.data['users'][user]
      data = JSON.stringify({
        id: userdata['pk'],
        username: userdata['name']
      })
      robot.http('http://api.avalonstar.tv/v1/viewers')
        .post(data) (err, res, body) ->
          if err
            console.log "Shit happened."
            return
          console.log "Response: #{body}"
      msg.send "Added " + userdata['name'] + " ."

  robot.respond /undo$/i, (msg) ->
    for user of robot.brain.data.users
      delete robot.brain.data['users'][user]['pk']
