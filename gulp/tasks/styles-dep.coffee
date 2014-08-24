paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')

$ =
	if: require('gulp-if')
	concat: require('gulp-concat')
	cssmin: require('gulp-cssmin')


module.exports = ->

	stream = gulp.src paths.stylesDep.src
		.pipe $.if(argv.prod, $.concat('vendor.min.css'))
		.pipe $.if(argv.prod, $.cssmin())
		.pipe $.if(!argv.prod, gulp.dest(paths.stylesDep.dest))
