var webpack = require('webpack');
var path = require('path');
var _ = require('lodash');
var config = module.exports = require('./default.config.js');

config = _.merge(config, {
    debug: true,
    displayErrorDetails: true,
    outputPathinfo: true,
    devtool: 'sourcemap',
});

config.module = {
    loaders: [
        { test: /\.js$/,   loader: "babel-loader" },
        { test: /\.jsx$/,  loader: "react-hot-loader!babel-loader" },
        { test: /\.scss$/, loader: "style-loader!css-loader!sass-loader" + 
                                   "?includePaths[]=" + path.join(config.context, "node_modules") +
                                   "&includePaths[]=" + path.join(config.context, "bower_components") }
    ]
};

config.devServer = {
    contentBase: 'frontend/assets',
    info: false,
    hot: true,
    inline: true,
    stats: {
        cached: false,
        exclude: [
            /node_modules[\\\/]react(-router)?[\\\/]/,
        ]
    }
};

config.plugins.push(
    new webpack.NoErrorsPlugin()
);