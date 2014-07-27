CONFIG = require '../config'
express = require 'express'

app = express()

app.get '/test', (req, res) ->
	res.send('Hello')

app.use express.static CONFIG.dist
app.listen CONFIG.port.static
