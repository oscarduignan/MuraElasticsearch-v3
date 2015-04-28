import Reflux from 'reflux';

export default Reflux.createActions([
    // need to have a way for this to be async so I can show a "loading..." when it's checking the status
    'checkElasticsearchStatus'
]);
