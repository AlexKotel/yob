favicon = require 'serve-favicon'
express = require 'express'
config = require '../config'

app = express()

app.use favicon("#{config.dist}/favicon.ico")

# SPA
app.use('/js', express.static("#{config.dist}/js"))
app.use('/css', express.static("#{config.dist}/css"))
app.use('/copy', express.static("#{config.dist}/copy"))
app.use('/views', express.static("#{config.dist}/views"))
app.use('/assets', express.static("#{config.dist}/assets"))
app.all '/*', (req, res) ->
	res.sendfile "#{config.dist}/index.html"


# NOT SPA
# app.use express.static(config.dist)

app.listen config.port.static
