import React from 'react';
import actions from 'actions';

export var ReindexButton = React.createClass({
    handleClick() {
        actions.reindexSiteContent.triggerAsync();
    },

    render() {
        return (
            <div>
                <button className="btn btn-success" style={{color: 'white', fontSize: '15px', marginBottom: '2px', marginRight: '5px', marginLeft: '5px'}} onClick={this.handleClick}>Reindex Site Content</button>
            </div>
        );
    }
});