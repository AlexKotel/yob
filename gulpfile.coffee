CONFIG = require './config'
argv = require('optimist').argv


# Gulp / Grunt
# ====================================================================
g = require 'gulp'
$ = require('gulp-load-plugins')(lazy: false, camelize: true)
$.grunt g



# Dependencies
# ====================================================================
streamqueue = require 'streamqueue'
browsersync = require 'browser-sync'
spritesmith = require 'gulp.spritesmith'
sequence = require 'run-sequence'
sizeOf = require 'image-size'
source = require 'vinyl-source-stream'
path = require 'path'
_ = require 'lodash'
q = require 'q'



# Config
# ====================================================================
TIMESTAMP = Date.now()
STYLUS_DATA = {}
JADE_DATA = {}
PROD = argv.prod
DEV = !argv.prod
DIST = CONFIG.dist
SRC = CONFIG.src




# Paths
# ====================================================================
paths =

	depScripts:
		dest: "#{DIST}/js/dep"
		src: [
			'bower_components/jquery/dist/jquery.js'
			'bower_components/lodash/dist/lodash.js'
			'bower_components/bootstrap/dist/js/bootstrap.js'
		]

	depStyles:
		dest: "#{DIST}/css/dep"
		src: [
			'bower_components/bootstrap/dist/css/bootstrap.css'
		]

	appScripts:
		dest: "#{DIST}/js"
		main: "#{SRC}/scripts/app.coffee"
		cwd: "#{SRC}/scripts"
		src: [
			"#{SRC}/scripts/app.coffee"
			"#{SRC}/scripts/**/*.coffee"
		]

	appStyles:
		dest: "#{DIST}/css"
		main: "#{SRC}/styles/__app.styl"
		cwd: "#{SRC}/styles"
		src: [
			"#{SRC}/styles/**/*.styl"
		]

	pages:
		dest: "#{DIST}"
		cwd: "#{SRC}/jade/pages"
		src: ["#{SRC}/jade/pages/**/*.jade"]

	views:
		dest: "#{DIST}/views"
		cwd: "#{SRC}/views"
		src: ["#{SRC}/jade/views/**/*.jade"]

	jade:
		src: [
			"#{SRC}/jade/inc/**/*.jade"
			"#{SRC}/jade/base/**/*.jade"
		]

	img:
		dest: "#{DIST}/assets/img"
		cwd: "#{SRC}/assets/img"
		src: ["#{SRC}/assets/img/**/*.{png,jpg,gif,svg}"]

	font:
		dest: "#{DIST}/assets/font"
		cwd: "#{SRC}/assets/font"
		src: ["#{SRC}/assets/font/**/*.{woff,ttf,eot,svg}"]

	data:
		dest: "#{DIST}/assets/data"
		cwd: "#{SRC}/assets/data"
		src: ["#{SRC}/assets/data/**/*"]



# Helpers
# ====================================================================
helpers =

	svgFilter: $.filter '**/*.svg'
	pngFilter: $.filter '**/*.png'
	jpgFilter: $.filter '**/*.jpg'
	gifFilter: $.filter '**/*.gif'

	errorHandler: (err) ->

		$.util.log 'Unhandled gulp exception...'
		$.util.log err.toString()
		$.util.beep()
		@emit 'end'

	getExtension: (filepath) ->

		path.extname(filepath).slice(1)



