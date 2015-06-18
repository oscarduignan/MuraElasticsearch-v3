component accessors=true {
    property name="ElasticsearchService";
    property name="Utilities";
    property name="ConfigBean";
    property name="BeanFactory";

    public function updateContent(required content, required $) {
        if (not content.getApproved()) return;
        if (not shouldIndex(content))  return removeContent(content, $);

        var siteID = $.event('siteID');
        var elasticsearch = getElasticClient(siteID);
        var contentJSON = getContentJSON(content);
        var oldFilename = content.getOldFilename();
        var filenameHasChanged = len(oldFilename) and content.getFilename() neq oldFilename;

        for (var index in getWriteAlias(siteID)) {
            elasticsearch.insertDocument(
                index=index,
                type=getType(),
                id=content.getContentID(),
                body=contentJSON
            );

            if (filenameHasChanged) {
                updateFilenames(
                    siteid=siteID,
                    index=index,
                    oldFilename=oldFilename,
                    newFilename=content.getFilename()
                );
            }
        }
    }

    public function removeContent(required content, required $) {
        var elasticsearch = getElasticClient($.event('siteID'));

        for(var index in getWriteAlias($.event('siteID'))) {
            elasticsearch.removeDocument(
                index=index,
                type=getType(),
                id=content.getContentID()
            );
        }
    }

    public function shouldIndex(required content, $) {
        if (isDefined("arguments.$") and structKeyExists(arguments.$, "getElasticsearchShouldIndex")) {
            return arguments.$.getElasticsearchShouldIndex(content);
        } else {
            return true;
        }
    }

    public function getContentJSON(required content, $) {
        if (isDefined("arguments.$") and structKeyExists(arguments.$, "getElasticsearchContentJSON")) {
            return arguments.$.getElasticsearchContentJSON(content);
        } else {
            return serializeJSON(getDefaultContentStruct(content));
        }
    }

    public function getDefaultContentStruct(required content) {
        var trimmedTags = [];

        for (var tag in listToArray(content.getTags())) {
            arrayAppend(trimmedTags, trim(tag));
        }

        var document = {
            "contentID"=content.getContentID(),
            "title"=content.getTitle(),
            "type"=content.getType(),
            "subType"=content.getSubType(),
            "typeAndSubType"=content.getType() & ">" & content.getSubType(),
            "body"=content.getBody(),
            "summary"=content.getSummary(),
            "file"=getAssociatedFileAsBase64(content),
            "tags"=trimmedTags,
            "url"=content.getUrl(),
            "created"=formatDatetime(content.getCreated()),
            "lastUpdate"=formatDatetime(content.getLastUpdate()),
            "filename"=content.getFilename(),
            "metaDesc"=content.getMetaDesc(),
            "metaKeywords"=content.getMetaKeywords(),
            "approved"=content.getApproved(),
            "display"=content.getDisplay()
        };

        if (isDate(content.getDisplayStart())) {
            document["displayStart"] = formatDatetime(content.getDisplayStart());
        }

        if (isDate(content.getDisplayStop())) {
            document["displayStop"] = formatDatetime(content.getDisplayStop());
        }

        return document;
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

    private function getType() {
        return getElasticsearchService().getContentType();
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