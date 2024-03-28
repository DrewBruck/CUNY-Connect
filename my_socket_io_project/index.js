const http = require('http');
const socketIo = require('socket.io');

const server = http.createServer((req, res) => {
	res.end('Hello Stanely! I\'m from Socket.IO server!');
});

const io = socketIo(server);

io.on('connection', (socket) =>{
	console.log('USER: Connected');

	socket.emit('Welcome', 'THis is a test');

	socket.on('msg', (message) => {
		console.log('Client Message:', message);
		io.emit('broadcast', message);	
	});

	socket.on('disconnect', () =>{
		console.log('USER: disconnected');
	});
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
	console.log('PORT: 3000');
});
