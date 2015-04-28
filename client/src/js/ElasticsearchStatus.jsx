import React from 'react';
import Reflux from 'reflux';
import statusStore from 'ElasticsearchStatusStore';

export default React.createClass({
    mixins: [Reflux.connect(statusStore, 'currentStatus')],

    render: function() {
        return (
            <div className="elasticsearch-status">
                <strong class="elasticsearch-status__label">Current status:</strong> {this.state.currentStatus ? this.state.currentStatus : "unknown"}
            </div>
        );
    }
});