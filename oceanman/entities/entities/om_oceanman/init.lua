AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

 
function ENT:Initialize()

	self.NextJump = 0
	self.landtimer = 0
	self.NextBite = 0
	self.CanBite = true
	
	self.Gape = 0
	
	self.fadecontrol = 0
	
	self:SetModel("models/leafdroid/ichthyosaur_phys.mdl")
	self:SetPos(self:GetPos()+Vector(0,0,64))
	self:DrawShadow(false)
	
	self.Visual = ents.Create("prop_dynamic")
	self.Visual:SetModel("models/ichthyosaur.mdl")
	self.Visual:SetParent(self)
	self.Visual:SetLocalPos(Vector(0,0,0))
	self.Visual:SetLocalAngles(Angle(0,0,0))
	self.Visual:Spawn()
	self.Visual.AutomaticFrameAdvance = true
	
	constraint.Weld( self.Visual, self.JawPhys, self.Visual:LookupBone("Ichthyosaur.Jaw_Bone"), 0, 0, true, false )
	
	self:SetNWEntity("Visual",self.Visual)
	self:SetPos(self:GetCreator():GetPos()+Vector(0,0,64))
	self:GetCreator():SetNWEntity("Fish",self)
	
	self:GetCreator():Spectate( OBS_MODE_CHASE )
	self:GetCreator():SpectateEntity( self )
	
	--models/player/items/humans/top_hat.mdl
	
	--[[
	for i=0,self.Visual:GetBoneCount()-1 do
	print(i,self.Visual:GetBoneName(i))
	end
	PrintTable(self.Visual:GetSequenceList())
	]]--
	
	self.CurHealth = 1000
	
	--PrintTable(self.Visual:GetSequenceList())

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	--self:EmitSound("npc/combine_gunship/gunship_moan.wav",0,math.random(70,90),1)

    local phys = self:GetPhysicsObject()

	phys:Wake()
	phys:SetMass(1500)
	
end

function ENT:OnRemove()
self:GetCreator():UnSpectate()
self:GetCreator():Spawn()
self:GetCreator():SetPos(self:GetPos())
end

function ENT:PhysicsCollide( data, phys )
	if data.Speed > 300 or (self.landtimer > 0 and data.Speed > 100 )then
		self:EmitSound("physics/flesh/flesh_strider_impact_bullet"..math.random(1,3)..".wav",75,100,.25)
	end	
	if data.HitEntity and data.HitEntity:IsValid() and ( data.HitEntity:GetPhysicsObject() or (data.HitEntity:IsPlayer() and data.HitEntity:Alive())) and data.Speed > 300 then
		self:EmitSound("npc/antlion_guard/shove1.wav",75,80,.25)
		
		local hitang = Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))*50
		
		if data.HitEntity:IsPlayer() then
			data.HitEntity:ViewPunch( hitang )
			data.HitEntity:SetVelocity(hitang:Forward()*10+self:GetVelocity()*.1)
		else
			data.HitEntity:GetPhysicsObject():ApplyForceCenter(hitang:Forward()*10+self:GetVelocity())
		end

	end
end

function ENT:OnTakeDamage( dmginfo )

local effectdata = EffectData()
effectdata:SetOrigin( dmginfo:GetDamagePosition() )
if dmginfo:GetAttacker():IsPlayer() then 
effectdata:SetNormal( dmginfo:GetAttacker():GetEyeTrace().HitNormal )
end
effectdata:SetFlags( 3 )
effectdata:SetColor( 0 )
effectdata:SetScale( 6 )
effectdata:SetMagnitude( 14 )
util.Effect( "bloodspray", effectdata )


local effectdata = EffectData()
effectdata:SetOrigin( dmginfo:GetDamagePosition() )
if dmginfo:GetAttacker():IsPlayer() then 
effectdata:SetNormal( dmginfo:GetAttacker():GetEyeTrace().HitNormal )
end
effectdata:SetFlags( 6 )
effectdata:SetColor( 0 )
effectdata:SetScale( 3 )
effectdata:SetMagnitude( 7 )
util.Effect( "bloodspray", effectdata )

self.CurHealth = self.CurHealth-dmginfo:GetDamage()

if self.CurHealth <= 0 then
self.CurHealth = 500
self:EmitSound("npc/antlion_guard/antlion_guard_die"..math.random(1,2)..".wav")
end

end

