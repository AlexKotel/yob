# Arguments
# ====================================================================
argv = require('optimist').argv
PROD = argv.prod
DEV = !argv.prod



# Gulp / Grunt
# ====================================================================
g = require 'gulp'
$ = require('gulp-load-plugins')(lazy: false, camelize: true)
$.grunt g



# Dependencies
# ====================================================================
_ = require 'lodash'
q = require 'q'
path = require 'path'
source = require 'vinyl-source-stream'
watchify = require 'watchify'
sequence = require 'run-sequence'
coffeeify  = require 'coffeeify'
browserify = require 'browserify'
streamqueue = require 'streamqueue'
browsersync = require 'browser-sync'
spritesmith = require 'gulp.spritesmith'



# Config
# ====================================================================
CONFIG_PORT         = 8000
CONFIG_BROWSERIFY   = false
CONFIG_BROWSERSYNC  = true
CONFIG_ICONFONT     = true
CONFIG_SVGSPRITE    = true
CONFIG_PNGSPRITE    = true
CONFIG_RETINASPRITE = true
DIST = 'dist'
SRC = 'src'



# Paths
# ====================================================================
paths =

	# Dependencies
	depJs:
		dest: "#{DIST}/js/dep"
		src: [
			'bower_components/jquery/dist/jquery.js'
			'bower_components/angular/angular.js'
		]

	depCss:
		dest: "#{DIST}/css/dep"
		src: [
			'bower_components/bootstrap/dist/css/bootstrap.css'
		]

	# App
	scripts:
		cwd: "#{SRC}/scripts"
		dest: "#{DIST}/js"
		app: "#{SRC}/scripts/app.coffee"
		src: [
			"#{SRC}/scripts/app.coffee"
			"#{SRC}/scripts/**/*.coffee"
		]

	styles:
		cwd: "#{SRC}/styles"
		dest: "#{DIST}/css"
		src: ["#{SRC}/styles/app.styl"]

	pages:
		cwd: "#{SRC}/jade/pages"
		dest: "#{DIST}"
		src: ["#{SRC}/jade/pages/**/*.jade"]

	views:
		cwd: "#{SRC}/views"
		dest: "#{DIST}/views"
		src: ["#{SRC}/jade/views/**/*.jade"]

	# Assets
	img:
		cwd: "#{SRC}/assets/img"
		dest: "#{DIST}/assets/img"
		src: ["#{SRC}/assets/img/**/*.{png,jpg,gif,svg}"]

	font:
		cwd: "#{SRC}/assets/font"
		dest: "#{DIST}/assets/font"
		src: ["#{SRC}/assets/font/**/*.{woff,ttf,eot,svg}"]

	data:
		cwd: "#{SRC}/assets/data"
		dest: "#{DIST}/assets/data"
		src: ["#{SRC}/assets/data/**/*"]



