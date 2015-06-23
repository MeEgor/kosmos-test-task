request = require 'request'
Promise = require 'bluebird'

module.exports = Promise.promisifyAll request
