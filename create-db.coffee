# create tables
# populate players

_  = require 'underscore'
db = require './lib/delivery-service/DB'
config = require('require-yml')('./config/seed.yml').seed
console.log config

names = config.names
usersCount = config.usersCount
ids = []

# create table Players
create_table_players = "
  CREATE TABLE IF NOT EXISTS players (
    id INT(11) NOT NULL AUTO_INCREMENT,
    vk_uid INT(11) NOT NULL,
    first_name CHAR(30) NOT NULL,
    PRIMARY KEY(id),
    UNIQUE(vk_uid),
    INDEX(first_name)
  );
"
db.query create_table_players, (err,rows,fields)->
  throw err if err
  console.log 'Table players was created'

# create table Deliveries
create_table_deliviries = "
  CREATE TABLE IF NOT EXISTS deliveries(
    id INT(11) NOT NULL AUTO_INCREMENT,
    template TEXT NOT NULL,
    status CHAR(10) NOT NULL DEFAULT 'new',
    PRIMARY KEY(id),
    INDEX(status)
  );
"
db.query create_table_deliviries, (err, rows, fields) ->
  throw err if err
  console.log 'Table deliveries was created'

# create table Messages
create_table_messages = "
  CREATE TABLE IF NOT EXISTS messages(
    id INT(11) NOT NULL AUTO_INCREMENT,
    player_id INT(11) NOT NULL,
    delivery_id INT(11) NOT NULL,
    status CHAR(10) NOT NULL DEFAULT 'new',
    PRIMARY KEY(id),
    INDEX(player_id),
    INDEX(delivery_id),
    INDEX(status)
  );
"
db.query create_table_messages, (err, rows, fields) ->
  throw err if err
  console.log 'Table messages was created'

# create players
while ids.length < usersCount
  ids.push Math.floor( Math.random() * Math.pow(10, 7) )
  ids = _.uniq ids

data = _.uniq(ids).map (id)->
  vk_uid:     id
  first_name: names[Math.floor( Math.random() * names.length )]

db.insert_ignore 'players', data, (err, info)->
  console.log info

db.connection().end()
