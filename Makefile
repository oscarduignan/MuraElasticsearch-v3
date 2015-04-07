.PHONY: clean build

clean:
	rm -f plugin.zip

build: clean
	cd .. && zip -r MuraElasticsearch/plugin.zip \
					MuraElasticsearch/model \
					MuraElasticsearch/tests \
					MuraElasticsearch/vendor \
					MuraElasticsearch/plugin \
					MuraElasticsearch/migrations \
					MuraElasticsearch/MuraElasticsearch.cfc \
					MuraElasticsearch/EventHandler.cfc \
					MuraElasticsearch/LICENSE \
					MuraElasticsearch/index.cfm