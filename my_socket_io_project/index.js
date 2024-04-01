const fs = require('fs')
const https = require('https');
const socketIo = require('socket.io');

const certOptions = {
        key: fs.readFileSync('/etc/letsencrypt/live/********/privkey.pem'),
        cert: fs.readFileSync('/etc/letsencrypt/live//********/fullchain.pem')
};

const server = https.createServer(certOptions, (req, res) => {
        res.writeHead(200);
        res.end('Security is NumBer OnE! I\'m from Socket.IO server!');
});

const io = socketIo(server, {
        cors: {
                origin: "https://cuny-connect.web.app/",
                methods: ["GET", "POST"],
                credentials: true
        }
});

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
