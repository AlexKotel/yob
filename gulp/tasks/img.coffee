paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')

$ =
	if: require('gulp-if')
	changed: require('gulp-changed')
	imagemin: require('gulp-imagemin')


module.exports = ->

	stream = gulp.src paths.img.src
		.pipe $.changed paths.img.dest
		.pipe $.if argv.prod, $.imagemin()
		.pipe gulp.dest paths.img.dest
