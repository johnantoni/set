fs = require 'fs'

exports.route = (request, response) ->
	fs.readFile __dirname + '/../lib/set.js', 'utf-8', (error, data) ->
		if error
			response.status 404
			response.send '<h1>Error 404: Could not find set.js</h1>'
		else
			response.status 200
			response.end data
