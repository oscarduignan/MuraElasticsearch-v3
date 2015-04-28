import React from 'react';
import { ServiceStatus } from 'ServiceStatus';

require('admin.scss');

React.render((
    <div style={{position: 'relative'}}>
        <h1>Mura Elasticsearch Admin</h1>

        <ServiceStatus />
    </div>
), document.getElementById('mura-elasticsearch-admin'));