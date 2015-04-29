import React from 'react';
import Reflux from 'reflux';
import actions from 'actions';

export var HistoryStore = Reflux.createStore({
    data: [],

    getInitialState() {
        return this.data;
    },
});

export var HistoryViewer = React.createClass({
    render() {
        return (
            <table className="table table-bordered" style={{fontSize: '14px', borderColor: '#CCC'}}>
                <tr style={{backgroundColor: '#EEE'}}>
                    <th>Started</th>
                    <th>Status</th>
                    <th>Indexed</th>
                </tr>
                <tr>
                    <td><span title="2 days ago">YYYY-MM-DD HH:SS</span> by <a href="#">Oscar</a></td>
                    <td>Completed</td>
                    <td>30</td>
                </tr>
            </table>
        );
    }
});
