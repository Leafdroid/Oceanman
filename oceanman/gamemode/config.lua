AddCSLuaFile()

GM.Config = {

	["RainbowFog"] = false, -- Lmao
	["RainbowFogWhite"] = 150, -- Lmao
	["RainbowFogSplit"] = 4, -- Lmao
	["RainbowFogWaterSplit"] = 800, -- Lmao

	["FogStart"] = -2000,
	["FogEnd"] = 35000,
	["FogColor"] = Color(255, 218, 198),
	["Density"] = .4,
	
	["BoatModelsDistance"] = 2048, -- How close the player needs to be to a boat to be able to see the props in/on it.
	["BoatBonesDistance"] = 2048, -- How close the player needs to be to a boat to be able to see the players bone modifications.

	["BaseHealth"] = 1000,
	["BaseStability"] = .5, -- Multiplier to keep boat aligned that is decreased alongside health
	
	["DeathSink"] = 512, -- Distance the boat has to sink to die
	["DeathTime"] = 20, -- Time to be upside down to die in case they dont sink
	
	["WaterFogStart"] = 0,
	["WaterFogEnd"] = 600,
	["WaterFogColor"] = Color(21, 48, 52),
	
	-- First argument is for the humans, second is for the monster.
	["UnderwaterFogStart"] = {-6000,-4000},
	["UnderwaterFogEnd"] = {1000,3500},
	["UnderwaterFogColor"] = {Color(21, 40, 52),Color(31, 50, 62)},
	
	["WaterPosition"] = { -- Literally any position above the water in the map, this is used to get the material and change the water fog via lua.
		["om_lake"] = {
			Vector( -5056, -1281, 115 )
		},
	},
	
	["SpawnZone"] = { -- Spawns at water height.
		["om_lake"] = {
			Vector( -3527, -3732, 176 ),
			Vector( 9734, 6706, 104 ),
		},
	},

}
