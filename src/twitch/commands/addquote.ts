import { format } from 'date-fns'
import { ChatClient } from '@twurple/chat'

import { addQuote } from '../../shared/quoteHandlers'
import { TwitchCommand } from '../types'

const formatText = (text: string, year: string): string => {
  const suffix = ` , ${year}`
  return text + suffix
}

const handleAddQuote = (
  client: ChatClient,
  { channel, user, text }: { channel: string; user: string; text: string },
  args: string[],
) => {
  const quote = args.join(' ')
  const regex = /"([^"]*?)" ~ (@[A-Za-z0-9_]+)/g
  if (regex.test(quote)) {
    const quotee = quote.split(regex)[2]
    const year = format(new Date(), 'yyyy')
    const text = formatText(quote, year)
    const payload = {
      text,
      year,
      quotee: quotee.replace('@', ''),
      quoter: user,
      timestamp: new Date().toISOString(),
    }

    const success = `I've added the quote to the database. Blame yourself or God. avalonSMUG`
    Promise.all([addQuote(payload), client.say(channel, success)])
  } else {
    const error = `I have bad OCD and can't accept that quote. Please format it like so: "<quote>" ~ @username`
    client.say(channel, error)
  }
}

export default <TwitchCommand>{
  name: 'addquote',
  aliases: ['quoteadd'],
  async execute(client, { channel, user, text }, ...args) {
    handleAddQuote(client, { channel, user, text }, args)
  },
}
