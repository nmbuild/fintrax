import http from 'http';
import { Readable } from 'stream';
import app from './app';

const port = Number(process.env.PORT) || 3000;

const server = http.createServer(async (req, res) => {
  try {
    const host = req.headers.host ?? `localhost:${port}`;
    const url = `http://${host}${req.url}`;
    // Convert Node’s IncomingMessage into a Web ReadableStream for fetch()
    const body: BodyInit | undefined = ['GET', 'HEAD'].includes(req.method || '')
      ? undefined
      : (Readable.toWeb(req) as unknown as BodyInit);

    const request = new Request(url, {
      method: req.method,
      headers: req.headers as any,
      body,
    });

    const response = await app.fetch(request);

    res.writeHead(response.status, Object.fromEntries(response.headers));
    const buffer = Buffer.from(await response.arrayBuffer());
    res.end(buffer);

  } catch (err: any) {
    console.error('Server error:', err);
    res.writeHead(500);
    res.end('Internal Server Error');
  }
});

server.listen(port, () => {
  console.log(`🚀 Auth service listening on http://localhost:${port}`);
});

export { server };