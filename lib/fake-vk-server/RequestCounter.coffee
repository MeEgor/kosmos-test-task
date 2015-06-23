class RequestCounter

  constructor: ->
    @count = 0
    @timer = setInterval =>
        @count = 0
        console.log "count now: #{ @count }"
      , 1000

  get: ->
    @count

  increment: ->
    @count += 1

module.exports = new RequestCounter()
