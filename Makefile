.PHONY: clean webpack_dev_server build install

clean:
	rm -f frontend/assets/*
	rm -f plugin.zip

webpack_dev_server: clean
	frontend/node_modules/.bin/webpack-dev-server --config frontend/webpack/default.config.js --hot --no-info --progress --colors

install:
	cd frontend && npm install
	cd frontend && bower install

build: clean install
	cd frontend && frontend/node_modules/.bin/webpack --config webpack/release.config.js
	cd .. && zip -r MuraElasticsearch/plugin.zip \
					MuraElasticsearch/model \
					MuraElasticsearch/frontend/assets \
					MuraElasticsearch/frontend/display_objects \
					MuraElasticsearch/vendor \
					MuraElasticsearch/plugin \
					MuraElasticsearch/migrations \
					MuraElasticsearch/MuraElasticsearch.cfc \
					MuraElasticsearch/EventHandler.cfc \
					MuraElasticsearch/LICENSE \
					MuraElasticsearch/index.cfm