# Helpers
# ====================================================================
helpers =

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

			# Iconfont
			"#{SRC}/assets/font/iconfont.{woff,ttf,eot,svg}"
			"#{SRC}/styles/tools/iconfont.styl"
			"#{SRC}/tools/iconfont/optimized"
			"#{SRC}/tools/iconfont/dist"

			# Sprite SVG
			"#{SRC}/assets/img/sprite.svg"
			"#{SRC}/styles/tools/svgsprite.styl"
			"#{SRC}/tools/svgsprite/optimized"
			"#{SRC}/tools/svgsprite/dist"

			# Sprite PNG
			"#{SRC}/assets/img/sprite.png"
			"#{SRC}/styles/tools/pngsprite.styl"
			"#{SRC}/tools/pngsprite/optimized"

			# Sprite Retina
			"#{SRC}/assets/img/sprite@1x.png"
			"#{SRC}/assets/img/sprite@2x.png"
			"#{SRC}/styles/tools/retinasprite.styl"
			"#{SRC}/tools/retinasprite/optimized"

		]

		g.src src, read: false
			.pipe $.clean()

	styles: ->

		g.src paths.styles.src
			.pipe $.plumber()
			.pipe $.stylus()
			.pipe $.autoprefixer()
			.pipe $.if PROD, $.cssmin()
			.pipe $.if DEV, g.dest(paths.styles.dest)

	scripts: ->

		stream = null

		if CONFIG_BROWSERIFY

			filename = if PROD then 'build' else 'app'

			bundle = browserify
				entries: "./#{paths.scripts.app}"
				extensions: ['.coffee']

			stream = bundle.bundle debug: DEV
				.on 'error', helpers.errorHandler
				.pipe source "#{filename}.js"
				.pipe g.dest paths.scripts.dest

		else

			stream = g.src paths.scripts.src
				.pipe $.changed paths.scripts.dest, extension: '.js'
				.pipe $.plumber()
				.pipe $.coffee()
				.pipe $.if PROD $.concat('app.concated.js')
				.pipe $.if PROD $.ngmin()
				.pipe $.if PROD $.uglify(mangle: false)
				.pipe $.if DEV g.dest(paths.scripts.dest)

		stream

	depStyles: ->

		g.src paths.depCss.src
			.pipe $.if PROD $.concat('vendor.concated.css')
			.pipe $.if PROD $.cssmin()
			.pipe $.if DEV g.dest paths.depCss.dest

	depScripts: ->

		g.src paths.depJs.src
			.pipe $.if PROD $.concat('vendor.concated.js')
			.pipe $.if PROD $.uglify()
			.pipe $.if DEV g.dest paths.depJs.dest

	inject: ->

		jsStream = streamqueue(objectMode: true)
		cssStream = streamqueue(objectMode: true)
		injectStream = streamqueue(objectMode: true)

		suffix = if PROD then "?t=#{Date.now()}" else ''

		config =
			addRootSlash: false
			startag: '| <!-- inject:{ext} -->'
			endtag:  '| <!-- endinject -->'
			ignorePath: "/#{DIST}/"
			transform: (filepath) ->
				switch helpers.getExtension(filepath)
					when 'css' then return "link(href='#{filepath}#{suffix}' rel='stylesheet')"
					when 'js' then return "script(src='#{filepath}#{suffix}')"

		jsStream.queue tasks.depScripts() if paths.depJs.src.length and not CONFIG_BROWSERIFY
		jsStream.queue tasks.scripts()

		cssStream.queue tasks.depStyles() if paths.depCss.src.length
		cssStream.queue tasks.styles()

		if PROD and not CONFIG_BROWSERIFY
			jsStream = jsStream.done()
		else
			jsStream = jsStream.done()
			
		if PROD
			cssStream = cssStream.done()
		else
			cssStream = cssStream.done()

		injectStream.queue jsStream
		injectStream.queue cssStream

		g.src "#{SRC}/jade/base/root.jade"
			.pipe $.inject(injectStream.done(), config)
			.pipe g.dest("#{SRC}/jade/base")

	pages: ->

		g.src paths.pages.src
			.pipe $.plumber()
			.pipe $.jade pretty: true
			.pipe g.dest paths.pages.dest

	views: ->

		g.src paths.views.src
			.pipe $.changed paths.views.dest, extension: '.html'
			.pipe $.plumber()
			.pipe $.jade pretty: true
			.pipe g.dest paths.views.dest

	img: ->

		# TODO:
		# Configure $.imagemin for .svg
		# Configure $.imagemin for .jpg
		# Configure $.imagemin for .gif

		stream = g.src paths.img.src

		stream
			.pipe $.filter '**/*.svg'
			.pipe $.changed paths.img.dest
			.pipe g.dest paths.img.dest

		stream
			.pipe $.filter '**/*.png'
			.pipe $.changed paths.img.dest
			.pipe $.imagemin()
			.pipe g.dest paths.img.dest

		stream
			.pipe $.filter '**/*.jpg'
			.pipe $.changed paths.img.dest
			.pipe g.dest paths.img.dest

		stream
			.pipe $.filter '**/*.gif'
			.pipe $.changed paths.img.dest
			.pipe g.dest paths.img.dest

	font: ->

		g.src paths.font.src
			.pipe $.changed paths.font.dest
			.pipe g.dest paths.font.dest

	data: ->

		g.src paths.data.src
			.pipe $.changed paths.data.dest
			.pipe g.dest paths.data.dest

	pngSprite: ->

		# TODO:
		# Refactor paths

		config =
			imgName: 'sprite.png'
			imgPath: '../assets/img/sprite.png'
			cssName: 'pngsprite.css'
			cssOpts:
				cssClass: (item) -> ".i.i-#{item.name}"

		stream = g.src "#{SRC}/tools/pngsprite/src/*.png"
			.pipe $.imagemin()
			.pipe g.dest "#{SRC}/tools/pngsprite/optimized"
			.pipe spritesmith config

		stream.img
			.pipe g.dest paths.img.cwd

		stream.css
			.pipe $.rename 'pngsprite.styl'
			.pipe g.dest "#{paths.styles.cwd}/tools"

	retinaSprite1: ->

		# TODO:
		# Refactor paths

		config =
			imgName: 'sprite@1x.png'
			imgPath: '../assets/img/sprite@1x.png'
			cssName: 'retinasprite.css'
			cssOpts:
				cssClass: (item) -> ".png.png-#{item.name}"

		stream = g.src "#{SRC}/tools/retinasprite/src/x1/*.png"
			.pipe $.imagemin()
			.pipe g.dest "#{SRC}/tools/retinasprite/optimized/x1"
			.pipe spritesmith config

		stream.img
			.pipe g.dest paths.img.cwd

		stream.css
			.pipe $.rename 'retinasprite.styl'
			.pipe g.dest "#{paths.styles.cwd}/tools"

	retinaSprite2: ->

		# TODO:
		# Refactor paths

		config =
			imgName: 'sprite@2x.png'
			cssName: 'retinasprite@2x.css' # will be not used

		stream = g.src "#{SRC}/tools/retinasprite/src/x2/*.png"
			.pipe $.imagemin()
			.pipe g.dest "#{SRC}/tools/retinasprite/optimized/x2"
			.pipe spritesmith config

		stream.img
			.pipe g.dest paths.img.cwd

	server: (next) ->

		app = [
			"#{DIST}/*.html"
			"#{DIST}/js/**/*.js"
			"#{DIST}/css/*.css"
			"#{DIST}/views/**/*.html"
			"#{DIST}/assets/img/**/*.{png,jpg,gif,svg}"
			"#{DIST}/assets/font/*.{woff,ttf,eot,svg}"
		]

		config =
			server:
				baseDir: "#{DIST}"
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

		browsersync.init app, config, next



