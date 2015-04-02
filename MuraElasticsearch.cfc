component accessors=true {
    property name="beanFactory";

    public function init(parentServiceFactory) {
        setBeanFactory(new vendor.ioc("/MuraElasticsearch/model", {
            singletonPattern = "(Indexer|Service|Utilities)$"
        }));
        
        if (isDefined("arguments.parentServiceFactory")) {
            getBeanFactory().setParent(parentServiceFactory);
        }
    }

    public function applyDBUpdates() {
        getBean("DatabaseUpdater").applyDBUpdates("/MuraElasticsearch/migrations");
    }

    public function updateContent(required content) {
        getBean("ContentIndexer").updateContent(content);
    }

    public function removeContent(required content) {
        getBean("ContentIndexer").removeContent(content);
    }

    public function indexSite(required siteID) {
        getBean("SiteIndexer").indexSite(siteID);
    }

    public function cancelIndexing(required siteID) {
        getBean("SiteIndexStatusService").cancel(siteID);
    }

    public function getBean(required name) {
        return getBeanFactory().getBean(name);
    }

}