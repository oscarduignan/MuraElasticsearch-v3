var webpack = require('webpack');
var path    = require('path');
var context = path.dirname(__dirname);

module.exports = {
    devtool: 'eval',
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
    },
    module: {
        loaders: [
            {
                test: /\.jsx?$/,
                include: path.join(context, 'src', 'js'),
                loaders: ['react-hot', 'babel'],
            },
            {
                test: /\.s?css$/,
                loaders: ['style', 'css', 'sass'],
            }
        ]
    },
    plugins: [
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoErrorsPlugin(),
    ],
    devServer: {
        contentBase: path.join(context, 'dist'),
        info: false,
        hot: true,
        inline: true,
        stats: {
            colors: true,
        },
    },
}