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
sequence = require 'run-sequence'
streamqueue = require 'streamqueue'
browsersync = require 'browser-sync'
spritesmith = require 'gulp.spritesmith'



# Config
# ====================================================================
CONFIG_BROWSERIFY   = false
CONFIG_ICONFONT     = true
CONFIG_SVGSPRITE    = true
CONFIG_PNGSPRITE    = true
CONFIG_RETINASPRITE = true
DIST = 'dist'
SRC = 'src'



# Paths
# ====================================================================
paths =

	depScripts:
		dest: "#{DIST}/js/dep"
		src: [
			'bower_components/jquery/dist/jquery.js'
			'bower_components/lodash/dist/lodash.js'
			'bower_components/fastclick/lib/fastclick.js'
			'bower_components/bootstrap/dist/js/bootstrap.js'
		]

	depStyles:
		dest: "#{DIST}/css/dep"
		src: [
			'bower_components/bootstrap/dist/css/bootstrap.css'
		]

	appScripts:
		dest: "#{DIST}/js"
		cwd: "#{SRC}/scripts"
		src: [
			"#{SRC}/scripts/app.coffee"
			"#{SRC}/scripts/**/*.coffee"
		]

	appStyles:
		dest: "#{DIST}/css"
		cwd: "#{SRC}/styles"
		src: [
			"#{SRC}/styles/app.styl"
		]

	pages:
		dest: "#{DIST}"
		cwd: "#{SRC}/jade/pages"
		src: ["#{SRC}/jade/pages/**/*.jade"]

	views:
		dest: "#{DIST}/views"
		cwd: "#{SRC}/views"
		src: ["#{SRC}/jade/views/**/*.jade"]

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

	depScripts: ->

		g.src paths.depScripts.src
			.pipe $.if PROD, $.concat('vendor.concated.js')
			.pipe $.if PROD, $.uglify()
			.pipe $.if DEV, g.dest(paths.depScripts.dest)

	depStyles: ->

		g.src paths.depStyles.src
			.pipe $.if PROD, $.concat('vendor.concated.css')
			.pipe $.if PROD, $.cssmin()
			.pipe $.if DEV, g.dest(paths.depStyles.dest)

	appScripts: ->

		g.src paths.appScripts.src
			.pipe $.changed paths.appScripts.dest, extension: '.js'
			.pipe $.plumber()
			.pipe $.coffee()
			.pipe $.if PROD, $.concat('app.concated.js')
			.pipe $.if PROD, $.ngmin()
			.pipe $.if PROD, $.uglify(mangle: false)
			.pipe $.if DEV, g.dest(paths.appScripts.dest)

	appStyles: ->

		g.src paths.appStyles.src
			.pipe $.plumber()
			.pipe $.stylus()
			.pipe $.autoprefixer()
			.pipe $.if PROD, $.cssmin()
			.pipe $.if DEV, g.dest(paths.appStyles.dest)

	inject: ->

		injector = "#{SRC}/jade/base/root.jade"

		suffix = if PROD then "?#{Date.now()}" else ''

		config =
			addRootSlash: false
			startag: '| <!-- inject:{ext} -->'
			endtag:  '| <!-- endinject -->'
			ignorePath: "/#{DIST}/"
			transform: (filepath) ->
				switch helpers.getExtension(filepath)
					when 'css' then return "link(href='#{filepath}#{suffix}' rel='stylesheet')"
					when 'js' then return "script(src='#{filepath}#{suffix}')"

		jsStream = ->
			streamqueue(objectMode: true)
				.queue tasks.depScripts
				.queue tasks.appScripts
				.done()
				.pipe $.if PROD, $.concat('build.js')
				.pipe $.if PROD, g.dest(paths.appScripts.dest)

		cssStream = ->
			streamqueue(objectMode: true)
				.queue tasks.depStyles
				.queue tasks.appStyles
				.done()
				.pipe $.if PROD, $.concat('build.css')
				.pipe $.if PROD, g.dest(paths.appStyles.dest)

		injectStream = ->
			streamqueue(objectMode: true)
				.queue jsStream
				.queue cssStream
				.done()

		g.src injector
			.pipe $.inject(injectStream(), config)
			.pipe g.dest("#{SRC}/jade/base")

	pages: ->

		g.src paths.pages.src
			# .pipe $.changed paths.pages.dest, extension: '.html'
			.pipe $.plumber()
			.pipe $.jade pretty: true
			.pipe g.dest paths.pages.dest

	views: ->

		g.src paths.views.src
			# .pipe $.changed paths.views.dest, extension: '.html'
			.pipe $.plumber()
			.pipe $.jade pretty: true
			.pipe g.dest paths.views.dest

	img: ->

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

		stream

	font: ->

		g.src paths.font.src
			.pipe $.changed paths.font.dest
			.pipe g.dest paths.font.dest

	data: ->

		g.src paths.data.src
			.pipe $.changed paths.data.dest
			.pipe g.dest paths.data.dest

	pngSprite: ->

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
			.pipe g.dest "#{paths.appStyles.cwd}/tools"

	retinaSprite1: ->

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
			.pipe g.dest "#{paths.appStyles.cwd}/tools"

	retinaSprite2: ->

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

	g.watch paths.img.src, ['img']
	g.watch paths.font.src, ['font']
	g.watch paths.data.src, ['data']

	g.watch paths.views.src, ['views']
	g.watch paths.pages.src, ['pages']

	g.watch paths.appStyles.src, ['styles']
	g.watch paths.appScripts.src, ['scripts']

	g.watch ["#{SRC}/tools/iconfont/src/*.svg"], ['grunt-font']
	g.watch ["#{SRC}/tools/svgsprite/src/*.svg"], ['grunt-svg']
	g.watch ["#{SRC}/tools/pngsprite/src/*.png"], ['pngsprite']
	g.watch ["#{SRC}/tools/retinasprite/src/x1/*.png"], ['retinasprite1']
	g.watch ["#{SRC}/tools/retinasprite/src/x2/*.png"], ['retinasprite2']
	g.watch ["#{SRC}/jade/inc/**/*.jade", "#{SRC}/jade/base/**/*.jade"], ['pages', 'views']



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
	args = ['clean']
	args.push tools if tools.length
	args.push assets  if assets.length
	args.push 'inject'
	args.push 'pages'
	args.push 'watch' if DEV
	args.push 'server'

	# Enjoy!
	sequence.apply @, args


# TODO:

# Test watch
# Compile only changed pages and views
# Generate png sprite variables for stylus
# Sync removing files from src to dist
# Add task 'extra copy'
# Add browserify support
# Add PORT configuration
# Add ./server + proxy
# Feel difference between 'browserify on change' and 'watchify'
# Configure iconfont
# Configure svg-sprite
# Configure $.imagemin for .svg
# Configure $.imagemin for .jpg
# Configure $.imagemin for .gif
# Remove limit of 256 files in linux
