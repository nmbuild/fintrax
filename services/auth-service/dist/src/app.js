"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const hono_1 = require("hono");
const clerk_sdk_node_1 = __importDefault(require("@clerk/clerk-sdk-node"));
const zod_1 = require("zod");
const app = new hono_1.Hono();
app.get('/health', (c) => c.text('OK'));
app.get('/profile', async (c) => {
    return c.json({ error: 'Auth not implemented' }, 501);
});
const inviteSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    role: zod_1.z.enum(['user', 'admin']),
});
app.post('/invite', async (c) => {
    const { email, role } = inviteSchema.parse(await c.req.json());
    await clerk_sdk_node_1.default.users.createUser({
        emailAddress: [email],
        publicMetadata: { role },
    });
    return c.json({ invited: email });
});
exports.default = app;
