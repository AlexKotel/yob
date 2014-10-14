app = angular.module('app', [])


class AppController
	constructor: ->
		console.log '[app] started'


angular.module('app').controller 'AppController', AppController
