import React from 'react';
import Router from 'react-router';
import { SearchForm, SearchResults } from 'Search';
import { IndexOverview } from 'IndexOverview';

var { Route, DefaultRoute, RouteHandler, Link } = Router;

require('admin.scss');

var Admin = React.createClass({
    render() {
        return (
            <div className="mes-admin">
                <div className="mes-admin__header clearfix">
                    <h1><Link to="admin">Elasticsearch</Link></h1>

                    <SearchForm />
                </div>

                <div className="mes-admin__content">
                    <RouteHandler />
                </div>

                <div className="mes-admin__footer">
                    <p>Plugin created by <a href="http://www.binaryvision.com">Binary Vision</a> learn more, contribute and get updates on the plugin's <a href="https://github.com/oscarduignan/MuraElasticsearch">GitHub repository</a></p>
                    <p><a href="https://www.elastic.co/products/elasticsearch">Elasticsearch</a> is a trademark of Elasticsearch BV, registered in the U.S. and in other countries.</p>
                </div>
            </div>
        );
    }
});

var routes = (
  <Route name="admin" path="/" handler={Admin}>
    <DefaultRoute handler={IndexOverview}/>
    <Route name="search" path="search" handler={SearchResults} />
  </Route>
);

Router.run(routes, Handler => {
    React.render(
        <Handler/>,
        document.getElementById('mura-elasticsearch-admin')
    );
});
