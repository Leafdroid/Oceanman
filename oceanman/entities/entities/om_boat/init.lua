AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
util.AddNetworkString( "PaddleBoat" )
util.AddNetworkString( "StartBoatRocket" )
util.AddNetworkString( "StopBoatRocket" )
util.AddNetworkString( "BoatScreenShake" )
 
function ENT:Initialize()
	
	self.Rocket = false
	self.Paddle = false
	
	self:SetModel("models/props_canal/boat002b.mdl")

	self:SetPos(self:GetCreator():GetPos()+Vector(0,0,0))
	self:GetCreator():SetNWEntity("Boat",self)
	self:SetNWEntity("Creator",self:GetCreator())
	
	self:GetCreator():Spectate( OBS_MODE_CHASE )
	self:GetCreator():SpectateEntity( self )

	self.CurHealth = GAMEMODE.Config["BaseHealth"]
	self:SetNWInt("Health",self.CurHealth)
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()

	phys:Wake()
	phys:SetMass(2500)
	
end

function ENT:OnRemove()
--self:GetCreator():UnSpectate()
--self:GetCreator():Spawn()
--self:GetCreator():SetPos(self:GetPos())
end

function ENT:PhysicsCollide( data, phys )

	if data.Speed > 300 then
		self:EmitSound("physics/wood/wood_plank_break"..math.random(1,4)..".wav",75,math.random(85,95),1)	
		
	if self.PreCrashSpeed and (!data.HitEntity or data.HitEntity.PreCrashSpeed) then
	
	local otherspeed = data.HitEntity.PreCrashSpeed
	local selfspeed = self.PreCrashSpeed
	
	local dir = (self:GetPos()-data.HitEntity:GetPos()):GetNormalized()
	
	local norm = math.Round(otherspeed:Dot(dir)/2)
	
	local othernorm = math.Round(selfspeed:Dot(-dir)/2)

	if norm < 0 then norm = 0 end
	self:TakeDamage(norm,self:GetCreator())

	end
		
	elseif data.Speed > 200 then
		self:EmitSound("physics/wood/wood_crate_impact_hard"..math.random(1,5)..".wav",75,math.random(85,95),1)	
	elseif data.Speed > 100 then
		self:EmitSound("physics/wood/wood_plank_impact_soft"..math.random(1,3)..".wav",75,80,1)
	end
		
end

function ENT:OnTakeDamage( dmginfo )
if !self:GetCreator() or !self:GetCreator():IsValid() then return end

print(self:GetCreator():Nick().." took "..dmginfo:GetDamage().." damage")
self.CurHealth = self.CurHealth-dmginfo:GetDamage()
self:SetNWInt("Health",self.CurHealth)

end

function ENT:Think()
local tickmult = FrameTime()*66

if !self:GetCreator() or !self:GetCreator():IsValid() then return end

self.PreCrashSpeed = self:GetVelocity()

if self:GetCreator():KeyDown(IN_SPEED) and !self.Rocket then
self.Rocket = true
net.Start( "StartBoatRocket" )
net.WriteEntity(self)
net.WriteEntity(self:GetCreator())
net.Broadcast()
elseif !self:GetCreator():KeyDown(IN_SPEED) and self.Rocket then
self.Rocket = false
net.Start( "StopBoatRocket" )
net.WriteEntity(self)
net.WriteEntity(self:GetCreator())
net.Broadcast()
end

if self.Rocket and !self.EngineSound then
	for k,v in pairs(player.GetAll()) do
	local vpos = v:GetPos()
	v:SetPos(self:GetPos())
	self:EmitSound( "vehicles/airboat/fan_motor_idle_loop1.wav", 75, 100, 1, CHAN_REPLACE )
	v:SetPos(vpos)
	end
	self.EngineSound = true
end
if !self.Rocket and self.EngineSound then
	for k,v in pairs(player.GetAll()) do
	local vpos = v:GetPos()
	v:SetPos(self:GetPos())
	self:EmitSound( "vehicles/airboat/fan_motor_shut_off1.wav", 75, 100, 1, CHAN_REPLACE )
	v:SetPos(vpos)
	end
	self.EngineSound = false
end

