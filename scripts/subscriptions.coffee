# Description:
#   Functionality around logging to the Avalonstar(tv) API.

module.exports = (robot) ->
  # Let's tell everybody about our emotes.
  robot.respond /emotes$/i, (msg) ->
    msg.send "We've got 10 emotes! avalonOOPS [OOPS], avalonFOCUS [FOCUS], avalonAWK [AWK], avalonHAI [HAI], avalonSTAR [STAR], avalonNOPE [NOPE], avalonDESK [DESK], avalonPLS [PLS], avalonWOAH [WOAH], and avalonHUG [HUG]. They are all the creations of the amazing LadyAsher, http://twitter.com/asherartistry."
