import Reflux from 'reflux';
import { getServiceStatus } from 'API';

var actions = Reflux.createActions({
    'checkServiceStatus': { asyncResult: true },
});

actions.checkServiceStatus.listen(function() {
    getServiceStatus((err, res) => err ? this.failed(err) : this.completed(res.body.status == 200 ? 'online' : 'offline'));
});

export default actions;