if self:GetCreator():KeyDown(IN_ATTACK2) and !self.Paddle then

	if self:WaterLevel() > 0 then
	self:EmitSound("player/footsteps/wade"..math.random(1,4)..".wav",75,math.random(90,110))
	else
	self:EmitSound("physics/wood/wood_strain"..math.random(1,3)..".wav",75,math.random(90,110))
	end

net.Start( "PaddleBoat" )
net.WriteEntity(self)
net.WriteEntity(self:GetCreator())
net.Broadcast()
	
	self.Paddle = true
	self.ForcePaddle = true
	timer.Simple(.82*(2/3),function()
	self.ForcePaddle = false
	end)
	timer.Simple(.82,function()
	self.Paddle = false
	end)
end

local plang = self:GetAngles()-self:GetCreator():EyeAngles()

self:GetCreator():SetPos( self:GetPos()+Vector(0,0,64) )

		self:GetPhysicsObject():AddAngleVelocity(-self:GetPhysicsObject():GetAngleVelocity()*.025*tickmult)
		local upvel = self:GetUp()*self:GetVelocity():Dot(self:GetUp())*0
		local sidevel = self:GetRight()*self:GetVelocity():Dot(self:GetRight())*.25
		self:GetPhysicsObject():SetVelocity(self:GetVelocity()-upvel-sidevel)
		
		if self:WaterLevel() > 0 then
		self:GetPhysicsObject():ApplyForceCenter(Vector(0,0,self:GetPhysicsObject():GetMass()*4.5*tickmult))
		end
		
		if self.Rocket and self:WaterLevel() > 0 then
		
			self:GetPhysicsObject():ApplyForceCenter(self:GetForward()*self:GetPhysicsObject():GetMass()*10*tickmult)
			self:GetPhysicsObject():AddAngleVelocity( Vector(0,-7.5*tickmult,0) )
		
		end
		
		if self.ForcePaddle then

				self:GetPhysicsObject():ApplyForceCenter(self:GetForward()*self:GetPhysicsObject():GetMass()*15*tickmult)
				self:GetPhysicsObject():AddAngleVelocity( Vector(0,-2.5*tickmult,0) )
		
			if !self:GetCreator():KeyDown(IN_WALK) then
				local dir = Vector(self:GetCreator():EyeAngles():Forward():GetNormalized().x,self:GetCreator():EyeAngles():Forward():GetNormalized().y,0)
				local turnspeed = math.Clamp(self:GetVelocity():Dot(self:GetForward())/80,1,2)
				self:GetPhysicsObject():ApplyForceOffset(-dir*self:GetPhysicsObject():GetMass()*turnspeed,self:GetPos()-self:GetForward()*64*tickmult)
				self:GetPhysicsObject():ApplyForceOffset(dir*self:GetPhysicsObject():GetMass()*turnspeed,self:GetPos()+self:GetForward()*64*tickmult)
			end
		
		end
		
		self:GetPhysicsObject():AddAngleVelocity( Vector(-self:GetLocalAngles().z*GAMEMODE.Config["BaseStability"],0,0)*self.CurHealth/GAMEMODE.Config["BaseHealth"]*tickmult ) -- Align angles

		if (self:GetPos()+self:GetUp()).z < self:GetPos().z then
		if !self.UpsideDownTimer then self.UpsideDownTimer = 0 end
			self.UpsideDownTimer=self.UpsideDownTimer+FrameTime()*2
			self:GetPhysicsObject():ApplyForceCenter(Vector(0,0,-self:GetPhysicsObject():GetMass()*self.UpsideDownTimer)*tickmult)
		elseif self.UpsideDownTimer != 0 then
			self.UpsideDownTimer = 0
		end

self:GetPhysicsObject():ApplyForceCenter(Vector(0,0,-self:GetPhysicsObject():GetMass()*self:GetPos().z/30)*tickmult)
	
if self:GetPos().z < GAMEMODE.WaterHeight-GAMEMODE.Config["DeathSink"] or self.UpsideDownTimer >= GAMEMODE.Config["DeathTime"] then
local fish = ents.Create("om_oceanman")
fish:SetPos(self:GetPos())
fish:SetCreator(self:GetCreator())
fish:Spawn()
fish:SetNWEntity("Creator",self:GetCreator())
self:Remove()

gamemode.Call("DeadBoat",self:GetCreator())
self:GetCreator():Spectate( OBS_MODE_CHASE )
self:GetCreator():SpectateEntity( fish )

end
	
self:NextThink(CurTime())
return true
end