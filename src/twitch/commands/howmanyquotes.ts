import { getQuoteListSize } from '../../shared/quoteHandlers'
import { TwitchCommand } from '../types'

export default <TwitchCommand>{
  name: 'howmanyquotes',
  aliases: ['howmany', 'quotecount'],
  async execute(client, { channel, user, text, msg }) {
    const count = await getQuoteListSize()
    client.say(channel, `@${user}, I see ${count} quotes in the database.`)
  },
}
