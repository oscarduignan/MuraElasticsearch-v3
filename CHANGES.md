# CHANGES

### [`v0.1.0`](https://github.com/oscarduignan/MuraElasticsearch/releases/tag/v0.1.0)

The aim with this release is that the underlying indexing should work just about now and have decent test coverage!

#### features

* maintain an index for each mura site which has the plugin enabled in elasticsearch
* by default index all content set to display that isn't excluded from the site search
* onContentSave add / update / remove content in the index
* gives you a way to reindex site content (updating index settings) with no downtime (currently no gui though)
* lets you override per site indexing behaviour through your content renderer
    * should a bit of content be indexed?
    * what content should be indexed when a full site index is triggered?
    * what settings should the site indice be created with?
    * how should mura content be serialized for elasticsearch?
* provides a basic client for querying elasticsearch
* includes unit tests for core functionality to provide confidence and maintainability
* permissive open source license
* trys to be a good example of how I currently architect mura plugins

#### next priorities

* need some tests for [model/SiteIndexer.cfc]
* need an interface to manager site indexing, probably build something here with React
    * initiate
        * for current site if site admin
        * for any site you want if super admin
    * view progress
        * for current site if site admin
        * for all sites if super admin
    * cancel
        * for current site if site admin
        * for any sites if super admin
    * view recent
        * for current site if site admin
        * for all sites if super admin
* need to log initiating user for site index
* add some example search display objects
* release my project level vagrant and ansible provisioning scripts to help people get started quickly
* update documentation
* add elasticsearchHost config option for Sites using class extensions
* decide and implement what should happen when
    * a user updates some content when elasticsearch is innaccessible, should we display an error or fail silently?
    * a user updates some content during a reindex before the content that has been loaded to be indexed is indexed. The loaded content is now out of date so we don't want to index it. Can we change the updateContent to an addContent and ignore errors saying it already exists so can't be added again?
