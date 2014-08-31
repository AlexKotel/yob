paths = require('../paths')
path = require('path')
argv = require('optimist').argv
gulp = require('gulp')


$ =
	inject: require('gulp-inject')


module.exports = ->


	scriptsDep = for scriptPath in paths.scriptsDep.src
		dest = paths.scriptsDep.dest
		script = path.basename(scriptPath)
		path.join(dest, script)


	scriptsApp = for scriptPath in paths.scriptsApp.src
		dest = paths.scriptsApp.dest
		script = path.relative(paths.scriptsApp.cwd, scriptPath).replace('.coffee', '.js')
		path.join(dest, script)


	stylesDep = for stylePath in paths.stylesDep.src
		dest = paths.stylesDep.dest
		style = path.basename(stylePath)
		path.join(dest, style)

	stylesApp = for stylePath in paths.stylesApp.src
		dest = paths.stylesApp.dest
		style = path.relative(paths.stylesApp.cwd, stylePath).replace('.styl', '.css')
		path.join(dest, style)


	src = []
		.concat(stylesDep)
		.concat(stylesApp)
		.concat(scriptsDep)
		.concat(scriptsApp)


	config =
		addRootSlash: true
		ignorePath: "/#{paths.dist}/"


	stream = gulp.src(paths.jade.injector)
		.pipe $.inject(gulp.src(src), config)
		.pipe gulp.dest("#{paths.src}/jade/base")
