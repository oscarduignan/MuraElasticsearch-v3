component accessors=true {
    property name="ElasticsearchService";
    property name="Utilities";
    property name="ConfigBean";
    property name="BeanFactory";
    property name="type" default="muraContent";

    public function updateContent(required content) {
        if (not content.getApproved()) return;
        if (not shouldIndex(content)) return removeContent(content);

        var elasticsearch = getElasticClient(content.getSiteID());
        var contentJSON = getContentJSON(content);
        var oldFilename = content.getOldFilename();
        var filenameHasChanged = len(oldFilename) and content.getFilename() neq oldFilename;

        for (var index in getWriteAlias(content.getSiteID())) {
            elasticsearch.insertDocument(
                index=index,
                type=getType(),
                id=content.getContentID(),
                body=contentJSON
            );

            if (filenameHasChanged) {
                updateFilenames(
                    siteid=content.getSiteID(),
                    index=index,
                    oldFilename=oldFilename,
                    newFilename=content.getFilename()
                );
            }
        }
    }

    public function removeContent(required content) {
        var elasticsearch = getElasticClient(content.getSiteID());

        for(var index in getWriteAlias(content.getSiteID())) {
            elasticsearch.removeDocument(
                index=index,
                type=getType(),
                id=content.getContentID()
            );
        }
    }

    public function shouldIndex(required content, $) {
        if (not isDefined("arguments.$"))
            arguments.$ = getBeanFactory().getBean("MuraScope").init(content.getSiteID());

        if (structKeyExists($, "getElasticsearchShouldIndex")) {
            return $.getElasticsearchShouldIndex(content);
        } else {
            return (
                content.getIsOnDisplay()
                and
                content.getSearchExclude() eq 0
            );
        }
    }

    public function getContentJSON(required content, $) {
        if (not isDefined("arguments.$"))
            arguments.$ = getBeanFactory().getBean("MuraScope").init(content.getSiteID());

        if (structKeyExists($, "getElasticsearchContentJSON")) {
            return $.getElasticsearchContentJSON(content);
        } else {
            return serializeJSON(getDefaultContentStruct(content));
        }
    }

    public function getDefaultContentStruct(required content) {
        return {
            "contentID"=content.getContentID(),
            "title"=content.getTitle(),
            "type"=content.getType(),
            "subType"=content.getSubType(),
            "body"=content.getBody(),
            "summary"=content.getSummary(),
            "file"=getAssociatedFileAsBase64(content),
            "tags"=listToArray(content.getTags()),
            "url"=content.getUrl(),
            "created"=formatDatetime(content.getCreated()),
            "lastUpdate"=formatDatetime(content.getLastUpdate()),
            "filename"=content.getFilename(),
            "metaDesc"=content.getMetaDesc(),
            "metaKeywords"=content.getMetaKeywords()
        };
    }

    private function getAssociatedFileAsBase64(required content) {
        return getUtilities().getAssociatedFileAsBase64(content);
    }

    private function updateFilenames(required siteID, required index, required oldFilename, required newFilename) {
        return (
            getElasticClient(siteID)
                .searchAndReplace(
                    index=index, 
                    type=getType(),
                    body={
                        "query"={
                            "match"={ // note that this requries a custom analyzer using path_hierarchy_tokenizer to work! see indexSettings.json
                                "filename"=oldFilename
                            }
                        }
                    },
                    fields="url,filename",
                    regex="^" & oldFilename,
                    substring=newFilename
                )
        );
    }

    private function formatDatetime(required datetime) {
        return getElasticsearchService().formatDatetime(datetime);
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