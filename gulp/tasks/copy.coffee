paths = require('../paths')
gulp = require('gulp')

$ =
	changed: require('gulp-changed')


module.exports = (cb) ->

	for glob in paths.copy
		gulp.src(glob.src)
			.pipe $.changed(glob.dest)
			.pipe gulp.dest(glob.dest)

	cb()
