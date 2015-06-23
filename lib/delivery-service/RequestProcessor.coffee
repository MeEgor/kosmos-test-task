mysql    = require 'mysql'
Promise  = require 'bluebird'
async    = require 'async'
request  = require './RequestAsync'
queue    = require './Queue'
logger   = require './logger'
db       = require './DB'


class TooFriquentlyError extends Error
  constructor: (@message, @errorData)->
  getData: -> @errorData

class ApiFatalError extends Error
  constructor: (@message)->

class RequestProcessor

  #private
  progress_request = (data)->
    request
      .postAsync 'http://localhost:8000/sendNotification',
        form:
          id: data.vk_uids.join(',')
          message: data.text

      .then (resp)->
        resp = JSON.parse(resp[0].body)
        if resp.code is 0
          resp.messages.forEach (msg)->
            logger.info "uid: #{ msg.id }; status: #{ msg.status }; message: #{ msg.message }"
          data.messages

        else if resp.code is 1
          throw new TooFriquentlyError 'too friquently', data

        else if resp.code is 2
          throw new ApiFatalError 'api is not available!'

      .then (messages)->
        console.log 'success! update messages', queue.length
        db
          .where 'messages.id', messages
          .updateAsync 'messages', { status:'sent' }

      .catch TooFriquentlyError, (e)->
        queue.push e.getData()
        logger.warn e.message
        console.log "RequestProcessor: warning! #{ e.message }", queue.length

      .catch ApiFatalError, (e)->
        console.log "RequestProcessor: fatal! #{ e.message }"
        logger.fatal e.message
        process.exit()

      .catch (e)->
        console.log "RequestProcessor: fatal! #{ e.message }"
        logger.fatal e.message
        process.exit()

  # public
  constructor: ->
    @go = false

  start: ->
    return if @go
    @go = true
    @process()
    console.log 'RequestProcessor: start'

  stop: ->
    return unless @go
    @go = false
    console.log 'RequestProcessor: stop'

  process: =>
    return unless @go
    console.log 'RequestProcessor: tick', queue.length
    if queue.length is 0
      console.log 'RequestProcessor: queue is empty. Wait... 5000 ms'
      setTimeout @process, 5000
    else
      async.whilst ()=>
            queue.length > 0
        , (next)->
            data = queue.shift()
            progress_request(data)
            setTimeout next, 300
        , ()=>
          console.log 'RequestProcessor: requests are done'
          @process()

module.exports = new RequestProcessor


