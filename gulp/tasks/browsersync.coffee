config = require('../../config')
paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')
browsersync = require('browser-sync')

$ =
	if: require('gulp-if')
	coffee: require('gulp-coffee')
	concat: require('gulp-concat')
	uglify: require('gulp-uglify')
	plumber: require('gulp-plumber')
	changed: require('gulp-changed')
	sourcemaps: require('gulp-sourcemaps')
	ngAnnotate: require('gulp-ng-annotate')


module.exports = ->

	app = [
		"#{paths.pages.dest}/*.html"
		"#{paths.views.dest}/**/*.html"
		"#{paths.scriptsApp.dest}/**/*.js"
		"#{paths.stylesApp.dest}/**/*.css"
		"#{paths.img.dest}/**/*.{png,jpg,jpeg,gif,svg}"
		"#{paths.font.dest}/**/*.{woff,ttf,eot,svg}"
	]

	config =
		proxy: "localhost:#{config.port.static}"
		ports:
			min: config.port.browserSync
			max: config.port.browserSync
		browser: [
			# 'opera'
			# 'safari'
			# 'firefox'
			# 'google chrome'
		]
		ghostMode:
			forms: true
			clicks: true
			scroll: true
			location: true

	browsersync.init app, config
