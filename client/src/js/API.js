import token from 'CSRFToken';
import Reflux from 'reflux';
import actions from 'actions';
import request from 'superagent';
import update from 'react/lib/update'

var API_URL = 'API.cfc';

export function search(options, callback) {
    var filter = {};

    // TODO abstract this so it works for tags too / any filters I have
    // TODO make the typeAndSubType global to search while maintaining count. And make it OR
    if (options.typeAndSubType) {
        var activeTypeAndSubTypes = [];

        Object.keys(options.typeAndSubType).map(typeAndSubType => {
            if (options.typeAndSubType[typeAndSubType] === 1) {
                activeTypeAndSubTypes.push(typeAndSubType);
            }
        });

        if (activeTypeAndSubTypes.length) {
            filter = {
                term: {
                    typeAndSubType: activeTypeAndSubTypes
                }
            };
        }
    }

    return request
        .post(API_URL)
        .query({method: 'search'})
        .send({
            query: {
                filtered: {
                    query: {
                        match_all: {}
                    },
                    filter: filter
                }
            },
            aggs: {
                tags: {
                    terms: {
                        field: 'tags',
                        size: 10
                    }
                },
                //all: {
                    //global: {},
                    // add filter here for the tags, so we see all
                    // the types available for the selected tags.
                    //aggs: {
                        typeAndSubType: {
                            terms: {
                                field: 'typeAndSubType'
                            }
                        }
                    //}
                //}
            },
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
            console.log(res);
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