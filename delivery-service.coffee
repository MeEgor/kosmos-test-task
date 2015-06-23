express          = require 'express'
bodyParser       = require 'body-parser'
Promise          = require 'bluebird'
db               = require './lib/delivery-service/DB'
queue            = require './lib/delivery-service/Queue'
requestGenerator = require './lib/delivery-service/RequestGenerator'
requestProcessor = require './lib/delivery-service/RequestProcessor'
Delivery         = require './lib/delivery-service/Delivery'

app = express()

app.use bodyParser.urlencoded
  extended: true

app.get '/', (req, res)->
  res.json
    code: 0
    message: 'Hello delivery-service'

app.get '/send', (req, res)->
  template = req.query.template or "Hell yeah! %first_name%"
  Delivery.create template
  res.send "Delivery begin"

# prepare messages
prepare_messages = db
  .where 'messages.status':'inflight'
  .updateAsync 'messages', {status:'new'}
# prepare deliveries
prepare_deliveries = db
  .where 'deliveries.status':'inprogress'
  .updateAsync 'deliveries', {status:'new'}
# start app after all prepared
Promise
  .all [prepare_deliveries, prepare_messages]
  .then ->
    requestGenerator.start()
    requestProcessor.start()

    app.listen 3000, ->
      console.warn "Delivery server is listening on port 3000"
