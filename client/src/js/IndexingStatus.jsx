import React from 'react';
import request from 'superagent';
import { getMostRecentIndexAll } from 'API';

export var IndexingStatus = React.createClass({
    getInitialState() {
        return {
            status: undefined
        }
    },

    getDefaultProps() {
        return {
            pollInterval: 1000
        }
    },

    getProgress() {
        getMostRecentIndexAll((err, res) => {
            if (!err) {
                this.setState(res.body);

                if (res.body.STATUS != 'indexing') {
                    clearInterval(this.interval);
                }
            }
        });
    },

    componentDidMount() {
        this.interval = setInterval(this.getProgress, this.props.pollInterval);
    },

    componentWillUnmount() {
        clearInterval(this.interval);
    },

    render() {
        var { TOTALINDEXED, TOTALTOINDEX, STATUS } = this.state;
        var percent = (
            STATUS == 'indexing'
                ? TOTALINDEXED / TOTALTOINDEX * 100
                : 100
        );

        return (
            <div className="progress" style={{position: 'relative', width: '100%', minWidth: '140px', margin: 'auto', height: '24px', lineHeight: '24px'}}>
                <div style={{position: 'absolute', textAlign: 'center', width: '100%', color: (STATUS == 'completed' || STATUS == 'failed' ? 'white' : '#333')}}>
                    {STATUS == 'indexing' && TOTALTOINDEX ? (
                        <span>{TOTALINDEXED ? TOTALINDEXED : 0} of {TOTALTOINDEX}</span>
                    ) : (
                        <span>{STATUS ? STATUS : 'indexing'}</span>
                    )}
                </div>
                <div className="progress-bar progress-bar-success" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style={{width: percent + "%", backgroundColor: (STATUS == 'completed' ? '#5bb75b' : STATUS == 'failed' ? 'rgb(211, 48, 48)' : '#999' ), textAlign: 'center', height: '100%'}}>
                    &nbsp;
                </div>
            </div>
        );
    }
});