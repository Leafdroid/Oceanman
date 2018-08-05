include('shared.lua')
 

net.Receive( "PaddleBoat", function()

local boat = net.ReadEntity()
local ply = net.ReadEntity()
if boat:GetNWEntity("Creator") and boat:GetNWEntity("Creator") == ply and boat:GetNWEntity("Creator"):IsValid() then


if timer.Exists(tostring(boat)..":PaddleTimer") then
timer.Remove(tostring(boat)..":PaddleTimer")
boat.Paddle = false
boat.paddleamount = 0
boat.ReversePaddle = false
end

	boat.Paddle = true
	timer.Create( tostring(boat)..":PaddleTimer", .82, 1, function()
		if boat:IsValid() then
			boat.Paddle = false
			boat.paddleamount = 0
			boat.ReversePaddle = false
		end
	end)
end

end )

net.Receive( "StartBoatRocket", function()
local boat = net.ReadEntity()
local ply = net.ReadEntity()
if boat:GetNWEntity("Creator") and boat:GetNWEntity("Creator") == ply and boat:GetNWEntity("Creator"):IsValid() then
boat.Rocket = true
end
end )

net.Receive( "StopBoatRocket", function()
local boat = net.ReadEntity()
local ply = net.ReadEntity()
if boat:GetNWEntity("Creator") and boat:GetNWEntity("Creator") == ply and boat:GetNWEntity("Creator"):IsValid() then
boat.Rocket = false
end
end )

 
function ENT:Draw()

local creator = self:GetNWEntity("Creator")

if !GAMEMODE.clientsidemodel then
GAMEMODE.clientsidemodel = ClientsideModel("models/xqm/jetenginepropeller.mdl")
GAMEMODE.clientsidemodel:SetNoDraw( true )
end


if !self.paddleamount then self.paddleamount = 0 end

