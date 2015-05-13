express = require('express')
async = require('async')
request = require('request')
User = require('../models/user')
saveErr = require('../servers/saveErr')
router = express.Router()


### GET home page. ###

router.get '/', (req, res, next) ->
  if req.session.username
    return res.redirect('/users')
  res.render 'access', title: 'Cnode2Pocket'
  return


router.get '/auth', (req, res) ->
  key = process.env.pocket
  console.log key

  codeUrl = 'https://getpocket.com/v3/oauth/request'
  redirect_uri = process.env.pocket_url
  form = {
    'consumer_key':key
    'redirect_uri':redirect_uri
  }
  op = {
    url:codeUrl
    form:form
  }
  async.auto
    getCode:(cb) ->
      request.post op, (err, response, body) ->
        return saveErr op.url, 1, {err:err} if err

        if response.statusCode is 200
          code = body.split('=')[1]
          cb(null, code)

        else
          saveErr op.url, 2, {err:body}
          req.session.error = "连接Pocket出错"
          return res.redirect('/')


    directUrl:['getCode', (cb, result) ->
      code = result.getCode
      req.session.code = code
      url = "https://getpocket.com/auth/authorize?request_token=#{code}&redirect_uri=#{redirect_uri}"
      return res.redirect url

    ]


router.get '/oauth_callback', (req, res) ->
  if not req.session.code
    return res.redirect('/')

  url = 'https://getpocket.com/v3/oauth/authorize'
  key = process.env.pocket
  username = ''
  token = ''
  form = {
    consumer_key:key
    code:req.session.code
    headers:{
      'Content-Type': 'application/json; charset=UTF-8'
    }
  }

  op = {
    url:url
    form:form
  }

  async.auto
    getAccessInfo:(cb) ->
      request.post op, (err, response, body) ->
        return saveErr op.url, 1, {err:err} if err

        if response.statusCode is 200
          console.log "body =>", body
          infoArr = body.split('&')
          token = infoArr[0].split('=')[1]
          username = infoArr[1].split('=')[1]
          cb()

        else
          req.session.error = "获取pocket token 出错"
          saveErr op.url, 1, {err:body}
          return res.redirect('/')


    checkUser:['getAccessInfo', (cb, result) ->
      User.findOne {username:username}, (err, row) ->
        return saveErr "", 2, {err:err} if err
        if not row
          cb()

        else
          row.token = token
          row.save (err2, row2) ->
            return saveErr "", 2, {err:err2} if err2

            console.log "in checkUser"
            req.session.username = row2.username
            req.session.subscribe = row2.subscribe
            return res.redirect('/users')
    ]

    createUser:['checkUser', (cb) ->
      newUser = new User()
      newUser.token = token
      newUser.username = username
      newUser.created = Date.now()
      newUser.save (err, row) ->
        return saveErr "", 2, {err:err} if err
        console.log "in createUser"
        req.session.username = row.username
        req.session.subscribe = row.subscribe
        return res.redirect('/users')

    ]



module.exports = router