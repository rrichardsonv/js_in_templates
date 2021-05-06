export function testy(...args) {
  console.log(`
  -----------------
  ${args.join('\n')}
  -----------------
  `)

  return args.length
}