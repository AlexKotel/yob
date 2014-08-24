paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')

tasks =
	views: require('./views')
	pages: require('./pages')
	inject: require('./inject')
	iconfont: require('./iconfont')
	spritePng: require('./sprite-png')
	spriteSvg: require('./sprite-svg')
	scriptsApp: require('./scripts-app')

module.exports = ->


	gulp.watch paths.img.src, ['img']
	gulp.watch paths.font.src, ['font']
	gulp.watch paths.stylesApp.src, ['styles-app']

	gulp.watch paths.scriptsApp.src
		.on 'change', (e) ->
			if e.type in ['changed']
				tasks.scriptsApp(true)

			if e.type in ['added']
				tasks.inject(true)

	gulp.watch paths.views.src
		.on 'change', (e) ->
			tasks.views(true)

	gulp.watch paths.pages.src
		.on 'change', (e) ->
			tasks.pages(true)

	gulp.watch paths.jade.src
		.on 'change', ->
			tasks.pages()
			tasks.views()
