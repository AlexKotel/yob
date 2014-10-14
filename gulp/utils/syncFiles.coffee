gulp = require('gulp')
_ = require('lodash')


$ =
	rename: require('gulp-rename')
	rimraf: require('gulp-rimraf')


module.exports = (fromPath, toPath, fromExt, toExt, cb = ->) ->

	console.log

	gulp.watch("#{fromPath}/**/*").on 'change', (e) ->

		if e.type in ['deleted']

			console.log 'Sync files...'

			if fromExt isnt toExt
				e.path = e.path.replace(fromExt, toExt)

			# IMPORTANT!
			# `fromPath` must contain '/' on end in Linux
			query = fromPath
			index = e.path.indexOf(query)
			deletedFilePath = e.path.substr(index + query.length)
			pathToRemove = toPath + deletedFilePath

			stream = gulp.src(pathToRemove, read: false)
			stream.pipe($.rimraf())
			stream.on('end', cb)


