import React from 'react';
import actions from 'actions';
import { Link } from 'react-router';

export var SearchForm = React.createClass({
    handleSubmit(event) {
        event.preventDefault();
        this.context.router.transitionTo('search', false, {q: this.refs.searchInput.getDOMNode().value});
    },

    contextTypes: {
        router: React.PropTypes.func.isRequired,
    },

    render() {
        return (
            <form onSubmit={this.handleSubmit} className="mes-search-form">
                <div className="input-append">
                    <input ref="searchInput" type="text" className="mes-search-form__text" />
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
    render() {
        return (
            <p>
                This feature is not yet implemented, <Link to="/">go back to the index overview</Link>
            </p>
        );
    }
});