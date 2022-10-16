import 'dotenv/config'
import Enmap from 'enmap'
import { promises as fs, readFileSync, readdirSync } from 'fs'
import { RefreshingAuthProvider } from '@twurple/auth'
import { ApiClient } from '@twurple/api'
import { ChatClient } from '@twurple/chat'

import { TwitchCommand } from './types'

export const initialize = async () => {
  const clientId = process.env.TWITCH_CLIENT_ID as string
  const clientSecret = process.env.TWITCH_CLIENT_SECRET as string
  const tokenData = JSON.parse(readFileSync('./tokens.json', 'utf-8'))

  const authProvider = new RefreshingAuthProvider(
    {
      clientId,
      clientSecret,
      onRefresh: async newTokenData =>
        await fs.writeFile(
          './tokens.json',
          JSON.stringify(newTokenData, null, 4),
          'utf-8'
        )
    },
    tokenData
  )

  const apiClient = new ApiClient({ authProvider })
  const client = new ChatClient({ authProvider, channels: ['avalonstar'] })
  await client.connect()

  const prefix = '!'
  const commands = new Enmap()
  const commandFiles = readdirSync(`${__dirname}/commands`).filter(
    file => file.endsWith('.ts') || file.endsWith('.js')
  )
  commandFiles.map(file => {
    const command: TwitchCommand = require(`./commands/${file}`).default
    commands.set(command.name, command)
  })

  client.onMessage((channel, user, text, msg) => {
    if (!text.startsWith(prefix)) return

    text = text.substring(prefix.length)
    user = msg.userInfo.displayName
    const [name, ...args] = text.split(' ')

    const command =
      commands.get(name) ||
      commands.find(cmd => cmd.aliases && cmd.aliases.includes(name))
    console.log(command)

    if (!command) return

    try {
      command.execute(client, { channel, user, text, msg }, args)
    } catch (error) {
      console.error(error)
    }
  })
}
