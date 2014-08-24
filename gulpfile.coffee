sequence = require('run-sequence')
argv = require('optimist').argv
gulp = require('./gulp')()
fs = require('fs')


gulp.task 'default', ->

	sequence.apply @, [

		'clean'

		# 'iconfont'
		# 'sprite-png'
		# 'sprite-svg'

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
