config = require('../config')

SRC = config.src
DIST = config.dist

module.exports =


	src: SRC
	dist: DIST


	scriptsDep:
		dest: "#{DIST}/js"


	stylesDep:
		dest: "#{DIST}/css"
		src: [
			# 'bower_components/bootstrap/dist/css/bootstrap.js'
		]


	scriptsApp:
		cwd: "#{SRC}/coffee"
		dest: "#{DIST}/js"
		main: "#{SRC}/coffee/index.coffee"
		src: ["#{SRC}/coffee/**/*.coffee"]


	stylesApp:
		cwd: "#{SRC}/stylus"
		dest: "#{DIST}/css"
		main: "#{SRC}/stylus/app.styl"
		src: ["#{SRC}/stylus/**/*.styl"]


	pages:
		cwd: "#{SRC}/jade/pages"
		dest: "#{DIST}"
		src: ["#{SRC}/jade/pages/**/*.jade"]


	views:
		cwd: "#{SRC}/jade/views"
		dest: "#{DIST}/views"
		src: ["#{SRC}/jade/views/**/*.jade"]


	jade:
		main: "#{SRC}/jade/base/root.jade"
		src: ["#{SRC}/jade/base/**/*.jade"]


	font:
		dest: "#{DIST}/font"
		cwd: "#{SRC}/font"
		src: ["#{SRC}/font/**/*.{woff,ttf,eot,svg}"]


	img:
		dest: "#{DIST}/img"
		cwd: "#{SRC}/img"
		src: ["#{SRC}/img/**/*.{png,jpg,jpeg,gif,svg}"]


	sprites:
		cwd: "#{SRC}/utils/sprite-png"
		destStylus: "#{SRC}/stylus/sprite-png"
		destSprite: "#{SRC}/img/sprite-png"


	copy: [
		src: "#{SRC}/favicon.ico"
		dest: "#{DIST}"
	]
