if not LPH_OBFUSCATED then
	LPH_JIT = function(Function)
		return Function
	end
	--
	LPH_JIT_MAX = function(Function)
		return Function
	end
	--
	LPH_NO_VIRTUALIZE = function(Function)
		return Function
	end
	--
	LPH_NO_UPVALUES = function(Function)
		return function(...)
			return Function(...)
		end
	end
	--
	LPH_ENCSTR = function(String)
		return String
	end
	--
	LPH_ENCNUM = function(Number)
		return Number
	end
	--
	LPH_CRASH = function()
		return rconsoleprint("DEBUG: CLIENT CALLED CRASH")
	end
	--

	if not getgenv then
		getgenv = function()
			return _G
		end
	end

	if not cloneref then
		cloneref = function(Reference)
			return Reference
		end
	end

	if not loadfile then
		loadfile = function(...)
			return ...
		end
	end

	if not readfile then
		readfile = function(...)
			return ...
		end
	end

	if not request then
		request = function(...)
			return ...
		end
	end

	if not clonefunction then
		clonefunction = function(f)
			return f
		end
	end

	if not newcclosure then
		newcclosure = function(...)
			return ...
		end
	end

	if not hookfunction then
		hookfunction = function() end
	end

	if not getrenv then
		getrenv = function()
			return {}
		end
	end
end 

local Directories = getgenv().Modules.Directories
local RayModule = getgenv().Modules.RayCasting
local Entities = getgenv().Modules.Entities

--// Modules

local DataStoreService = game:GetService("DataStoreService")
local Players = game.GetService(game, "Players")
local Workspace = game.GetService(game, "Workspace")
local TweenService = game.GetService(game, "TweenService")
local RunService = game.GetService(game, "RunService")
local UserInputService = game.GetService(game, "UserInputService")
local HttpService = game.GetService(game, "HttpService")
local GuiService = game.GetService(game, "GuiService")
local soundService = game.GetService(game, "SoundService")
local Lighting = game.GetService(game,"Lighting")
local Stats = cloneref(game:GetService("Stats"))
local Terrain = workspace.Terrain

local Camera = Workspace.CurrentCamera 
local viewportSize = Camera.ViewportSize
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()
local GuiSpace = gethui and gethui() or Client.PlayerGui
local Utility = {}
local Requests = {}
local Debris = cloneref(game:GetService("Debris"))
local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

local RunService = game:GetService("RunService")
local core_gui = game:GetService("CoreGui")
local http_service = game:GetService("HttpService")

local Targeting_Object = {}
Targeting_Object.__index = Targeting_Object

if game.GameId == 113491250 then -- PHANTOM FORCES
    function Targeting_Object:get_character(entry)
        if not entry then return nil end
        if not entry:getThirdPersonObject() then return nil end
        return entry:getThirdPersonObject()
    end

    function Targeting_Object:is_friendly(entry)
        return not entry:isEnemy() --entry:IsEneny(); -- not not needed
    end

    function Targeting_Object:get_health(entry)
        return entry:getHealth()
    end

    function Targeting_Object:getPart(Entry,part)
        if part == "Root" then
            part = "Torso"
        end
        return Entry:getBodyPart(part)
    end

    function Targeting_Object:getName(entry)
		if not entry then return end

		return tostring(entry._player)
	end
    --
else -- uni
    function Targeting_Object:get_character(player)
        --print("called",player)
        if player.Character then
            return player.Character
        end
        return nil
    end

    function Targeting_Object:get_weapon(player)
        --print("called",player)
        if player.Character and player.Character:FindFirstChild("EquippedTool") then
            return player.Character.EquippedTool.Value
        end
        return "None"
    end

    function Targeting_Object:is_friendly(player)
        return player.Team and player.Team == Client.Team
    end

    function Targeting_Object:get_health(player)
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                return hum.Health,hum.MaxHealth
            end
        end
        return 100,100
    end

    function Targeting_Object:getPart(character,part)
        if part == "Root" then
            part = "HumanoidRootPart"
        end
        return game.FindFirstChild(character,part)
    end

    function Targeting_Object:getName(entry)
		if not entry then return end

		return tostring(entry.Name)
	end
    --
end

