component accessors=true {
    property name="configBean";
    property name="pluginManager";
    property name="settingsManager";
    property name="beanFactory";
    property name="pluginConfig";

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

    public function getPluginPath(path='') {
        return getConfigBean().getContext() & '/plugins/' & getPluginConfig().getDirectory() & path;
    }

}