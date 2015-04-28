.PHONY: clean run_webpack_dev_server install_build_dependencies build_release

clean:
	rm -f client/dist/*
	rm -f plugin.zip

run_webpack_dev_server: clean install_build_dependencies
	client/node_modules/.bin/webpack-dev-server --config client/webpack/dev.config.js

install_build_dependencies:
	cd client && npm install
	cd client && bower install

build_release: clean install_build_dependencies
	client/node_modules/.bin/webpack --config client/webpack/dev.config.js -p
	cd .. && zip -r MuraElasticsearch/plugin.zip \
					MuraElasticsearch/model \
					MuraElasticsearch/client/dist \
					MuraElasticsearch/vendor \
					MuraElasticsearch/plugin \
					MuraElasticsearch/migrations \
					MuraElasticsearch/MuraElasticsearch.cfc \
					MuraElasticsearch/EventHandler.cfc \
					MuraElasticsearch/LICENSE \
					MuraElasticsearch/index.cfm