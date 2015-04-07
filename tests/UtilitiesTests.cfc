component extends="testbox.system.BaseSpec" {
    include template="muraTestHelpers.cfm";

    function beforeTests() {
        plugin = new MuraElasticsearch.MuraElasticsearch(application.serviceFactory);

        utilities = plugin.getBean("Utilities");
    }

    function afterTests() {
        clearDefaultSiteTrash();
    }

}