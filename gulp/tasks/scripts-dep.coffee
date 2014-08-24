paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')

$ =
	if: require('gulp-if')
	concat: require('gulp-concat')
	uglify: require('gulp-uglify')


module.exports = ->

	stream = gulp.src paths.scriptsDep.src
		.pipe $.if(argv.prod, $.concat('vendor.min.css'))
		.pipe $.if(argv.prod, $.uglify())
		.pipe $.if(!argv.prod, gulp.dest(paths.scriptsDep.dest))
