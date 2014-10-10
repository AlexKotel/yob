config = require('../config')

SRC = config.src
DIST = config.dist

module.exports =


	src: SRC
	dist: DIST


	scriptsDep:
		dest: "#{DIST}/js/dep"
		src: [
			# 'bower_components/jquery/dist/jquery.js'
			# 'bower_components/bootstrap/dist/js/bootstrap.js'
			'bower_components/lodash/dist/lodash.js'
			'bower_components/angular/angular.js'
		]


	stylesDep:
		dest: "#{DIST}/css/dep"
		src: [
			'bower_components/normalize-css/normalize.css'
		]


	scriptsApp:
		cwd: "#{SRC}/scripts"
		dest: "#{DIST}/js/app"
		main: "#{SRC}/scripts/app.coffee"
		src: [
			"#{SRC}/scripts/app.coffee"
			"#{SRC}/scripts/**/*.coffee"
		]


	stylesApp:
		cwd: "#{SRC}/styles"
		dest: "#{DIST}/css/app"
		main: "#{SRC}/styles/app.styl"
		src: [
			"#{SRC}/styles/**/*.styl"
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


	copy: [
		src: "#{SRC}/favicon.ico"
		dest: "#{DIST}"
	]
