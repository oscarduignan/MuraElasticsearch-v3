component extends="testbox.system.BaseSpec" {
    include template="muraTestHelpers.cfm";

    function beforeTests() {
        plugin = new MuraElasticsearch.MuraElasticsearch(application.serviceFactory);

        utilities = plugin.getBean("Utilities");
    }

    function afterTests() {
        clearDefaultSiteTrash();
    }

    function test_getFilenameOfLastVersion_to_return_an_empty_string_if_it_has_no_previous_version() {
        try {
            var content = createContent();

            $assert.isEqual("", utilities.getFilenameOfLastVersion(content));
        } finally {
            try{
                content.delete();
            } catch(any e) {}
        }
    }

    function test_getFilenameOfLastVersion_to_return_filename_of_previous_version_when_it_has_been_revised() {
        try {
            var content = createContent({
                title="initial"
            });

            sleep(500);

            var latestContent = getContent(content.getContentID()).setURLTitle("updated").setApproved(1).save();

            $assert.isEqual("initial", utilities.getFilenameOfLastVersion(latestContent));
        } finally {
            try {
                content.delete();
                latestContent.delete();
            } catch(any e) {}
        }
    }

}