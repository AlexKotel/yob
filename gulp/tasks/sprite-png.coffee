paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')

$ =
	if: require('gulp-if')
	imagemin: require('gulp-imagemin')


module.exports = (cb) ->
	console.log 'Sprite-png not implemented'
	cb()