# Tasks
# ====================================================================
tasks =

	clean: ->

		src = [

			# Distribution
			"#{DIST}"

			# Underscore template results
			"#{SRC}/jade/base/root.jade"
			"#{SRC}/styles/app.styl"

			# Iconfont
			"#{SRC}/assets/font/iconfont-*.{woff,ttf,eot,svg}"
			"#{SRC}/styles/tools/iconfont.styl"
			"#{SRC}/tools/iconfont/optimized"
			"#{SRC}/tools/iconfont/dist"

			# Sprite SVG
			"#{SRC}/assets/img/sprite-*.svg"
			"#{SRC}/styles/tools/sprite-svg.styl"
			"#{SRC}/tools/svgsprite/optimized"
			"#{SRC}/tools/svgsprite/dist"

			# Sprite PNG
			"#{SRC}/assets/img/sprite-*.png"
			"#{SRC}/styles/tools/sprite-png.styl"
			"#{SRC}/tools/pngsprite/optimized"

			# Sprite Retina
			"#{SRC}/assets/img/sprite-*@1x.png"
			"#{SRC}/assets/img/sprite-*@2x.png"
			"#{SRC}/styles/tools/sprite-retina.styl"
			"#{SRC}/tools/retinasprite/optimized"

		]

		stream = g.src src, read: false
			.pipe $.clean()

	depScripts: ->

		stream = g.src paths.depScripts.src
			.pipe $.if PROD, $.concat('vendor.concated.js')
			.pipe $.if PROD, $.uglify()
			.pipe $.if DEV, g.dest(paths.depScripts.dest)

	depStyles: ->

		stream = g.src paths.depStyles.src
			.pipe $.if PROD, $.concat('vendor.concated.css')
			.pipe $.if PROD, $.cssmin()
			.pipe $.if DEV, g.dest(paths.depStyles.dest)

	appScripts: (onlyChanged) ->

		stream = g.src paths.appScripts.src

		if onlyChanged
			stream = stream
				.pipe $.changed paths.appScripts.dest, extension: '.js'

		stream = stream
			.pipe $.plumber()
			.pipe $.if DEV, $.sourcemaps.init()
			.pipe $.coffee()
			.pipe $.if PROD, $.concat('app.concated.js')
			.pipe $.if PROD, $.ngmin()
			.pipe $.if PROD, $.uglify(mangle: false)
			.pipe $.if DEV, $.sourcemaps.write()
			.pipe $.if DEV, g.dest(paths.appScripts.dest)

	appStyles: ->

		STYLUS_DATA.retinaSpriteUrl = "../assets/img/sprite-#{TIMESTAMP}@2x.png"
		STYLUS_DATA.retinaSpriteWidth = sizeOf("src/assets/img/sprite-#{TIMESTAMP}@2x.png").width
		STYLUS_DATA.retinaSpriteHeight = sizeOf("src/assets/img/sprite-#{TIMESTAMP}@2x.png").height

		stream = g.src paths.appStyles.main
			.pipe $.rename('app.styl')
			.pipe $.template STYLUS_DATA
			.pipe g.dest(paths.appStyles.cwd)
			.pipe $.plumber()
			.pipe $.stylus()
			.pipe $.autoprefixer()
			.pipe $.if PROD, $.cssmin()
			.pipe $.if DEV, g.dest(paths.appStyles.dest)

	inject: ->

		injector = "#{SRC}/jade/base/__root.jade"

		suffix = if PROD then "?#{Date.now()}" else ''

		config =
			addRootSlash: false
			startag: '| <!-- inject:{ext} -->'
			endtag:  '| <!-- endinject -->'
			ignorePath: "/dist/"
			transform: (filepath) ->
				switch helpers.getExtension(filepath)
					when 'css' then return "link(href='#{filepath}' rel='stylesheet')"
					when 'js' then return "script(src='#{filepath}')"

		jsStream = ->
			stream = streamqueue(objectMode: true)
			stream = stream.queue(tasks.depScripts) if paths.depScripts.src.length
			stream = stream.queue(tasks.appScripts)
				.done()
				.pipe $.if PROD, $.concat("build-#{TIMESTAMP}.js")
				.pipe $.if PROD, g.dest(paths.appScripts.dest)

		cssStream = ->
			stream = streamqueue(objectMode: true)
			stream = stream.queue(tasks.depStyles) if paths.depStyles.src.length
			stream = stream.queue(tasks.appStyles)
				.done()
				.pipe $.if PROD, $.concat("build-#{TIMESTAMP}.css")
				.pipe $.if PROD, g.dest(paths.appStyles.dest)

		injectStream = ->
			streamqueue(objectMode: true)
				.queue jsStream
				.queue cssStream
				.done()

		stream = g.src injector
			.pipe $.inject(injectStream(), config)
			.pipe $.rename('root.jade')
			.pipe g.dest("#{SRC}/jade/base")

	pages: (onlyChanged) ->

		stream = g.src paths.pages.src

		if onlyChanged
			stream = stream.pipe $.changed paths.pages.dest, extension: '.html'

		stream = stream
			.pipe $.plumber()
			.pipe $.jade pretty: true, data: JADE_DATA
			.pipe g.dest paths.pages.dest

	views: (onlyChanged) ->

		stream = g.src paths.views.src

		if onlyChanged
			stream = stream.pipe $.changed paths.views.dest, extension: '.html'

		stream = stream
			.pipe $.plumber()
			.pipe $.jade pretty: true, data: JADE_DATA
			.pipe g.dest paths.views.dest

	img: ->

		stream = g.src paths.img.src

			.pipe $.changed paths.img.dest

			# .pipe helpers.pngFilter
			# .pipe helpers.pngFilter.restore()

			# .pipe helpers.svgFilter
			# .pipe helpers.svgFilter.restore()

			# .pipe helpers.jpgFilter
			# .pipe helpers.jpgFilter.restore()

			# .pipe helpers.gifFilter
			# .pipe helpers.gifFilter.restore()

			.pipe $.if PROD, $.imagemin()
			.pipe g.dest paths.img.dest

	font: ->

		stream = g.src paths.font.src
			.pipe $.changed paths.font.dest
			.pipe g.dest paths.font.dest

	data: ->

		stream = g.src paths.data.src
			.pipe $.changed paths.data.dest
			.pipe g.dest paths.data.dest

	pngSprite: ->

		imgName = "sprite-#{TIMESTAMP}"
		cssName = "sprite-png"

		config =
			imgName: "#{imgName}.png"
			imgPath: "../assets/img/#{imgName}.png"
			cssName: "#{cssName}.css"
			algorithm: 'binary-tree'
			cssOpts:
				cssClass: (item) -> ".i.i-#{item.name}"

		stream = g.src "#{SRC}/tools/pngsprite/src/*.png"
			.pipe $.if PROD, $.imagemin()
			.pipe g.dest "#{SRC}/tools/pngsprite/optimized"
			.pipe spritesmith config

		stream.css
			.pipe $.rename "#{cssName}.styl"
			.pipe g.dest "#{paths.appStyles.cwd}/tools"

		stream.img
			.pipe g.dest paths.img.cwd

	retinaSprite1: ->

		imgName = "sprite-#{TIMESTAMP}@1x"
		cssName = "sprite-retina"

		config =
			imgName: "#{imgName}.png"
			imgPath: "../assets/img/#{imgName}.png"
			cssName: "#{cssName}.css"
			algorithm: 'binary-tree'
			cssOpts:
				cssClass: (item) -> ".png.png-#{item.name}"

		stream = g.src "#{SRC}/tools/retinasprite/src/x1/*.png"
			.pipe $.if PROD, $.imagemin()
			.pipe g.dest "#{SRC}/tools/retinasprite/optimized/x1"
			.pipe spritesmith config

		stream.css
			.pipe $.rename "#{cssName}.styl"
			.pipe g.dest "#{paths.appStyles.cwd}/tools"

		stream.img
			.pipe g.dest paths.img.cwd

	retinaSprite2: ->

		imgName = "sprite-#{TIMESTAMP}@2x"
		cssName = "WILL_BE_NOT_USED_BUT_REQUIRED"

		config =
			imgName: "#{imgName}.png"
			cssName: "#{cssName}.css"
			algorithm: 'binary-tree'

		stream = g.src "#{SRC}/tools/retinasprite/src/x2/*.png"
			.pipe $.if PROD, $.imagemin()
			.pipe g.dest "#{SRC}/tools/retinasprite/optimized/x2"
			.pipe spritesmith config

		stream.img
			.pipe g.dest paths.img.cwd

	server: (next) ->

		server = require './server/server'

		app = [
			"#{DIST}/*.html"
			"#{DIST}/js/**/*.js"
			"!#{DIST}/js/dep/**/*.js"
			"#{DIST}/css/*.css"
			"!#{DIST}/css/dep/*.css"
			"#{DIST}/views/**/*.html"
			"#{DIST}/assets/img/**/*.{png,jpg,gif,svg}"
			"#{DIST}/assets/font/*.{woff,ttf,eot,svg}"
		]

		config =
			reloadDelay: 200
			proxy: "localhost:#{CONFIG.port.static}"
			ports:
				min: CONFIG.port.browserSync
				max: CONFIG.port.browserSync
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

		server.start ->
			browsersync.init app, config, next



