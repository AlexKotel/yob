paths = require('../paths')
gulp = require('gulp')

$ =
	changed: require('gulp-changed')


module.exports = ->

	stream = gulp.src(paths.font.src)
		.pipe $.changed(paths.font.dest)
		.pipe gulp.dest(paths.font.dest)
