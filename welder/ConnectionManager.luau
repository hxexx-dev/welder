--!strict
type ConnectionManagerClass = {
	__index: ConnectionManagerClass,
	new: () -> ConnectionManager,
	connect: (self: ConnectionManager, key: string, connection: RBXScriptConnection) -> (),
	disconnect: (self: ConnectionManager, key: string) -> (),
	disconnectAll: (self: ConnectionManager) -> (),
}

export type ConnectionManager = setmetatable<
	{ _disconnectFunctions: { [string]: DisconnectFunction } },
	ConnectionManagerClass
>

export type DisconnectFunction = () -> ()

local ConnectionManager: ConnectionManagerClass = {} :: ConnectionManagerClass
ConnectionManager.__index = ConnectionManager

ConnectionManager.new = function(): ConnectionManager
	return setmetatable({ _disconnectFunctions = {} }, ConnectionManager) :: ConnectionManager
end

ConnectionManager.connect = function(self: ConnectionManager, key: string, connection: RBXScriptConnection): ()
	local prev = self._disconnectFunctions[key]
	if prev then
		prev()
	end
	self._disconnectFunctions[key] = function()
		connection:Disconnect()
	end
end

ConnectionManager.disconnect = function(self: ConnectionManager, key: string): ()
	local fn = self._disconnectFunctions[key]
	if fn then
		fn()
	end
end

ConnectionManager.disconnectAll = function(self: ConnectionManager): ()
	for _, fn in pairs(self._disconnectFunctions) do
		fn()
	end
	table.clear(self._disconnectFunctions)
end

return ConnectionManager
