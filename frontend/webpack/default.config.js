var path = require('path');
var webpack = require('webpack');

var config = module.exports = {
    devtool: 'eval',
    context: path.dirname(__dirname),
};

config.entry = {
    admin: [
        'webpack-dev-server/client?http://localhost:8080',
        'webpack/hot/only-dev-server',
        './javascripts/admin'
    ]
};

config.output = {
    filename: '[name].js',
    path: path.join(config.context, 'assets'),
    publicPath: 'http://localhost:8080/assets/'
};

config.resolve = {
    extensions: ['', '.js', '.jsx'],
    root: [
        path.join(config.context, 'javascripts'),
        path.join(config.context, 'stylesheets')
    ]
};

config.module = {
    loaders: [
        {
            test: /\.jsx?$/,
            include: path.join(config.context, "javascripts"),
            loaders: ["react-hot", "babel"]
        },
        {
            test: /\.scss$/,
            loaders: ["style", "css", "sass"]
        }
    ]
};

config.plugins = [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin()
];
