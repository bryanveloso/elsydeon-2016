import { SapphireClient } from '@sapphire/framework'

export const initialize = async () => {
  const token = process.env.DISCORD_TOKEN as string

  const client = new SapphireClient({ intents: ['GUILDS', 'GUILD_MESSAGES'] })
  client.login(token)
}
