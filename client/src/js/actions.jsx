import Reflux from 'reflux';
import { getServiceStatus, reindexSiteContent } from 'API';

var actions = Reflux.createActions({
    'getServiceStatus': { asyncResult: true },
    'reindexSiteContent': { asyncResult: true },
});

actions.getServiceStatus.listen(function(historySince) {
    getServiceStatus(historySince, (err, res) => err ? this.failed(err, res) : this.completed(res));
});

actions.reindexSiteContent.listen(function() {
    reindexSiteContent((err, res) => err ? this.failed(err, res) : this.completed(res));
});

export default actions;