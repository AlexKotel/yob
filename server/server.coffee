compression = require('compression')
express = require('express')
config = require('../config')
http = require('http')


app = express()
app.use compression()
app.use '/', express.static("#{config.dist}")


app.get '/test', (req, res) -> res.send("Test")


http
	.Server(app)
	.listen(process.env.PORT or config.port.static)
