component accessors=true {
    property name="ElasticsearchService";
    property name="ContentIndexer";
    property name="Utilities";
    property name="SiteIndexStatusService";
    property name="BeanFactory";

    public function indexSite(required siteID) {
        lock name="elasticIndexSite#siteID#" type="exclusive" timeout="10" {
            if (currentlyIndexing(siteID)) { return }

            var indexID = startIndexing(siteID);
        }

        var $ = getBeanFactory().getBean("MuraScope").init(siteID);

        var newIndex = createIndexForSite(siteID);

        var siteContent = getSiteContent(siteID);

        updateProgress(indexID, {
            newIndex=newIndex,
            totalToIndex=siteContent.getRecordCount()
        });

        for (var i=1; i lte siteContent.pageCount(); i++) {
            siteContent.setPage(i);

            var updates = [];

            while (siteContent.hasNext()) {
                var content = siteContent.next();

                if (shouldIndex(content, $)) {
                    arrayAppend(updates, { "index" = { "_id" = content.getContentID() } });
                    arrayAppend(updates, getContentJSON(content, $));
                }
            }

            bulk(siteID, updates, newIndex, getType());

            updateProgress(indexID, {
                totalIndexed=siteContent.currentIndex()
            });

            if (indexingCancelled(indexID)) { return; }
        }

        emit("onIndexSite", { siteID=siteID, newIndex=newIndex });

        if (indexingCancelled(indexID)) { return; }

        changeSiteIndex(siteID, newIndex);

        completeIndexing(indexID);
    }

    public function getIndexConfigJSON(required siteID) {
        var $ = getBeanFactory("MuraScope").init(siteID);

        if (structKeyExists($, "getElasticsearchIndexConfigJSON")) {
            return $.getElasticsearchIndexConfigJSON();
        } else {
            return serializeJSON(getDefaultIndexConfigStruct(siteID));
        }
    }

    public function getDefaultIndexConfigStruct(required siteID) {
        return {
            "settings": {
                "index": {
                    "analysis": {
                        "analyzer": {
                            "path_analyzer": {
                                "tokenizer": "path_hierarchy",
                                "filter": "lowercase"
                            }
                        }
                    }
                }
            },
            "mappings"={
                "#getType()#": {
                    "properties": {
                        "contentID": { "type": "string", "index": "not_analyzed" },
                        "title": { "type": "string" },
                        "type": { "type": "string", "index": "not_analyzed" },
                        "subType": { "type": "string", "index": "not_analyzed" },
                        "summary": { "type": "string" },
                        "body": { "type": "string" },
                        "file": {
                            "type": "attachment",
                            "fields" : {
                                "title" : { "store" : "yes" },
                                "date" : { "store" : "yes" },
                                "keywords" : { "store" : "yes" },
                                "content_type" : { "store" : "yes" },
                                "content_length" : { "store" : "yes" },
                                "language" : { "store" : "yes" }
                            }
                        },
                        "tags": { "type": "string", "index_name": "tag", "index": "not_analyzed" },
                        "url": { "type": "string", "index": "not_analyzed" },
                        "filename": { "type": "string", "analyzer": "path_analyzer" },
                        "lastUpdate": { "type": "date", "format": "date_time" },
                        "created": { "type": "date", "format": "date_time" },
                        "metaDesc": { "type": "string" },
                        "metaKeywords": { "type": "string" }
                    },
                    "_source": {
                        "excludes": [ "file" ]
                    }
                }
            },
            "aliases"={
                "#getWriteAliasName(siteID)#"={}
            }
        };
    }

    private function changeSiteIndex(required siteID, required newIndex) {
        var actions = [];

        for(var index in getAlias(siteID)) {
            arrayAppend(actions, { "remove"={ "index"=index, "alias"=siteID } });
        }

        for(var index in getWriteAlias(siteID)) {
            if(index neq newIndex) {
                arrayAppend(actions, { "remove"={ "index"=index, "alias"=getWriteAliasName(siteid) } });
            }
        }

        arrayAppend(actions, { "add"={ "index"=newIndex, "alias"=siteID } });

        application.elasticsearch = actions;

        return getElasticClient(siteID).updateAliases(actions);
    }

    private function createIndexForSite(required siteID) {
        var name = siteID & "_" & now().getTime();
        getElasticClient(siteID).createIndex(name, getIndexConfigJSON(siteID));
        return name;
    }

    private function currentlyIndexing(required siteID) {
        return getSiteIndexStatusService().inProgress(siteID);
    }

    private function startIndexing(required siteID) {
        return getSiteIndexStatusService().start(siteID);
    }

    private function indexingCancelled(required indexID) {
        return getSiteIndexStatusService().wasCancelled(indexID);
    }

    private function completeIndexing(required indexID) {
        return getSiteIndexStatusService().complete(indexID);
    }

    private function updateProgress(required indexID, required values) {
        return getSiteIndexStatusService().update(indexID, values);
    }

    private function shouldIndex(required content) {
        return getContentIndexer().shouldIndex(content);
    }

    private function getContentJSON(required content) {
        return getContentIndexer().getContentJSON(content);
    }

    private function getType() {
        return getContentIndexer().getType();
    }

    private function bulk(required siteID, required actions, required index, required type) {
        return getElasticClient(siteID).bulk(actions, index, type);
    }

    private function emit(required event, required context) {
        return getUtilities().emit(event, context);
    }

    private function getElasticClient(required siteID) {
        return getElasticsearchService().getClientForSite(siteID);
    }

    private function getWriteAlias(required siteID) {
        return getAlias(siteID, getWriteAliasName(siteID));
    }

    private function getAlias(required siteID, alias='') {
        var response = getElasticClient(siteID).getAlias(name=len(alias) ? alias : siteID, ignore="404");
        return (
            response.is200()
                ? structKeyArray(response.toJSON())
                : []
        );
    }

    private function getWriteAliasName(required siteID) {
        return getElasticsearchService().getWriteAliasName(siteID);
    }

    private function getSiteContent(required siteID) {
        return (
            getBeanFactory()
                .getBean("feed")
                    .setSiteID(siteID)
                    .setMaxItems(9999)
                    .setShowNavOnly(0)
                .getIterator()
                    .setNextN(50)
        );
    }

}