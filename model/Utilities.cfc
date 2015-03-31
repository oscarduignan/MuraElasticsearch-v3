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


}