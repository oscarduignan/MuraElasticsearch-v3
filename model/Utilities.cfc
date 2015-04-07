component accessors=true {
    property name="configBean";
    property name="pluginManager";
    property name="settingsManager";
    property name="beanFactory";

    public function getSite(required siteID) {
        return getSettingsManager().getSite(siteID);
    }

    public function getSiteConfig(required siteID, required key, defaultValue='') {
        return len(getSite(siteID).getValue(key))
            ? getSite(siteID).getValue(key)
            : defaultValue;
    }

    public function getInstanceConfig(required key, defaultValue='') {
        return len(getConfigBean().getValue(key))
            ? getConfigBean().getValue(key)
            : defaultValue;
    }

    public function emit(required eventName, eventObject={}, firstOnly=false) {
        return getPluginManager().announceEvent(
            eventToAnnounce=eventName,
            currentEventObject=(
                isObject(eventObject)
                    ? eventObject
                    : createObject("component", "mura.event").init(eventObject)
            ),
            index=(firstOnly ? 1 : 0) // only fire first handler found
        );
    }

    public function getFilenameOfLastVersion(required content) {
        /*

        until I hear back about ticket, have to assume we can only get filename of last
        version for content that comes in via an onContentSave() event where it will have
        the oldFilename key set. Might be that's the only place we need it, because during
        a reindex where we manually pass stuff to the index we know the filenames don't
        need updating.

        https://github.com/blueriver/MuraCMS/issues/1860 

        */

        if (len(content.getOldFilename())) { return content.getOldFilename(); }

        var dbtype = lcase(getConfigBean().getDBType());

        var result = (
            new query()
                .setDatasource(getConfigBean().getDatasource())
                .setSQL("
                    select #dbtype eq "mssql" ? "top 2" : ""#
                        tcontent.filename
                    from tcontent 
                    where
                        tcontent.contentid = :contentID
                        and tcontent.siteid = :siteID
                        and tcontent.approved = 1
                        and tcontent.active != 1
                    order by tcontent.lastupdate desc
                    #false and dbtype eq "mysql" ? "limit 2" : ""#
                ")
                .addParam(name="contentID", value=content.getContentID(), cfsqltype="cf_sql_varchar")
                .addParam(name="siteID", value=content.getSiteID(), cfsqltype="cf_sql_varchar")
                .execute()
                .getResult()
        );

        return result.recordCount gt 1 ? result.filename[2] : '';
    }

    public function getFileAsBase64(required filePath) {
        return binaryEncode(fileReadBinary(filePath), "base64");
    }

    public function getAssociatedFileAsBase64(required content) {
        if (len(content.getFileID()) and content.getType().equalsIgnoreCase("file")) {
            return getFileAsBase64(getPathToAssociatedFile(content));
        } else {
            return "";
        };
    }

    public function getPathToAssociatedFile(required content) {
        var delim = getConfigBean().getFileDelim();

        if (len(content.getFileID())) {
            return getConfigBean().getFileDir() & delim & content.getSiteID() & delim & "cache" & delim & "file" & delim & content.getFileID() & "." & content.getFileExt();
        } else {
            return "";
        }
    }


}