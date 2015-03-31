component extends="testbox.system.BaseSpec" {

    function beforeTests() {
        siteIndexLog = new MuraElasticsearch.model.SiteIndexStatusService();
        siteIndexLog.setConfigBean(getMockBox().createStub().$("getDatasource", url.datasource));
    }

    function test_start_creates_record_in_db() {
        transaction {
            var indexID = siteIndexLog.start("test");

            var indexLog = getIndexLog(indexID);

            $assert.isTrue(indexLog.recordCount gt 0);
            $assert.isTrue(isDate(indexLog.startedAt));
            $assert.isTrue(isDate(indexLog.updatedAt));
            $assert.isFalse(isDate(indexLog.stoppedAt));
            $assert.isEqual('', indexLog.newIndex)
            $assert.isFalse(isNumeric(indexLog.totalToIndex))
            $assert.isFalse(isNumeric(indexLog.totalIndexed))
            $assert.isEqual("test", indexLog.siteID);
            $assert.isEqual(siteIndexLog.getStatusIndexing(), indexLog.status);

            transactionRollback();
        }
    }

    function test_update_updates_record_in_db_with_single_value() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.update(indexID, {newIndex="test_12345"});

            var indexLog = getIndexLog(indexID);

            $assert.isEqual(indexLog.newIndex, "test_12345");

            transactionRollback();
        }
    }

    function test_update_updates_record_in_db_with_multiple_values() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.update(indexID, {newIndex="test_12345", totalToIndex=10});

            var indexLog = getIndexLog(indexID);

            $assert.isEqual(indexLog.newIndex, "test_12345");
            $assert.isEqual(indexLog.totalToIndex, 10);

            transactionRollback();
        }
    }

    function test_update_updates_updatedAt() {
        transaction {
            var indexID = siteIndexLog.start("test");

            var updatedAt = getIndexLog(indexID).updatedAt;

            sleep(1000);

            siteIndexLog.update(indexID, {newIndex="test_12345"});

            var indexLog = getIndexLog(indexID);

            $assert.isGT(indexLog.updatedAt, updatedAt);

            transactionRollback();
        }
    }

    function test_cancel_updates_record_in_db() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.cancel("test");

            var indexLog = getIndexLog(indexID);

            $assert.isEqual(siteIndexLog.getStatusCancelled(), indexLog.status);
            $assert.isTrue(isDate(indexLog.stoppedAt));

            transactionRollback();
        }
    }

    function test_complete_updates_record_in_db() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.complete(indexID);

            var indexLog = getIndexLog(indexID);

            $assert.isEqual(siteIndexLog.getStatusCompleted(), indexLog.status);
            $assert.isTrue(isDate(indexLog.stoppedAt));

            transactionRollback();
        }
    }

    function test_fail_updates_record_in_db() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.fail(indexID);

            var indexLog = getIndexLog(indexID);

            $assert.isEqual(siteIndexLog.getStatusFailed(), indexLog.status);
            $assert.isTrue(isDate(indexLog.stoppedAt));

            transactionRollback();
        }
    }

    function test_inProgress_returns_true_when_indexing_started_and_not_stopped() {
        transaction {
            siteIndexLog.start("test");

            $assert.isTrue(siteIndexLog.inProgress("test"));

            transactionRollback();
        }
    }

    function test_inProgress_returns_false_when_cancelled() {
        transaction {
            siteIndexLog.start("test");

            siteIndexLog.cancel("test");

            $assert.isFalse(siteIndexLog.inProgress("test"));

            transactionRollback();
        }
    }

    function test_inProgress_returns_false_when_failed() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.fail(indexID);

            $assert.isFalse(siteIndexLog.inProgress("test"));

            transactionRollback();
        }
    }

    function test_inProgress_returns_false_when_completed() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.complete(indexID);

            $assert.isFalse(siteIndexLog.inProgress("test"));

            transactionRollback();
        }
    }

    function test_wasCancelled_returns_true_when_cancelled() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.cancel("test");

            $assert.isTrue(siteIndexLog.wasCancelled(indexID));

            transactionRollback();
        }
    }

    function test_wasCancelled_returns_false_when_indexing() {
        transaction {
            var indexID = siteIndexLog.start("test");

            $assert.isFalse(siteIndexLog.wasCancelled(indexID));

            transactionRollback();
        }
    }

    function test_wasCancelled_returns_false_when_completed() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.complete(indexID);

            $assert.isFalse(siteIndexLog.wasCancelled(indexID));

            transactionRollback();
        }
    }

    function test_wasCancelled_returns_false_when_failed() {
        transaction {
            var indexID = siteIndexLog.start("test");

            siteIndexLog.fail(indexID);

            $assert.isFalse(siteIndexLog.wasCancelled(indexID));

            transactionRollback();
        }
    }

    private function getIndexLog(required indexID) {
        return (
            new query(datasource=url.datasource, sql="SELECT * FROM #siteIndexLog.getTableName()# WHERE indexID = :indexID")
                .addParam(name="indexID", value=indexID, cfsqltype="cf_sql_varchar")
                .execute()
                .getResult()
        );
    }

}