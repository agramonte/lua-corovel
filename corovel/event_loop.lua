--====================================================================--
-- corovel/event_loop.lua
-- generates an event-loop, Corona SDK-style
--
-- by David McCuskey
-- Documentation: http://docs.davidmccuskey.com/display/docs/Lua+Corovel
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2014 David McCuskey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]



--====================================================================--
-- Corovel : Event Loop
--====================================================================--

-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"


--====================================================================--
-- Main Function

-- eventLoopGenerator()
-- @params params table of options
-- * command_path string path/name of module to load
-- * eps number approximate "events per second" to process
--
local function eventLoopGenerator( params )
	-- print( "eventLoopGenerator", params.command_path )

	--== Imports

	-- Globals, these are set in environment
	_G.Runtime = require 'corovel.corona.runtime'
	_G.timer = require 'corovel.corona.timer'
	_G.system = require 'corovel.corona.system'

	-- Local scope
	local socket = require 'socket'
	local Command = require( params.command_path )

	--== Setup, Constants

	local EPS = params.eps or 100/1000 -- 100 ms
	local cmd

	-- use timer to perform Runtime actions
	_G.timer.performWithDelay( EPS, _G.Runtime, -1 )

	--== Processing

	if type( Command ) == 'boolean' then
		-- no return value from Lua file
		cmd = Command

	else
		if Command.new then
			cmd = Command:new( params )
		else
			cmd = Command
		end
		if cmd.execute then cmd:execute() end
	end

	--== Loop until done

	while cmd == true or cmd.is_working do
		-- print("Checking Command Event Runtime")
		timer:_checkEventSchedule()
		socket.sleep( EPS )
	end

end

return {
	createEventLoop=eventLoopGenerator
}
