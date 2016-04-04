var webpack = require('webpack');
var ExtractText = require('extract-text-webpack-plugin');

module.exports = {
	context: __dirname,
	entry: [
		'webpack/hot/dev-server',
		'webpack-hot-middleware/client',
		'./public/js/site.coffee'
	],
	module: {
		loaders: [
			{ test:/\.css$/, loader:'style!css' },
			{ test:/\.coffee$/, loader:'coffee-loader' },
			{ test:/\.styl$/, loader:'style-loader!css-loader!stylus-loader' }
		]
	},
	output: {
		path: __dirname,
		publicPath: '/public/build/',
		filename: 'bundle.js'
	},
	plugins: [
		new webpack.optimize.OccurenceOrderPlugin(),
		new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin()
	]
};
