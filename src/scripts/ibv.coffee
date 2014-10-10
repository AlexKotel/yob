ibv = angular.module('ibv', [])

ibv.directive 'ibvSelect', ($timeout) ->

	restrict: 'E'
	require: '^ngModel'
	templateUrl: "views/ibv-select.html"
	scope:
		ngModel: '='
		options: '='
		valField: '@'
		keyField: '@'
		placeholder: '@'

	link: (scope, el, attrs, ngModelCtrl) ->

		valField = scope.valField.toString().trim()
		keyField = scope.keyField.toString().trim()

		scope.$watch 'ngModel', -> scope.setLabel()

		scope.setLabel = ->
			if (typeof scope.ngModel is 'undefined') or (!scope.ngModel)
				scope.label = scope.placeholder
				return

			for option in scope.options
				if option[valField] is ngModelCtrl.$modelValue
					scope.label = scope.getOptionKey(option)

		scope.selectVal = (option) ->
			ngModelCtrl.$setViewValue(option[valField])

		scope.getOptionKey = (option) ->
			option[keyField]

		scope.getOptionSelected = (option) ->
			return true if option[keyField] is scope.label
