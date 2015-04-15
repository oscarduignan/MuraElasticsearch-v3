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

    public function getBean(required name) {
        return getBeanFactory().getBean(name);
    }

    // todo refactor this out to a plugin/api.cfc or something like that, need to think about access control
    remote function getElasticsearchStatus(required siteid) returnFormat="json" {
        return application.serviceFactory.getBean("MuraElasticsearch").getBean("ElasticsearchService").getClientForSite(siteid).getStatus();
    }

}