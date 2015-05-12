ArticleSave = require('../servers/saveArticle')

a = new ArticleSave()
a.getPage 1, () ->
  console.log "ok"