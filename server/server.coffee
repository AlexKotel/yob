CONFIG = require '../config'
express = require 'express'

app = express()

app.get '/test', (req, res) ->
	res.send('Hello')

app.use express.static CONFIG.dist

module.exports =

	start: (cb) ->
		app.listen CONFIG.port.static, ->
			cb?.call()
