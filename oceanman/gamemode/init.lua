AddCSLuaFile()
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString( "GetSkyCamera" )
util.AddNetworkString( "GiveSkyCamera" )
util.AddNetworkString( "ClientRoundEndSound" )

net.Receive( "GetSkyCamera", function( len, ply )
net.Start("GiveSkyCamera")
net.WriteInt(ents.FindByClass("sky_camera")[1]:GetSaveTable().scale,8)
net.WriteVector(ents.FindByClass("sky_camera")[1]:GetSaveTable().m_vecOrigin)
net.Send( ply  )
end )

function GM:SetupPlayerVisibility( ply, viewEntity )
end

function GM:PlayerDeath( victim, inflictor, attacker )
victim:CreateRagdoll()
victim.NextSpawn = CurTime()+2
end

function GM:PlayerDeathThink( ply )
	if !ply.NextSpawn then ply.NextSpawn = CurTime()+2 end

	if ply.NextSpawn < CurTime() then
		ply:Spawn()
	end
	
return true
end

function GM:PlayerSelectSpawn()
return nil
end

function GM:PlayerDisconnected( ply )
	if table.HasValue(GAMEMODE.Alive,ply) then
		gamemode.Call("DeadBoat", ply )
	end
end

function GM:PlayerInitialSpawn(ply)

		local tbl = GAMEMODE.Config["SpawnZone"][game.GetMap()]
		local spawnpos = Vector(math.random(tbl[1].x,tbl[2].x),math.random(tbl[1].y,tbl[2].y),GAMEMODE.WaterHeight or 100)
			
		 ply:SetPos(spawnpos)
		   
		local fish = ents.Create("om_oceanman")
		fish:SetAngles(Angle(90,math.random(0,360),0))
		ply:StripWeapons()
		fish:SetCreator(ply)
		fish:Spawn()
		
		timer.Simple(0,function()
		ply:SetNWEntity("Fish",fish)
		
		fish:SetNWEntity("Creator",ply)
	
		ply:Spectate( OBS_MODE_CHASE )
		ply:SpectateEntity( self )
		
		if #player.GetAll() == 2 then
			gamemode.Call("RoundStart")
		end
		end)
		
end

function GM:DeadBoat( dead )
table.RemoveByValue(GAMEMODE.Alive,dead)
PrintTable(GAMEMODE.Alive)
if #GAMEMODE.Alive <= 1 then
net.Start("ClientRoundEndSound")
net.Broadcast()

GAMEMODE.Alive[1]:AddText({Color( 255, 225, 150 ), "Game over, "..GAMEMODE.Alive[1]:Nick().." wins!"})
timer.Simple(10,function()
gamemode.Call("RoundStart")
end)
end
end

function GM:CanPlayerSuicide( ply )
return false
end

function GM:RoundStart()
GAMEMODE.Alive = {}
game.CleanUpMap()

		for k,v in pairs(player.GetAll()) do
		
			local tbl = GAMEMODE.Config["SpawnZone"][game.GetMap()]
			local spawnpos = Vector(math.random(tbl[1].x,tbl[2].x),math.random(tbl[1].y,tbl[2].y),GAMEMODE.WaterHeight or 100)
			
		   v:SetPos(spawnpos)
		   
			local boat = ents.Create("om_boat")
			boat:SetAngles(Angle(0,math.random(0,360),0))
			v:StripWeapons()
			boat:SetCreator(v)
			boat:Spawn()
			table.insert(GAMEMODE.Alive,v)
		
		end	
		
end