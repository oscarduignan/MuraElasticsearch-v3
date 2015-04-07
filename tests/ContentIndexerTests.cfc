component extends="testbox.system.BaseSpec" {
    include template="muraTestHelpers.cfm";

    function beforeTests() {
        param name="url.host" default="localhost:9200";

        plugin = new MuraElasticsearch.MuraElasticsearch(application.serviceFactory);

        contentIndexer = plugin.getBean("ContentIndexer");

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

    function test_getDefaultContentStruct_returns_the_expected_structure() {
        try {
            var content = createContent({
                title="testTitle",
                body="testBody",
                summary="testSummary",
                tags="a,b,c",
                metaDesc="testMetaDesc",
                metaKeywords="testMetaKeywords",
                active=1
            });

            var contentStruct = contentIndexer.getDefaultContentStruct(content);

            $assert.isEqual(content.getContentID(), contentStruct["contentID"]);
            $assert.isEqual(content.getTitle(), contentStruct["title"]);
            $assert.isEqual("Page", contentStruct["type"]);
            $assert.isEqual("Default", contentStruct["subType"]);
            $assert.isEqual(content.getBody(), contentStruct["body"]);
            $assert.isEqual(content.getSummary(), contentStruct["summary"]);
            $assert.isEqual("", contentStruct["file"]);
            $assert.isEqual(listToArray(content.getTags()), contentStruct["tags"]);
            $assert.isEqual(content.getUrl(), contentStruct["url"]);
            $assert.isEqual(esService.formatDatetime(content.getCreated()), contentStruct["created"]);
            $assert.isEqual(esService.formatDatetime(content.getLastUpdate()), contentStruct["lastUpdate"]);
            $assert.isEqual(content.getFilename(), contentStruct["filename"]);
            $assert.isEqual(content.getMetaDesc(), contentStruct["metaDesc"]);
            $assert.isEqual(content.getMetaKeywords(), contentStruct["metaKeywords"]);
        } finally {
            if(isDefined("local.content") and not content.getIsNew()) {
                content.delete();
            }
        }
    }

    function test_getContentJSON_returns_json_serialized_defaultContentStruct_when_not_overriden() {
        try {
            var content = createContent({
                title="testTitle",
                body="testBody",
                summary="testSummary",
                tags="a,b,c",
                metaDesc="testMetaDesc",
                metaKeywords="testMetaKeywords",
                active=1
            });

            var serializedDefaultContentStruct = serializeJSON(contentIndexer.getDefaultContentStruct(content));

            $assert.isEqual(serializedDefaultContentStruct, contentIndexer.getContentJSON(content, getMuraScope("default")));
        } finally {
            if(isDefined("local.content") and not content.getIsNew()) {
                content.delete();
            }
        }
    }

    function test_getContentJSON_returns_getElasticsearchContentJSON_when_its_defined_on_the_sites_contentrenderer() {
        try {
            var content = createContent();

            var $ = (
                getMockBox()
                    .prepareMock(getMuraScope("default"))
                        .$("getElasticsearchContentJSON", "test")
            );

            $assert.isEqual("test", contentIndexer.getContentJSON(content, $));
        } finally {
            if(isDefined("local.content") and not content.getIsNew()) {
                content.delete();
            }
        }
    }

    function test_shouldIndex_returns_true_when_content_should_be_indexed() {
        $assert.isTrue(contentIndexer.shouldIndex(newContent({}), getMuraScope("default")));
    }

    function test_shouldIndex_returns_false_when_content_should_not_be_indexed() {
        $assert.isFalse(contentIndexer.shouldIndex(newContent({searchExclude=1, display=0}), getMuraScope("default")));
    }

    function test_shouldIndex_returns_getElasticsearchShouldIndex_when_its_defined_on_the_sites_contentrenderer() {
        var $ = (
            getMockBox()
                .prepareMock(getMuraScope("default"))
                    .$("getElasticsearchShouldIndex", false)
        );

        $assert.isFalse(contentIndexer.shouldIndex(newContent({}), $));
    }

    function test_updateContent_should_index_content_that_should_be_indexed_and_is_approved() {
        try {
            var content = createContent();

            contentIndexer.updateContent(content);

            esClient.refreshIndex("default");

            $assert.isTrue(esClient.documentExists(
                "default",
                contentIndexer.getType(),
                content.getContentID()
            ));
        } finally {
            if(isDefined("local.content") and not content.getIsNew()) {
                content.delete();
            }
        }
    }

    function test_updateContent_should_not_index_content_that_should_be_indexed_but_is_not_approved() {
        try {
            var content = createContent({
                approved=0 // means it's a draft!
            });

            contentIndexer.updateContent(content);

            esClient.refreshIndex("default");

            $assert.isFalse(esClient.documentExists(
                "default",
                contentIndexer.getType(),
                content.getContentID()
            ));
        } finally {
            if(isDefined("local.content") and not content.getIsNew()) {
                content.delete();
            }
        }
    }

    function test_removeContent_should_remove_content_from_index() {
        try {
            var content = createContent();

            contentIndexer.updateContent(content);

            $assert.isTrue(esClient.documentExists(
                "default",
                contentIndexer.getType(),
                content.getContentID()
            ));

            contentIndexer.removeContent(content);

            esClient.refreshIndex("default");

            $assert.isFalse(esClient.documentExists(
                "default",
                contentIndexer.getType(),
                content.getContentID()
            ));
        } finally {
            if(isDefined("local.content") and not content.getIsNew()) {
                content.delete();
            }
        }
    }

    function test_updateContent_should_remove_content_from_index_that_should_not_be_indexed() {
        try {
            var content = createContent();

            contentIndexer.updateContent(content);

            $assert.isTrue(esClient.documentExists(
                "default",
                contentIndexer.getType(),
                content.getContentID()
            ));

            content.setSearchExclude(1).save();

            contentIndexer.updateContent(content);

            esClient.refreshIndex("default");

            $assert.isFalse(esClient.documentExists(
                "default",
                contentIndexer.getType(),
                content.getContentID()
            ));
        } finally {
            if(isDefined("local.content") and not content.getIsNew()) {
                content.delete();
            }
        }
    }

    function test_updateContent_should_update_filenames_of_indexed_content_when_oldFilename_is_present_and_changed() {
        try {
            // create content to test with and index it
            var content1 = createContent({
                title="first-title"
            });
            var content2 = createContent({
                parentID=content1.getContentID(),
                title="second-title"
            });
            contentIndexer.updateContent(content1);
            contentIndexer.updateContent(content2);

            // update filename and index the updated content
            var updatedContent = (
                getContent(content1.getContentID())
                    .setURLTitle("first-title-change")
                    .setApproved(1)
                    .save()
                    .setOldFilename("first-title") // mimic behaviour of onContentSave() event
            );
            contentIndexer.updateContent(updatedContent);

            esClient.refreshIndex("default");

            $assert.isEqual(updatedContent.getFilename(), esClient.getDocument(
                "default",
                contentIndexer.getType(),
                content1.getContentID()
            ).toJSON()["_source"]["filename"]);

            $assert.isEqual(getContent(content2.getContentID()).getFilename(), esClient.getDocument(
                "default",
                contentIndexer.getType(),
                content2.getContentID()
            ).toJSON()["_source"]["filename"]);
        } finally {
            if(isDefined("local.content1") and not content1.getIsNew()) {
                content1.delete();
            }
            if(isDefined("local.content2") and not content2.getIsNew()) {
                content2.delete();
            }
        }
    }

}