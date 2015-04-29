component accessors=true {
    property name="Host";

    function init(
        host
    ) {
        setHost(arguments.host);
        return this;
    }

    function getStatus() {
        return makeHttpRequest(method="get", url=createURL(), ignore="404").toJSON();
    }

    function search(
        required body,
        index="",
        type="",
        params="",
        ignore=""        
    ) {
        if (not len(index) and len(type)) index = "*";

        if (isStruct(params)) params = structToQueryString(params);

        return makeHttpRequest(
            method="post",
            url=createUrl(index, type, "_search") & params,
            body=body,
            ignore=ignore
        );
    }

    function searchScroll(
        required scroll,
        required scrollID,
        ignore=""        
    ) {
        return makeHttpRequest(
            method="get",
            url=createURL("_search", "scroll") & structToQueryString({scroll=scroll, scroll_id=scrollID}),
            ignore=ignore
        );
    }

    /*** INDEX METHODS ******************************************************/

    function createIndex(
        required name,
        body="",
        ignore=""        
    ) {
        return makeHttpRequest(
            method="put",
            url=createUrl(name),
            body=body,
            ignore=ignore
        );
    }

    function deleteIndex(
        required name,
        ignore=""        
    ) {
        return makeHttpRequest(
            method="delete",
            url=createUrl(name),
            ignore=ignore
        );
    }

    function indexExists(
        required name
    ) {
        return makeHttpRequest(
            method="head",
            url=createUrl(name),
            ignore="404"
        ).is200();
    }

    function refreshIndex(
        name="",
        ignore=""        
    ) {
        return makeHttpRequest(
            method="post",
            url=createUrl(name, "_refresh"),
            ignore=ignore
        );
    }

    /*** ALIAS METHODS ******************************************************/

    function createAlias(
        required name,
        required index,
        ignore=""        
    ) {
        return makeHttpRequest(
            method="post",
            url=createUrl("_aliases"),
            body={
                "actions"=[
                    {"add"= {"index"=index, "alias"=name}}
                ]
            },
            ignore=ignore
        );
    }

    function removeAlias(
        required name,
        index="_all",
        ignore=""        
    ) {
        return makeHttpRequest(
            method="post",
            url=createUrl("_aliases"),
            body={
                "actions"=[
                    {"remove"= {"index"=index, "alias"=name}}
                ]
            },
            ignore=ignore
        );
    }

    function changeAlias(
        required name,
        required index,
        previousIndex="_all",
        ignore=""        
    ) {
        return updateAliases(
            [
                {"remove" = {"index"=previousIndex, "alias"=name}},
                {"add" = {"index"=index, "alias"=name}}
            ],
            ignore=ignore
        );
    }

    function updateAliases(
        required actions,
        ignore=""        
    ) {
        return makeHttpRequest(
            method="post",
            url=createUrl("_aliases"),
            body={
                "actions"=actions
            },
            ignore=ignore
        );
    }

    function getAlias(
        index="",
        alias="",
        ignore=""
    ) {
        return makeHttpRequest(
            method="get",
            url=createUrl(index, "_alias", alias),
            ignore=ignore
        );
    }

    function aliasExists(
        required name,
        index=""
    ) {
        return makeHttpRequest(
            method="head",
            url=createUrl(index, "_alias", name),
            ignore="404"
        ).is200();
    }

    /*** DOCUMENT METHODS ***************************************************/

    function insertDocument(
        required index,
        required type,
        required id,
        required body,
        ignore=""
    ) {
        return makeHttpRequest(
            method="put",
            url=createUrl(index, type, id),
            body=body,
            ignore=ignore
        );
    }

    function getDocument(
        required index,
        required type,
        required id,
        ignore=""
    ) {
        return makeHttpRequest(
            method="get",
            url=createUrl(index, type, id),
            ignore=ignore
        );
    }

    function updateDocument(
        required index,
        required type,
        required id,
        required body,
        ignore=""
    ) {
        return makeHttpRequest(
            method="post",
            url=createUrl(index, type, id, "_update"),
            body=body,
            ignore=ignore
        );
    }

    function documentExists(
        required index,
        required type,
        required id
    ) {
        return makeHttpRequest(
            method="head",
            url=createUrl(index, type, id),
            ignore="404"
        ).is200();
    }

    function removeDocument(
        required index,
        required type,
        required id,
        ignore=""
    ) {
        return makeHttpRequest(
            method="delete",
            url=createUrl(index, type, id),
            ignore=ignore
        );
    }

    /*** BULK ***************************************************************/

    function bulk(
        required actions,
        index="",
        type="",
        ignore=""
    ) {
        for (var i=1; i lte arrayLen(actions); i++) {
            if (not isJSON(actions[i])) actions[i] = serializeJSON(actions[i]);
        }

        return makeHttpRequest(
            method="post",
            url=createUrl(index, type, "_bulk"),
            body=arrayToList(actions, "#chr(10)#") & "#chr(10)#",
            ignore=ignore
        );
    }

    function searchAndReplace(
        required index,
        required type,
        required body,
        required fields,
        required regex,
        required substring,
        scope="all",
        ignore=""
    ) {
        var scroll_id = search(
            index=index,
            type=type,
            body=body,
            params={
                "search_type"="scan",
                "scroll"="5m"
            }
        ).toJSON()["_scroll_id"];

        var results = searchScroll(scroll="5m", scrollId=scroll_id).toJSON();

        while (arrayLen(results["hits"]["hits"])) {
            var actions = [];

            for (var i=1; i lte arrayLen(results["hits"]["hits"]); i++) {
                var record = results["hits"]["hits"][i];

                var updatedDoc = {};

                for (var field in listToArray(fields)) {
                    if (structKeyExists(record["_source"], field)) {
                        updatedDoc[field] = reReplace(record["_source"][field], regex, substring, scope);
                    }
                }

                arrayAppend(actions, { "update"={ "_id"=record["_id"], "_type"=record["_type"], "_index"=record["_index"] } });
                arrayAppend(actions, { "doc"=updatedDoc });
            }

            bulk(
                actions=actions,
                ignore=ignore
            );

            var results = searchScroll(scroll="5m", scrollId=scroll_id, ignore="404").toJSON();
        }
    }
 
    /*** PRIVATE METHODS ****************************************************/

    private function createUrl() {
        var href = getHost();

        for(var param in arguments) {
            if(len(arguments[param])) { href = listAppend(href, arguments[param], "/"); }
        }

        return href;
    }

    HTTP_ERRORS = {
        0   = "elasticsearch.TransportError.ConnectionError",
        400 = "elasticsearch.TransportError.RequestError",
        404 = "elasticsearch.TransportError.NotFoundError",
        409 = "elasticsearch.TransportError.ConflictError"
    };

    private function makeHttpRequest(
        required string method,
        required string url,
        any body,
        array auth,
        struct params={},
        struct headers={},
        string ignore=""
    ) {
        var http = new http(
            url=arguments.url,
            method=arguments.method
        );

        if (isDefined("arguments.auth")) {
            http.setUsername(auth[1]);
            http.setPassword(auth[2]);
        }

        if (isDefined("arguments.body") and (not isSimpleValue(arguments.body) or len(arguments.body))) {
            if (not structKeyExists(headers, "Content-Type")) {
                if (isStruct(body) or isJson(body)) {
                    http.addParam(type="header", name="Content-Type", value="application/json");
                } else if (isXml(body)) {
                    http.addParam(type="header", name="Content-Type", value="application/xml; charset=UTF-8");
                }
            }

            http.addParam(type="body", value=(isStruct(body) ? serializeJSON(body) : body));
        }

        for (var key in arguments.params)
            http.addParam(type="url", name=key, value=params[key]);
        for (var key in arguments.headers)
            http.addParam(type="headers", name=key, value=headers[key]);

        var response = new ElasticsearchResponse().setResponse(http.send().getPrefix());

        if (response.hasErrors() and (arguments.ignore != "all" or not listFindNoCase(response.getStatusCode(), arguments.ignore))) {
            var responseJSON = response.toJSON();

            var errorType = (
                structkeyexists(HTTP_ERRORS, response.getStatusCode())
                    ? HTTP_ERRORS[response.getStatusCode()]
                    : "elasticsearch.TransportError"
            );

            var errorDetail = (
                isstruct(responseJSON) and structkeyexists(responseJSON, "error")
                    ? responseJSON.error
                    : ""
            );

            throw(
                type=errorType,
                message=errorType,
                detail=errorDetail,
                extendedInfo=response.toString(),
                code=response.getStatusCodeString()
            );
        }

        return response;
    }

    private function structToQueryString(required structure) {
        var queryString = "";

        for (var key in structure) {
            queryString = listAppend(queryString, URLEncodedFormat(lcase(key)) & "=" & URLEncodedFormat(structure[key]), "&");
        }

        return "?" & queryString;
    }

}
