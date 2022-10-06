import { TwitchCommand } from '../types'

export default <TwitchCommand>{
  name: 'slap',
  aliases: [],
  async execute(client, { channel, user, text, msg }, ...args) {
    if (args.length > 1) {
      client.say(channel, `/me slaps ${args.join(' ')} around a bit with a large trout.`)
    } else {
      client.say(channel, `/me slaps ${msg.userInfo.displayName} around a bit with a large trout.`)
    }
  },
}
