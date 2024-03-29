component accessors=true {
    property name="Utilities";
    property name="ConfigBean";
    property name="tableName"       default="esSiteIndexLog";
    property name="statusIndexing"  default="indexing" setter=false;
    property name="statusCancelled" default="cancelled" setter=false;
    property name="statusCompleted" default="completed" setter=false;
    property name="statusFailed"    default="failed" setter=false;

    function start(required siteID) {
        var indexID = createUUID();

        newQuery("
            INSERT INTO #getTableName()# (
                indexID, siteID, status, startedAt, updatedAt
            ) VALUES (
                :indexID, :siteID, :status, now(), now()
            )
        ")
            .addParam(name="indexID", value=indexID, cfsqltype="cf_sql_varchar")
            .addParam(name="siteID", value=siteID, cfsqltype="cf_sql_varchar")
            .addParam(name="status", value=getStatusIndexing(), cfsqltype="cf_sql_varchar")
            .execute();

        return indexID;
    }

    function update(required indexID, required values) {
        var sql = "";
        var query = newQuery();

        for (var key in values) {
            sql = listAppend(sql, "#key# = :#key#", ",");
            query.addParam(name=key, value=values[key], cfsqltype=getSQLType(values[key]));
        }

        query.setSQL("UPDATE #getTableName()# SET #sql#, updatedAt = now() WHERE indexid = :indexID");
        query.addParam(name="indexID", value=indexID, cfsqltype="cf_sql_varchar");

        return query.execute();
    }

    function cancel(required siteID) {
        return (
            newQuery("UPDATE #getTableName()# SET status = :cancelled, updatedAt = now(), stoppedAt = now() WHERE siteid = :siteID AND status = :indexing")
                .addParam(name="indexing", value=getStatusIndexing(), cfsqltype="cf_sql_varchar")
                .addParam(name="cancelled", value=getStatusCancelled(), cfsqltype="cf_sql_varchar")
                .addParam(name="siteID", value=siteID, cfsqltype="cf_sql_varchar")
                .execute()
        );
    }

    function getNewIndex(required indexID) {
        return (
            newQuery("SELECT newIndex from #getTableName()# WHERE indexid = :indexid")
                .addParam(name="indexid", value=indexID, cfsqltype="cf_sql_varchar")
                .execute()
                .getResult()
                .newIndex
        );
    }

    function getHistory(required siteID, since) {
        var query = newQuery("
            SELECT * FROM #getTableName()#
            WHERE siteid = :siteID
            #isDefined("arguments.since") ? "AND startedAt >= :since" : ""#
            ORDER BY startedAt desc
        ").addParam(name="siteID", value=siteID, cfsqltype="cf_sql_varchar");

        if (isDefined("arguments.since")) {
            query.addParam(name="since", value=parseDateTime(arguments.since), cfsqltype="cf_sql_timestamp");
        }

        var results = query.execute().getResult();
        var resultsArray = [];

        for (var i=1; i<results.recordCount; i++) {
            arrayAppend(resultsArray, getUtilities().getQueryRow(results, i));
        }

        return resultsArray;
    }

    /*
    function getMostRecent(required siteID) {
        return getUtilities().getQueryRow(
            // todo make this limit work with mssql or mysql
            newQuery("SELECT * from #getTableName()# WHERE siteid = :siteID ORDER BY startedAt desc LIMIT 1")
                .addParam(name="siteID", value=siteID, cfsqltype="cf_sql_varchar")
                .execute()
                .getResult()
        , 1);
    }
    */

    function complete(required indexID) {
        return update(indexID, {status=getStatusCompleted(), stoppedAt=now()});
    }

    function fail(required indexID, details="") {
        return update(indexID, {status=getStatusFailed(), stoppedAt=now(), failureDetails=serializeJSON(details)});
    }

    function inProgress(required siteID) {
        return (
            newQuery("SELECT indexID from #getTableName()# WHERE siteid = :siteID AND status = :status")
                .addParam(name="siteID", value=siteID, cfsqltype="cf_sql_varchar")
                .addParam(name="status", value=getStatusIndexing(), cfsqltype="cf_sql_varchar")
                .execute()
                .getResult()
        ).recordCount gt 0;
    }

    function wasCancelled(required indexID) {
        return (
            newQuery("SELECT indexID from #getTableName()# WHERE indexid = :indexID AND status = :status")
                .addParam(name="indexID", value=indexID, cfsqltype="cf_sql_varchar")
                .addParam(name="status", value=getStatusCancelled(), cfsqltype="cf_sql_varchar")
                .execute()
                .getResult()
        ).recordCount gt 0;
    }

    private function newQuery(sql="") {
        return new query(datasource=getConfigBean().getDatasource(), sql=sql);
    }

    private function getSQLType(required param) {
        if (isDate(arguments.param)) {
            return "cf_sql_timestamp";
        } else if (isNumeric(arguments.param)) {
            return "cf_sql_integer";
        } else {
            return "cf_sql_varchar";
        }
    }
}