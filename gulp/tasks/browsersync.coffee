config = require('../../config')
paths = require('../paths')
browsersync = require('browser-sync')


module.exports = (cb) ->

	files = [
		"#{paths.pages.dest}/*.html"
		"#{paths.views.dest}/**/*.html"
		"#{paths.scriptsApp.dest}/**/*.js"
		"#{paths.stylesApp.dest}/**/*.css"
		"#{paths.img.dest}/**/*.{png,jpg,jpeg,gif,svg}"
		"#{paths.font.dest}/**/*.{woff,ttf,eot,svg}"
	]

	config =
		proxy: "localhost:#{config.port.static}"
		ports:
			min: config.port.browserSync
			max: config.port.browserSync
		browser: [
			# 'opera'
			# 'safari'
			# 'firefox'
			# 'google chrome'
		]
		ghostMode:
			forms: true
			clicks: true
			scroll: true
			location: true

	browsersync.init(files, config)
	cb()
