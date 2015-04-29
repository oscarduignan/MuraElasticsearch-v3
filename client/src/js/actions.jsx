import Reflux from 'reflux';
import { getServiceStatus, reindexSiteContent } from 'API';

var actions = Reflux.createActions({
    'checkServiceHealth': { asyncResult: true },
    'reindexSiteContent': { asyncResult: true },
});

actions.checkServiceHealth.listen(function() {
    getServiceStatus((err, res) => err ? this.failed(err, res) : this.completed(res.body.status == 200 ? 'online' : 'offline'));
});

actions.reindexSiteContent.listen(function() {
    reindexSiteContent((err, res) => err ? this.failed(err, res) : this.completed(res));
});

export default actions;