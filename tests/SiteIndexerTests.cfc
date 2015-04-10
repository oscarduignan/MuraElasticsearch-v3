component extends="testbox.system.BaseSpec" {
    include template="muraTestHelpers.cfm";

    function beforeTests() {
        param name="url.host" default="localhost:9200";

        plugin = new MuraElasticsearch.MuraElasticsearch(application.serviceFactory);

        siteIndexer = plugin.getBean("SiteIndexer");

        esClient = plugin.getBean("ElasticsearchClient").setHost(url.host);
        esService = plugin.getBean("ElasticsearchService");
    }

    function afterTests() {
        clearDefaultSiteTrash();
    }

    function test_getIndexConfigJSON_returns_getElasticsearchIndexConfigJSON_when_its_defined_on_the_contentrenderer() {
        var uuid = createUUID();

        $assert.isEqual(uuid, siteIndexer.getIndexConfigJSON(
            getMockBox()
                .prepareMock(getMuraScope("default"))
                    .$("getElasticsearchIndexConfigJSON", uuid)
        ));
    }

    function test_getIndexConfigJSON_returns_serialized_getDefaultIndexConfigStruct_when_getElasticsearchIndexConfigJSON_is_not_defined() {
        $assert.isEqual(
            serializeJSON(siteIndexer.getDefaultIndexConfigStruct("default")),
            siteIndexer.getIndexConfigJSON(getMuraScope("default"))
        );
    }

    function test_indexSite_should_index_all_site_content_to_a_new_index_and_switch_sites_alias_to_use_new_index_when_complete() {
        try {
            var siteContent = getSiteContentIterator();
            var siteIndexer = getMockBox().prepareMock(siteIndexer).$("getSiteContentIterator", siteContent[2]);
            var newIndexName = plugin.getBean("SiteIndexStatusService").getNewIndex(siteIndexer.indexSite(getMuraScope("default")));
            var indices = structKeyArray(esClient.getAlias(alias="default").toJSON());
            $assert.isEqual([newIndexName], indices);
            esClient.refreshIndex("default");
            var elasticsearchContent = esClient.search(index="default", body={
                "query"={
                    "match_all"={}
                } 
            }).toJSON();
            $assert.isEqual(5, elasticsearchContent["hits"]["total"]);
        } finally {
            if (isDefined("newIndexName")) {
                esClient.deleteIndex(name=newIndexName, ignore="404");
            }

            for (var i=1; i LTE ArrayLen(siteContent[1]); i++) {
                siteContent[1][i].delete();
            }
        }
    }

    // siteIndexer
        // indexsite
            // should let you override content to index with content renderer
            // should let you override index settings with content renderer
            // should let you override if content should be indexed with content renderer
            // should let you override the default host with a site setting
            // should index the content in the site iterator that should be indexed
            // should not index the content in the site iterator that should not be indexed
            // should change update site alias when compeled indexing
            // should be able to cancel indexing
            // triggering it while another index is in progress should cancel the other index
            // should log the results of the index in the database
                // totalIndexed
                // newIndex
                // status
                // startedAt
                // completedAt
            // should reset write alias too

    function getSiteContentIterator() {
        var uuid = createUUID();

        var content = [
            createContent({tags=uuid}),
            createContent({tags=uuid}),
            createContent({tags=uuid}),
            createContent({tags=uuid}),
            createContent({tags=uuid})
        ];

        return [content, (
            getMuraBean("feed")
                .setSiteID("default")
                .addParam(
                    field='tcontenttags.tag',
                    condition='CONTAINS',
                    dataType='varchar',
                    criteria=uuid
                )
                .getIterator()
                .setNextN(2)
        )];
    }

}