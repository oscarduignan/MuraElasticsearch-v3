import React from 'react';
import Header from 'Header';
import actions from 'actions';

React.render((
    <div>
        <Header/>
        <button onClick={actions.checkElasticsearchStatus}>refresh status</button>
    </div>
), document.getElementById('mura-elasticsearch-admin'));