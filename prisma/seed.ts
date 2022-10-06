import { PrismaClient } from '@prisma/client'

import json from './data.json'

const prisma = new PrismaClient()

async function main() {
  json.map(async (quote) => {
    const q = await prisma.quote.create({
      data: {
        timestamp: quote.timestamp,
        text: quote.text,
        quotee: quote.quotee,
        quoter: quote.quoter,
        year: quote.year,
      },
    })

    console.log({ q })
  })
}

main()
  .then(async () => {
    await prisma.$disconnect()
  })
  .catch(async (e) => {
    console.error(e)
    await prisma.$disconnect()
    process.exit(1)
  })
