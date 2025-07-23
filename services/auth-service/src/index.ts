import { Hono } from 'hono';
import clerkClient from '@clerk/clerk-sdk-node';
import { z } from 'zod';

const app = new Hono();

// Health check
app.get('/health', c => c.text('OK'));

// Protected profile
// TODO: Implement Clerk authentication middleware for Hono
app.get('/profile', async c => {
  // Example: Extract userId from a verified JWT or Clerk session
  // const userId = ...;
  // if (!userId) return c.json({ error: 'No userId found' }, 401);
  // const user = await clerkClient.users.getUser(userId);
  // return c.json({
  //   id: user.id,
  //   email: user.emailAddresses[0]?.emailAddress || null
  // });
  return c.json({ error: 'Auth not implemented' }, 501);
});

// Invite endpoint
const inviteSchema = z.object({
  email: z.string().email(),
  role: z.enum(['user', 'admin'])
});
// TODO: Implement Clerk authentication middleware for Hono
app.post('/invite', async c => {
  const data = inviteSchema.parse(await c.req.json());
  // TODO: enforce 'admin' role from your own DB
  await clerkClient.users.createUser({
    emailAddress: [data.email],
    publicMetadata: { role: data.role }
  });
  return c.json({ invited: data.email });
});

app.fire();
