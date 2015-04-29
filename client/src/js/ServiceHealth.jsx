import React from 'react';
import Reflux from 'reflux';
import actions from 'actions';
import { ReindexButton } from 'ReindexButton';

export var HostStore = Reflux.createStore({
    getInitialState() {
        return undefined;
    },

    init() {
        this.listenTo(actions.checkServiceHealth.completed, (res) => this.trigger(res.body.host));
    },
});

export var StatusStore = Reflux.createStore({
    getInitialState() {
        return undefined;
    },

    init() {
        this.listenTo(actions.checkServiceHealth, () => this.trigger('loading'));
        this.listenTo(actions.checkServiceHealth.failed, () => this.trigger('offline'));
        this.listenTo(actions.checkServiceHealth.completed, (res) => this.trigger(res.body.status));
    },
});

export var ServiceHealth = React.createClass({
    mixins: [
        Reflux.connect(HostStore, 'host'),
        Reflux.connect(StatusStore, 'status'),
    ],

    componentDidMount() {
        this.checkServiceHealth();
    },

    checkServiceHealth() {
        actions.checkServiceHealth.triggerAsync();
    },

    render() {
        var { host, status } = this.state;

        return (
            <div className={"service-status service-status--" + status} style={{}}>
                <div>
                    {status ? (
                        <div>
                            {host ? <h3>{host}</h3> : false}
                            <div>
                                <span className="service-status__label">
                                    {status}
                                </span>
                            </div>
                        </div>
                    ) : false }
                    <div>
                        <button onClick={this.checkServiceHealth}>
                            Check service status
                        </button>
                    </div>
                </div>
                <div>
                    <ReindexButton />
                </div>
            </div>
        );
    }
});