AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("player.lua")

function GM:PlayerConnect( name, ip )
	PrintMessage( HUD_PRINTTALK, "" .. name .. " started connecting.")
	for k,v in pairs (player.GetAll()) do
	sound.Play( "buttons/button1.wav", v:GetPos() )
	end
end

function GM:PlayerInitialSpawn( ply )

	ply:SetNoCollideWithTeammates( true )
	ply:KillSilent()
	
	if #team.GetPlayers(2) < #team.GetPlayers(1) then
		ply:SetTeam(2)
	elseif #team.GetPlayers(1) < #team.GetPlayers(2) then
		ply:SetTeam(1)
	elseif #team.GetPlayers(1) == #team.GetPlayers(2) then
		ply:SetTeam(math.random(1,2))
	end
	
	
end

function GM:PlayerAuthed( ply, steamID, uniqueID )
	PrintMessage( HUD_PRINTTALK, "" .. ply:Nick() .. " has connected.")
	for k,v in pairs (player.GetAll()) do
	sound.Play( "buttons/button9.wav", v:GetPos() )
	end
end

rebdead = 0
comdead = 0

function GM:PlayerDeath( victim, inflictor, attacker )
if #player.GetAll() >= 1 then
if victim:Team() == 1 then
rebdead = rebdead + 1
elseif victim:Team() == 2 then  
comdead = comdead + 1
end

if rebdead == #team.GetPlayers(1) or comdead == #team.GetPlayers(2) then
timer.Simple( 0.1, function()
for k,v in pairs (player.GetAll()) do
v:KillSilent()
rebdead = 0
comdead = 0
v:Spawn()
--[[if v:Team() == 1 then
table.insert( rque, v )
PrintTable(rque)
elseif v:Team() == 2 then
table.insert( cque, v )
PrintTable(cque)
end
]]--
end
end)
--game.CleanUpMap(false

	if ( victim == attacker ) then
		PrintMessage( HUD_PRINTTALK, victim:Name() .. " committed suicide." )
	else
		PrintMessage( HUD_PRINTTALK, victim:Name() .. " was killed by " .. attacker:Name() .. "." )
	end
end


end

end

function GM:PlayerShouldTakeDamage( victim, pl )
if pl:IsPlayer() and pl != victim then -- check the attacker is player 	
if( pl:Team() == victim:Team() and GetConVarNumber( "mp_friendlyfire" ) == 0 ) then -- check the teams are equal and that friendly fire is off.
		return false -- do not damage the player
	end
end
 
	return true -- damage the player
end

function GM:PlayerDeathThink( ply )
return true
end

function GM:Think()

	for k,v in pairs (player.GetAll()) do
	
	posy = v:GetPos()
	
		if (posy.y > -3 and posy.y < 3) and !(posy.y > -1 and posy.y < 1) then
			v:SetPos(Vector(posy.x,0,posy.z))
		end
	
	end

end

combinemodels = {
"models/player/combine_super_soldier.mdl",
"models/player/combine_soldier_prisonguard.mdl",
"models/player/combine_soldier.mdl"
}

hook.Add( "KeyPress", "jumpsound", function( ply, key )
	
	local roundpos = math.Round(ply:GetPos().y)
	
	--if ply:GetVelocity().y > 0 then return end
	
		if ( key == IN_BACK ) and ply:IsOnGround() then
		
			if (roundpos < -75 and roundpos > -85) then return end
			
			if (roundpos > 75 and roundpos < 85) then
				ply:SetVelocity( Vector( 0, -725, 0 ) )
			elseif (roundpos > -5 and roundpos < 5) then
				ply:SetVelocity( Vector( 0, -850, 0 ) )
			end
			
		end
		
		if ( key == IN_FORWARD ) and ply:IsOnGround() then
		
			if (roundpos > 75 and roundpos < 85) then return end
			
			if (roundpos < -75 and roundpos > -85) then
				ply:SetVelocity( Vector( 0, 725, 0 ) )
			elseif (roundpos > -5 and roundpos < 5) then
				ply:SetVelocity( Vector( 0, 850, 0 ) )
			end
			
		end
end )

function GM:PlayerSpawn( ply )

	ply:SetArmor( 100 )
	ply:SetRunSpeed(200)
	ply:SetWalkSpeed(100)
	ply:SetJumpPower(220)
	ply:Give("weapon_stunstick")
	ply:Give("weapon_357")
	ply:Give("weapon_ar2")
	ply:Give("weapon_crossbow")
	ply:Give("weapon_frag")
	ply:Give("weapon_bugbait")
	
	if ply:Team() == 1 then 
	ply:SetModel("models/player/group03/male_0"..math.random(1,9)..".mdl")
	end
	
	if ply:Team() == 2 then
	ply:SetModel(table.Random( combinemodels))
	end
end

function GM:PlayerDisconnected( ply )
	PrintMessage( HUD_PRINTTALK, ply:Name().. " has left the server." )
	for k,v in pairs (player.GetAll()) do
	sound.Play( "buttons/combine_button1.wav", v:GetPos() )
	end
	
local randomrebel = table.Random(team.GetPlayers(1))
local randomcombine = table.Random(team.GetPlayers(2))

	if #team.GetPlayers(2) < #team.GetPlayers(1) then
		randomrebel:SetTeam(2)
	elseif #team.GetPlayers(1) < #team.GetPlayers(2) then
		randomcombine:SetTeam(1)
	elseif #team.GetPlayers(1) == #team.GetPlayers(2) then
	end
	
end

RebelModels = { 
"male_01", --Van
"male_02", --Ted
"male_03", --Joe
"male_04", --Eric
"male_05", --Art
"male_06", --Sandro
"male_07", --Mike
"male_08", --Vance
"male_09", --Erdin
"female_01", --Joey
"female_02", --Kanisha
"female_03", --Kim
"female_04", --Chau
"female_05", --Naomi
"female_06"  --Lakeetra
}

function GM:PlayerSelectSpawn( ply )
local rebels = ents.FindByClass("info_player_terrorist")
local combines = ents.FindByClass("info_player_counterterrorist")

    local random_1 = math.random(#rebels)
	local random_2 = math.random(#combines)
 
	if ply:Team() == 2 then
    return combines[random_2]
	elseif ply:Team() == 1 then
	return rebels[random_1]
	end
 
end

