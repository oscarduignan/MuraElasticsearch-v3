import token from 'CSRFToken';
import Reflux from 'reflux';
import actions from 'actions';
import request from 'superagent';
import update from 'react/lib/update'

var API_URL = 'API.cfc';

export function getServiceStatus(callback) {
    return request
        .get(API_URL)
        .set('X-CSRF-Token', token)
        .query({method: 'getServiceStatus'})
        .end(ErrorStore.handleError(callback));
}

export function getIndexHistory(callback) {
    return request
        .get(API_URL)
        .set('X-CSRF-Token', token)
        .query({method: 'getIndexHistory'})
        .end(ErrorStore.handleError(callback));
}

export function getMostRecentIndexAll(callback) {
    return request
        .get(API_URL)
        .set('X-CSRF-Token', token)
        .query({method: 'getMostRecentIndexAll', queryFormat: 'column'})
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