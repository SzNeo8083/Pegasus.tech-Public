local Utility_object = {}
Utility_object.__index = Utility_object

function Utility_object:QuickInstance(Class, Data) 
    local Object = Instance.new(Class);
    for Property, Value in pairs(Data) do 
        Object[Property] = Value;
    end;
    return Object
end;

function Utility_object:RgbToHex(color)
    if typeof(color) == "Color3" then
        color = { R = color.R, G = color.G, B = color.B }
    end
    local r = math.round(color.R * 255)
    local g = math.round(color.G * 255)
    local b = math.round(color.B * 255)
    return ('%02X%02X%02X'):format(r, g, b)
end

function Utility_object:lerpColor(value, colorA, colorB)
    if typeof(colorA) == "Color3" then
        colorA = { R = colorA.R, G = colorA.G, B = colorA.B }
    end
    if typeof(colorB) == "Color3" then
        colorB = { R = colorB.R, G = colorB.G, B = colorB.B }
    end
    value = math.clamp(value,0,100)
    local t = value / 100
    local r = math.round(colorA.R * 255 * (1 - t) + colorB.R * 255 * t)
    local g = math.round(colorA.G * 255 * (1 - t) + colorB.G * 255 * t)
    local b = math.round(colorA.B * 255 * (1 - t) + colorB.B * 255 * t)
    return ('%02X%02X%02X'):format(r, g, b)
end

getgenv().Modules.Utility = Utility_object
return Utility_object
