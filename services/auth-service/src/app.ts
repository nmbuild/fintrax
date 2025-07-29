import { Hono } from 'hono'
import clerkClient from '@clerk/clerk-sdk-node'
import { z } from 'zod'

const app = new Hono()

app.get('/health', (c) => c.text('OK'))

app.get('/profile', async (c) => {
  return c.json({ error: 'Auth not implemented' }, 501)
})

const inviteSchema = z.object({
  email: z.string().email(),
  role: z.enum(['user', 'admin']),
})

app.post('/invite', async (c) => {
  const { email, role } = inviteSchema.parse(await c.req.json())
  await clerkClient.users.createUser({
    emailAddress: [email],
    publicMetadata: { role },
  })
  return c.json({ invited: email })
})

export default app
