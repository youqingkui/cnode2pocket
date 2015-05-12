mongoose = require('./mongoose')

UserSchema = mongoose.Schema
  username:{type:String, unique:true}
  created:Number
  token:String
  subscribe:{type:Boolean, default:false}



module.exports = mongoose.model('User', UserSchema)