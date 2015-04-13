var webpack = require('webpack');
var path = require('path');
var _ = require('lodash');
var config = module.exports = require('./default.config.js');

config.output = _.merge(config.output, {
    filename: '[name]-[chunkhash].bundle.js',
    chunkFilename: '[id]-[chunkhash].bundle.js',
});

config.module = {
    loaders: [
        { test: /\.jsx?$/, loader: "babel-loader" },
        { test: /\.scss$/, loader: "style-loader!css-loader!sass-loader" + 
                                   "?includePaths[]=" + path.join(config.context, "node_modules") +
                                   "&includePaths[]=" + path.join(config.context, "bower_components") }
    ]
};

config.plugins.push(
    new webpack.optimize.UglifyJsPlugin(),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.DedupePlugin(),
    new webpack.DefinePlugin({
        "process.env": {
            NODE_ENV: JSON.stringify("production")
        }
    }),
    new webpack.NoErrorsPlugin(),
    function() {
        this.plugin("done", function(stats) {
            require("fs").writeFileSync(
                path.join(config.context, "assets", "manifest.json"),
                JSON.stringify(stats.toJson().assetsByChunkName)
            )
        });
    }
);