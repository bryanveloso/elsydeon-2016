import { TwitchCommand } from '../types'

const shitposts = [
  `Before I visited Avalonstar, my village did not know of the wonders of hammers. We often used sticks, bricks, or cousin William's thick forehead to drive nails. Avalonstar came through with lightning-fast delivery of hammers to me and to all of my friends and loved ones. Thank you Avalonstar.`,
  `too late, already agreed upon, law allows this, lawyer agrees. judge had ruled in our favour. case closed. sealing case away in a box and burying it in the deepest cave. cutesader forever avalonAYAYA`,
]

export default <TwitchCommand>{
  name: 'shitpost',
  aliases: [],
  async execute(client, { channel }, ...args) {
    const shitpost = shitposts[Math.floor(Math.random() * shitposts.length)]
    return client.say(channel, shitpost)
  },
}
