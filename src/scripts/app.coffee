$.ajax
	type: 'GET'
	url: '/test'
	success: (res) ->
		console.log res
		$('body').hide().fadeIn(1000)