function Targeting_Object:getClosestPlayerToCenter(PlayerTable,PartList,MaxRange,MaxScreenPoint,MinScreenPoint) -- PartList
    local TargetData = {}
	local smallest = math.huge
    local smallest2 = math.huge
									
    for i, player in pairs(PlayerTable) do
        if self:is_friendly(player) then
            continue
        end

        if table.find(Entities.whitelist,self:getName(player)) then
            --print("skipped whitelist entry")
            continue
        end

        local Char = self:get_character(player)

        if not Char then
            continue
        end

        local root = self:getPart(Char,"Root")

        if not root then
            continue
        end

        local healt,_ = self:get_health(player)

        if not (healt > 0) then
            continue
        end

        local WorldPosition = root.CFrame.p

        if not WorldPosition then
            continue
        end

        local WorldDistance = (Camera.CFrame.p - WorldPosition).Magnitude

        local screenPoint,onscreen = Camera:WorldToViewportPoint(WorldPosition)

        if not onscreen then
            continue
        end

        local screendistance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
        local part

        if #PartList == 0 then
            part = self:getPart(Char,"Head")
        else
			for _, ListPart in PartList do
                local realpart = self:getPart(Char,ListPart)
				if (not realpart) then
					continue
				end

				local screendistance2, onscreen2 = Camera:WorldToViewportPoint(realpart.Position)
				local partDistance = (Vector2.new(screendistance2.X, screendistance2.Y) - screenCenter).Magnitude
				if partDistance < smallest2 then
					smallest2 = partDistance
					part = realpart
				end
			end
        end

        if not part then
            continue
        end

        local isVisible = RayModule:IsPartVisible(Camera.CFrame.p,part)

        -- Main logic here after compleitng all the checks to validate any targets left in the table

        if (WorldDistance < MaxRange) and (screendistance < MaxScreenPoint) and (screendistance > MinScreenPoint) and (screendistance < smallest) then
            smallest = screendistance
            TargetData = { 
                ["Part"] = part,
                ["Player"] = player,
                ["Character"] = Char,
                ["WorldPosition"] = WorldPosition,
                ["ScreenPoint"] = screenPoint,
                ["Visible"] = isVisible,
            }
        end

    end
    --table.foreach(TargetData,print)
    return TargetData
end

function Targeting_Object:getClosestPlayerToMouse(PlayerTable,PartList,MaxRange,MaxScreenPoint,MinScreenPoint) -- PartList
    local TargetData = {}
	local smallest = math.huge
    local smallest2 = math.huge
    local screenCenter = UserInputService:GetMouseLocation()
									
    for i, player in pairs(PlayerTable) do
        if self:is_friendly(player) then
            continue
        end

        if table.find(Entities.whitelist,self:getName(player)) then
            --print("skipped whitelist entry")
            continue
        end

        local Char = self:get_character(player)

        if not Char then
            continue
        end

        local root = self:getPart(Char,"Root")

        if not root then
            continue
        end

        local healt,_ = self:get_health(player)

        if not (healt > 0) then
            continue
        end

        local WorldPosition = root.CFrame.p

        if not WorldPosition then
            continue
        end

        local WorldDistance = (Camera.CFrame.p - WorldPosition).Magnitude

        local screenPoint,onscreen = Camera:WorldToViewportPoint(WorldPosition)

        if not onscreen then
            continue
        end

        local screendistance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
        local part

        if #PartList == 0 then
            part = self:getPart(Char,"Head")
        else
			for _, ListPart in PartList do
                local realpart = self:getPart(Char,ListPart)
				if (not realpart) then
					continue
				end

				local screendistance2, onscreen2 = Camera:WorldToViewportPoint(realpart.Position)
				local partDistance = (Vector2.new(screendistance2.X, screendistance2.Y) - screenCenter).Magnitude
				if partDistance < smallest2 then
					smallest2 = partDistance
					part = realpart
				end
			end
        end

        if not part then
            continue
        end

        local isVisible = RayModule:IsPartVisible(Camera.CFrame.p,part)

        -- Main logic here after compleitng all the checks to validate any targets left in the table

        if (WorldDistance < MaxRange) and (screendistance < MaxScreenPoint) and (screendistance > MinScreenPoint) and (screendistance < smallest) then
            smallest = screendistance
            TargetData = { 
                ["Part"] = part,
                ["Player"] = player,
                ["Character"] = Char,
                ["WorldPosition"] = WorldPosition,
                ["ScreenPoint"] = screenPoint,
                ["Visible"] = isVisible,
            }
        end

    end
    --table.foreach(TargetData,print)
    return TargetData
end

getgenv().Modules.Targeting = Targeting_Object
return Targeting_Object

