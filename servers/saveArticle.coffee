request = require('request')
async = require('async')
Article = require('../models/article')
User = require('../models/user')

class ArticleSave
  constructor:() ->
    @baseUrl = 'https://cnodejs.org/api/v1/topics?tab=good&page='
    @urlArr = []


  getPage:(page, cb) ->
    self = @
    url = self.baseUrl + page
    async.auto
      getInfo:(callback) ->
        request.get url, (err, res, body) ->
          return console.log err if err

          data = JSON.parse(body)

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
              return console.log err if err

              if not row
                newArt = new Article(tmp)
                newArt.save (err2, row2) ->
                  return console.log err2 if err2
                  console.log row2

                self.pushUser(tmp)
            callback()

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
          return console.log err if err

          users = rows
          cb()

      pushInfo:['findUser', (cb) ->
        async.eachLimit users, 10, (item, callback) ->
          form.access_token = item.token
          op =
            form:form
            url:'https://getpocket.com/v3/add'

          request.post op, (err, res, body) ->
            return console.log err if err
            console.log body
            callback()

        ,() ->
          console.log "### eachLimit all do ###"
      ]



module.exports = ArticleSave




