require('angular-animate')
require('angular-touch')
require('angular-ui-router')

module.exports = angular.module('app', [
	'ngAnimate'
	'ngTouch'
	'ui.router'
])
.controller 'AppController', require('./controllers/AppController')
