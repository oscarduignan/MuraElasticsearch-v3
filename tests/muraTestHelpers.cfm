<cfscript>

    function getMuraScope(siteid="default") {
        if (not len(siteid)) { arguments.siteid = session.siteid; }

        return getMuraBean("muraScope").init(siteid);
    }

    function getMuraBean(required name) {
        return application.serviceFactory.getBean(name);
    }

    function getContent(required contentid, siteid="default") {
        return getMuraBean("content").loadBy(contentid=contentid, siteid=siteid);
    }

    function newContent(content={}) {
        var defaults = {
            siteid="default",
            parentid="00000000000000000000000000000000001",
            title="unit test content #createUUID()#",
            approved=1
        };

        structAppend(defaults, content, true);

        var contentBean = getMuraBean("content");

        for (var key in defaults) {
            contentBean.setValue(key, defaults[key]);
        }

        return contentBean;
    }

    function clearDefaultSiteTrash() {
        return getMuraBean("TrashManager").empty(siteid="default");
    }

    // delete after using then clearDefaultSiteTrash() afterTests
    function createContent(content={}) {
        return newContent(content).save();
    }

</cfscript>
