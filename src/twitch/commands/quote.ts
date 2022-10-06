import { ChatClient } from '@twurple/chat/lib'
import { TwitchPrivateMessage } from '@twurple/chat/lib/commands/TwitchPrivateMessage'

import { getRandomQuote } from '../../shared/quoteHandlers'
import { TwitchCommand } from '../types'

const handleGetQuote = async (
  client: ChatClient,
  { channel, user }: { channel: string; user: string },
  args: string[],
) => {
  let message: string

  if (args.length > 1) {
    const error = `Woah there ${user}. One word at a time. avalonBAKA`
    return client.say(channel, error)
  }

  const [quote] = await getRandomQuote()
  message = `I found this quote: “${quote?.text}” ~ @${quote?.quotee}`

  return client.say(channel, message)
}

export default <TwitchCommand>{
  name: 'quote',
  aliases: [],
  async execute(client, { channel, user, text, msg }, ...args) {
    await handleGetQuote(client, { channel, user }, args)
  },
}
