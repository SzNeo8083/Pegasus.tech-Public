local Directories = getgenv().Modules.Directory
local Utility = getgenv().Modules.Utility

local Sound_Object = {}
Sound_Object.__index = Sound_Object

Sound_Object.ShootSounds = {    
    ["Scar20"] = "91510933153450",
    ["SSg08"] = "2476571739",
    ["AWP"] = "2753888131",
    ["AK47-CS:GO"] = "2476570846",
    ["G3SG1"] = "18512294165",
    ["Deagle"] = "82286818216627",
    ["USP-S"] = "4108910200",
    ["USP"] = "2515499360",
    ["HK416"] = "8241511326",
    ["M4A1"] = "9057685835",
    ["SKS"] = "8660502251",
    ["SKS-Silenced"] = "8660503874",
    ["FiveSeven"] = "9057668558",
    ["AK47-Tarkov"] = "122655160661494",
    ["AK47-Rust"] = "7011577038",
    ["Arrow"] = "76555891505373",
	["Redeem"] = "136932376101446",
	["Click"] = "139658322785649",
	["POP"] = "140515349341063",
}

Sound_Object.HitSoundNames = {
	"Bameware.mp3";
	"Beep.mp3";
	"Bow.mp3";
	"Bubble.mp3";
	"Cod.mp3";
	"CSGO.mp3";
	"Fatality1.mp3";
	"Fatality2.mp3";
	"MarioCoins.mp3";
	"MinecraftXP.mp3";
	"Neverlose.mp3";
	"NoName.mp3";
	"OSU.mp3";
	"Rifk7.mp3";
	"Rust.mp3";
	"Skeet.mp3";
	"pegasus_hitsound.mp3";
	"mog.mp3";
	"bell.mp3";
	"vineboom.mp3";
	"Blackout.mp3";
	"Stick.mp3";
	"Sparkle.mp3";
	"Forenite.mp3";
	"Pow.mp3";
	"Staple.mp3";
	"Bame.mp3";
	"Tch.mp3";
	"MinecraftHit.mp3";
	"Wood.mp3";
};

task.spawn(function() 
	local files = table.create(1); do
		files.sounds = listfiles(Directories.Sound)

		if (#files.sounds == #Sound_Object.HitSoundNames) then
			for index, sound in next, Sound_Object.HitSoundNames do 
				writefile(Directories.Sound.. "/" .. sound, game:HttpGet("https://raw.githubusercontent.com/SzNeo8083/SzNeo8083.github.io/main/sounds/" .. sound))
				print("downloaded "..sound)
			end
		end
	end
end)

Sound_Object.ShootSoundNames = {}

for name, _ in pairs(Sound_Object.ShootSounds) do
    table.insert(Sound_Object.ShootSoundNames, name)
end

function Sound_Object:CreateAudio(parent, audioname, volume, pitch)
	local new_sound = Utility:QuickInstance("Sound", {
		Name = "",
		Parent = parent,
		SoundId = getcustomasset(Directories.Sound.."/"..audioname),
		Volume = volume,
	})
	Utility:QuickInstance("PitchShiftSoundEffect", {
		Name = "",
		Parent = new_sound,
		Octave = pitch,
	})

	new_sound:Play()

	task.spawn(function()
		wait(5)
		new_sound:Destroy()
	end)
end

getgenv().Modules.Sounds = Sound_Object
return Sound_Object
