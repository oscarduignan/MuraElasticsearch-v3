component extends="testbox.system.BaseSpec" {

    function beforeTests() {
        databaseUpdater = new MuraElasticsearch.model.DatabaseUpdater();
        databaseUpdater.setBeanFactory(getMockBox().createStub().$("getBean", true));
    }

    function test_applyDBUpdates_runs_all_updates_in_correct_order() {
        databaseUpdater.applyDBUpdates("/MuraElasticsearch/tests/migrations");

        $assert.isEqual([1,2,3], databaseUpdater.orderUpdatesWereRun);
    }

}