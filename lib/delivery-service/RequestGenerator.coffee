mysql    = require 'mysql'
Promise  = require 'bluebird'
async    = require 'async'
queue    = require './Queue'
Player   = require './Player'
Delivery = require './Delivery'
Message  = require './Message'


class DeliveryError extends Error
  constructor: (@message)->

class NoDeliveriesError extends Error
  constructor: (@message)->

class DeliveryIsDoneError extends Error
  constructor: (@message)->

class RequestGenerator

  #private
  create_requests = (first_name, delivery)->
    delivery
      .messages first_name
      .then (raw_ids)->
        throw new DeliveryIsDoneError if raw_ids.length is 0
        batches_count = Math.ceil raw_ids.length / 100
        batches = []
        # не лучшая идея
        for i in [0..batches_count-1]
          batches.push raw_ids.slice( i * 100, i * 100 + 100 )
        Promise.map batches, (batch)->
          ids = batch.map (row)->row.id
          return [] if ids.length is 0
          Message.toInflight(ids)

      .then (data)->
        Promise.map data, (ids)->
          return if ids.length is 0
          Message
            .toQueueData delivery, ids, first_name
            .then (request_params)->
              queue.push request_params

      .catch DeliveryIsDoneError, (e)->
        delivery.toDone()

  process_delivery = (delivery)->
    delivery.updateStatus 'inprogress'
      .then ->
        Player.names()
      .then (names)->
        Promise.map names, (name)->create_requests name, delivery

  # public
  constructor: ->
    @go = false

  start: ->
    return if @go
    @go = true
    @process()
    console.log 'RequestGenerator: start'

  stop: ->
    return unless @go
    @go = false
    console.log 'RequestGenerator: stop'

  process: =>
    Delivery
      .notFinished()
      .then (deliveries)->
        throw new NoDeliveriesError if deliveries.length is 0
        Promise.map deliveries, (delivery)->process_delivery(delivery)

      .catch NoDeliveriesError, (e)->
        console.log 'RequestGenerator: no deliveies to send... Wait 5000 ms'

      .finally ()=>
        console.log 'RequestGenerator: queue done. Length is', queue.length
        setTimeout(@process, 5000) if @go

module.exports = new RequestGenerator


