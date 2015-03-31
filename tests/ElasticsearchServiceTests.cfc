component extends="testbox.system.BaseSpec" {

    function beforeTests() {
        es = new MuraElasticsearch.MuraElasticsearch().getBean("ElasticsearchService");
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