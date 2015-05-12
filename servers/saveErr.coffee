email = require('./email')()


saveErr = (href, type, infoJson, cb) ->
  console.log infoJson.err

  log = new ErrLog()
  log.href = href
  log.type = type
  log.info = JSON.stringify(infoJson)


  emailBody = JSON.stringify(log)
  email.send(emailBody)

  if cb
    return cb(infoJson.err)



module.exports = saveErr


