gulp = require('gulp')
_ = require('lodash')


$ =
	rename: require('gulp-rename')
	rimraf: require('gulp-rimraf')

tasks =
	autoinject: require('../tasks/autoinject')

module.exports = (fromPath, toPath, fromExt, toExt) ->

	gulp.watch("#{fromPath}/**/*").on 'change', (e) ->

		if e.type in ['deleted']

			if fromExt isnt toExt
				e.path = e.path.replace(fromExt, toExt)


			console.log "from: #{fromPath}"
			console.log "to: #{toPath}"

			# IMPORTANT!
			# fromPath must contain '/' on end
			query = fromPath
			index = e.path.indexOf(query)
			deletedFilePath = e.path.substr(index + query.length)
			pathToRemove = toPath + deletedFilePath

			stream = gulp.src(pathToRemove, read: false)

			stream.pipe $.rimraf()

			stream.on 'end', -> tasks.autoinject()


