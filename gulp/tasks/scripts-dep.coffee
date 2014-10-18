pack = require('../../package.json')
paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')
path = require('path')


$ =
	if: require('gulp-if')
	uglify: require('gulp-uglify')
	rename: require('gulp-rename')
	plumber: require('gulp-plumber')
	browserify: require('gulp-browserify')


module.exports = ->

	requireAll = (bundle) ->
		for vendor, path of pack.browser
			bundle.require(vendor)

	bundleConfig =
		debug: false

	noop = path.join(__dirname, '../utils/noop.js')

	stream = gulp.src(noop, read: false)
		.pipe $.browserify(bundleConfig)
		.on 'prebundle', requireAll

	stream
		.pipe $.rename('vendor.js')
		.pipe $.if(argv.prod, $.uglify())
		.pipe gulp.dest(paths.scriptsDep.dest)
