import { PrismaClient } from '@prisma/client'

import * as discord from './discord'
import * as twitch from './twitch'

const prisma = new PrismaClient()

;(async () => {
  try {
    // await discord.initialize()
    await twitch.initialize()
    await prisma.$disconnect()
  } catch (error) {
    console.error(error)
    await prisma.$disconnect()
    process.exit(1)
  }
})()
