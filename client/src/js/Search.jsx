import React from 'react';
import Reflux from 'reflux';
import actions from 'actions';
import { Link } from 'react-router';
import pick from 'lodash/object/pick';
import update from 'react/lib/update';
import moment from 'moment';

export var SearchOptionsStore = Reflux.createStore({
    data: {},

    getInitialState() {
        return this.data;
    },

    init() {
        this.listenTo(actions.updateQuery, (q) => {
            this.data = {
                q: q
            };
            this.trigger(this.data);
            // this should not be debounced really should it
            // and when clicking this it should stop you
            // clicking any filters.
        });
    }
});

export var SearchResultsStore = Reflux.createStore({
    data: {
        inProgress: false
    },

    getInitialState() {
        return this.data;
    },

    init() {
        this.listenTo(SearchOptionsStore, (options) => {
            actions.debouncedSearch(options);
            this.data = update(this.data, {
                $merge: {
                    inProgress: true,
                }
            });
            this.trigger(this.data);
        })

        this.listenTo(actions.search.completed, (res) => {
            this.data = update(this.data, {
                $merge: {
                    inProgress: false,
                    response: res.body
                }
            });
            this.trigger(this.data);
        });
    },
});

export var SearchForm = React.createClass({
    getInitialState() {
        return pick(this.context.router.getCurrentQuery(), 'q');
    },

    handleChange(event){
        this.setState({q: event.target.value});
    },

    handleSubmit(event) {
        event.preventDefault();
        actions.updateQuery(this.state.q);
        this.context.router.transitionTo('search', false, {q: this.state.q});
    },

    contextTypes: {
        router: React.PropTypes.func.isRequired,
    },

    render() {
        return (
            <form onSubmit={this.handleSubmit} className="mes-search-form">
                <div className="input-append">
                    <input value={this.state.q} onChange={this.handleChange} type="text" className="mes-search-form__text" />
                    <button type="submit" className="btn mes-search-form__submit">Search</button>
                </div>
                <div className="mes-search-form__tip">
                    Tip: leave the field blank to browse all content
                </div>
            </form>
        );
    }
});

export var SearchResults = React.createClass({
    mixins: [Reflux.connect(SearchResultsStore, 'search')],

    componentDidMount() {
        // TODO add filters to the URL too
        actions.updateQuery(this.context.router.getCurrentQuery().q);
    },

    contextTypes: {
        router: React.PropTypes.func.isRequired,
    },

    render() {
        var { inProgress, response } = this.state.search;

        return (
            <div className="mes-search">
                <div className="mes-search__back">
                    <Link to="/">&lt; Back to index overview</Link>
                </div>
                <div className="mes-search__summary">
                    {response
                        ? <span>Viewing the first 10 results of the {response.hits.total} found for your search</span>
                        : false}
                </div>
                <div className="mes-search__results">
                    {response ? response.hits.hits.map(result => <SearchResult result={result} />) : false}
                </div>
            </div>
        );
    }
});

export var SearchResult = React.createClass({
    render() {
        var { _score, _source } = this.props.result;
        var { url, title, body, lastUpdate, type, subType } = _source;

        return (
            <div className="mes-search-result">
                <h2><a href={url}>{title}</a></h2>
                <p className="mes-search-result__meta"><strong>score:</strong> {_score}, <strong>type:</strong> {type}, <strong>subtype:</strong> {subType}, <strong>last updated:</strong> <span title={lastUpdate}>{moment(lastUpdate).fromNow()}</span></p>
                {body}
            </div>
        );
    }
});