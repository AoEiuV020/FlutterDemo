"use strict";

globalThis.require = require;
globalThis.fs = require("fs");
globalThis.path = require("path");
globalThis.TextEncoder = require("util").TextEncoder;
globalThis.TextDecoder = require("util").TextDecoder;

globalThis.performance ??= require("performance");

globalThis.crypto ??= require("crypto");

require("../prebuild/Web/wasm_exec");

const go = new Go();
go.argv = process.argv.slice(2);
go.env = Object.assign({ TMPDIR: require("os").tmpdir() }, process.env);
go.exit = process.exit;
WebAssembly.instantiate(fs.readFileSync('../prebuild/Web/libnative_add.wasm'), go.importObject).then((result) => {
	process.on("exit", (code) => { // Node.js exits if no event handler is pending
		console.log("exit", code);
		if (code === 0 && !go.exited) {
			// deadlock, make Go print error and stack traces
			go._pendingEvent = { id: 0 };
			go._resume();
		}
	});
	return go.run(result.instance);
}).catch((err) => {
	console.error(err);
	process.exit(1);
});
// 创建HTTP服务器防止进程退出
const http = require('http');
const server = http.createServer((req, res) => {
	console.log('Received request for ' + req.url);
	const url = require('url');
	const uri = url.parse(req.url, true)
	const query = uri.query;
	if (uri.pathname === '/sum') {
        // curl 'localhost:8080/sum?a=3&b=4'
		const a = parseInt(query.a) || 0;
		const b = parseInt(query.b) || 0;
		const result = globalThis.sum(a, b);
		res.writeHead(200, {'Content-Type': 'text/plain'});
		res.end(result.toString());
	} else {
		res.writeHead(200, {'Content-Type': 'text/plain'});
		res.end('Server running to keep Node.js alive\n');
	}
});
server.listen(8080, () => {
	console.log('HTTP server running on port 8080');
});
