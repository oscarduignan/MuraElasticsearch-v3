<cfset (
    dbUtility
        .setTable("esSiteIndexLog")
            .alterColumn(column="status", datatype="varchar", length=35)
)>