# CLI
# ====================================================================
g.task 'clean', tasks.clean
g.task 'img', tasks.img
g.task 'font', tasks.font
g.task 'data', tasks.data
g.task 'pngsprite', tasks.pngSprite
g.task 'retinasprite1', tasks.retinaSprite1
g.task 'retinasprite2', tasks.retinaSprite2
g.task 'scripts', tasks.scripts
g.task 'styles', tasks.styles
g.task 'views', tasks.views
g.task 'inject', tasks.inject
g.task 'pages', tasks.pages
g.task 'server', tasks.server



# Watch
# ====================================================================
g.task 'watch', ->

	# TODO:
	# Refactor jade watchers
	# Feel difference between 'browserify on change' and 'watchify'

	g.watch paths.img.src, ['img']
	g.watch paths.font.src, ['font']
	g.watch paths.data.src, ['data']
	g.watch paths.views.src, ['views']
	g.watch paths.pages.src, ['pages']
	g.watch paths.styles.src, ['styles']
	g.watch paths.scripts.src, ['scripts']

	g.watch "#{SRC}/tools/iconfont/src/*.svg", ['grunt-font']
	g.watch "#{SRC}/tools/svgsprite/src/*.svg", ['grunt-svg']
	g.watch "#{SRC}/tools/pngsprite/src/*.png", ['pngsprite']
	g.watch "#{SRC}/tools/retinasprite/src/x1/*.png", ['retinasprite1']
	g.watch "#{SRC}/tools/retinasprite/src/x2/*.png", ['retinasprite2']

	jade = [
		"#{SRC}/jade/inc/**/*.jade"
		"#{SRC}/jade/base/**/*.jade"
	]

	g.watch jade, ['pages', 'views']




# Build
# ====================================================================
g.task 'default', ->

	# Tools
	tools = []
	tools.push 'pngsprite' if CONFIG_PNGSPRITE
	tools.push 'grunt-svg' if CONFIG_SVGSPRITE
	tools.push 'grunt-font' if CONFIG_ICONFONT
	tools.push 'retinasprite1' if CONFIG_RETINASPRITE
	tools.push 'retinasprite2' if CONFIG_RETINASPRITE

	# Assets
	assets = []
	assets.push 'img'
	assets.push 'data'
	assets.push 'font'
	assets.push 'views'

	# Tasks
	args = []
	args.push 'clean'
	args.push tools if tools.length
	args.push assets  if assets.length
	args.push 'inject'
	args.push 'pages'
	args.push 'watch'
	args.push 'server'

	# Enjoy!
	sequence.apply @, args


# TODO:
# - watch jade
# - use PORT
# - make ./server + proxy
# - test watch
# - refactor inject and scropts+styles