express = require('express')
PushUser = require('../servers/pushUser')
Article = require('../models/article')
User = require('../models/user')
async = require('async')
saveErr = require('../servers/saveErr')
router = express.Router()

### GET users listing. ###

router.get '/', (req, res, next) ->

  Article.count {}, (err, count) ->
    return saveErr "", 2, {err:err} if err

    title = "Pocket连接管理"
    subscribe = req.session.subscribe

    return res.render 'users',
      {title:title,subscribe:subscribe,count:count}


router.get '/subscribe', (req, res) ->
  username = req.session.username
  subscribe = req.session.subscribe

  User.findOne {username:username}, (err, row) ->
    return saveErr "", 2, {err:err} if err

    if not row
      req.session.error = "没有找到用户"
      return res.redirect('/')

    if subscribe is true
      subscribe = false

    else
      subscribe = true

    row.subscribe = subscribe
    row.save (err2, row2) ->
      return saveErr "", 2, {err:err2} if err2

      req.session.subscribe = subscribe

      return res.redirect('/')



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