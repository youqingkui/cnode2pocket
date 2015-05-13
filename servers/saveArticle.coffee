request = require('request')
async = require('async')
Article = require('../models/article')
User = require('../models/user')
saveErr = require('../servers/saveErr')
class ArticleSave
  constructor:() ->
    @baseUrl = 'https://cnodejs.org/api/v1/topics?tab=good&page='
    @urlArr = []


  getPage:(page, cb) ->
    self = @
    url = self.baseUrl + page
    console.log url
    async.auto
      getInfo:(callback) ->
        request.get url, (err, res, body) ->
          return saveErr url, 1, {err:err,body:body} if err

          try
            data = JSON.parse(body)
          catch
            return saveErr url, 3, {err:body}


          callback(null, data)


      pieceUrl:['getInfo', (callback, result) ->
        data = result.getInfo
        if data.data.length
          data.data.forEach (item) ->
            tmp =
              url:'https://cnodejs.org/topic/' + item.id
              title:item.title
              created:Date.now()

            Article.findOne {url:tmp.url}, (err, row) ->
              return saveErr tmp.url, 2, {err:err} if err

              if not row
                newArt = new Article(tmp)
                newArt.save (err2, row2) ->
                  return saveErr  "", 2, {err:err2} if err2

                self.pushUser(tmp)

          self.getPage(page + 1, cb)

        else
          console.log "page =>", page, data
      ]


  pushUser:(info) ->
    self = @
    form = {
      url:info.url
      title : info.title
      tags : 'Cnode'
      consumer_key:process.env.pocket
      access_token:''
    }
    users = []
    async.auto
      findUser:(cb) ->
        User.find {subscribe:true}, (err, rows) ->
          return saveErr "", 2, {err:err} if err

          users = rows
          cb()

      pushInfo:['findUser', (cb) ->
        if users.length
          async.eachLimit users, 10, (item, callback) ->
            form.access_token = item.token
            op =
              form:form
              url:'https://getpocket.com/v3/add'

            request.post op, (err, res, body) ->
              return saveErr op.url, 1, {err:err,body:body} if err

              console.log body
              callback()

          ,() ->
            console.log "### push user subscribe #{form.url} all do ###"
      ]



module.exports = ArticleSave




