db = require './DB'

class Player

  constructor: (@data)->

  @names: ->
    db
      .queryAsync 'select distinct(players.first_name) as name from players;'
      .then (rows)->
        names = rows[0].map (row)->row.name

module.exports = Player