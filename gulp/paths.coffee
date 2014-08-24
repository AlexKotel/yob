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


	img:
		dest: "#{config.dist}/assets/img"
		cwd: "#{config.src}/assets/img"
		src: ["#{config.src}/assets/img/**/*.{png,jpg,jpeg,gif,svg}"]


	font:
		dest: "#{config.dist}/assets/font"
		cwd: "#{config.src}/assets/font"
		src: ["#{config.src}/assets/font/**/*.{woff,ttf,eot,svg}"]


	jade:
		injector: "#{config.src}/jade/base/root.jade"
		src: [
			"#{config.src}/jade/inc/**/*.jade"
			"#{config.src}/jade/base/**/*.jade"
			"!#{config.src}/jade/base/root.jade"
		]

	copy: [
		src: "#{config.src}/copy/favicon.ico"
		dest: "#{config.dist}"
	]