function ENT:Attack()

	self.Attacking = true
	self:EmitSound("npc/ichthyosaur/attack_growl"..math.random(1,3)..".wav")
	self.Visual:SetPlaybackRate(1)
	self.Visual:ResetSequence(self.Visual:LookupSequence("attackstart"))

	timer.Simple(.5,function()
		if self:IsValid() then
		
			local tr = util.TraceHull( {
				start = self:GetPos(),
				endpos = self:GetPos()+self:GetForward()*32,
				filter = function( ent ) if ent != self and ent != self.Visual then return true end end,
				mins = -Vector( 32, 32, 32 ),
				maxs = Vector( 32, 32, 32 ),
			} )
			
				self.Visual:SetPlaybackRate(1)
				
				if tr.Entity and tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:Alive() then
					self.Visual:ResetSequence(self.Visual:LookupSequence("attackend"))
					local hitang = Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))*50
					tr.Entity:ViewPunch( hitang )
					tr.Entity:SetVelocity(hitang:Forward()*5)
					tr.Entity:TakeDamage( math.random(54,61), self )
					self:EmitSound("npc/zombie/claw_strike"..math.random(1,3)..".wav",75,math.random(95,105))
					if math.random(1,3) == 1 then self:FindNewTarget() end
				else
					self.Visual:ResetSequence(self.Visual:LookupSequence("attackmiss"))
					self:EmitSound("npc/antlion_guard/angry"..math.random(1,3)..".wav",75,math.random(65,85))
					if math.random(1,3) == 1 then self:FindNewTarget() end
				end
			
			timer.Simple(.5,function()
				if self:IsValid() then
					self.Attacking = false
				end
			end)
		end
	end)
	
	self.NextAttack = CurTime()+2
end

function ENT:Bite()

	self:EmitSound("npc/barnacle/barnacle_bark"..math.random(1,2)..".wav")
	

	local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos()+self:GetForward()*48,
		filter = function( ent ) if ent != self and ent != self.Visual and !ent:IsWorld() then return true end end,
		mins = -Vector( 32, 32, 32 ),
		maxs = Vector( 32, 32, 32 ),
	} )
	

	if tr.Entity:IsValid() then

	self:EmitSound("npc/headcrab/headbite.wav",75,math.random(70,80))
	
	local hitang = Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))*50
	
		if tr.Entity:IsPlayer() and tr.Entity:Alive() then
			tr.Entity:ViewPunch( hitang )
			tr.Entity:SetVelocity(hitang:Forward()*50+self:GetVelocity())
			tr.Entity:TakeDamage( math.random(54,61), self )
		elseif tr.Entity:GetPhysicsObject():IsValid() then
			self.biteweld = constraint.Weld( tr.Entity, self, 0, 0, 0, false, false )
				timer.Simple(1,function()
					if self.biteweld:IsValid() then
						self.biteweld:Remove()
					end
				end)
			tr.Entity:TakeDamage( math.random(54,61), self )
		end
	end

end

function ENT:Think()
local tickmult = FrameTime()*66

local playbackrate = math.Clamp(self:GetVelocity():Length(),0,2000)/1000

--if self:WaterLevel() > 2 then
	if (self:GetCreator():KeyDown(IN_ATTACK) or self.StartOpening and self.Gape < 250) and self.CanBite and self.NextBite < CurTime() then
		self.Gape=self.Gape+FrameTime()*500
		if !self.MouthOpen then
		self:EmitSound("npc/barnacle/barnacle_tongue_pull2.wav")
		end
		self.MouthOpen = true
		self.StartOpening = true
	else
		self.CanBite = false
		self.StartOpening = false
		self.Gape=self.Gape-FrameTime()*1500
		if self.MouthOpen then
		self:Bite()
		self.MouthOpen = false
		self.NextBite = CurTime()+1
		end
		if self.Gape <= 0 then
		self.CanBite = true
		end
	end
if self.Gape > 250 then self.Gape = 250 elseif self.Gape < 0 then self.Gape = 0 end
--end
local biteang = -self.Gape/4+20

self.Visual:ManipulateBoneAngles(self.Visual:LookupBone("Ichthyosaur.Jaw_Bone"),Angle(0,biteang,0))

local plang = self:GetAngles()-self:GetCreator():EyeAngles()
if plang.x > 15 then plang.x = 15 elseif plang.x < -15 then plang.x = -15 end
if plang.y > 15 then plang.y = 15 elseif plang.y < -15 then plang.y = -15 end

--self.Visual:ManipulateBoneAngles(self.Visual:LookupBone("Ichthyosaur.Head_Bone"),Angle(0,-biteang,0))
self.Visual:ManipulateBonePosition(self.Visual:LookupBone("Ichthyosaur.Jaw_Bone"),Vector(-5,0,0))
self.Visual:ManipulateBoneAngles(self.Visual:LookupBone("Ichthyosaur.Head_Bone"),Angle(plang.y,plang.x,0))

if self:WaterLevel() > 0 and self.fadecontrol < 1 then self.fadecontrol=self.fadecontrol+FrameTime() end

if self:WaterLevel() > 1 then 
self:GetPhysicsObject():SetMaterial("gmod_ice")
else
self:GetPhysicsObject():AddAngleVelocity(-self:GetPhysicsObject():GetAngleVelocity()*.1)
self:GetPhysicsObject():SetMaterial("alienflesh")
end

