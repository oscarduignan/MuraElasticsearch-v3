<cfset (
    dbUtility
        .setTable("esSiteIndexLog")
            .addColumn(column="indexid", datatype="varchar", length=35)
            .addColumn(column="siteid", datatype="varchar", length=25)
            .addColumn(column="userid", datatype="varchar", length=35)
            .addColumn(column="newIndex", datatype="varchar", length=100)
            .addColumn(column="status", datatype="int")
            .addColumn(column="totalToIndex", datatype="int")
            .addColumn(column="totalIndexed", datatype="int")
            .addColumn(column="startedAt", datatype="datetime")
            .addColumn(column="stoppedAt", datatype="datetime")
            .addColumn(column="updatedAt", datatype="datetime")
            .addIndex("siteid")
            .addIndex("userid")
            .addIndex("status")
)>