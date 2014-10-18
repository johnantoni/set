################################################################################
#
# Tally Express.
#
# Released under the MIT license.
#
# Copyright (c) 2013 Aral Balkan.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################

jsdom = require 'jsdom'
fs = require 'fs'

# Load the Tally engine.
set = (fs.readFileSync __dirname + '/set.js', 'utf8').toString()

# The Express 3 export.
exports.__express = (path, data, callback) ->
	fs.readFile path, 'utf8', (error, template) ->
		if error
			return callback(error)

		html = render(template, data)

		callback null, html

render = (template, data) ->
	# Create the DOM.
	document = jsdom.jsdom(template)
	window = document.parentWindow
	window.console = console

	# Create a private member in the data to communicate with the Tally engine in the DOM.
	data.__set = {} unless data.__set

	# Flag so Tally knows it is running on the server
	# and will remove nodes that don’t satisfy conditionals
	# (data-qif) instead of setting them to display: none
	# like it does when running on the client.
	data.__set['server'] = yes;

	# Create Tally in the DOM.
	window.run set

	#
	# Copy over formatters and hooks (if any) from the special __set namespace
	# in the data object to the Tally object in the DOM.
	#

	#
	# Copy custom formatter(s), if any.
	# (Use custom formatters to modify values before they are rendered.)
	#
	customFormatters = data.__set['formatters']
	if customFormatters
		window.set.format[customFormatter] = customFormatters[customFormatter] for customFormatter of customFormatters

	#
	# Copy the attributeWillChange and textWillChange hooks.
	# (Use these hooks to perform actions before a node is modified—e.g., animate, run debug code.)
	#
	window.set.attributeWillChange = data.__set['attributeWillChange']
	window.set.textWillChange = data.__set['textWillChange']

	#
	# Inject Data option: if set, this will result in a copy
	# of the data being injected into the template at set.data
	# (Useful if you want to append to it via Ajax calls, etc.
	# When rendering a timeline, for example.)
	#
	if data.__set['injectData']
		head = window.document.getElementsByTagName('head')[0]
		script = window.document.createElement('script')
		script.setAttribute('type', 'text/javascript')
		script.textContent = 'set.data = ' + JSON.stringify(data, null, 2) + ';'
		head.appendChild(script)

	#
	# Static output option: if set, set will strip the following
	# from templates rendered on the server:
	#
	# 1. All Tally attributes
	# 2. Any elements with falsy values for data-set-if
	#
	# (Note: any elements marked data-set-dummy are stripped from
	#  ===== final output regardless of this setting. Also, this setting
	#        has no effect when Tally is used on the client side.)
	#
	if data.__set['renderStatic']
		window.set.renderStatic = yes

	#
	# Save the data on the DOM and run Tally.
	#
	window.data = data

	# NB. window.document is tracing out as [ null ] in the function itself
	# === although window.document.innerHTML works. window.document.documentElement
	#     also works. I’ll be darned if I know why or where the problem is.
	try
		window.run ('set(window.document.documentElement, window.data);')
	catch e
		throw e

	html = window.document.documentElement.innerHTML;

	return html

exports.render = render
