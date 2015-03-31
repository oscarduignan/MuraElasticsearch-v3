component accessors=true {
    property name="beanFactory";
    property name="parentBeanFactory";

    public function init(parentBeanFactory) {
        if (isDefined("arguments.parentBeanFactory"))
            setParentBeanFactory(parentBeanFactory);
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

    public function cancelIndexing(required siteID) {
        getBean("SiteIndexStatusService").cancel(siteID);
    }

    public function indexSite(required siteID) {
        getBean("SiteIndexer").indexSite(siteID);
    }

    public function getBean(required name) {
        return getBeanFactory().getBean(name);
    }

    private function getBeanFactory() {
        if (not isDefined("beanFactory")) initBeanFactory();

        return beanFactory;
    }

    private function initBeanfactory() {
        beanFactory = new vendor.ioc("/MuraElasticsearch/model", {
            singletonPattern = "(Indexer|Service|Utilities)$"
        });
        
        if (isDefined("variables.parentBeanFactory"))
            beanFactory.setParent(getParentBeanFactory());
    }

}