# CLI
# ====================================================================
g.task 'clean', tasks.clean

g.task 'pngsprite', tasks.pngSprite
g.task 'retinasprite1', tasks.retinaSprite1
g.task 'retinasprite2', tasks.retinaSprite2

g.task 'img', tasks.img
g.task 'font', tasks.font
g.task 'data', tasks.data

g.task 'scripts', tasks.appScripts
g.task 'styles', tasks.appStyles
g.task 'pages', tasks.pages
g.task 'views', tasks.views

g.task 'inject', tasks.inject
g.task 'server', tasks.server



# Watch
# ====================================================================
g.task 'watch', ->

	# Assets
	g.watch paths.img.src, ['img']
	g.watch paths.font.src, ['font']
	g.watch paths.data.src, ['data']

	# Tools
	g.watch ["#{SRC}/tools/iconfont/src/*.svg"], ['grunt-font']
	g.watch ["#{SRC}/tools/svgsprite/src/*.svg"], ['grunt-svg']
	g.watch ["#{SRC}/tools/pngsprite/src/*.png"], ['pngsprite']
	g.watch ["#{SRC}/tools/retinasprite/src/x1/*.png"], ['retinasprite1']
	g.watch ["#{SRC}/tools/retinasprite/src/x2/*.png"], ['retinasprite2']

	# Styles
	g.watch paths.appStyles.src, ['styles']

	# Scripts
	g.watch paths.appScripts.src, (e) ->
		if e.type is 'added'
			tasks.inject()

		if e.type is 'changed'
			tasks.appScripts(true)

	# Jade
	g.watch paths.views.src
		.on 'change', ->
			tasks.views(true)

	g.watch paths.pages.src
		.on 'change', ->
			tasks.pages(true)

	g.watch paths.jade.src
		.on 'change', ->
			tasks.pages()
			tasks.views()



