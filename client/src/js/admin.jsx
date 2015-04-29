import React from 'react';
import { ServiceHealth } from 'ServiceHealth';
import { HistoryViewer } from 'HistoryViewer';

require('admin.scss');

React.render((
    <div style={{position: 'relative'}}>
        <h1 style={{color: '#5bb75b !important'}}>Elasticsearch</h1>
        <ServiceHealth />
        <h2 style={{fontWeight: 'bold'}}>Index history</h2>
        <HistoryViewer />
    </div>
), document.getElementById('mura-elasticsearch-admin'));