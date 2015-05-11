mongoose = require('./mongoose')

UserSchema = mongoose.Schema
  username:String
  created:Number
  token:String
  subscribe:Boolean



module.exports = mongoose.model('User, UserSchema')