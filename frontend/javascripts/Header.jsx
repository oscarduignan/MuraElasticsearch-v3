import React from 'react';
import ElasticsearchStatus from 'ElasticsearchStatus';

export default class Header extends React.Component {
    render() {
        return (
            <div className="mura-elasticsearch-header">
                <h1>Mura Elasticsearch Admin</h1>

                <ElasticsearchStatus siteid="elastic" />
            </div>
        );
    }
}