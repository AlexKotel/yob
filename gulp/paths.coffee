config = require('../config')

module.exports =


	src: config.src
	dist: config.dist


	scriptsDep:
		dest: "#{config.dist}/js/dep"
		src: [
			'bower_components/jquery/dist/jquery.js'
			'bower_components/lodash/dist/lodash.js'
			'bower_components/bootstrap/dist/js/bootstrap.js'
		]


	stylesDep:
		dest: "#{config.dist}/css/dep"
		src: [
			'bower_components/bootstrap/dist/css/bootstrap.css'
		]


	scriptsApp:
		cwd: "#{config.src}/scripts"
		dest: "#{config.dist}/js/app"
		main: "#{config.src}/scripts/app.coffee"
		src: [
			"#{config.src}/scripts/app.coffee"
			"#{config.src}/scripts/**/*.coffee"
		]


	stylesApp:
		cwd: "#{config.src}/styles"
		dest: "#{config.dist}/css/app"
		main: "#{config.src}/styles/app.styl"
		src: [
			"#{config.src}/styles/**/*.styl"
		]


	pages:
		cwd: "#{config.src}/jade/pages"
		dest: "#{config.dist}"
		src: ["#{config.src}/jade/pages/**/*.jade"]


	views:
		dest: "#{config.dist}/views"
		cwd: "#{config.src}/views"
		src: ["#{config.src}/jade/views/**/*.jade"]


	jade:
		injector: "#{config.src}/jade/base/root.jade"
		src: ["#{config.src}/jade/base/**/*.jade"]


	img:
		dest: "#{config.dist}/img"
		cwd: "#{config.src}/img"
		src: ["#{config.src}/img/**/*.{png,jpg,jpeg,gif,svg}"]


	font:
		dest: "#{config.dist}/font"
		cwd: "#{config.src}/font"
		src: ["#{config.src}/font/**/*.{woff,ttf,eot,svg}"]


	copy: [
		src: "#{config.src}/favicon.ico"
		dest: "#{config.dist}"
	]
