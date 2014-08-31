paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')

syncFiles = require('../helpers/syncFiles')

tasks =
	views: require('./views')
	pages: require('./pages')
	inject: require('./inject')
	iconfont: require('./iconfont')
	spritePng: require('./sprite-png')
	spriteSvg: require('./sprite-svg')
	scriptsApp: require('./scripts-app')
	autoinject: require('./autoinject')


module.exports = ->

	# gulp.watch paths.img.src, ['img']
	# gulp.watch paths.font.src, ['font']
	# gulp.watch paths.stylesApp.src, ['styles-app']

	# gulp.watch ["#{paths.src}/tools/sprite-png/src/*.png"], ['sprite-png']


	# gulp.watch ["#{paths.scriptsApp.cwd}/**/*"]
	# 	.on 'change', (e) ->

	# 		if e.type in ['changed']
	# 			tasks.scriptsApp(true)

	# 		if e.type in ['added']
	# 			tasks.scriptsApp(true).on 'end', tasks.autoinject

	# gulp.watch paths.views.src
	# 	.on 'change', (e) ->
	# 		tasks.views(true)

	# gulp.watch paths.pages.src
	# 	.on 'change', (e) ->
	# 		tasks.pages(true)

	# gulp.watch paths.jade.src
	# 	.on 'change', ->
	# 		tasks.pages()

	syncFiles(paths.scriptsApp.cwd, paths.scriptsApp.dest, '.coffee', '.js')
