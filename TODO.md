# stuff left to do
- DONE fill out elasticsearchclient
- DONE port tests from old plugin
    - DONE elasticsearchClient
    - DONE elasticsearchClientStubbed
- DONE write tests for contentindexer
- TODO write tests for siteindexer
- DONE write tests for utilities
- DONE write tests for elasticsearchservice
- TODO write any missing tests for elasticsearchclient
- TODO write documentation
- TODO add settings class extensions (just host needed I think)
- DONE push to github
- TODO write an example replacement display object for the site search
- TODO log initiating user when starting an index
- TODO create interface for reindexing content for sites with react
- TODO include some bootstrapping stuff (like my ansible setup) or an example mura site with this configured that can just be vagrant up'ed
- TODO get my ansible playbooks installing the attachment plugin
- DONE should it be "getContentJSON" or should it just be "get representation for elasticsearch" and then if it's a struct it will be auto serialized anyway?
- DONE extract out the repeated stuff from contentindexer and siteindexer relating to getting aliases, stick it in elasticsearchservice I think
- DONE allow overriding siteIndexer.getSiteContent like with the other bits via the contentrenderer
- TODO add more emit'ed events - cancel / fail / completed in siteIndexStatusService?
- DONE test by hand that the contentRenderer overrides work (and write some unit tests for this)
- TODO what will happen if someone updates some content before an index has been created? Ideally just fail silently

## priorities summarised
* get an interface created to let people trigger an index
* add elasticsearchHost site setting class extension to sites
* write tests for SiteIndexer and ContentIndexer
* create examples/ folder and write an example replacement for the default search display object
* update documentation
* create an example project so people can try the plugin out, include my vagrant / ansible stuff to get things provisioned
