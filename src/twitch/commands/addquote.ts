import { format } from 'date-fns'
import { ChatClient } from '@twurple/chat'

import { addQuote } from '../../shared/quoteHandlers'
import { TwitchCommand } from '../types'

const handleAddQuote = (
  client: ChatClient,
  { channel, user, text }: { channel: string; user: string; text: string },
  ...args: string[][]
) => {
  const quote = args[0].join(' ')
  const regex = /"([^"]*?)" ~ (@[A-Za-z0-9_]+)/g

  if (regex.test(quote)) {
    const quotee = quote.split(regex)[2]
    const year = format(new Date(), 'yyyy')
    const text = quote.split(regex)[1]
    const timestamp = format(new Date(), 't')
    const payload = {
      text: text.trimEnd(),
      year,
      quotee: quotee.replace('@', ''),
      quoter: user,
      timestamp
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
  }
}
