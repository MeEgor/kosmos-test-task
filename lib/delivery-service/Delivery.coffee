db = require './DB'

class Delivery

  constructor: (@data)->

  # set locals variables
  get: (key)->
    @data[key]

  set: (key, value)->
    @data[key] = value

  id: ->
    @data.id

  # methods with DB
  updateStatus: (value)->
    db
      .where 'deliveries.id', @id()
      .limit 1
      .updateAsync 'deliveries', {status: value}

  toDone: ->
    console.log "Delivery: try to finish delivery #{ @id() }..."
    db
      .select 'messages.id'
      .where "messages.delivery_id = #{@data.id} AND (messages.status = 'new' OR messages.status = 'inflight')"
      .getAsync 'messages'
      .then (rows)=>
        if rows[0].length is 0
          console.log "Delivery: success. Delivery #{ @id() } is done."
          @updateStatus 'done'
        else
          console.log "Delivery: delivery #{ @id() } still has some messages."

  messages: (name)->
    db
      .select ['messages.id']
      .join 'players', 'players.id = messages.player_id', 'inner'
      .where
        'messages.delivery_id': @data.id
        'players.first_name': name
        'messages.status': 'new'
      .getAsync 'messages'
      .then (rows)->
        rows = rows[0]

  @create: (template)->
    delivery_id = null
    db
      .insertAsync 'deliveries', template: template
      .then (data)->
        delivery_id = data[0].insertId
        create_messages = "
          INSERT INTO messages (player_id, delivery_id)
          SELECT players.id AS player_id, #{ delivery_id } AS delivery_id FROM players;
        "
        db
          .queryAsync create_messages

      .then (rows)->
        console.log 'delivery created ->', delivery_id
        Delivery.find delivery_id

  @find: (id)->
    db
      .select ['deliveries.id', 'deliveries.template']
      .where 'deliveries.id', id
      .limit 1
      .getAsync 'deliveries'
      .then (rows)=>
        new Delivery rows[0][0]

  @notFinished: ->
     db
      .where "deliveries.status = 'new' OR deliveries.status = 'inprogress'"
      .getAsync 'deliveries'
      .then (rows)->
        deliveries = rows[0].map (row)->
          new Delivery row

module.exports = Delivery

