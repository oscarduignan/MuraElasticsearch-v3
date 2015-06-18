component accessors=true output=true {
    property name="ElasticsearchService";
    property name="ContentIndexer";
    property name="Utilities";
    property name="SiteIndexStatusService";
    property name="BeanFactory";

    public function indexSite(required $) {
        var siteID = $.event('siteID');

        lock name="elasticIndexSite#siteID#" type="exclusive" timeout="10" {
            cancelExistingIndexing(siteID);

            var indexID = startIndexing(siteID);
        }

        try {
            var newIndex = createIndexForSite($);

            var siteContent = getSiteContentIterator($);

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

        return indexID;
    }

    public function getIndexConfigJSON(required $) {
        if (structKeyExists($, "getElasticsearchIndexConfigJSON")) {
            return $.getElasticsearchIndexConfigJSON();
        } else {
            return serializeJSON(getDefaultIndexConfigStruct($.event("siteID")));
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
                        "typeAndSubType": { "type": "string", "index": "not_analyzed" },
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
                        "metaKeywords": { "type": "string" },
                        "approved": { "type": "string", "index": "not_analyzed" },
                        "display": { "type": "string", "index": "not_analyzed" },
                        "displayStart": { "type": "date", "format": "date_time" },
                        "displayStop": { "type": "date", "format": "date_time" }
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

    public function getDefaultSiteContentFeed(required siteID) {
        return (
            getBeanFactory().
                getBean("feed")
                    .setSiteID(siteID)
                    // give us everything!
                    .setMaxItems(999999)
                    // we want stuff even if it's set not to display in the nav
                    .setShowNavOnly(0)
                    // we don't want stuff that shouldn't be in the search though
                    .setShowExcludeSearch(0)
                    // got to set this otherwise you only get content where now() is between displayStart and displayStop
                    .setLiveOnly(0)
                    // because we set LiveOnly=0 we set this so we don't get content set to display=false
                    .addParam(field='Display', condition='!=', criteria=0)
                    // and we also have to set this because we don't want draft content
                    .addParam(field='Approved', criteria=1)
                    // and we set this because we only want the latest revision of content
                    .setIsActive(1)
        );
    }

    private function getLiveOnlyFilter() {
        // if you want to index unpublished drafts too so you can search them then
        // you just need to set the site content feed to not filter out unnapproved
        // content and then query the index the site's alias points to directly.
        return {
            "and": [
                { "term": { "approved": 1 } },
                { "or": [
                    { "term": { "display": 1 } },
                    { "and": [
                        { "term": { "display": 2 } },
                        { "and": [
                            { "or": [
                                { "not": { "exists": { "field": "displayStart" } } },
                                { "range": { "displayStart": { "lte": "now" } } }
                            ] },
                            { "or": [
                                { "not": { "exists": { "field": "displayStop" } } },
                                { "range": { "displayStop": { "gte": "now" } } }
                            ] }
                        ] }
                    ] }
                ] }
            ]
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

        arrayAppend(actions, { "add"={ "index"=newIndex, "alias"=siteID, "filter"=getLiveOnlyFilter() } });

        application.elasticsearch = actions;

        return getElasticClient(siteID).updateAliases(actions);
    }

    private function createIndexForSite(required $) {
        var siteID = $.event('siteID');
        var indexName = siteID & "_" & now().getTime();
        getElasticClient(siteID).createIndex(indexName, getIndexConfigJSON($));
        return indexName;
    }

    private function getSiteContentIterator(required $) {
        if (structKeyExists($, "getElasticsearchContentIterator")) {
            return $.getElasticsearchContentIterator();
        } else {
            return (
                getDefaultSiteContentFeed($.event('siteid'))
                    .getIterator()
                        .setNextN(100)
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
        return getElasticsearchService().getContentType();
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