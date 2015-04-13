.PHONY: clean build

clean:
	rm -f frontend/assets/*
	rm -f plugin.zip

build: clean
	cd frontend && npm install
	cd frontend && bower install
	cd frontend && webpack --config webpack/release.config.js
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