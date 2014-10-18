sequence = require('run-sequence')
config = require('../../config')
paths = require('../paths')
getFoldersList = require('../utils/getFoldersList')
argv = require('optimist').argv
gulp = require('gulp')
path = require('path')
rimraf = require('rimraf')
fs = require('fs')
_ = require('lodash')
TIMESTAMP = Date.now()


$ =
	if: require('gulp-if')
	sprite: require('css-sprite').stream
	imagemin: require('gulp-imagemin')


tasks = {}


# Register cleaning tasks
gulp.task 'sprite-png-clean-stylus', (cb) -> rimraf(paths.sprites.destStylus, cb)
gulp.task 'sprite-png-clean-png', (cb) -> rimraf(paths.sprites.destSprite, cb)
gulp.task 'sprite-png-clean', (cb) ->
	sequence.apply @, ['sprite-png-clean-stylus', 'sprite-png-clean-png', cb]


# Register generators tasks
for spriteName in getFoldersList(paths.sprites.cwd)

	taskName = "sprite-png-#{spriteName}"

	tasks[taskName] = do ->

		spriteCwd = path.join(paths.sprites.cwd, spriteName)
		spriteSrc = "#{spriteCwd}/*.png"

		# Default configs
		pluginConfig =
			name: "#{spriteName}"
			prefix: "png-#{spriteName}"
			style: "#{spriteName}.styl"
			cssPath: "/img/sprite-png/"
			margin: 10
			format: 'png'
			template: 'gulp/utils/sprite-png.mustache'
			orientation: 'binary-tree'

		# User configs
		overrideConfig = config.sprite?.png?[spriteName]
		if overrideConfig
			_.extend pluginConfig, overrideConfig

		return ->
			gulp.src(spriteSrc)
				# .pipe $.if(argv.prod, $.imagemin())
				.pipe $.sprite(pluginConfig)
				.pipe $.if('*.png', gulp.dest(paths.sprites.destSprite), gulp.dest(paths.sprites.destStylus))

	gulp.task taskName, tasks[taskName]


module.exports = (cb) ->

	spriteTasks = []
	spriteTasks.push(taskName) for taskName, task of tasks
	sequence.apply @, ['sprite-png-clean', spriteTasks, cb]
