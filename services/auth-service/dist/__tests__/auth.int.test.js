"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const app_1 = __importDefault(require("../src/app"));
describe('Auth Service Routes (unit/integration)', () => {
    it('GET /health → 200 OK', async () => {
        const res = await app_1.default.fetch(new Request('http://localhost/health'));
        expect(res.status).toBe(200);
        expect(await res.text()).toBe('OK');
    });
});
