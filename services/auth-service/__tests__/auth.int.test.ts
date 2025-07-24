
import app from '../src/app';

describe('Auth Service Routes (unit/integration)', () => {
  it('GET /health → 200 OK', async () => {
    const res = await app.fetch(new Request('http://localhost/health'));
    expect(res.status).toBe(200);
    expect(await res.text()).toBe('OK');
  });

});