# RBXScriptConnectionManager

A Open-Source Module which makes it easier to manage RBXScriptConnection's, and provides addition functionality.

## Installation

In ROBLOX Studio, you may load it in as a module script named `RBXScriptConnectionManager`, with the following :

```lua
local RBXScriptConnectionManager = require(script.RBXScriptConnectionManager);
```
## Usage

Creating a new manager :
```lua
local ExampleManager = RBXScriptConnectionManager.new();
```
Adding a connection to the manager :
```lua
local ExampleConnection : RBXScriptConnection = TextButton.MouseButton1Click:Connect(function()
  -- Nothing here, since this is just an example.
end);

-- Add our connection to the manager
local ConnectionID : string, Success : boolean = ExampleManager:Cache(ExampleConnection);
```
Removing a connection from the manager :
```lua
-- If the connection was added successfully, we are able disconnect it.
if Success then
  -- In-case you just want to disconnect a single connection.
  local Disconnected : boolean = ExampleManager:Disconnect(ConnectionID)

  -- Want to disconnect everything in the manager? we've got you covered!
  local Disconnected : boolean = ExampleManager:DisconnectAll();

  -- Forgot to store the `ConnectionID` somewhere in your spaghetti code?
  -- then providing the connection itself will also work!
  local Disconnected : boolean = ExampleManager:Disconnect(ExampleConnection);
end
```
Want more information on the manager your using?
Each manager you create will store some extra properties in case your interested :

- `RBXScriptConnectionManager.Size` - Number of connections actively connected.
- `RBXScriptConnectionManager.Created` - Time in seconds since UNIX EPOCH, representing when the manager was created.
- `RBXScriptConnectionManager.Updated` - Time in seconds since UNIX EPOCH, representing the last time the manager was changed, or the last time a connection was connected/disconnected from the manager.

## License
[MIT](https://choosealicense.com/licenses/mit/)
