paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')

$ =
	if: require('gulp-if')
	stylus: require('gulp-stylus')
	cssmin: require('gulp-cssmin')
	plumber: require('gulp-plumber')
	sourcemaps: require('gulp-sourcemaps')
	autoprefixer: require('gulp-autoprefixer')


module.exports = ->

	stream = gulp.src paths.stylesApp.main
		.pipe $.plumber()
		.pipe $.if(!argv.prod, $.sourcemaps.init())
		.pipe $.stylus()
		.pipe $.autoprefixer($.autoprefixer('ie 8'))
		.pipe $.if(argv.prod, $.cssmin())
		.pipe $.if(!argv.prod, $.sourcemaps.write())
		.pipe $.if(!argv.prod, gulp.dest(paths.stylesApp.dest))
