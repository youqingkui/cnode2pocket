// Generated by CoffeeScript 1.8.0
(function() {
  var AriticleSchema, mongoose;

  mongoose = require('./mongoose');

  AriticleSchema = mongoose.Schema({
    url: {
      type: String,
      unique: true
    },
    title: String,
    created: Number
  });

  module.exports = mongoose.model('Ariticle', AriticleSchema);

}).call(this);

//# sourceMappingURL=article.js.map