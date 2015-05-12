express = require('express')
PushUser = require('../servers/pushUser')
async = require('async')
router = express.Router()

### GET users listing. ###

router.get '/', (req, res, next) ->
  return res.render 'users'


router.get '/push', (req, res) ->
  username = req.session.username
  p = new PushUser(username)
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
        req.session.success = "推送成功"
        return res.redirect '/users'

  ]



module.exports = router