self:GetCreator():SetPos( self:GetPos() )

if self:WaterLevel() > 2 then
		self:GetPhysicsObject():AddAngleVelocity(-self:GetPhysicsObject():GetAngleVelocity()*.1*self.fadecontrol*tickmult)
		local upvel = self:GetUp()*self:GetVelocity():Dot(self:GetUp())*self.fadecontrol*2
		local sidevel = self:GetRight()*self:GetVelocity():Dot(self:GetRight())*self.fadecontrol*2
		self:GetPhysicsObject():SetVelocity(self:GetVelocity()-upvel-sidevel*tickmult)
		self:GetPhysicsObject():ApplyForceCenter(Vector(0,0,-self:GetPhysicsObject():GetMass()*.85)*tickmult)
end

	if self:WaterLevel() > 2 then
		
		if self:GetCreator():KeyDown(IN_FORWARD) or self:GetCreator():KeyDown(IN_BACK) or self:GetCreator():KeyDown(IN_SPEED) then
		local speed = 0
		local speedmult = 1
		
		if self:GetCreator():KeyDown(IN_DUCK) then
			speedmult = .5
		end
		if self:GetCreator():KeyDown(IN_SPEED) then
			speedmult = 4.5
		end
		
		if self:GetCreator():KeyDown(IN_BACK) then
			speed = -2.5
		end
		if self:GetCreator():KeyDown(IN_FORWARD) then
			speed = 5
		end

		
			self:GetPhysicsObject():ApplyForceCenter(self:GetForward()*self:GetPhysicsObject():GetMass()*self.fadecontrol*speed*speedmult)
		
			if !self:GetCreator():KeyDown(IN_WALK) then
				local dir = self:GetCreator():EyeAngles():Forward():GetNormalized()
				local turnspeed = math.Clamp(self:GetVelocity():Length(),0,1000)/100+2
				self:GetPhysicsObject():ApplyForceOffset(-dir*self:GetPhysicsObject():GetMass()*turnspeed*self.fadecontrol,self:GetPos()-self:GetForward()*64*tickmult)
				self:GetPhysicsObject():ApplyForceOffset(dir*self:GetPhysicsObject():GetMass()*turnspeed*self.fadecontrol,self:GetPos()+self:GetForward()*64*tickmult)
			end
		
		end

	else
	
		if self:GetCreator():KeyDown(IN_FORWARD) then
		self:GetPhysicsObject():AddAngleVelocity(Vector(0,15,0)*tickmult)
		end
		if self:GetCreator():KeyDown(IN_BACK) then
		self:GetPhysicsObject():AddAngleVelocity(Vector(0,-15,0)*tickmult)
		end
		
		if self:GetCreator():KeyDown(IN_JUMP) and self.NextJump < CurTime() then
		
			local tr = util.TraceHull( {
				start = self:GetPos(),
				endpos = self:GetPos()-Vector(0,0,32),
				filter = function( ent ) if ent != self and ent != self.Visual and (ent:IsWorld() or string.find(ent:GetClass(),"physics")) then return true end end,
				mins = Vector(-32,-32,-1),
				maxs = Vector(32,32,1),
			} )
		
			if tr.Entity:IsValid() or tr.Entity:IsWorld() then
		
				self:GetPhysicsObject():ApplyForceCenter(self:GetCreator():GetAimVector()*self:GetPhysicsObject():GetMass()*96*tickmult)
				self:GetPhysicsObject():ApplyForceCenter(Vector(0,0,self:GetPhysicsObject():GetMass()*256)*tickmult)
				self.NextJump = CurTime()+.5
				
			end
		
		end

	end
	
	if self:WaterLevel() > 1 then
		self.landtimer = 0
			
			self.Visual:SetPlaybackRate(playbackrate+.1)
			self.Visual:ResetSequence(self.Visual:LookupSequence("swim"))
			
			self:GetPhysicsObject():AddAngleVelocity( Vector(-self:GetLocalAngles().z*.25,0,0) ) -- Align angles

		underwater = true
		thrashsound = true
	else
		self.landtimer=self.landtimer+FrameTime()
		if self:WaterLevel() < 1 and self.fadecontrol > 0 then self.fadecontrol=self.fadecontrol-FrameTime()*2 end
		
			self.Visual:SetPlaybackRate(1)
			self.Visual:ResetSequence(self.Visual:LookupSequence("thrash"))
		
		if self:GetLocalAngles().z < 25 then
			self:GetPhysicsObject():AddAngleVelocity( Vector(100,0,0) )
		elseif self:GetLocalAngles().z > -25 and self.Stranded then
			self:GetPhysicsObject():AddAngleVelocity( -Vector(100,0,0) )
		end
		
	end

self:NextThink(CurTime())
return true
end