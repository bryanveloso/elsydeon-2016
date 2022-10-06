import { getLatestQuote } from '../../shared/quoteHandlers'
import { TwitchCommand } from '../types'

export default <TwitchCommand>{
  name: 'latestquote',
  aliases: ['lastquote'],
  async execute(client, { channel, user, text }) {
    const quote = await getLatestQuote()
    client.say(channel, `I found this quote: “${quote?.text}” ~ ${quote?.quotee}, ${quote?.year}`)
  },
}
