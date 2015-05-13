ArticleSave = require('../servers/saveArticle')
schedule = require("node-schedule")
rule = new schedule.RecurrenceRule()
rule.minute = 30
schedule.scheduleJob rule, () ->
  a = new ArticleSave()
  a.getPage 1, () ->
    console.log "ok"