local Workspace = cloneref(game.GetService(game, "Workspace"));
local Players = cloneref(game.GetService(game, "Players"));
local Client = Players.LocalPlayer; 
local Mouse = Client:GetMouse();

local RaycastModule = {
    Instances = {};
};

RaycastModule.__index = RaycastModule

--// initial class builder
function RaycastModule:New(Name: string)
    local NewRaycastBuilder = setmetatable({
        Name = Name, 
        IgnoreWater = true, 
        RaycastParams = RaycastParams.new(),
        CreatedAt = tick(),
        LastUsed = tick(),
    }, RaycastModule)

    RaycastModule.Instances[Name] = NewRaycastBuilder
    return NewRaycastBuilder
end

--// Parameter setting
function RaycastModule:SetParams(Data: table)
    for Index, Value in Data do 
        self.RaycastParams[Index] = Value 
    end
end

function RaycastModule:SetFilterType(FilterType: EnumItem) 
    self.RaycastParams.FilterType = FilterType
end

function RaycastModule:SetFilter(Filter: table) 
    self.RaycastParams.FilterDescendantsInstances = Filter
end

function RaycastModule:AppendToFilter(Object: Instance) 
    table.insert(self.RaycastParams.FilterDescendantsInstances, Object)
end

function RaycastModule:SetIgnoreWater(State: boolean) 
    self.RaycastParams.IgnoreWater = State
end

--// Presets
function RaycastModule:Send(Origin: Vector3, Destination: Vector3) 
    local Direction = (Destination - Origin).Unit
    local Distance = (Destination - Origin).Magnitude
    local Result = Workspace:Raycast(Origin, Direction * Distance, self.RaycastParams)
    return Result
end

--// Useful if you already have direction
function RaycastModule:SendToDirection(Origin: Vector3, Direction: Vector3, Distance: number) 
    local NormalizedDir = Direction.Unit
    local Result = Workspace:Raycast(Origin, NormalizedDir * (Distance + 7.5), self.RaycastParams)
    return Result
end

--// Useful for basic visible checks
function RaycastModule:IsPartVisible(Origin: Vector3, Part: Instance, Model)
    local Result = self:Send(Origin, Part.CFrame.Position)

    if Result and Result.Instance and Model and Result.Instance:IsDescendantOf(Model) then 
        return true, Origin, Part 
    end;
    
    if Result and Result.Instance == Part then 
        return true, Origin, Part
    end
    return false
end

--// Useful for model wide visible checks
function RaycastModule:IsModelVisible(Origin: Vector3, Destination: Vector3, Model: Instance)
    local Result = self:Send(Origin, Destination)
    if Result and Result.Instance and (Result.Instance:IsDescendantOf(Model) or Result.Instance == Model) then 
        return true, Origin, Destination
    end
    return false, nil, nil
end

--// Preset for mouse raycasting
function RaycastModule:MouseRaycast(Distance: number)
    local Direction = Mouse.UnitRay.Direction.Unit
    local Result = Workspace:Raycast(Mouse.UnitRay.Origin, Direction * (Distance + 7.5), self.RaycastParams)
    return Result
end

--// Multi-scan manipulation
function RaycastModule:FindVisiblePositionOnModel(Origin: CFrame, Model: Instance, PartsList: table)
    local Results = {}
    for _, Offset in ManipulationOffsets do 
        local WorldPosition = (Origin * Offset).Position
        for _, PartName in PartsList do 
            local Part = Model:FindFirstChild(PartName)
            if not Part then continue end
            local IsVisible = self:IsPartVisible(WorldPosition, Part)
            if IsVisible then
                table.insert(Results, {
                    ["Part"] = Part,
                    ["NewOrigin"] = WorldPosition,
                    ["OldOrigin"] = Origin
                })
            end
        end
    end
    return Results
end;

--// Single-scan manipulation
function RaycastModule:FindVisiblePositionOnPart(Origin: CFrame, Part: Instance, Model)
    for _, Offset in ManipulationOffsets do 
        local WorldPosition = (Origin * Offset).Position
        if self:IsPartVisible(WorldPosition, Part, Model) then
            return {
                ["Part"] = Part,
                ["NewOrigin"] = WorldPosition,
                ["OldOrigin"] = Origin
            }
        end
    end
    return nil
end;

--// Multi-scan manipulation (underground)
function RaycastModule:FindUndergroundVisiblePositionOnModel(Origin: CFrame, Model: Instance, PartsList: table)
    local Results = {}
    for _, Offset in UndergroundOffsets do 
        local WorldPosition = (Origin * Offset).Position
        for _, PartName in PartsList do 
            local Part = Model:FindFirstChild(PartName)
            if not Part then continue end
            local IsVisible = self:IsPartVisible(WorldPosition, Part)
            if IsVisible then
                table.insert(Results, {
                    ["Part"] = Part,
                    ["NewOrigin"] = WorldPosition,
                    ["OldOrigin"] = Origin
                })
            end;
        end;
    end;
    return Results;
end;

--// Single-scan manipulation (underground)
function RaycastModule:FindUndergroundVisiblePositionOnPart(Origin: CFrame, Part: Instance, Model)
    for _, Offset in UndergroundOffsets do 
        local WorldPosition = (Origin * Offset).Position
        if self:IsPartVisible(WorldPosition, Part, Model) then
            return {
                ["Part"] = Part,
                ["NewOrigin"] = WorldPosition,
                ["OldOrigin"] = Origin
            }
        end
    end
    return nil
end;

getgenv().Modules.RayCasting = RaycastModule
return RaycastModule
