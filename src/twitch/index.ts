import 'dotenv/config'
import { promises as fs, readFileSync } from 'fs'
import { RefreshingAuthProvider } from '@twurple/auth'
import { ChatClient } from '@twurple/chat'

export const initialize = async () => {
  const clientId = process.env.TWITCH_CLIENT_ID as string
  const clientSecret = process.env.TWITCH_CLIENT_SECRET as string
  const tokenData = JSON.parse(readFileSync('./tokens.json', 'utf-8'))

  const authProvider = new RefreshingAuthProvider(
    {
      clientId,
      clientSecret,
      onRefresh: async (newTokenData) =>
        await fs.writeFile('./tokens.json', JSON.stringify(newTokenData, null, 4), 'utf-8'),
    },
    tokenData,
  )

  const client = new ChatClient({ authProvider, channels: ['avalonstar'] })
  await client.connect()

  client.onMessage((channel, user, text) => {
    if (text === '!ping') {
      client.say(channel, 'Sup.')
    }
  })
}
