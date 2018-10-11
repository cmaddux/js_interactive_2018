const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');

const knex = require('knex')({
    client: 'mysql',
    connection: {
        host : 'mysql',
        user : 'root',
        password : 'password',
        database : 'js_interactive_2018_db'
    }
});

const redis = require('redis').createClient(
    {
        host: 'redis-master'
    }
);

const app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

const router = express.Router();
router.get(
    '/',
    (req, res, next) => {
        try {
            return Promise.all(
                [
                    new Promise(resolve => {
                        knex.raw('SELECT 1+1 AS RESULT')
                            .then(() => resolve(true))
                            .catch(
                                err => {
                                    console.log(err);
                                    resolve(false);
                                }
                            );

                    }),
                    new Promise(resolve => {
                        redis.set('test_key', err => {
                            if (err) {
                                console.log(err);
                                resolve(false);
                            }

                            resolve(true);
                            redis.quit();
                        });

                    }),
                ]
            ).then(
                ([ mysqlOK, redisOK ]) => {
                    res.render(
                        'index',
                        {
                            mysqlOK,
                            redisOK,
                            title: 'JS Interactive 2018!'
                        }
                    );
                }
            );

        } catch (err) {
            return next(err);
        }

    }
);

app.use(router);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
    next(createError(404));
});

// error handler
app.use(function(err, req, res) {
    // set locals, only providing error in development
    res.locals.message = err.message;
    res.locals.error = req.app.get('env') === 'development' ? err : {};

    // render the error page
    res.status(err.status || 500);
    res.render('error');
});

module.exports = app;
