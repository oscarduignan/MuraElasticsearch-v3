component accessors=true output=true {
    property name="ElasticsearchService";
    property name="ContentIndexer";
    property name="Utilities";
    property name="SiteIndexStatusService";
    property name="BeanFactory";

    public function indexSite(required siteID) {
        lock name="elasticIndexSite#siteID#" type="exclusive" timeout="10" {
            cancelExistingIndexing(siteID);

            var indexID = startIndexing(siteID);
        }

        try {
            var $ = getBeanFactory().getBean("MuraScope").init(siteID);

            var newIndex = createIndexForSite(siteID);

            var siteContent = getSiteContent($);

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

            emit("onIndexSite", { siteID=siteID, indexID=indexID, newIndex=newIndex });

            if (indexingCancelled(indexID)) { return; }

            changeSiteIndex(siteID, newIndex);

            flagIndexingAsCompleted(indexID);
        } catch(any e) {
            flagIndexingAsFailed(indexID, e);

            if (isDefined("newIndex")) removeIndexFromWriteAlias(siteID, newIndex);
        }
    }

    public function getIndexConfigJSON(required siteID) {
        var $ = getBeanFactory().getBean("MuraScope").init(siteID);

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

    private function getSiteContent(required $) {
        if (structKeyExists($, "getElasticsearchContentIterator")) {
            return $.getElasticsearchContentIterator();
        } else {
            return (
                getBeanFactory()
                    .getBean("feed")
                        .setSiteID($.event("siteid"))
                        .setMaxItems(9999)
                        .setShowNavOnly(0)
                    .getIterator()
                        .setNextN(50)
            );
        }
    }

    private function currentlyIndexing(required siteID) {
        return getSiteIndexStatusService().inProgress(siteID);
    }

    private function startIndexing(required siteID) {
        return getSiteIndexStatusService().start(siteID);
    }

    private function cancelExistingIndexing(required siteID) {
        return getSiteIndexStatusService().cancel(siteID);
    }

    private function flagIndexingAsFailed(required indexID, exception) {
        var details = {};

        if (isDefined("arguments.exception")) {
            details["type"]         = exception.type;
            details["message"]      = exception.message;
            details["detail"]       = exception.detail;
            details["extendedInfo"] = exception.extendedInfo;
            details["code"]         = exception.code;
        }

        return getSiteIndexStatusService().fail(indexID, details);
    }

    private function flagIndexingAsCompleted(required indexID) {
        return getSiteIndexStatusService().complete(indexID);
    }

    private function indexingCancelled(required indexID) {
        return getSiteIndexStatusService().wasCancelled(indexID);
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

    private function removeIndexFromWriteAlias(required siteID, required indexName) {
        return getElasticClient(siteID).removeAlias(name=getWriteAliasName(siteID), index=indexName, ignore="404");
    }

    private function emit(required event, required context) {
        return getUtilities().emit(event, context);
    }

    private function getElasticClient(required siteID) {
        return getElasticsearchService().getClientForSite(siteID);
    }

    private function getWriteAlias(required siteID) {
        return getElasticsearchService().getWriteAliasForSite(siteID);
    }

    private function getAlias(required siteID) {
        return getElasticsearchService().getAliasForSite(siteID);
    }

    private function getWriteAliasName(required siteID) {
        return getElasticsearchService().getWriteAliasName(siteID);
    }

}