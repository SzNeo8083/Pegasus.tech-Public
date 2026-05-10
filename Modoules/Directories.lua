local Directory = {};
getgenv().Modules = {};

function Directory:Format(Name, ...)
    local Format = table.concat({...}, "/");
    Directory[Name] = Format;
    return Format
end;

local function mkdir(Directory) 
    if not isfolder(Directory) then 
        makefolder(Directory);
    end;
end;

local Main = "PegasusTech";
local Configs = Directory:Format("Configs", Main, "Configs");
local Assets = Directory:Format("Assets", Main, "Assets");
local Theme = Directory:Format("Theme", Main, "Theme");
local Images = Directory:Format("Images", Main, "Images");
local Cache = Directory:Format("Cache", Main, "Cache");
local Fonts = Directory:Format("Fonts", Main, "Fonts");
local Sound = Directory:Format("Sound", Main, "Sound");

mkdir(Main);
mkdir(Configs);
mkdir(Theme);
mkdir(Assets);
mkdir(Images);
mkdir(Cache);
mkdir(Fonts);
mkdir(Sound);

getgenv().Modules.Directory = Directory;
return Directory; 
