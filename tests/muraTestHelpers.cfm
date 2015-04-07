<cfscript>

    function getMuraScope(siteid="") {
        if (not len(siteid)) { arguments.siteid = session.siteid; }

        return getMuraBean("muraScope").init(siteid);
    }

    function getMuraBean(required name) {
        return application.serviceFactory.getBean(name);
    }

    function newContent(content={}) {
        var contentBean = getMuraBean("content");

        for (var key in content) {
            contentBean.setValue(key, content[key]);
        }

        return contentBean;
    }

    // run inside a transaction!
    function createContent(content={}) {
        var contentBean = getMuraBean("content");

        for (var key in content) {
            contentBean.setValue(key, content[key]);
        }

        return contentBean.save();
    }

</cfscript>
