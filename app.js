// Generated by CoffeeScript 1.8.0
(function() {
  var MongoStore, accessLog, app, bodyParser, cookieParser, errorLog, express, favicon, fs, logger, path, routes, session, settings, users;

  express = require('express');

  path = require('path');

  favicon = require('serve-favicon');

  logger = require('morgan');

  cookieParser = require('cookie-parser');

  session = require('express-session');

  settings = require('./settings');

  MongoStore = require('connect-mongo')(session);

  bodyParser = require('body-parser');

  routes = require('./routes/index');

  users = require('./routes/users');

  fs = require('fs');

  app = express();

  accessLog = fs.createWriteStream('access.log', {
    flags: 'a'
  });

  errorLog = fs.createWriteStream('error.log', {
    flags: 'a'
  });

  app.set('views', path.join(__dirname, 'views'));

  app.set('view engine', 'jade');

  app.use(logger('dev'));

  app.use(bodyParser.json());

  app.use(bodyParser.urlencoded({
    extended: false
  }));

  app.use(cookieParser());

  app.use(session({
    secret: settings.cookieSecret,
    store: new MongoStore({
      db: settings.db
    }),
    saveUninitialized: true,
    resave: true
  }));

  app.use(express["static"](path.join(__dirname, 'public')));

  app.use(logger('combined', {
    stream: accessLog
  }));

  app.use(function(req, res, next) {
    res.locals.username = req.session.username;
    res.locals.error = req.session.error;
    res.locals.success = req.session.success;
    req.session.error = null;
    req.session.success = null;
    return next();
  });

  app.use('/', routes);

  app.use('/users', function(req, res, next) {
    if (!req.session.username) {
      return res.redirect('/');
    }
    return next();
  }, users);

  app.use(function(req, res, next) {
    var err;
    err = new Error('Not Found');
    err.status = 404;
    next(err);
  });

  app.use(function(err, req, res, next) {
    var meta;
    meta = '[' + new Date() + '] ' + req.url + '\n';
    errorLog.write(meta + err.stack + '\n');
    return next(err);
  });

  if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
      res.status(err.status || 500);
      res.render('error', {
        message: err.message,
        error: err
      });
    });
  }

  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: {}
    });
  });

  module.exports = app;

}).call(this);

//# sourceMappingURL=app.js.map
