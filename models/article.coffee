mongoose = require('./mongoose')

AriticleSchema = mongoose.Schema
  url:{type:String, unique:true}
  title:String
  created:Number

module.exports = mongoose.model('Ariticle', AriticleSchema)