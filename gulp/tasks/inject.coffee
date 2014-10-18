paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')
streamqueue = require('streamqueue')


$ =
	if: require('gulp-if')
	inject: require('gulp-inject')
	concat: require('gulp-concat')


tasks =
	scriptsDep: require('./scripts-dep')
	scriptsApp: require('./scripts-app')
	stylesDep: require('./styles-dep')
	stylesApp: require('./styles-app')


module.exports = ->

	config =
		addRootSlash: true
		ignorePath: "/#{paths.dist}/"

	jsStream = ->
		stream = streamqueue(objectMode: true)
			.queue(tasks.scriptsDep)
			.queue(tasks.scriptsApp)
			.done()

	cssStream = ->
		stream = streamqueue(objectMode: true)
		stream = stream.queue(tasks.stylesDep) if paths.stylesDep.src.length
		stream = stream.queue(tasks.stylesApp)
			.done()
			.pipe $.if(argv.prod, $.concat("app.css"))
			.pipe $.if(argv.prod, gulp.dest(paths.stylesApp.dest))

	injectStream = ->
		streamqueue(objectMode: true)
			.queue(jsStream)
			.queue(cssStream)
			.done()

	stream = gulp.src(paths.jade.main)
		.pipe $.inject(injectStream(), config)
		.pipe gulp.dest("#{paths.src}/jade/base")
