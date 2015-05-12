request = require('request')
async = require('async')
User = require('../models/user')
Article = require('../models/article')

class PushUser
  constructor:(@username) ->
    @token = ''
    @articleArr = []



  getToken:(cb) ->
    self = @
    User.findOne {username:self.username}, (err, row) ->
      return console.log err if err

      if not row
        cb("没有找到此用户")

      else
        self.token = row.token
        cb()


  getArticle:(cb) ->
    self = @
    Article.find (err, rows) ->
      return console.log err if err

      self.articleArr = rows

      cb()


  pushInfo:(cb) ->
    self = @

    async.eachLimit self.articleArr, 20, (item, callback) ->
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
        return console.log err if err
        console.log body
        data = JSON.parse body
        console.log data.item.normal_url
        callback()

    ,() ->
      console.log "##### all dododo #####"
      cb()






module.exports = PushUser







