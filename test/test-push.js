// Generated by CoffeeScript 1.8.0
(function() {
  var PushUser, async, p;

  PushUser = require('../servers/pushUser');

  async = require('async');

  p = new PushUser('youqingkui');

  async.series([
    function(cb) {
      return p.getToken(function(err) {
        if (err) {
          return console.log(err);
        }
        return cb();
      });
    }, function(cb) {
      return p.getArticle(function(err) {
        if (err) {
          return console.log(err);
        }
        return cb();
      });
    }, function(cb) {
      return p.pushInfo(function(err) {
        if (err) {
          return console.log(err);
        }
        return console.log("dododo");
      });
    }
  ]);

}).call(this);

//# sourceMappingURL=test-push.js.map
