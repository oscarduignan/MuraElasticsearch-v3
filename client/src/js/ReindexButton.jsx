import React from 'react';
import Reflux from 'reflux';
import actions from 'actions';
import { IndexingStatus } from 'IndexingStatus';

export var ReindexStatusStore = Reflux.createStore({
    getInitialState() {
        return undefined;
    },

    init() {
        this.listenTo(actions.reindexSiteContent, () => this.trigger('indexing'));
        this.listenTo(actions.reindexSiteContent.completed, () => this.trigger('completed'));
        this.listenTo(actions.reindexSiteContent.failed, () => this.trigger('failed'));
    },
});

export var ReindexButton = React.createClass({
    mixins: [Reflux.connect(ReindexStatusStore, 'status')],

    handleClick() {
        actions.reindexSiteContent.triggerAsync();
    },

    render() {
        var { status } = this.state;

        return (
            <div>
                {status
                    ? <IndexingStatus />
                    : (
                        <button style={{fontSize: '14px'}} onClick={this.handleClick}>
                            Reindex site content
                        </button>
                    )}
            </div>
        );
    }
});