# Description:
#   Utilities that kinda sorta make my job easier.

module.exports = (robot) ->
  robot.respond /reset$/i, (msg) ->
    robot.brain.data.viewers ?= {}
    robot.brain.save()

  robot.respond /apifill$/i, (msg) ->
    # Grab the username and password for the API from environment variables.
    # Combine both so they can be included in a authorization header.
    api_user = process.env.API_USERNAME
    api_pass = process.env.API_PASSWORD
    api_auth = 'Basic ' + new Buffer(api_user + ':' + api_pass).toString('base64')

    for user of robot.brain.data.users
      userdata = robot.brain.data['viewers'][user]
      data = JSON.stringify({ id: userdata['pk'], username: userdata['name'] })
      robot.http('http://api.avalonstar.tv/v1/viewers')
        .headers(Authorization: api_auth, Accept: 'application/json')
        .post(data) (err, res, body) ->
          console.log "Response: #{body}"
          msg.send "Added " + userdata['name'] + " ."

  robot.respond /undo$/i, (msg) ->
    for user of robot.brain.data.users
      delete robot.brain.data['viewers']
