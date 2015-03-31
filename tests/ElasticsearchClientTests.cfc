component extends="testbox.system.BaseSpec" {

    function beforeTests() {
        param name="url.host" default="localhost:9200";

        es = new MuraElasticsearch.MuraElasticsearch().getBean("ElasticsearchClient").setHost(url.host);
    }

    function setUp() {
        indices = []
        for(var i=1;i<2;i++) { indices[i] = "test_index_" & lcase(createUUID()); }
    }

    private function removeTestIndices() {
        for(var index in indices) {
            es.deleteIndex(name=index, ignore="404");
        }
    }

    function test_createIndex_and_indexExists_and_deleteIndex() {
        try {

            es.createIndex(name=indices[1]);
            $assert.isTrue(es.indexExists(name=indices[1]));
            es.deleteIndex(name=indices[1]);
            $assert.isFalse(es.indexExists(name=indices[1]));

        } finally { removeTestIndices(); }
    }

    function test_insertDocument_and_documentExists_and_removeDocument() {
        try {

            es.createIndex(name=indices[1]);

            es.insertDocument(
                index=indices[1],
                type="test",
                id=1,
                body={}
            );

            $assert.isTrue(es.documentExists(
                index=indices[1],
                type="test",
                id=1
            ));

            es.removeDocument(
                index=indices[1],
                type="test",
                id=1
            );

            $assert.isFalse(es.documentExists(
                index=indices[1],
                type="test",
                id=1
            ));
        } finally {
            removeTestIndices();
        }
    }

    function test_searchAndReplace() {
        try {

            es.createIndex(name=indices[1]);

            es.insertDocument(
                index=indices[1],
                type="test",
                id=1,
                body={ "path1"="a/b/c/d/e" }
            );

            es.insertDocument(
                index=indices[1],
                type="test",
                id=2,
                body={ "path1"="a/b/c/d/e", "path2"="a/b/c/d/e", "path3"="a/b/c/d/e" }
            );

            es.refreshIndex(indices[1]);

            es.searchAndReplace(
                index=indices[1],
                type="test",
                body={
                    "query"={
                        "match_all"={}
                    }
                },
                fields="path1,path2",
                regex="c/d",
                substring="x/y",
                scope="all"
            );

            var doc1 = es.getDocument(indices[1], "test", 1).toJSON();
            var doc2 = es.getDocument(indices[1], "test", 2).toJSON();

            $assert.isEqual(
                "a/b/x/y/e",
                doc1["_source"]["path1"]
            );

            $assert.isEqual(
                "a/b/x/y/e",
                doc2["_source"]["path1"]
            );

            $assert.isEqual(
                "a/b/x/y/e",
                doc2["_source"]["path2"]
            );

            $assert.isEqual(
                "a/b/c/d/e",
                doc2["_source"]["path3"]
            );

        } finally { removeTestIndices(); }
    }

}