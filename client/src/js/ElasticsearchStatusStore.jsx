import Reflux from 'reflux';
import actions from './actions';
import request from 'superagent';

export default Reflux.createStore({
    init: function() {
        this.listenTo(actions.checkElasticsearchStatus, this.onStatusCheck);
    },

    onStatusCheck: function() {
        // TODO need to be able to have a separate store for each siteid, not sure best way to do this at the moment
        request
            .get("API.cfc?method=getElasticsearchStatus&siteid=elastic")
            .end(function(err, res) {
                if (res.ok && res.body.status === 200) {
                    this.trigger('ONLINE');
                } else {
                    this.trigger('OFFLINE');
                }
            }.bind(this));
    }
});