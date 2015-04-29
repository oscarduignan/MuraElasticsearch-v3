import React from 'react';
import { ServiceHealth } from 'ServiceHealth';
import { HistoryViewer } from 'HistoryViewer';

require('admin.scss');

/* need to have index stats too, maybe just copy default bootstrap form layout for this page */
/* <p style={{marginTop: '40px'}}><strong>TODO:</strong> make this appear in modal / alert on click of reindex site content with confirm / cancel options "this is required when you update index settings, it will not cause downtime, and updates made while the reindex is in progress will be made to the current and new index"</p> */

React.render((
    <div>
        <div className="clearfix" style={{display: 'flex', position: 'relative', height: '100px'}}>
            <h1 style={{flex:1,margin:'auto 0', color: '#5bb75b !important'}}>Elasticsearch</h1>

            <ServiceHealth />
        </div>
    </div>
), document.getElementById('mura-elasticsearch-admin'));