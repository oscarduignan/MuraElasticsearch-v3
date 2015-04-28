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