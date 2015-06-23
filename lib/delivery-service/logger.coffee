Promise  = require 'bluebird'
fs       = require 'fs'

fs = Promise.promisifyAll fs
log_file = 'logs/logger.log'

class MyLogger
  line = (text, level)->
    "#{ new Date() } #{ level } #{ text };\n"
  info: (text)-> fs.appendFileAsync log_file, line(text, 'info')
  fatal:(text)-> fs.appendFileAsync log_file, line(text, 'fatal')
  warn: (text)-> fs.appendFileAsync log_file, line(text, 'warn')
  error:(text)-> fs.appendFileAsync log_file, line(text, 'error')

module.exports = new MyLogger
