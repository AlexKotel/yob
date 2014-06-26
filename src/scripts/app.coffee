# angular = require 'angular'
# $ = require 'jquery'

$ ->
	$('body')
		.hide()
		.fadeIn(2000)

angular.module 'app', []

angular.module('app').controller 'AppCtrl', ->
	console.log 'App started'