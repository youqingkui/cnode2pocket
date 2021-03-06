// Generated by CoffeeScript 1.8.0
(function() {
  var User, async, express, request, router, saveErr;

  express = require('express');

  async = require('async');

  request = require('request');

  User = require('../models/user');

  saveErr = require('../servers/saveErr');

  router = express.Router();


  /* GET home page. */

  router.get('/', function(req, res, next) {
    if (req.session.username) {
      return res.redirect('/users');
    }
    res.render('access', {
      title: 'Cnode2Pocket'
    });
  });

  router.get('/auth', function(req, res) {
    var codeUrl, form, key, op, redirect_uri;
    key = process.env.pocket;
    console.log(key);
    codeUrl = 'https://getpocket.com/v3/oauth/request';
    redirect_uri = process.env.pocket_url;
    form = {
      'consumer_key': key,
      'redirect_uri': redirect_uri
    };
    op = {
      url: codeUrl,
      form: form
    };
    return async.auto({
      getCode: function(cb) {
        return request.post(op, function(err, response, body) {
          var code;
          if (err) {
            return saveErr(op.url, 1, {
              err: err
            });
          }
          if (response.statusCode === 200) {
            code = body.split('=')[1];
            return cb(null, code);
          } else {
            saveErr(op.url, 2, {
              err: body
            });
            req.session.error = "连接Pocket出错";
            return res.redirect('/');
          }
        });
      },
      directUrl: [
        'getCode', function(cb, result) {
          var code, url;
          code = result.getCode;
          req.session.code = code;
          url = "https://getpocket.com/auth/authorize?request_token=" + code + "&redirect_uri=" + redirect_uri;
          return res.redirect(url);
        }
      ]
    });
  });

  router.get('/oauth_callback', function(req, res) {
    var form, key, op, token, url, username;
    if (!req.session.code) {
      return res.redirect('/');
    }
    url = 'https://getpocket.com/v3/oauth/authorize';
    key = process.env.pocket;
    username = '';
    token = '';
    form = {
      consumer_key: key,
      code: req.session.code,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8'
      }
    };
    op = {
      url: url,
      form: form
    };
    return async.auto({
      getAccessInfo: function(cb) {
        return request.post(op, function(err, response, body) {
          var infoArr;
          if (err) {
            return saveErr(op.url, 1, {
              err: err
            });
          }
          if (response.statusCode === 200) {
            console.log("body =>", body);
            infoArr = body.split('&');
            token = infoArr[0].split('=')[1];
            username = infoArr[1].split('=')[1];
            return cb();
          } else {
            req.session.error = "获取pocket token 出错";
            saveErr(op.url, 1, {
              err: body
            });
            return res.redirect('/');
          }
        });
      },
      checkUser: [
        'getAccessInfo', function(cb, result) {
          return User.findOne({
            username: username
          }, function(err, row) {
            if (err) {
              return saveErr("", 2, {
                err: err
              });
            }
            if (!row) {
              return cb();
            } else {
              row.token = token;
              return row.save(function(err2, row2) {
                if (err2) {
                  return saveErr("", 2, {
                    err: err2
                  });
                }
                console.log("in checkUser");
                req.session.username = row2.username;
                req.session.subscribe = row2.subscribe;
                return res.redirect('/users');
              });
            }
          });
        }
      ],
      createUser: [
        'checkUser', function(cb) {
          var newUser;
          newUser = new User();
          newUser.token = token;
          newUser.username = username;
          newUser.created = Date.now();
          return newUser.save(function(err, row) {
            if (err) {
              return saveErr("", 2, {
                err: err
              });
            }
            console.log("in createUser");
            req.session.username = row.username;
            req.session.subscribe = row.subscribe;
            return res.redirect('/users');
          });
        }
      ]
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=index.js.map
