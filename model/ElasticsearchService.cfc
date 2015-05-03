component accessors=true {
    property name="BeanFactory";
    property name="Utilities";
    property name="SiteIndexStatusService";
    property name="contentType" default="muraContent";

    this.DATE_FORMAT = "yyyy-MM-dd";
    this.DATETIME_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";

    dateFormatter = createObject("java", "java.text.SimpleDateFormat").init(this.DATE_FORMAT);
    datetimeFormatter = createObject("java", "java.text.SimpleDateFormat").init(this.DATETIME_FORMAT);

    public function parseDate(required datetimeString) {
        return dateFormatter.parse(datetimeString);
    }

    public function parseDatetime(required datetimeString) {
        return datetimeFormatter.parse(datetimeString);
    }

    public function formatDate(required datetime) {
        return dateFormatter.format(datetime);
    }

    public function formatDatetime(required datetime) {
        return datetimeFormatter.format(datetime);
    }

    public function getWriteAliasForSite(required siteID) {
        return getAliasForSite(siteID, getWriteAliasName(siteID));
    }

    public function getAliasForSite(required siteID, alias='') {
        var response = getClientForSite(siteID).getAlias(alias=len(alias) ? alias : siteID, ignore="404");

        return (
            response.is200()
                ? structKeyArray(response.toJSON())
                : []
        );
    }

    public function getWriteAliasName(required alias) {
        return alias & "_write";
    }

    public function getClientForSite(required siteID) {
        return getClientForHost(getHost(siteID));
    }

    public function getClientForHost(required host) {
        if(not structKeyExists(structGet("clients"), host))
            clients[host] = getBeanFactory().getBean("ElasticsearchClient").setHost(host);

        return clients[host];
    }

    public function search(required siteid, q="", from=0, size=10) {
        return getClientForSite(siteid).search({
            'query'={
                'match_all'={}
            },
            'facets'={
                'tags'={'terms'={'field'='tags', 'size'=10}},
                'types'={'terms'={'field'='typeAndSubType'}}
            },
            'from'=from,
            'size'=size
        }, siteid, getContentType());
    }

    public function getStatus(required siteid, historySince) {
        var stats = getClientForSite(siteid).getStats(index=siteid, stats="docs", ignore="all");
        var online = (not stats.hasErrors()) or stats.is404();
        return {
            "host"=getHost(siteid),
            "status"=online ? "online" : "offline",
            "size"=online ? stats.toJSON()["_all"]["total"]["docs"]["count"] : "",
            "history"=getReindexHistory(siteid=arguments.siteid, since=arguments.historySince)
        };
    }

    public function getReindexHistory(required siteid, since) {
        return getSiteIndexStatusService().getHistory(argumentCollection=arguments);
    }

    public function getHost(required siteID, defaultValue="localhost:9200") {
        return getUtilities().getSiteConfig(siteID, "elasticsearchHost", defaultValue);
    }

}