import { PrismaClient, Quote } from '@prisma/client'

const prisma = new PrismaClient()

export const addQuote = async (payload: Omit<Quote, 'id'>) => {
  return await prisma.quote.create({ data: payload })
}

export const getLatestQuote = async () => {
  return await prisma.quote.findFirst({ orderBy: { timestamp: 'desc' } })
}

export const getQuoteById = async () => {}

export const getQuoteByTerm = async (term: string) => {}

export const getRandomQuote = async () => {
  const response = await prisma.$queryRaw<Quote[]>`SELECT * FROM quote ORDER BY RANDOM() LIMIT 1`
  console.log(response)
  return response
}

export const getQuoteListSize = async () => {
  return await prisma.quote.count()
}
