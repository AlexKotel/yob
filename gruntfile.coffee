TIMESTAMP = Date.now()
DIST = 'dist'
SRC = 'src'

module.exports = (grunt) ->


	require('load-grunt-tasks')(grunt)


	grunt.initConfig


		copy:

			svg:

				files: [
					expand: true
					cwd: "#{SRC}/tools/svgsprite/dist/svg"
					src: '*.svg'
					dest: "#{SRC}/assets/img"
				,
					expand: true
					cwd: "#{SRC}/tools/svgsprite/dist"
					src: '*.css'
					dest: "#{SRC}/styles/tools"
					ext: '.styl'
				]

			font:

				files: [
					expand: true
					cwd: "#{SRC}/tools/iconfont/dist"
					src: '*.{woff,ttf,eot,svg}'
					dest: "#{SRC}/assets/font"
				,
					expand: true
					cwd: "#{SRC}/tools/iconfont/dist"
					src: '*.css'
					dest: "#{SRC}/styles/tools"
					ext: '.styl'
				]


		svgmin:

			svg:

				expand: true
				cwd: "#{SRC}/tools/svgsprite/src"
				src: '*.svg'
				dest: "#{SRC}/tools/svgsprite/optimized"

			font:

				expand: true
				cwd: "#{SRC}/tools/iconfont/src"
				src: '*.svg'
				dest: "#{SRC}/tools/iconfont/optimized"


		webfont:

			font:

				options:
					font: "iconfont-#{TIMESTAMP}"
					engine: 'node'
					hashes: false
					htmlDemo: false
					relativeFontPath: '../assets/font'
					templateOptions:
						baseClass: 'fi'
						classPrefix: 'fi-'
				src: "#{SRC}/tools/iconfont/optimized/*.svg"
				dest: "#{SRC}/tools/iconfont/dist"
				destCss: "#{SRC}/tools/iconfont/dist"


		svgsprite:

			svg:

				src: "#{SRC}/tools/svgsprite/optimized/"
				dest: "#{SRC}/tools/svgsprite/dist"
				options:
					dims: true
					common: 'svg'
					sprite: "sprite-#{TIMESTAMP}"
					render:
						css:
							dest: 'sprite-svg.css'


	grunt.registerTask 'svg', [
		'svgmin:svg'
		'svgsprite'
		'copy:svg'
	]


	grunt.registerTask 'font', [
		'svgmin:font'
		'webfont'
		'copy:font'
	]


	grunt.registerTask 'default', []
