import token from 'CSRFToken';
import Reflux from 'reflux';
import actions from 'actions';
import request from 'superagent';
import update from 'react/lib/update'

var API_URL = 'API.cfc';

export function search(options, callback) {
    return request
        .post(API_URL)
        .query({method: 'search'})
        .send({
            query: {
                query_string: {
                    query: options.q || '*',
                    fields: ['title', 'summary', 'body', 'tags']
                }
            },
            // TODO add pagination
            from: 0,
            size: 10
        })
        .end(ErrorStore.handleError(callback));
}

export function getServiceStatus(historySince, callback) {
    var query = {method: 'getServiceStatus'};

    if (historySince) query.historySince = historySince;

    return request
        .get(API_URL)
        .set('X-CSRF-Token', token)
        .query(query)
        .end(ErrorStore.handleError(callback));
}

export function reindexSiteContent(callback) {
    return request
        .post(API_URL)
        .set('X-CSRF-Token', token)
        .query({method: 'reindexSiteContent'})
        .end(ErrorStore.handleError(callback));
}

export var ErrorStore = Reflux.createStore({
    errors: [],

    handleError(callback) {
        return (err, res) => {
            if (err) this.addError(err, res);
            callback(err, res);
        };
    },

    addError(err, res) {
        this.errors = update(this.errors, {$push: [{
            timestamp: Date.now(),
            err: err,
            res: res
        }]});
        this.trigger(this.errors);
    },
});