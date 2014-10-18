pack = require('../../package.json')
paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')


$ =
	if: require('gulp-if')
	uglify: require('gulp-uglify')
	rename: require('gulp-rename')
	plumber: require('gulp-plumber')
	ngAnnotate: require('gulp-ng-annotate')
	browserify: require('gulp-browserify')


module.exports = ->

	externalAll = (bundle) ->
		for vendor, path of pack.browser
			bundle.external(vendor)

	bundleConfig =
		debug: !argv.prod
		extensions: ['.coffee']

	stream = gulp.src(paths.scriptsApp.main, read: false)

	stream = stream
		.pipe $.plumber()
		.pipe $.browserify(bundleConfig)
		.on 'prebundle', externalAll

	stream
		.pipe $.rename('app.js')
		.pipe $.if(argv.prod, $.uglify(mangle: false))
		.pipe gulp.dest(paths.scriptsApp.dest)
