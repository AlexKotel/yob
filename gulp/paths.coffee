config = require('../config')

SRC = config.src
DIST = config.dist

module.exports =


	src: SRC
	dist: DIST


	scriptsDep:
		dest: "#{DIST}/js/dep"
		src: [
			# 'bower_components/bootstrap/dist/js/bootstrap.js'
			'bower_components/lodash/dist/lodash.js'
			'bower_components/jquery/dist/jquery.js'
			'bower_components/angular/angular.js'
		]


	stylesDep:
		dest: "#{DIST}/css/dep"
		src: [
			# 'bower_components/bootstrap/dist/css/bootstrap.js'
		]


	scriptsApp:
		cwd: "#{SRC}/coffee"
		dest: "#{DIST}/js/app"
		main: "#{SRC}/coffee/app.coffee"
		src: [
			"#{SRC}/coffee/app.coffee"
			"#{SRC}/coffee/**/*.coffee"
		]


	stylesApp:
		cwd: "#{SRC}/stylus"
		dest: "#{DIST}/css/app"
		main: "#{SRC}/stylus/app.styl"
		src: [
			"#{SRC}/stylus/**/*.styl"
		]


	pages:
		cwd: "#{SRC}/jade/pages"
		dest: "#{DIST}"
		src: ["#{SRC}/jade/pages/**/*.jade"]


	views:
		cwd: "#{SRC}/jade/views"
		dest: "#{DIST}/views"
		src: ["#{SRC}/jade/views/**/*.jade"]


	jade:
		injector: "#{SRC}/jade/base/root.jade"
		src: ["#{SRC}/jade/base/**/*.jade"]


	img:
		dest: "#{DIST}/img"
		cwd: "#{SRC}/img"
		src: ["#{SRC}/img/**/*.{png,jpg,jpeg,gif,svg}"]


	font:
		dest: "#{DIST}/font"
		cwd: "#{SRC}/font"
		src: ["#{SRC}/font/**/*.{woff,ttf,eot,svg}"]


	sprites:
		cwd: "#{SRC}/utils/sprite-png"


	copy: [
		src: "#{SRC}/favicon.ico"
		dest: "#{DIST}"
	]
