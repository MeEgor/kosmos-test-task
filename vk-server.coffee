express    = require 'express'
app        = express()
counter    = require './lib/fake-vk-server/RequestCounter'
bodyParser = require 'body-parser'
config     = require('require-yml')('./config/vk.yml').vk

app.use bodyParser.urlencoded
  extended: true

app.get '/', (req, res)->
  res.json
    code: 0
    message: 'Hello fake vk service'

app.post '/sendNotification', (req, res)->
  fatal = Math.floor(Math.random() * 10000) <= 10000 * config.fatalChance
  counter.increment()
  if fatal
    res.json
      code: 2
      description: 'Server fatal error'

  else if counter.get() > config.requestsPerSecond
    res.json
      code: 1
      description: 'Too frequently'

  else
    console.log req.body
    res.json
      code: 0
      messages: req.body.id.split(',').map (id)->
        blocked = Math.floor(Math.random() * 100) <= config.blockChance
        # return
        id: id
        status: if blocked then 'blocked' else 'send'
        message: req.body.message

server = app.listen 8000, ->
  console.warn "VK fake server is listening on port 8000"
