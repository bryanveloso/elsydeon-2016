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

  robot.respond /backfill$/i, (msg) ->
    pk = 0 # Shell user is first.
    for user of robot.brain.data.users
      robot.brain.data['viewers'][user]['name'] = user.name
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

  robot.respond /population$/i, (msg) ->
    count = Object.keys(robot.brain.data.users).length
    msg.send "#{count} people have visited Avalonstar."

  robot.respond /schedule$/i, (msg) ->
    msg.send "Follow Bryan (https://twitter.com/bryanveloso) for exact times!"

  # User management commands.
  # Fired when any user enters the room.
  robot.enter (response) ->
    data = robot.brain.data
    user = response.envelope.user.name

    console.log "User entered!"
    unless data['users'][user]['pk']?
     data['users'][user]['pk'] = Object.keys(data.users).length + 1

  # Fired when any user leaves the room.
  robot.leave (response) ->
    console.log "User exited!"
    console.log response.envelope
