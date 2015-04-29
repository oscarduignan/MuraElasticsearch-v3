import React from 'react';
import Reflux from 'reflux';
import actions from 'actions';
import { ReindexButton } from 'ReindexButton';

export var ServiceHealthStore = Reflux.createStore({
    getInitialState() {
        return 'unknown';
    },

    init() {
        this.listenTo(actions.checkServiceHealth, () => this.trigger('loading'));
        this.listenTo(actions.checkServiceHealth.failed, () => this.trigger('offline'));
        this.listenTo(actions.checkServiceHealth.completed, (status) => this.trigger(status));
    },
});

export var ServiceHealth = React.createClass({
    mixins: [Reflux.connect(ServiceHealthStore, 'status')],

    componentDidMount() {
        this.checkServiceHealth();
    },

    checkServiceHealth() {
        actions.checkServiceHealth.triggerAsync();
    },

    render() {
        var { status } = this.state;

        return (
            <div style={{position: 'absolute', top:'10px', right:0}}>
                <div style={{margin: 0, display: 'inline-block', border: '1px solid #CCC', borderRight: 0, borderRadius: '5px', borderTopRightRadius: 0, borderBottomRightRadius:0, textAlign: 'left', height: '37px', lineHeight: '37px', fontSize: '14px'}} className={"well clearfix service-status service-status--" + status}>
                    <span style={{marginLeft: '4px', paddingBottom: '3px', width: '120px', marginRight: '20px', display: 'inline-block', verticalAlign: 'middle', lineHeight: 'normal'}} className="service-status__status">
                        <strong style={{marginRight: '10px'}}>Current status:</strong>
                        <span style={{display: 'inline-block', marginTop: '4px'}} className="service-status__label">{status}</span>
                    </span>
                    <button style={{marginRight: '5px', marginBottom: '2px', verticalAlign: 'middle', lineHeight: 'normal', display: 'inline-block', fontSize: '15px'}} className="btn service-status__refresh" onClick={this.checkServiceHealth}>refresh</button>
                </div>
                <div style={{lineHeight: '37px',border: '1px solid #CCC', height: '37px', borderLeft: 0, padding: '9px', fontSize: '14px', backgroundColor: '#EAEAEA', display: 'inline-block', borderTopRightRadius: '5px', borderBottomRightRadius: '5px'}}>
                    <ReindexButton />
                </div>
            </div>
        );
    }
});