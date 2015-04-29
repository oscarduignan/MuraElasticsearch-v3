var webpack = require('webpack');
var path    = require('path');
var context = path.dirname(__dirname);

module.exports = {
    devtool: 'eval',
    debug: true,
    context: context,
    entry: {
        admin: [
            'webpack-dev-server/client?http://localhost:8080',
            'webpack/hot/only-dev-server',
            path.join(context, 'src', 'js', 'admin.jsx'),
        ]
    },
    output: {
        filename: '[name].js',
        path: path.join(context, 'dist'),
        publicPath: 'http://localhost:8080/dist/',
    },
    resolve: {
        extensions: ['', '.js', '.jsx'],
        root: [
            path.join(context, 'src', 'js'),
            path.join(context, 'src', 'sass'),
        ]
    },
    module: {
        loaders: [
            { test: /\.jsx?$/, loader: 'react-hot!babel', include: path.join(context, 'src', 'js') },
            { test: /\.s?css$/, loader: 'style!css!sass' },
        ]
    },
    plugins: [
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoErrorsPlugin(),
    ],
    devServer: {
        info: false,
        hot: true,
        inline: true,
        stats: {
            colors: true,
        },
    },
}