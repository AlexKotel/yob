app = angular.module('app', ['ibv'])

app.controller 'AppController',

	class AppController

		constructor: ->

			@user =
				name: ''
				city: 0

			@user =
				name: 3
				city: 2

			@select =
				names: []
				cities: []

			# Names
			@select.names.push(val: 1, key: 'Vasya')
			@select.names.push(val: 2, key: 'Slava')
			@select.names.push(val: 3, key: 'Denchik')

			# Cities
			@select.cities.push(val: 1, key: 'Paris')
			@select.cities.push(val: 2, key: 'Moscow')
			@select.cities.push(val: 3, key: 'London')

		resetName: =>
			@user.name = ''

		resetCity: =>
			@user.city = ''

		addNames: =>
			@select.names.push(val: 4, key: 'Max')
			@select.names.push(val: 5, key: 'Klim')
			@select.names.push(val: 6, key: 'Taran')


# """
# 	<ul class="dropdown-menu" style="max-height:300px;overflow-y:scroll">
# 		<li
# 			ng-repeat="item in items"
# 			ng-click="cancelClose($event)"
# 			ng-class="{red: hover,blue:setCheckboxChecked(item)}"
# 			ng-mouseenter="hover = true"
# 			ng-mouseleave="hover = false">
#
# 		    <div class="input-group">
# 		    	<input
# 		    		type="checkbox"
# 		    		ng-checked="setCheckboxChecked(item)"
# 		    		ng-click="selectVal(item,$index)">
# 		    	<a href=""  tabindex="-1" > {{item[textField]}}</a>
# 		    </div>
#
# 	    </li>
# 	</ul>
# """




