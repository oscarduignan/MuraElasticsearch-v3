<cfset (
    dbUtility
        .setTable("esSiteIndexLog")
            .addColumn(column="failureDetails", datatype="text")
)>
