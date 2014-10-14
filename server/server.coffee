express = require('express')
socket = require('socket.io')
http = require('http')


config = require('../config')



app = express()
server = http.Server(app)
io = socket(server)


app.set 'port', process.env.PORT or config.port.static
app.use '/', express.static("#{config.dist}")

server.listen app.get('port'), ->
	console.log "Server started at port: #{app.get('port')}"
