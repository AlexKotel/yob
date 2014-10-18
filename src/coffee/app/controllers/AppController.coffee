class AppController

	constructor: (@$http)->
		console.log '[app] started'

		$http(url: "/test").then (res) ->
			console.log res.data

module.exports = AppController
