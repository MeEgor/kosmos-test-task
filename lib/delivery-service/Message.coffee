db = require './DB'

class Message

  constructor: (@data)->

  @toInflight: (ids)->
    db
      .where 'id', ids
      .updateAsync 'messages', { status: 'inflight' }
      .then (resp)->ids
      .catch ->[]

  @toQueueData: (delivery, ids, name)->
    db
      .select ['players.vk_uid']
      .join 'players', 'players.id = messages.player_id', 'inner'
      .where 'messages.id', ids
      .limit ids.length
      .getAsync 'messages'
      .then (rows)->
        # return
        messages: ids
        text:     delivery.get('template').replace(/%first_name%/g, name)
        vk_uids:  rows[0].map (row)->row.vk_uid

module.exports = Message
