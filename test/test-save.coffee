ArticleSave = require('../servers/saveArticle')
schedule = require("node-schedule")
#rule = new schedule.RecurrenceRule()
#rule.minute = 30
rule1 = new schedule.RecurrenceRule()
rule1.dayOfWeek = [0, new schedule.Range(1, 6)]
rule1.hour = 20
rule1.minute = 10

schedule.scheduleJob rule1, () ->
  a = new ArticleSave()
  a.getPage 1, () ->
    console.log "ok"