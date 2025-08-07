"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.server = void 0;
const http_1 = __importDefault(require("http"));
const stream_1 = require("stream");
const app_1 = __importDefault(require("./app"));
require("dotenv/config");
const port = Number(process.env.PORT) || 3000;
const server = http_1.default.createServer(async (req, res) => {
    try {
        const host = req.headers.host ?? `localhost:${port}`;
        const url = `http://${host}${req.url}`;
        const body = ['GET', 'HEAD'].includes(req.method || '')
            ? undefined
            : stream_1.Readable.toWeb(req);
        const request = new Request(url, {
            method: req.method,
            headers: req.headers,
            body,
        });
        const response = await app_1.default.fetch(request);
        res.writeHead(response.status, Object.fromEntries(response.headers));
        const buffer = Buffer.from(await response.arrayBuffer());
        res.end(buffer);
    }
    catch (err) {
        console.error('Server error:', err);
        res.writeHead(500);
        res.end('Internal Server Error');
    }
});
exports.server = server;
server.listen(port, () => {
    console.log(`🚀 Auth service listening on http://localhost:${port}`);
});
