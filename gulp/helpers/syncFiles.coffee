gulp = require('gulp')


$ =
	rename: require('gulp-rename')
	rimraf: require('gulp-rimraf')

module.exports = (fromPath, toPath, fromExt, toExt) ->

	gulp.watch("#{fromPath}/**/*").on 'change', (e) ->

		if e.type in ['deleted']

			deletedPath = e.path

			console.log fromPath
			console.log deletedPath


