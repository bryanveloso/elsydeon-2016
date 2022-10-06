import { TwitchCommand } from '../types'

export default <TwitchCommand>{
  name: 'ping',
  aliases: [],
  async execute(client, { channel, user, text }) {
    client.say(channel, 'Sup.')
  },
}
