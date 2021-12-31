--[[::

Copyright (C) 2021, Luc Rodriguez.

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

--::]]

------------------
--// Services //--
------------------

local HttpService : HttpService = game:GetService("HttpService");

-------------------------
--// Initalize Class //--
-------------------------

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager;

--------------------------
--// Type Definitions //--
--------------------------

type ConnectionManager = {
	-- Core Data
	Connections : {[string] : RBXScriptConnection},
	IDs : {[RBXScriptConnection] : string},
	
	-- Extra Data
	Created : number,
	Updated : number,
	Size : number
};

-------------------
--// Functions //--
-------------------

-- Replicate `assert` functionality, but using a `warning` instead of an `error`.
local function WarnAssert(Condition : boolean?, Output : string?) : nil?
	-- Check that the `Condition` is either `false` or `nil`.
	if not (Condition) then
		-- If so, then push a warning.
		warn(Output or tostring(Condition) or "");
	end;
end;

--------------------
--// Contructor //--
--------------------

-- Create a new `ConnectionManager`.
function ConnectionManager.new() : ConnectionManager
	-- Initalize a table containing
	-- basic structure of a `ConnectionManager`.
	local self : ConnectionManager = setmetatable({
		-- Core data
		["Connections"] = {},
		["IDs"] = {},
		
		-- Extra data
		["Created"] = 0,
		["Updated"] = 0,
		["Size"] = 0
	}, ConnectionManager);
	
	-- Retrive the current time,
	-- including milisecond precision.
	local Time : number = tick();
	
	-- Update the extra data.
	self.Created = Time;
	self.Updated = Time;
	
	-- Respond with the newly
	-- created `ConnectionManager`.
	return (self);
end;

-----------------
--// Methods //--
-----------------

-- Adds an active connection to the current ConnectionManager.
function ConnectionManager:Cache(Connection : RBXScriptConnection?) : (string, boolean)
	-- Check if the `Connection` provided is a `RBXScriptConnection`.
	local ValidConnection : boolean = typeof(Connection) == "RBXScriptConnection";
	
	-- If not, then push a warning.
	WarnAssert(ValidConnection, string.format("Attempt to cache a `%s` value, expected a `RBXScriptConnection`.", typeof(Connection)));
	
	-- If it is, then continue.
	if (ValidConnection) then
		-- First, check that the `Connection` hasn't already 
		-- been disconnected. if it has, then push an error.
		assert(ValidConnection.Connected, "Attempted to cache a `RBXScriptConnection` which has already been disconnected.");
		
		-- Otherwise, Generate a unique ID for this connection.
		local ConnectionID : string = string.gsub(HttpService:GenerateGUID(false), "-", "");
		
		-- Proceed with the `Connection` process.
		self.Connections[ConnectionID] = Connection;
		self.IDs[Connection] = ConnectionID;
		self.Updated = tick();
		self.Size += 1;
		
		-- Then finish by returning the `ConnectionID`
		-- and `true` to indicate a successful connection.
		return (ConnectionID), (true);
	end;
	
	-- If we get to this line
	-- then that means that
	-- the connection failed
	-- to be added to the Cache.
	return (""), (false);
end;

-- Disconnects an active connection given either an ID or a RBXScriptConnection.
function ConnectionManager:Disconnect(Input : (string | RBXScriptConnection)?) : boolean
	-- Check if the input provided was a string.
	local IsStringInput : boolean = typeof(Input) == "string";
	
	-- Check if the input was either a `string` or `RBXScriptConnection`.
	local ValidInput : boolean = IsStringInput or typeof(Input) == "RBXScriptConnection";
	
	-- If the input provided wasn't valid, then push a warning.
	WarnAssert(ValidInput, string.format("Attempt to disconnect a `%s` value, expected a `string` or `RBXScriptConnection`."));
	
	-- If the input is "currently" valid.
	if (ValidInput) then
		-- Then check one more time.
		ValidInput = if (typeof(Input) == "string") then (#Input == 32) else (true);
	end;
	
	-- If the input isn't valid anymore, then push an error.
	assert(ValidInput, "Attempt to disconnect an Invalid ID.");
	
	-- Check if the input if valid.
	if (ValidInput) then
		-- Then check if it's in the current `ConnectionManager`'s Cache.
		local IsInCache : boolean = self[ if (IsStringInput) then ("Connections") else ("IDs") ][Input] ~= nil;
		
		-- If it is in the Cache.
		if (IsInCache) then
			-- Then retrive both the `Connection` and it's `ID`.
			local ID : string = if (IsStringInput) then (Input) else (self.IDs[Input]);
			local Connection : RBXScriptConnection = self.Connections[ID];
			
			-- Check if the Connection provided has already been disconnected.
			assert(Connection.Connected, "Attempted to disconnect a `RBXScriptConnection` which has already been disconnected.")
			
			-- If not, then proceed with the "disconnecting" process.
			Connection:Disconnect();
			self.Connections[ID] = nil;
			self.IDs[Connection] = nil;
			self.Updated = tick();
			self.Size -= 1;
			
			-- Finish off by returning "true" to indicate
			-- that the connection was successfully disconnected.
			return (true);
		end;
	end;
	
	-- If were get to this line then 
	-- that means the connection
	-- failed to disconnect.
	return (false);
end;

-- Disconnects all active connections.
function ConnectionManager:DisconnectAll() : boolean
	-- Iterate over every active connection.
	for _, Connection in pairs(self.Connections) do
		-- Fire the `:Disconnect` method, provided the current `Connection`.
		local Success : boolean = self:Disconnect(Connection);
		
		-- If the `Connection` did not disconnect successfully.
		if not (Success) then 
			-- Then
			return (false);
		end;
	end;
	
	-- Otherwise
	return (true);
end;

----------------
--// Ending //--
----------------

return (ConnectionManager);
