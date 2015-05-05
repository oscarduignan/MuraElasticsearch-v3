import Reflux from 'reflux';
import { search, getServiceStatus, reindexSiteContent } from 'API';
import debounce from 'lodash/function/debounce';

var actions = Reflux.createActions({
    'updateQuery': {},
    'toggleFilter': {},
    'search': { asyncResult: true },
    'getServiceStatus': { asyncResult: true },
    'reindexSiteContent': { asyncResult: true },
});

actions.search.listen(function(options) {
    search(options, (err, res) => err ? this.failed(err, res) : this.completed(res));
});

actions.debouncedSearch = debounce(actions.search, 500);

actions.getServiceStatus.listen(function(historySince) {
    getServiceStatus(historySince, (err, res) => err ? this.failed(err, res) : setTimeout(_ => this.completed(res), 1000));
});

actions.reindexSiteContent.listen(function() {
    reindexSiteContent((err, res) => err ? this.failed(err, res) : this.completed(res));
});

export default actions;