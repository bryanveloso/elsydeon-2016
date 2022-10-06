import { PrismaClient } from '@prisma/client'

import * as twitch from './twitch'

const prisma = new PrismaClient()

;(async () => {
  try {
    await twitch.initialize()
    await prisma.$disconnect()
  } catch (error) {
    console.error(error)
    await prisma.$disconnect()
    process.exit(1)
  }
})()
