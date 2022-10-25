import axios from 'axios'

import { TwitchCommand } from '../types'

interface MarkovResponse {
  response: string
}

const endpoint = process.env.ELSYDEON_PYTHON_URL as string

const getMarkov = async (): Promise<MarkovResponse> => {
  return await (
    await axios.get(`${endpoint}/markov`)
  ).data
}

export default <TwitchCommand>{
  name: 'markov',
  aliases: ['wtf'],
  async execute(client, { channel, user, text }) {
    const markov = await getMarkov()
    client.say(
      channel,
      `Whipped this up from some old quotes: avalonEUREKA "${markov.response}"`
    )
  }
}
