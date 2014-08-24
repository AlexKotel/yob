paths = require('../paths')
rimraf = require('rimraf')

module.exports = (cb) ->
	rimraf(paths.dist, cb)
