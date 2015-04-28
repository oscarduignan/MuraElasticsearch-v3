import React from 'react';
import Header from 'Header';
import actions from 'actions';

require('admin.scss');

React.render((
    <div>
        <Header/>
        <button onClick={actions.checkElasticsearchStatus}>refresh status</button>
    </div>
), document.getElementById('mura-elasticsearch-admin'));