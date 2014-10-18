################################################################################
#
# Set examples.
#
# The server for the Set examples.
#
# Copyright © 2013, Aral Balkan.
# Released under the MIT license. (http://opensource.org/licenses/MIT)
#
################################################################################


express = require 'express'
set = require './lib/set-express.coffee'

superagent = require 'superagent'

# Helper: create a route from a route name (e.g., /simple -> /routes/simple.coffee)
createRoute = (routeName) ->
	path = if routeName == '/' then 'main' else routeName[1..]
	route = require('./routes/' + path + '.coffee').route
	app.get routeName, route

#
# Set up Express with Set as the templating engine.
#
app = express()
app.engine 'html', (require './lib/set-express.coffee').__express
app.set 'view engine', 'html'
app.set 'views', __dirname + '/views'
app.use express.static('views')

# Index: links to the readme and examples.
createRoute '/'

# Simple template example (with static data)
createRoute '/simple'

# App.net global timeline example.
createRoute '/posts'

# App.net global timeline example.
createRoute '/posts-client-side-updates'

# App.net global timeline example with profiling.
createRoute '/profile'

# A route to render the readme.md file
# createRoute '/readme'

# If /js/set.js is requested, get it from the lib folder
# (so I don’t have to keep remembering to deploy it to the client)
createRoute '/set.js'


app.listen (process.env.PORT || 3000)

console.log '\nServer running… visit http://localhost:3000/ to play with the Set examples.\n'


