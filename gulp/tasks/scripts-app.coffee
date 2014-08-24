paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')

$ =
	if: require('gulp-if')
	coffee: require('gulp-coffee')
	concat: require('gulp-concat')
	uglify: require('gulp-uglify')
	plumber: require('gulp-plumber')
	changed: require('gulp-changed')
	sourcemaps: require('gulp-sourcemaps')
	ngAnnotate: require('gulp-ng-annotate')


module.exports = (onlyChanged = false) ->

	stream = gulp.src paths.scriptsApp.src

	if onlyChanged
		stream = stream
			.pipe $.changed paths.scriptsApp.dest, extension: '.js'

	stream = stream
		.pipe $.plumber()
		.pipe $.if(!argv.prod, $.sourcemaps.init())
		.pipe $.coffee()
		.pipe $.if(argv.prod, $.concat('app.concated.js'))
		.pipe $.if(argv.prod, $.ngAnnotate())
		.pipe $.if(argv.prod, $.uglify(mangle: false))
		.pipe $.if(!argv.prod, $.sourcemaps.write())
		.pipe $.if(!argv.prod, gulp.dest(paths.scriptsApp.dest))
