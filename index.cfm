<!--

admin UI here

    reindex site

    view progress of site reindex

    cancel reindex

maybe can provide an example replacement search display object

-->
<cfparam name="session.siteid" default="default">

<cfparam name="$" default="#application.serviceFactory.getBean("MuraScope").init(session.siteID)#">

<cfset plugin = $.getBean("MuraElasticsearch")>

<cfif not $.currentUser().isLoggedIn()>
    <!--- TODO check user is site admin or super admin --->
    <cflocation url="#$.globalConfig("context")#/admin/" addtoken="false">
</cfif>

<cfoutput>
    <cfsavecontent variable="body">
        <cfif not plugin.usingWebpackDevServer()>
            <script>__webpack_public_path__ = '#plugin.getWebpackPublicPath()#';</script>
        </cfif>
        <div id="mura-elasticsearch-admin"></div>
        <script src="#plugin.getWebpackAssetPath("admin.js")#"></script>
    </cfsavecontent>
    #application.pluginManager.renderAdminTemplate(body=body, pageTitle="MuraElasticsearch")#
</cfoutput>

<cfhtmlhead text='<meta name="csrf-token" content="#hash(session.mura.csrfsecretkey)#">'>

<cfif isDefined("url.generateContent")>
    <cfloop from="1" to="50" index="i">
        <cfset $.getBean("content").setParentID("00000000000000000000000000000000001").setApproved(1).setTitle("generated " & i).setBody("Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?").save()>
    </cfloop>
</cfif>