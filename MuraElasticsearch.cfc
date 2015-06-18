component accessors=true {
    property name="beanFactory";

    public function init(parentServiceFactory) {
        setBeanFactory(new vendor.ioc("/MuraElasticsearch/model", {
            singletonPattern = "(Indexer|Service|Utilities)$"
        }));

        if (isDefined("arguments.parentServiceFactory")) {
            getBeanFactory()
                .setParent(parentServiceFactory)
                .addBean("PluginConfig", parentServiceFactory.getBean("PluginManager").getConfig("MuraElasticsearch"));
        }
    }

    public function applyDBUpdates() {
        getBean("DatabaseUpdater").applyDBUpdates("/MuraElasticsearch/migrations");
    }

    public function updateContent(required content, required $) {
        getBean("ContentIndexer").updateContent(content, $);
    }

    public function removeContent(required content, required $) {
        getBean("ContentIndexer").removeContent(content, $);
    }

    public function indexSite(required $) {
        getBean("SiteIndexer").indexSite($);
    }

    public function cancelIndexing(required siteID) {
        getBean("SiteIndexStatusService").cancel(siteID);
    }

    public function getWebpackAssetPath(required asset) {
        return getBean("WebpackService").getAssetPath(asset);
    }

    public function getWebpackPublicPath() {
        return getBean("WebpackService").getPublicPath();
    }

    public function usingWebpackDevServer() {
        return getBean("WebpackService").usingWebpackDevServer();
    }

    public function searchSite(required siteid, required body, muraContentOnly=true) {
        return getBean("ElasticsearchService").getClientForSite(siteid).search(
            body=body,
            index=siteid,
            type=(muraContentOnly ? getBean("ElasticsearchService").getContentType() : "")
        );
    }

    public function getStatus(required siteID, historySince) {
        return getBean("ElasticsearchService").getStatus(argumentCollection=arguments);
    }

    public function getBean(required name) {
        return getBeanFactory().getBean(name);
    }

}