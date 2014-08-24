sequence = require('run-sequence')
argv = require('optimist').argv
gulp = require('./gulp')()
fs = require('fs')


gulp.task 'default', ->

	sequence.apply @, [

		'clean'

		'sprite-png'

		[
			'img'
			'font'
			'views'
			'copy'
		]

		'inject'

		'pages'

		[
			'watch'
			'browsersync'
			'server'
		]

	]
