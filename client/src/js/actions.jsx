import Reflux from 'reflux';
import { search, getServiceStatus, reindexSiteContent } from 'API';

var actions = Reflux.createActions({
    'search': { asyncResult: true },
    'getServiceStatus': { asyncResult: true },
    'reindexSiteContent': { asyncResult: true },
});

actions.search.listen(function(q) {
    search(q, undefined, undefined, (err, res) => err ? this.failed(err, res) : this.completed(res));
});

actions.getServiceStatus.listen(function(historySince) {
    getServiceStatus(historySince, (err, res) => err ? this.failed(err, res) : this.completed(res));
});

actions.reindexSiteContent.listen(function() {
    reindexSiteContent((err, res) => err ? this.failed(err, res) : this.completed(res));
});

export default actions;