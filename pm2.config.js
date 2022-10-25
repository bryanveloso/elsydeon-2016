module.exports = {
  apps: [
    {
      name: 'elsydeon',
      script: './dist/index.js',
      ignore_watch: ['prisma']
    }
  ]
}
