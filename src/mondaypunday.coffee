# Description
#   Grab the Monday Punday
#
# Dependencies:
#   "htmlparser": "1.7.6"
#   "soupselect": "0.2.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot monday punday - grab the latest monday punday
#   hubot monday punday random - gives a random monday punday
#
# Author:
#   wil

HTMLParser = require "htmlparser"
Select     = require("soupselect").select
baseurl    = "http://mondaypunday.com/"

module.exports = (robot) ->
  robot.respond /monday\s?punday( latest)?$/i, (msg) ->
    getLatest msg, (url) -> 
      post(msg, url)

  robot.respond /monday\s?punday random/i, (msg) ->
    getLatest msg, (url) -> 
        count = url.match(/\d+/) - 1
        count = (Math.floor(Math.random() * count)) + 1
        url = baseurl + count
        post(msg, url)


getLatest = (msg, cb) ->
  msg.robot.http(baseurl).get() (err, res, body) ->
      return msg.send "It's eternally Sunday" if err

      if res.statusCode == 302
        location = res.headers['location']
        cb location
      else
        cb baseurl

post = (msg, url) ->
  msg.robot.http(url).get() (err, res, body) ->
    msg.send getImage body, ".entry .aligncenter"
    msg.send url

getImage = (body, selector) ->
  html_handler  = new HTMLParser.DefaultHandler((()->), ignoreWhitespace: true )
  html_parser   = new HTMLParser.Parser html_handler

  html_parser.parseComplete body
  Select( html_handler.dom, selector )[0].attribs.src
