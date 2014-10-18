config = require('../../config')
paths = require('../paths')
gulp = require('gulp')
getFoldersList = require('../utils/getFoldersList')


tasks =
	views: require('./views')
	pages: require('./pages')


module.exports = ->

	gulp.watch paths.img.src, ['img']
	gulp.watch paths.font.src, ['font']
	gulp.watch paths.stylesApp.src, ['styles-app']
	gulp.watch paths.scriptsApp.src, ['scripts-app']

	gulp.watch("#{paths.views.cwd}/**/*").on 'change', -> tasks.views(true)
	gulp.watch("#{paths.pages.cwd}/**/*").on 'change', -> tasks.pages(true)
	gulp.watch(paths.jade.src).on 'change', -> tasks.pages()

	for spriteName in getFoldersList(paths.sprites.cwd)
		gulp.watch("#{paths.sprites.cwd}/#{spriteName}/*.png", ["sprite-png-#{spriteName}"])
