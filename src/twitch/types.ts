import { ChatClient } from '@twurple/chat/lib'
import { TwitchPrivateMessage } from '@twurple/chat/lib/commands/TwitchPrivateMessage'

export interface TwitchCommand {
  name: string
  aliases: Array<string>
  execute(
    client: ChatClient,
    {
      channel,
      user,
      text,
      msg,
    }: { channel: string; user: string; text: string; msg: TwitchPrivateMessage },
    ...args: string[]
  ): void
}
