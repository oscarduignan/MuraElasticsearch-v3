var path = require('path');
var webpack = require('webpack');

var config = module.exports = {
    context: path.dirname(__dirname),
}

config.entry = {
    admin: './javascripts/admin'
};

config.output = {
    filename: '[name].bundle.js',
    path: path.join(config.context, 'assets')
};

config.resolve = {
    extensions: ['', '.js', '.jsx'],
    root: [
        path.join(config.context, 'javascripts'),
        path.join(config.context, 'stylesheets')
    ],
    modulesDirectories: [ 'node_modules', 'bower_components' ], 
};

config.plugins = [
    new webpack.ResolverPlugin([
        new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin('.bower.json', ['main'])
    ])
];