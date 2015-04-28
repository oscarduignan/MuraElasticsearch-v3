var webpack = require('webpack');
var path    = require('path');
var context = path.dirname(__dirname);

module.exports = {
    context: context,
    entry: {
        admin: path.join(context, 'src', 'js', 'admin.jsx'),
    },
    output: {
        filename: '[name]-[chunkhash].js',
        path: path.join(context, 'dist'),
    },
    resolve: {
        extensions: ['', '.js', '.jsx'],
        root: [
            path.join(context, 'src', 'js'),
            path.join(context, 'src', 'sass'),
        ],
    },
    module: {
        loaders: [
            { test: /\.jsx?$/, loader: 'babel', include: path.join(context, 'src', 'js') },
            { test: /\.s?css$/, loader: 'style!css!sass' },
        ]
    },
    plugins: [
        new webpack.PrefetchPlugin("react"),
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                warnings: false
            }
        }),
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
                    path.join(context, "dist", "manifest.json"),
                    JSON.stringify(stats.toJson().assetsByChunkName)
                )
            });
        }
    ]
}