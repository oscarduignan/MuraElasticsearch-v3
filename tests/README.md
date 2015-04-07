# How to run these tests

* You need to have a copy of testbox mapped at /testbox
* You need to have mura and elasticsearch running
* You need to supply a ?host=ELASTICSEARCH_HOST param if elasticsearch isn't available at localhost:9200
* You need to run the tests from under the mura webroot
* These tests will create and remove content for testing on the default site, make sure the plugin is not enabled for the default mura site when running these tests as that will interfere with the results and slow stuff down!
* Run tests by opening them in your browser with ?method=runRemote, for example: /plugins/MuraElasticsearch/tests/DatabaseUpdaterTests.cfc?method=runRemote