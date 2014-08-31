paths = require('../paths')
argv = require('optimist').argv
gulp = require('gulp')



$ =
	if: require('gulp-if')
	rename: require('gulp-rename')
	imagemin: require('gulp-imagemin')
	spritesmith: require('gulp.spritesmith')


module.exports = ->

	timestamp = Date.now()

	config =
		algorithm: 'binary-tree'
		imgName: 'sprite.png'
		imgPath: '/img/sprite.png'
		cssName: 'sprite-png.css'
		cssOpts:
			cssClass: (item) -> ".i.i-#{item.name}"

	stream = gulp.src("#{paths.src}/tools/sprite-png/src/*.png")
		.pipe $.if(argv.prod, $.imagemin())
		.pipe gulp.dest("#{paths.src}/tools/sprite-png/optimized")
		.pipe $.spritesmith(config)

	stream.css
		.pipe $.rename('sprite-png.styl')
		.pipe gulp.dest("#{paths.stylesApp.cwd}/tools")

	stream.img
		.pipe gulp.dest(paths.img.cwd)