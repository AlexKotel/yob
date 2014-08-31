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


	# Img
	gulp.watch paths.img.src, ['img']


	# Font
	gulp.watch paths.font.src, ['font']


	# Tools
	gulp.watch paths.stylesApp.src, ['styles-app']


	# Stylus
	gulp.watch ["#{paths.src}/tools/sprite-png/src/*.png"], ['sprite-png']


	# Coffee
	gulp.watch(["#{paths.scriptsApp.cwd}/**/*"]).on 'change', (e) ->
		if e.type in ['changed']
			tasks.scriptsApp(true)
		if e.type in ['added']
			tasks.scriptsApp(true).on 'end', tasks.autoinject


	# Jade
	gulp.watch(paths.views.src).on 'change', -> tasks.views(true)
	gulp.watch(paths.pages.src).on 'change', -> tasks.pages(true)
	gulp.watch(paths.jade.src).on 'change', -> tasks.pages()

	# Sync remove
	syncFiles(paths.scriptsApp.cwd, paths.scriptsApp.dest, '.coffee', '.js', tasks.autoinject)
	syncFiles(paths.pages.cwd, paths.pages.dest, '.jade', '.html')
	syncFiles(paths.views.cwd, paths.views.dest, '.jade', '.html')
	syncFiles(paths.font.cwd, paths.font.dest)
	syncFiles(paths.img.cwd, paths.img.dest)
