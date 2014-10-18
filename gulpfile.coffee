sequence = require('run-sequence')
argv = require('optimist').argv
gulp = require('./gulp')()
fs = require('fs')


gulp.task 'default', ->

	console.time('Build time:')

	sequence.apply @, [

		'clean'

		'sprite-png'

		[
			'img'
			'font'
			'copy'
			'views'
		]

		# [
		# 	'styles-app'
		# 	'styles-dep'
		# 	'scripts-app'
		# 	'scripts-dep'
		# ]

		'inject'

		'pages'

		[
			'watch'
			'browsersync'
			'server'
		]

		-> console.timeEnd('Build time:')

	]
