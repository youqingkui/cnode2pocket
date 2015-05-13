request = require('request')
async = require('async')
User = require('../models/user')
Article = require('../models/article')
saveErr = require("../servers/saveErr")

class PushUser
  constructor:(@username) ->
    @token = ''
    @articleArr = []


  # 获取用户token
  getToken:(cb) ->
    self = @
    User.findOne {username:self.username}, (err, row) ->
      return saveErr "", 2, {err:err} if err

      if not row
        cb("没有找到此用户")

      else
        self.token = row.token
        cb()

  # 获取要推送的文章
  getArticle:(cb) ->
    self = @
    Article.find (err, rows) ->
      return saveErr "", 2, {err:err} if err

      self.articleArr = rows

      cb()


  pushInfo:(cb) ->
    self = @

    async.eachLimit self.articleArr, 40, (item, callback) ->
      form = {
        url:item.url
        title:item.title
        tags : 'Cnode'
        consumer_key:process.env.pocket
        access_token:self.token
      }

      op =
        form:form
        url:'https://getpocket.com/v3/add'

      request.post op, (err, res, body) ->
        return saveErr op.url, 1, {err:err, body:body} if err
        try
          data = JSON.parse body
        catch
          return saveErr op.url, 3, {err:body}

        console.log data.item.normal_url
        callback()

    ,() ->
      console.log "##### all do #{self.username} #####"
      cb()






module.exports = PushUser







