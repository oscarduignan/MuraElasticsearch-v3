component extends="testbox.system.BaseSpec" {

    function beforeTests() {
        param name="url.host" default="localhost:9200";

        es = (
            getMockBox()
                .prepareMock(new MuraElasticsearch.MuraElasticsearch().getBean("ElasticsearchService"))
                    .$("getHost", url.host)
        );
    }

    function setUp() {
        indices = []
        for(var i=1;i<=2;i++) { indices[i] = "test_index_" & lcase(createUUID()); }
    }

    function test_getAliasForSite_returns_empty_array_when_no_indices_have_that_alias() {
        $assert.isEqual([], es.getAliasForSite("test_alias_" & lcase(createUUID())));
    }

    function test_getAliasForSite_returns_array_of_indices_with_the_alias() {
        var esClient = es.getClientForHost(url.host);
        var alias = "test_alias_" & lcase(createUUID());

        esClient.createIndex(name=indices[1], body={
            "aliases"={
                "#alias#"={}
            }
        });

        esClient.createIndex(name=indices[2], body={
            "aliases"={
                "#alias#"={}
            }
        });

        var aliasIndices = es.getAliasForSite(alias);

        for(var index in indices) {
            esClient.deleteIndex(name=index, ignore="404");
        }

        $assert.includes(aliasIndices, indices[1]);
        $assert.includes(aliasIndices, indices[2]);
        $assert.isEqual(2, arrayLen(aliasIndices));
    }

    function test_getWriteAliasName_returns_alias_with_correct_suffix() {
        $assert.isEqual("test_write", es.getWriteAliasName("test"));
    }

    function test_getClientForHost_returns_instance_of_ElasticsearchClient_with_host_set() {
        var esClient1 = es.getClientForHost("localhost:9200");
        var esClient2 = es.getClientForHost("localhost:9300");

        $assert.instanceOf(esClient1, "ElasticsearchClient");
        $assert.isEqual("localhost:9200", esClient1.getHost());

        $assert.instanceOf(esClient2, "ElasticsearchClient");
        $assert.isEqual("localhost:9300", esClient2.getHost());
    }

}