import React from 'react';
import Reflux from 'reflux';
import actions from 'actions';
import cx from 'classnames';
import update from 'react/lib/update';
import find from 'lodash/collection/find';
import sortBy from 'lodash/collection/sortBy';
import unique from 'lodash/array/unique';
import ReactCSSTransitionGroup from 'react/lib/ReactCSSTransitionGroup';
import moment from 'moment';

var IsLoadingStore = Reflux.createStore({
    getInitialState() {
        return false;
    },

    init() {
        this.listenTo(actions.getServiceStatus, _ => this.trigger(true));
        this.listenTo(actions.getServiceStatus.failed, _ => this.trigger(false));
        this.listenTo(actions.getServiceStatus.completed, _ => this.trigger(false));
    },
});

var ServiceStatusStore = Reflux.createStore({
    data: {
        host: undefined,
        status: undefined,
        size: undefined,
        history: []
    },

    getInitialState() {
        return this.data;
    },

    init() {
        this.listenTo(actions.getServiceStatus.completed, this.update);
    },

    update(res) {
        var { host, status, size, history } = res.body;

        this.data = update(this.data, {
            host: {$set: host},
            status: {$set: status},
            size: {$set: size},
            history: {$apply: (current) => {
                if (!history) return current;
                current.unshift(...history);
                return sortBy(unique(current, 'INDEXID'), function(reindex) {
                    return new Date(reindex["startedAt"]);
                });
            }},
        });

        this.trigger(this.data);
    },
});

export var IndexOverview = React.createClass({
    getInitialState() {
        return {
            visibleHistory: 5
        };
    },

    mixins: [
        Reflux.connect(IsLoadingStore, 'loading'),
        Reflux.connect(ServiceStatusStore, 'service'),
    ],

    checkForUpdates(delay=0) {
        var { service } = this.state;
        var { history } = service;
        actions.getServiceStatus(history && history.length > 1 ? history[1]['STARTEDAT'] : undefined, delay);
    },

    componentDidMount() {
        this.checkForUpdates();
        this.checkForUpdatesInterval = setInterval(_ => this.checkForUpdates(1000), 10000);
    },

    componentWillUnmount() {
        clearInterval(this.checkForUpdatesInterval);
    },

    render() {
        var { service, loading, visibleHistory } = this.state;
        var { host, status, size, history } = service;

        return (
            <dl>
                <dt>Service status</dt>
                <dd>
                    <table className="mes-details table table-bordered">
                        <tr>
                            <th>Host</th>
                            <td>{host ? host : "N/A"}</td>
                        </tr>
                        <tr>
                            <th>Status</th>
                            <td>
                                <span className={cx({
                                    'mes-details__status': true,
                                    'mes-details__status--online':  status == "online",
                                    'mes-details__status--offline': status == "offline",
                                })}>
                                    {status ? status : "N/A"}
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <th>Content indexed</th>
                            <td>{size ? size : "N/A"}</td>
                        </tr>
                    </table>
                </dd>
                <dt>Indexing operations</dt>
                <dd>
                    <ul className="mes-index-actions">
                        <li><button className="btn" onClick={() => {
                            actions.reindexSiteContent();
                            this.checkForUpdates();
                        }}>Reindex site content</button></li>
                    </ul>
                </dd>
                <dt>Reindex history <span className="mes-tip">{!loading ? <span>automatically refreshed every 10 seconds, <a style={{cursor: 'pointer'}} onClick={_ => { this.checkForUpdates(1000)}}>check now</a></span> : <span>checking for updates, please wait...</span>}</span></dt>
                <dd style={{textAlign:"center"}}>
                    <table className="table table-bordered mes-index-history">
                        <thead>
                            <tr>
                                <th className="mes-index-history__started">started</th>
                                <th className="mes-index-history__status">status</th>
                            </tr>
                        </thead>
                        <ReactCSSTransitionGroup component="tbody" transitionName="mes-reindex" transitionLeave={false}>
                            {history && history.length ? history.slice(0, visibleHistory).map(entry => {
                                var { INDEXID, STARTEDAT, TOTALINDEXED, TOTALTOINDEX, STATUS } = entry;
                                return (
                                    <tr key={INDEXID} title={moment(STARTEDAT).fromNow()} className={cx({
                                        'mes-reindex': true,
                                        'mes-reindex--failed': STATUS == 'failed',
                                        'mes-reindex--completed': STATUS == 'completed',
                                        'mes-reindex--cancelled': STATUS == 'cancelled',
                                    })}>
                                        <td>{moment(STARTEDAT).format("MMMM Do YYYY, h:mm:ss a")}</td>
                                        <td>
                                            <div className="progress" style={{position: 'relative', width: '100%', minWidth: '140px', margin: 'auto', height: '24px', lineHeight: '24px'}}>
                                                <div style={{position: 'absolute', textAlign: 'center', width: '100%', color: '#333'}}>
                                                    {STATUS} {TOTALTOINDEX ? "("+(TOTALINDEXED ? TOTALINDEXED : 0) + " of " + TOTALTOINDEX+")" : false}
                                                </div>
                                                {TOTALINDEXED ? (
                                                    <div className="progress-bar" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style={{width: ((TOTALINDEXED/TOTALTOINDEX)*100)+"%", textAlign: 'center', height: '100%'}}>
                                                        &nbsp;
                                                    </div>
                                                ) : false}
                                            </div>
                                        </td>
                                    </tr>
                               );
                            }) : false }
                        </ReactCSSTransitionGroup>
                    </table>
                    {visibleHistory < history.length ? <button className="btn" onClick={() => {
                        this.setState({visibleHistory: visibleHistory + 5});
                    }}>show more...</button> : false}
                </dd>
            </dl>
        );
    }
});