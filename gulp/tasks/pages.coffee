paths = require('../paths')
gulp = require('gulp')

$ =
	if: require('gulp-if')
	jade: require('gulp-jade')
	plumber: require('gulp-plumber')
	changed: require('gulp-changed')


module.exports = (onlyChanged = false) ->

	stream = gulp.src(paths.pages.src)

	if onlyChanged
		stream = stream.pipe $.changed(paths.pages.dest, extension: '.html')

	stream = stream
		.pipe $.plumber()
		.pipe $.jade(pretty: true)
		.pipe gulp.dest(paths.pages.dest)