if !self.righthandpos then self.righthandpos = Vector(0,0,0) end
if !self.righthandang then self.righthandang = Angle(0,0,0) end

		if self:GetNWEntity("Creator") and self:GetNWEntity("Creator"):IsValid() then
		
			GAMEMODE.clientsidemodel:SetModel( self:GetNWEntity("Creator"):GetModel() )
			GAMEMODE.clientsidemodel:SetModelScale(1)
			GAMEMODE.clientsidemodel:SetSequence("sit_melee2")
			--PrintTable(GAMEMODE.clientsidemodel:GetSequenceList())
			GAMEMODE.clientsidemodel:SetPos( self:GetPos()-self:GetForward()*48+self:GetRight()*8 )
			GAMEMODE.clientsidemodel:SetAngles( self:GetAngles()+Angle(-10,0,0) )
			
			local righthand = GAMEMODE.clientsidemodel:LookupBone("ValveBiped.Bip01_R_Hand")

			if self:GetPos():Distance(LocalPlayer():GetPos()) < (GAMEMODE.Config["BoatBonesDistance"] or 0) then
			
			local spine1 = GAMEMODE.clientsidemodel:LookupBone("ValveBiped.Bip01_Spine")
			local spine2 = GAMEMODE.clientsidemodel:LookupBone("ValveBiped.Bip01_Spine1")
			local head = GAMEMODE.clientsidemodel:LookupBone("ValveBiped.Bip01_Head1")
			
			local rightarm = GAMEMODE.clientsidemodel:LookupBone("ValveBiped.Bip01_R_Upperarm")
			
			local forwardspeed = math.Clamp( self:GetVelocity():Dot(self:GetForward())/30, -30, 30 )
			local sidespeed = math.Clamp( self:GetVelocity():Dot(self:GetRight())/7.5, -45, 45 )
			
			local lookdir = self:GetAngles().y-self:GetNWEntity("Creator"):EyeAngles().y
			
			if self.Paddle then
			
			if self.paddleamount < 96 and !self.ReversePaddle then
				self.paddleamount=self.paddleamount+FrameTime()*64
			else
				self.ReversePaddle = true
				self.paddleamount=self.paddleamount-FrameTime()*96
			end
			
			GAMEMODE.clientsidemodel:ManipulateBoneAngles(rightarm,Angle(45,-45+self.paddleamount/1.5,-self.paddleamount/6))
			else
			GAMEMODE.clientsidemodel:ManipulateBoneAngles(rightarm,Angle(45,-45,0))
			end
			
			GAMEMODE.clientsidemodel:ManipulateBoneAngles(righthand,Angle(-20-self.paddleamount/2,40-self.paddleamount/2,-20))

			
			GAMEMODE.clientsidemodel:ManipulateBoneAngles(head,Angle(sidespeed,-forwardspeed,0))
			GAMEMODE.clientsidemodel:ManipulateBoneAngles(spine2,Angle(-sidespeed,-forwardspeed,0))
			GAMEMODE.clientsidemodel:ManipulateBoneAngles(spine1,Angle(-sidespeed,-forwardspeed,0))
			
			end
			
			GAMEMODE.clientsidemodel:SetupBones()
			GAMEMODE.clientsidemodel:DrawModel()
			
			if self:GetPos():Distance(LocalPlayer():GetPos()) < (GAMEMODE.Config["BoatModelsDistance"] or 0) then
			
			local matrix = GAMEMODE.clientsidemodel:GetBoneMatrix( righthand )
			self.righthandpos, self.righthandang = LocalToWorld( Vector(5,0,-8), Angle(0,0,0), matrix:GetTranslation(), matrix:GetAngles() ) --LocalToWorld( Vector(2,0,0), Angle(-80,0,-20), matrix:GetTranslation(), matrix:GetAngles() )
			
			GAMEMODE.clientsidemodel:SetModel("models/props_foliage/tree_poplar_01.mdl") --"models/props_c17/pushbroom.mdl") css model
			GAMEMODE.clientsidemodel:SetModelScale(.1)
			GAMEMODE.clientsidemodel:SetPos( self.righthandpos )
			GAMEMODE.clientsidemodel:SetAngles( self.righthandang )
			GAMEMODE.clientsidemodel:SetupBones()
			GAMEMODE.clientsidemodel:DrawModel()
			
			if !self.propellerspin then self.propellerspin = 0 end
			if self.Rocket then
			self.propellerspin = self.propellerspin+FrameTime()*1000
			end
			
			if self.propellerspin >= 360 then self.propellerspin = 0 end
						
			local ang = self:GetAngles()
			ang:RotateAroundAxis(self:GetForward(),16)
			ang:RotateAroundAxis(self:GetUp(),-10)
			ang:RotateAroundAxis(self:GetRight(),0)
			GAMEMODE.clientsidemodel:SetModel("models/gibs/airboat_broken_engine.mdl")
			GAMEMODE.clientsidemodel:SetModelScale(.5)
			GAMEMODE.clientsidemodel:SetPos( self:GetPos()-self:GetForward()*55+self:GetRight()*21-self:GetUp()*6 )
			GAMEMODE.clientsidemodel:SetAngles( ang )
			GAMEMODE.clientsidemodel:SetupBones()
			GAMEMODE.clientsidemodel:DrawModel()
			
			local ang = self:GetAngles()
			ang:RotateAroundAxis(self:GetForward(),-16)
			ang:RotateAroundAxis(self:GetUp(),10)
			ang:RotateAroundAxis(self:GetRight(),0)
			GAMEMODE.clientsidemodel:SetModel("models/gibs/airboat_broken_engine.mdl")
			GAMEMODE.clientsidemodel:SetModelScale(.5)
			GAMEMODE.clientsidemodel:SetPos( self:GetPos()-self:GetForward()*55-self:GetRight()*21-self:GetUp()*6 )
			GAMEMODE.clientsidemodel:SetAngles( ang )
			GAMEMODE.clientsidemodel:SetupBones()
			GAMEMODE.clientsidemodel:DrawModel()

			local ang = self:GetAngles()
			ang:RotateAroundAxis(self:GetForward(),self.propellerspin)
			ang:RotateAroundAxis(self:GetUp(),6)
			ang:RotateAroundAxis(self:GetRight(),185)
			GAMEMODE.clientsidemodel:SetModel("models/xqm/jetenginepropeller.mdl")
			GAMEMODE.clientsidemodel:SetModelScale(.5)
			GAMEMODE.clientsidemodel:SetPos( self:GetPos()-self:GetForward()*64+self:GetRight()*18-self:GetUp()*9 )
			GAMEMODE.clientsidemodel:SetAngles( ang )
			GAMEMODE.clientsidemodel:SetupBones()
			GAMEMODE.clientsidemodel:DrawModel()
			
			local ang = self:GetAngles()
			ang:RotateAroundAxis(self:GetForward(),-self.propellerspin)
			ang:RotateAroundAxis(self:GetUp(),-6)
			ang:RotateAroundAxis(self:GetRight(),185)
			GAMEMODE.clientsidemodel:SetModel("models/xqm/jetenginepropeller.mdl")
			GAMEMODE.clientsidemodel:SetModelScale(.5)
			GAMEMODE.clientsidemodel:SetPos( self:GetPos()-self:GetForward()*64-self:GetRight()*19-self:GetUp()*9 )
			GAMEMODE.clientsidemodel:SetAngles( ang )
			GAMEMODE.clientsidemodel:SetupBones()
			GAMEMODE.clientsidemodel:DrawModel()

			local ang = self:GetAngles()
			ang:RotateAroundAxis(self:GetForward(),180)
			ang:RotateAroundAxis(self:GetUp(),185)
			ang:RotateAroundAxis(self:GetRight(),210)
			GAMEMODE.clientsidemodel:SetModel("models/props_junk/gascan001a.mdl")
			GAMEMODE.clientsidemodel:SetModelScale(1)
			GAMEMODE.clientsidemodel:SetPos( self:GetPos()-self:GetForward()*56+self:GetUp()*7.5+-self:GetRight()*10 )
			GAMEMODE.clientsidemodel:SetAngles( ang )
			GAMEMODE.clientsidemodel:SetupBones()
			GAMEMODE.clientsidemodel:DrawModel()
			
			end
			
		end

self:DrawModel()
--[[
if self.Rocket then

local effectdata = EffectData()
effectdata:SetOrigin( self:GetPos()-self:GetForward()*55+self:GetRight()*21-self:GetUp()*10 )
util.Effect( "boatenginesmoke", effectdata )

local vPoint = Vector( 0, 0, 0 )
local effectdata = EffectData()
effectdata:SetOrigin( self:GetPos()-self:GetForward()*55-self:GetRight()*21-self:GetUp()*10 )
util.Effect( "boatenginesmoke", effectdata )

end
]]--
end
