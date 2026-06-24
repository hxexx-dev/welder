--!strict
local Selection = game:GetService("Selection")
local textures = require(script.Parent:WaitForChild("Textures"))
local ConnectionManager = require(script.Parent:WaitForChild("ConnectionManager"))
local Logger = require(script.Parent:WaitForChild("Logger"))

type Welder = { init: (plugin: Plugin) -> () }

local Welder: Welder = {} :: Welder

local part0: BasePart?
local part1: BasePart?
local function onSelectionChanged(): ()
	local current = Selection:Get()
	local statedPart0 = current[1]
	local statedPart1 = current[2]
	if statedPart0 and statedPart0:IsA("BasePart") and statedPart1 and statedPart1:IsA("BasePart") then
		part0 = statedPart0
		part1 = statedPart1
	else
		part0 = nil
		part1 = nil
	end
end

local className: string
local isAnimatableMode: boolean
local function weld(): ()
	if part0 and part1 then
		local weldInstance = Instance.new(className) :: Motor6D
		weldInstance.Part0 = part0
		weldInstance.Part1 = part1
		weldInstance.Name = part1.Name
		weldInstance.C1 = part1.CFrame:ToObjectSpace(part0.CFrame)
		weldInstance.Parent = part0
		Logger.log(`Successfully created '{className}' with parts '{part0}' and '{part1}':`, weldInstance)
	else
		Logger.warn(
			`Could not create weld: First 2 of selected instances are not a BasePart class or one of them doesn't exist`
		)
	end
end

local changeModeButton: PluginToolbarButton
local function changeMode(): ()
	isAnimatableMode = not isAnimatableMode
	changeModeButton.Icon = isAnimatableMode and textures.motor6D or textures.weld
	className = isAnimatableMode and "Motor6D" or "Weld"
	Logger.log(`Changed class to: '{isAnimatableMode and "Motor6D" or "Weld"}'`)
end

local connectionManager: ConnectionManager.ConnectionManager
local function cleanup(): ()
	connectionManager:disconnectAll()
end

Welder.init = function(plugin: Plugin): ()
	local toolbar = plugin:CreateToolbar("Welder")

	connectionManager = ConnectionManager.new()
	isAnimatableMode = false
	className = isAnimatableMode and "Motor6D" or "Weld"
	changeModeButton =
		toolbar:CreateButton("Class", "Click to toggle Motor6D", isAnimatableMode and textures.motor6D or textures.weld)

	connectionManager:connect(
		"CHANGE_CLASS_CLICKED",
		changeModeButton.Click:Connect(function()
			changeMode()
		end)
	)
	connectionManager:connect(
		"UNLOADING",
		plugin.Unloading:Connect(function()
			cleanup()
		end)
	)
	connectionManager:connect(
		"SELECTION_CHANGED",
		Selection.SelectionChanged:Connect(function()
			onSelectionChanged()
		end)
	)
	connectionManager:connect(
		"WELD_CLICKED",
		toolbar:CreateButton("Weld", "Click to create weld", textures.attachment).Click:Connect(function()
			weld()
		end)
	)
end

return Welder
