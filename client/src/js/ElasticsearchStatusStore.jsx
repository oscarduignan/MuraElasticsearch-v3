import Reflux from 'reflux';
import request from 'superagent';
import actions from 'actions';
import token from 'CSRFToken';

export default Reflux.createStore({
    init: function() {
        this.listenTo(actions.checkElasticsearchStatus, this.onStatusCheck);
    },

    onStatusCheck: function() {
        // TODO need to be able to have a separate store for each siteid, not sure best way to do this at the moment
        request
            .get('API.cfc?method=getElasticsearchStatus&siteid=elastic')
            .set('X-CSRF-Token', token)
            .end(function(err, res) {
                if (res.ok && res.body.status === 200) {
                    this.trigger('ONLINE');
                } else {
                    this.trigger('OFFLINE');
                }
            }.bind(this));
    }
});