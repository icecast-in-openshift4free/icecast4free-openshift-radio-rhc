#!/usr/bin/env python
import os

import logging,sys
from time import time

import tornado.httpserver
import tornado.ioloop
import tornado.web
from tornado import gen
from tornado.httpclient import AsyncHTTPClient

class Application(tornado.web.Application):
    def __init__(self):
        handlers = [
            (r"/", MainHandler),
            (r"/gen", GenAsyncHandler),
        ]
        settings = dict(
            static_path=os.path.join(os.path.dirname(__file__), "static"),
            cookie_secret="yyahw99q7Uytq0Kla_qiak6aswpklsqazoleush12n",
            autoescape=None,
            debug=False,
        )
        tornado.web.Application.__init__(self, handlers, **settings)

class MainHandler(tornado.web.RequestHandler):
    def get(self):
        code = 'print "Hello World"'

        self.write(code)
        for i in os.environ:
            self.write('%s: %s' % (str(i), str(os.environ[i])))

class GenAsyncHandler(tornado.web.RequestHandler):
    @gen.coroutine
    def get(self):
        self.write('here')
        http_client = AsyncHTTPClient()
        response = yield http_client.fetch("http://google.com")
        self.do_read(response)
        
    def do_read(self, response):
        logging.error(response.body)
        self.write(str(response.body))

def main(ip, port=8080):
    http_server = tornado.httpserver.HTTPServer(Application())
    http_server.listen(port, ip)
    tornado.ioloop.IOLoop.instance().start()


if __name__ == "__main__":
    # ip = os.environ['OPENSHIFT_DIY_IP']

    try:
        ip = os.environ['OPENSHIFT_DIY_IP']
        port = int(sys.argv[1])
    except:
        ip='127.0.0.1'
        port=15001
    main(ip, port)
    s=1
