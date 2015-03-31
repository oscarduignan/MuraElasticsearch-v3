component extends="testbox.system.BaseSpec" {

    function beforeTests() {
        host = "#host#";

        elasticsearch = getMockBox().createMock("MuraElasticsearch.model.ElasticsearchClient").$(method="getHost", returns=host).$(method="makeHTTPRequest", callLogging=true);
    }

    /** SEARCH **************************************************************/

    function test_search_with_index_and_mapping() {
        elasticsearch.search(body={"query"="test"}, index="testIndex", type="testType");

        assertExpectedRequestIsMade(
            { method="post", url="#host#/testIndex/testType/_search", body={"query"="test"} },
            getLastHttpRequest()
        );
    }

    function test_search_with_index_and_no_mapping() {
        elasticsearch.search(body={"query"="test"}, index="testIndex");

        assertExpectedRequestIsMade(
            { method="post", url="#host#/testIndex/_search", body={"query"="test"} },
            getLastHttpRequest()
        );
    }

    function test_search_with_no_index_and_mapping() {
        elasticsearch.search(body={"query"="test"}, type="testType");

        assertExpectedRequestIsMade(
            { method="post", url="#host#/*/testType/_search", body={"query"="test"} },
            getLastHttpRequest()
        );
    }

    function test_search_with_no_index_and_no_mapping() {
        elasticsearch.search(body={"query"="test"});

        assertExpectedRequestIsMade(
            { method="post", url="#host#/_search", body={"query"="test"} },
            getLastHttpRequest()
        );
    }

    /** INDICES *************************************************************/

    function test_createIndex() {
        elasticsearch.createIndex(name="testIndex");

        assertExpectedRequestIsMade(
            { method="put", url="#host#/testIndex" },
            getLastHttpRequest()
        );
    }

    function test_createIndex_with_no_name()
        expectedException="expression" // missing parameter
    {
        elasticsearch.createIndex();
    }

    function test_deleteIndex() {
        elasticsearch.deleteIndex(name="testIndex");

        assertExpectedRequestIsMade(
            { method="delete", url="#host#/testIndex" },
            getLastHttpRequest()
        );
    }

    function test_deleteIndex_with_no_name()
        expectedException="expression" // missing parameter
    {
        elasticsearch.deleteIndex();
    }

    /** BULK ****************************************************************/

    function test_bulk_with_no_index_and_no_type() {
        elasticsearch.bulk(
            actions=[
                { "index"={ "_index"="testIndex", "_type"="testType", "_id"="1" } },
                { "field1"="value1" }
            ]
        );

        assertExpectedRequestIsMade(
            { method="post", url="#host#/_bulk", body='{"index":{"_id":"1","_index":"testIndex","_type":"testType"}}#chr(10)#{"field1":"value1"}#chr(10)#' },
            getLastHttpRequest()
        );
    }

    function test_bulk_with_index_and_no_type() {
        elasticsearch.bulk(
            index="testIndex",
            actions=[
                { "index"={ "_id"="1", "_type"="testType" } },
                { "field1"="value1" }
            ]
        );

        assertExpectedRequestIsMade(
            { method="post", url="#host#/testIndex/_bulk", body='{"index":{"_id":"1","_type":"testType"}}#chr(10)#{"field1":"value1"}#chr(10)#' },
            getLastHttpRequest()
        );
    }

    function test_bulk_with_index_and_type() {
        elasticsearch.bulk(
            index="testIndex",
            type="testType",
            actions=[
                { "index"={ "_id"="1" } },
                { "field1"="value1" }
            ]
        );

        assertExpectedRequestIsMade(
            { method="post", url="#host#/testIndex/testType/_bulk", body='{"index":{"_id":"1"}}#chr(10)#{"field1":"value1"}#chr(10)#' },
            getLastHttpRequest()
        );
    }

    /** TEST HELPERS ********************************************************/

    private function assertExpectedRequestIsMade(required expected, required actual) {
        for (var key in expected) {
            $assert.isEqual(expected[key], actual[key]);
        }
    }

    private function getLastHttpRequest() {
        return elasticsearch.$calllog().makeHTTPRequest[arrayLen(elasticsearch.$calllog().makeHTTPRequest)];
    }

}