# Build
# ====================================================================
g.task 'default', ->

	# Tasks
	args = ['clean']

	args.push 'pngsprite' if CONFIG.tools.spritePng
	args.push 'grunt-svg' if CONFIG.tools.spriteSvg
	args.push 'grunt-font' if CONFIG.tools.iconfont
	args.push 'retinasprite1' if CONFIG.tools.spriteRetina
	args.push 'retinasprite2' if CONFIG.tools.spriteRetina

	args.push 'img'
	args.push 'data'
	args.push 'font'
	args.push 'views'

	args.push 'inject'
	args.push 'pages'
	args.push 'watch' if DEV
	args.push 'server'

	# Enjoy!
	sequence.apply @, args



# DEPLOY
# ====================================================================
g.task 'deploy', do ->

	$.shell.task [

		# Selectel deploy
		# "tar czvf #{SELECTEL.ARCHIVE} #{DIST}"
		# "curl -i -X PUT '#{SELECTEL.HOST}/?extract-archive=tar.gz' -H 'X-Auth-Token: #{SELECTEL.TOKEN}' -T '#{SELECTEL.ARCHIVE}'"

		# Simple git deploy
		# "git add ."
		# "git commit -m 'New build'"
		# "git push origin master"

		# Simple heroku deploy
		# "git push heroku master"
		
	]

g.task 'auth', $.shell.task [""]


### TODO:

[ ] Test watch images
[x] Test watch jade
[x] Test watch stylus
[x] Test watch coffee
[x] Test watch assets
[x] Compile only changed pages and views
[x] Compile only changed scripts
[ ] Optimize and copy only changed images/data/fonts
[x] Timestamp in all sprites
[x] Autoinject new scripts
[x] Add .coffee sourcemaps
[x] Add PORT
[x] Add task 'deploy'
[ ] Add link in stylus to @2x sprite
[ ] Remove timestamp in iconfont.styl
[ ] Generate png/retina sprite variables for stylus
[ ] Sync removing files from src to dist
[ ] Add browserify support
[ ] Add ./server + proxy support
[ ] Add task 'extra copy'
[ ] Feel difference between 'browserify on change' and 'watchify'
[ ] Configure iconfont
[ ] Configure svg-sprite
[ ] Configure $.imagemin for .svg
[ ] Configure $.imagemin for .jpg
[ ] Configure $.imagemin for .gif
[ ] Refactor autoinject

###
