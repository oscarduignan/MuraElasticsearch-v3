import React from 'react';
import Reflux from 'reflux';
import actions from 'actions';

export var ServiceStatusStore = Reflux.createStore({
    getInitialState() {
        return 'unknown';
    },

    init() {
        this.listenTo(actions.checkServiceStatus, () => this.trigger('loading'));
        this.listenTo(actions.checkServiceStatus.failed, () => this.trigger('offline'));
        this.listenTo(actions.checkServiceStatus.completed, (status) => this.trigger(status));
    },
});

export var ServiceStatus = React.createClass({
    mixins: [Reflux.connect(ServiceStatusStore, 'status')],

    triggerRefresh() {
        actions.checkServiceStatus.triggerAsync();
    },

    render() {
        var { status } = this.state;

        return (
            <div style={{position: 'absolute', top: '10px', right: 0, textAlign: 'left', height: '30px', lineHeight: '30px', fontSize: '14px'}} className={"well clearfix service-status service-status--" + status}>
                <span style={{paddingBottom: '3px', width: '150px', marginRight: '50px', display: 'inline-block', verticalAlign: 'middle', lineHeight: 'normal'}} className="service-status__status">
                    <strong style={{marginRight: '10px'}}>status:</strong>
                    <span style={{display: 'inline-block', marginTop: '-7px'}} className="service-status__label">{status}</span>
                </span>
                <button style={{marginBottom: '3px', verticalAlign: 'middle', lineHeight: 'normal', display: 'inline-block'}} className="service-status__refresh" onClick={this.triggerRefresh}>refresh</button>
            </div>
        );
    }
});