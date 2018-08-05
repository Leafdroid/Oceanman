
AddCSLuaFile()

DeriveGamemode( "base" )

GM.Name = "Oceanman"
GM.Author = "Leafdroid [76561198004949954]"
GM.Email = "Leafdroids@gmail.com"
GM.Website = ""

include("serveraddtext.lua")
include("config.lua")

function GM:Initialize()
end

function GM:PlayerSpawn( ply )

local cl_playermodel = ply:GetInfo( "cl_playermodel" )
local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
util.PrecacheModel( modelname )
ply:SetModel( modelname )

ply:SetPlayerColor( util.StringToType( ply:GetInfo( "cl_playercolor" ), "Vector" ) )
	
end

function GM:KeyPress( ply,key )
	if ( key == IN_JUMP ) and ply:IsOnGround() then
	
		local plymins,plymaxs = ply:GetHull()
		local uptrace = util.TraceHull( {
			start = ply:GetPos(),
			endpos = ply:GetPos()+Vector(0,0,4),
			filter = function(ent) if ent != ply and string.find(ent:GetClass(),"physics*") then return true else return false end end,
			mins = plymins,
			maxs = plymaxs,
		} )
		if !uptrace.Entity:IsValid() and !uptrace.Entity:IsWorld()  then
		
			local downtrace = util.TraceHull( {
				start = ply:GetPos(),
				endpos = ply:GetPos()-Vector(0,0,4),
				filter = ply,
				mins = plymins,
				maxs = plymaxs,
			} )

			ply:SetPos(ply:GetPos()+Vector(0,0,4))
			
			if downtrace.Entity:IsValid() and downtrace.Entity:GetPhysicsObject():IsValid() then
				local speedo = downtrace.Entity:GetVelocity( downtrace.Entity:GetVelocity() )
				downtrace.Entity:GetPhysicsObject():ApplyForceOffset( -ply:GetVelocity()-Vector( 0, 0, ply:GetJumpPower()*100 ), ply:GetPos() )
				ply:SetVelocity( Vector( 0, 0, ply:GetJumpPower() ) )
				timer.Simple(0,function()
				ply:SetVelocity(speedo)
				end)
			else
				ply:SetVelocity( Vector( 0, 0, ply:GetJumpPower() ) )
			end
			
		end
	end
end


local waterfound = false
GM.WaterHeight = 0

function GM:Think()

	if !waterfound then
		local tr = util.TraceLine( {
			start = GAMEMODE.Config["WaterPosition"][game.GetMap()][1],
			endpos = GAMEMODE.Config["WaterPosition"][game.GetMap()][1]-Vector(0,0,32768),
			mask = MASK_WATER,
		} )
		waterfound = true
		GAMEMODE.WaterHeight = tr.HitPos.z
	end

	for k,ply in pairs(player.GetAll()) do

		local vmins,vmaxs = ply:GetHull()
		local downtrace = util.TraceHull( {
			start = ply:GetPos(),
			endpos = ply:GetPos()-Vector(0,0,4),
			filter = function(ent) if ent != ply and string.find(ent:GetClass(),"physics*") then return true else return false end end,
			mins = plymins,
			maxs = plymaxs,
		} )
		
		if downtrace.Entity:IsValid() and SERVER then
		--downtrace.Entity:GetPhysicsObject():SetMaterial("floatingstandable")

				--ply:SetVelocity(-downtrace.Entity:GetVelocity()*.135)
				--downtrace.Entity:GetPhysicsObject():SetMass(1250)

				--downtrace.Entity:GetPhysicsObject():SetVelocity(downtrace.Entity:GetVelocity()-Vector(0,0,downtrace.Entity:GetVelocity().z)*.1)
				--downtrace.Entity:GetPhysicsObject():AddAngleVelocity(-downtrace.Entity:GetPhysicsObject():GetAngleVelocity()*.4)
				
		end
		
		
	if SERVER and ply:GetNWEntity("Fish") and ply:GetNWEntity("Fish"):IsValid() and ply:EyePos().z <= GAMEMODE.WaterHeight then

	if !ply.Underwater then
		timer.Simple(0,function()
		--ply:ConCommand( "stopsound" )
		ply.Underwater = true
		end)
	end
	
	else
	
		ply.Underwater = false
		
	end
	
	end
		
end

local mply = FindMetaTable("Player")

function GM:Move( ply, cmd )

function mply:ForwardSpeed()
	if self == ply then
		return cmd:GetForwardSpeed()
	end
end
function mply:SideSpeed()
	if self == ply then
		return cmd:GetSideSpeed()
	end
end

end

function GM:EntityTakeDamage( target, dmginfo )
	if string.find(dmginfo:GetAttacker():GetClass(),"asd_*") or string.find(dmginfo:GetAttacker():GetClass(),"physics*") or dmginfo:IsFallDamage() then 
		dmginfo:SetDamage(0) 
	end
end
