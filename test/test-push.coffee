PushUser = require('../servers/pushUser')
async = require('async')
p = new PushUser('youqingkui')
async.series [
  (cb) ->
    p.getToken (err) ->
      return console.log err if err

      cb()

  (cb) ->
    p.getArticle (err) ->
      return console.log err if err

      cb()

  (cb) ->
    p.pushInfo (err) ->
      return console.log err if err


      console.log "dododo"



]