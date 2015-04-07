component extends="testbox.system.BaseSpec" {
    include template="muraTestHelpers.cfm";

    function beforeTests() {
        param name="url.host" default="localhost:9200";

        plugin = new MuraElasticsearch.MuraElasticsearch(application.serviceFactory);

        siteIndexer = plugin.getBean("SiteIndexer");

        esClient = plugin.getBean("ElasticsearchClient").setHost(url.host);
        esService = plugin.getBean("ElasticsearchService");

        esClient.createIndex(name="default", body={
            "aliases"={
                "#esService.getWriteAliasName("default")#"={}
            }
        }, ignore="400");
    }

    function afterTests() {
        clearDefaultSiteTrash();

        esClient.deleteIndex(name="default", ignore="404");
    }

}