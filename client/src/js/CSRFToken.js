import filter from 'lodash/collection/filter';

var meta = filter(document.getElementsByTagName('meta'), e => e.getAttribute('name') == 'csrf-token');

module.exports = meta.length ? meta[0].getAttribute('content') : undefined;