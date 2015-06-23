Promise    = require 'bluebird'
Db         = require 'mysql-activerecord'
dbConfig   = require('require-yml')('./config/database.yml').db

db = new Db.Adapter
    server:   dbConfig.server
    username: dbConfig.username
    password: dbConfig.password
    database: dbConfig.database

module.exports = Promise.promisifyAll(db)

