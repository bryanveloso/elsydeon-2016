# Description:
#   Manage aspects of the channel, like users.
#
# Commands:
#  hubot enable autosave - Enables the brain's auto-save mechanism.
#  hubot disable autosave - Disabled the brain's auto-save mechanism.

module.exports = (robot) ->
    # Enables the brain's auto-save mechanism.
    robot.respond /enable autosave$/i, (msg) ->
      if robot.auth.hasRole(msg.envelope.user, 'admin')
        robot.brain.setAutoSave = true
        robot.logger.debug "Enabled the brain's auto-save mechanism."

    # Disables the brain's auto-save mechanism.
    robot.respond /disable autosave$/i, (msg) ->
      user = msg.envelope.user
      if robot.auth.hasRole(user, 'admin')
        robot.brain.setAutoSave = false
        robot.logger.debug "Disabled the brain's auto-save mechanism."
