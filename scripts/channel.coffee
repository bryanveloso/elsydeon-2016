# Description:
#   Tell the chatters about the channel!
#
# Commands:
#  hubot population - Responds with the total number of unique usernames.
#  hubot gems - Tell people about the lovely team that is the Hidden Gems.
#  hubot schedule - Tell the viewers about your schedule.

moment = require 'moment'

module.exports = (robot) ->
  robot.enter (msg) ->
    # Use TWITCHCLIENT 3.
    robot.adapter.command 'twitchclient', '3'

  # The below are all flat commands (simply text, etc).
  robot.respond /blind$/i, (msg) ->
    msg.send "This is a blind run! No tips, tricks, or spoilers unless Bryan explicitly asks. Everybody gets one warning and each subsequent violation will earn yourself a purge."

  robot.respond /teams$/i, (msg) ->
    msg.send "Bryan is a proud member of 4 teams on Twitch: Main Menu (http://twitch.tv/team/mainmenu/), ComboNATION (http://twitch.tv/team/combonation), the Hidden Gems (http://twitch.tv/team/gems), and of course Twitch Staff (http://twitch.tv/team/staff)."

  robot.respond /mainmenu$/i, (msg) ->
    since = moment([2015, 0, 9, 9]).fromNow()
    msg.send "Quality content on Twitch you say? Look no further than Main Menu (http://twitch.tv/team/mainmenu/). Bryan was recruited #{since}."

  robot.respond /gems$/i, (msg) ->
    since = moment([2014, 7, 13, 21]).fromNow()
    msg.send "Follow Bryan's amazing teammates on the Hidden Gems (http://twitch.tv/team/gems). Bryan was inducted into the Hidden Gems #{since}."

  robot.respond /cn$/i, (msg) ->
    since = moment([2014, 11, 10, 21]).fromNow()
    msg.send "Bryan's been a part of #ComboNATION (http://twitch.tv/team/combonation) since #{since}."

  robot.respond /(bot|code|oss)$/i, (msg) ->
    msg.send "Interested in the code that powers this channel? You can find it all on GitHub! Overlays: http://github.com/bryanveloso/avalonstar-tv • Bot: http://github.com/bryanveloso/elsydeon • Chat: http://github.com/bryanveloso/avalonstar-live"
    msg.send "All code is provided for eductional purposes only and all designs are -owned- by Bryan. If you steal them and we're coming after you."

  robot.respond /visitors$/i, (msg) ->
    count = Object.keys(robot.brain.data.users).length
    msg.send "#{count} people have visited Avalonstar."

  # The below are all administrative commands of some sort.
  robot.respond /reset roles$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'admin')
      for viewer in robot.brain.data.viewers
        delete viewer['roles']
      msg.send "Viewer roles have been manually reset."
      return
    msg.send "I'm sorry #{msg.envelope.user.name}. You're not Bryan, so you can't run this."
