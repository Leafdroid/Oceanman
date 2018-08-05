
AddCSLuaFile()
include("shared.lua")

local hat = ClientsideModel( "models/gmod_tower/headcrabhat.mdl" )
hat:SetNoDraw( true )

local modeltable = {
--[[
[1] = {
"models/Gibs/HGIBS.mdl",
"Ichthyosaur.Head_Bone",
Vector( -20, 6, 0 ),
Angle( 180, -12, 90 ),
10,
},
]]--
}

local SourceSkyname = GetConVar("sv_skyname"):GetString()
local SourceSkyPre  = {"lf","ft","rt","bk","dn","up",}
local SourceSkyMat  = {
    Material("skybox/"..SourceSkyname.."lf"),
    Material("skybox/"..SourceSkyname.."ft"),
    Material("skybox/"..SourceSkyname.."rt"),
    Material("skybox/"..SourceSkyname.."bk"),
    Material("skybox/"..SourceSkyname.."dn"),
    Material("skybox/"..SourceSkyname.."up"),
}

function ChangeSkybox(skyboxname)
for i = 1,6 do 
	local D = Material("skybox/"..skyboxname..SourceSkyPre[i]):GetTexture("$basetexture")
			SourceSkyMat[i]:SetTexture("$basetexture",D)
	end
end
--ChangeSkybox("sky_79")

local skyboxscale = nil
local skyboxpos = nil

net.Receive( "GiveSkyCamera", function()
skyboxscale = net.ReadInt(8)
skyboxpos = net.ReadVector()
end )

function GM:SetupSkyboxFog()

	if !skyboxscale then
		net.Start("GetSkyCamera")
		net.SendToServer()
	else

		render.FogStart( GAMEMODE.Config["FogStart"]/skyboxscale )
		render.FogEnd( GAMEMODE.Config["FogEnd"]/skyboxscale )
		
		render.FogMaxDensity( GAMEMODE.Config["Density"] )
		render.FogMode( MATERIAL_FOG_LINEAR )
		
		if GAMEMODE.Config["RainbowFog"] then
			local col = HSVToColor( CurTime() % 6 * 60, 1, 1 )
			local split = GAMEMODE.Config["RainbowFogSplit"]
			local add = GAMEMODE.Config["RainbowFogWhite"]
			render.FogColor( col.r/split+add, col.g/split+add, col.b/split+add )
		else
			render.FogColor( GAMEMODE.Config["FogColor"].r, GAMEMODE.Config["FogColor"].g, GAMEMODE.Config["FogColor"].b )
		end
	end

return true
end

function GM:HUDPaint()
if LocalPlayer():GetNWEntity("Boat") then
local stability = LocalPlayer():GetNWEntity("Boat"):GetNWInt("Health")/GAMEMODE.Config["BaseHealth"]
draw.DrawText( "Boat Stability: ".. math.Round(stability*100) .."%", "TargetID", ScrW() * 0.5, ScrH()-24, Color( 255-255*stability, 255*stability, 0, 255 ), TEXT_ALIGN_CENTER )
end
end

function GM:SetupWorldFog()

		render.FogStart( GAMEMODE.Config["FogStart"] )
		render.FogEnd( GAMEMODE.Config["FogEnd"] )
		
		render.FogMaxDensity( GAMEMODE.Config["Density"] )
		render.FogMode( MATERIAL_FOG_LINEAR )
		
		if GAMEMODE.Config["RainbowFog"] then
			local col = HSVToColor( CurTime() % 6 * 60, 1, 1 )
			local split = GAMEMODE.Config["RainbowFogSplit"]
			local add = GAMEMODE.Config["RainbowFogWhite"]
			render.FogColor( col.r/split+add, col.g/split+add, col.b/split+add )
		else
			render.FogColor( GAMEMODE.Config["FogColor"].r, GAMEMODE.Config["FogColor"].g, GAMEMODE.Config["FogColor"].b )
		end

return true
end

local topicon = Material("ui/topfangs.png")
local bottomicon = Material("ui/bottomfangs.png")
local gape = 0
local nextbite = 0
local startopen = false
local canbite = false
local mouthopen = false


local waterfound = false
local watermat = nil
local underwatermat = nil

function GM:PostDrawOpaqueRenderables(_,isDrawingSkybox)

	if !waterfound then
		local tr = util.TraceLine( {
			start = GAMEMODE.Config["WaterPosition"][game.GetMap()][1],
			endpos = GAMEMODE.Config["WaterPosition"][game.GetMap()][1]-Vector(0,0,32768),
			mask = MASK_WATER,
		} )
		waterfound = true
		watermat = Material(tr.HitTexture)
		underwatermat = Material(watermat:GetString("$bottommaterial"))
		watermat:SetInt("$reflectentities", 1)
		underwatermat:SetInt("$reflectentities", 1)
		watermat:SetFloat("$refractamount", 1.5)
		underwatermat:SetFloat("$refractamount", 1.5)
		
		print(" \n<##############[ UNDERWATER SETTINGS ]##############>")
		PrintTable(underwatermat:GetKeyValues())
		print(" <##############[ UNDERWATER SETTINGS ]##############>\n")
	end

		watermat:SetInt("$fogstart",GAMEMODE.Config["WaterFogStart"])
		watermat:SetInt("$fogend",GAMEMODE.Config["WaterFogEnd"])
		
		if GAMEMODE.Config["RainbowFog"] then
			local col = HSVToColor( CurTime() % 6 * 60, 1, 1 )
			local split = GAMEMODE.Config["RainbowFogWaterSplit"]
			watermat:SetVector("$fogcolor",Vector(col.r/split,col.g/split,col.b/split))
		else
			watermat:SetVector("$fogcolor",Vector(GAMEMODE.Config["WaterFogColor"].r,GAMEMODE.Config["WaterFogColor"].g,GAMEMODE.Config["WaterFogColor"].b)/255)
		end
		
		if underwatermat then
		local num = 1
		if LocalPlayer():GetNWEntity("Fish") and LocalPlayer():GetNWEntity("Fish"):IsValid() then
		num = 2
		end
			underwatermat:SetInt("$fogstart",GAMEMODE.Config["UnderwaterFogStart"][num])
			underwatermat:SetInt("$fogend",GAMEMODE.Config["UnderwaterFogEnd"][num])
			
			if num == 2 then
			underwatermat:SetString("$underwateroverlay","")
			else
			underwatermat:SetString("$underwateroverlay","effects/water_warp01")
			end
			
			if GAMEMODE.Config["RainbowFog"] then
				local col = HSVToColor( CurTime() % 6 * 60, 1, 1 )
				local split = GAMEMODE.Config["RainbowFogWaterSplit"]
				underwatermat:SetVector("$fogcolor",Vector(col.r/split,col.g/split,col.b/split))
			else
				underwatermat:SetVector("$fogcolor",Vector(GAMEMODE.Config["UnderwaterFogColor"][num].r,GAMEMODE.Config["UnderwaterFogColor"][num].g,GAMEMODE.Config["UnderwaterFogColor"][num].b)/255)
			end
		end


	for k,v in pairs(ents.FindByClass("om_oceanman")) do
		if v:GetNWEntity("Visual") and v:GetNWEntity("Visual"):IsValid() then
			for i=1,#modeltable do

				local boneid = v:GetNWEntity("Visual"):LookupBone( modeltable[i][2] )
				local matrix = v:GetNWEntity("Visual"):GetBoneMatrix( boneid )
				if !matrix then return end
				
				local newpos, newang = LocalToWorld( modeltable[i][3], modeltable[i][4], matrix:GetTranslation(), matrix:GetAngles() )
				
				--print(newpos,newang)
				hat:SetModel(modeltable[i][1])
				hat:SetPos( newpos )
				hat:SetAngles( newang )
				hat:SetModelScale(modeltable[i][5])
				hat:SetupBones()
				hat:DrawModel()
				
				if modeltable[i][6] then
				render.SetMaterial(Material("cable/hydra"))
				render.DrawBeam( newpos+hat:GetUp()*37.5+hat:GetForward()*52-hat:GetRight()*1, newpos+hat:GetForward()*2048, 8, 1, 1)
				--[[
				local effectdata = EffectData()
				effectdata:SetStart( newpos+hat:GetUp()*43+hat:GetForward()*60 )
				effectdata:SetOrigin( newpos+hat:GetForward()*1024 )
				util.Effect( "ToolTracer", effectdata )
				]]--
				end
			
			end
		end
	end
	
	--[[
	local spos = Vector( -512, 246, 193 )
	local waves = 64
	local pos =Vector(0,0,0)
	
	if !isDrawingSkybox then
	for a=-waves,waves do
	pos = pos+Vector(16,16,0)*a
		local ang = Angle(-45,45,0)
	for i =1,8 do
	ang = ang+Angle(90/8,0,0)

	cam.Start3D2D( Vector(pos.x,pos.y,GAMEMODE.WaterConfig[game.GetMap()]["Height"]-24.9*2)+ang:Up()*64, ang, .1 )
		surface.SetDrawColor( GAMEMODE.WaterConfig["Color"].r,GAMEMODE.WaterConfig["Color"].g,GAMEMODE.WaterConfig["Color"].b,GAMEMODE.WaterConfig["Color"].a )
		surface.SetMaterial( watermat )
		local pos = 63*2
		surface.DrawTexturedRectUV( -pos/2, -16384*10, pos, 32768*10, 0, 0, 512, 512 )
	cam.End3D2D()
	
	end
	end
	end
	
	if !isDrawingSkybox then
		cam.Start3D2D( Vector(0,0,GAMEMODE.WaterConfig[game.GetMap()]["Height"]), Angle(0,0,0), 1 )
			surface.SetDrawColor( GAMEMODE.WaterConfig["Color"].r,GAMEMODE.WaterConfig["Color"].g,GAMEMODE.WaterConfig["Color"].b,GAMEMODE.WaterConfig["Color"].a )
			surface.SetMaterial( watermat )
			surface.DrawTexturedRectUV( -16384, -16384, 32768, 32768, 0, 0, 512, 512 )
		cam.End3D2D()
	else
		if !skyboxpos or !skyboxscale then
			net.Start("GetSkyCamera")
			net.SendToServer()
		else
			cam.Start3D2D( skyboxpos+Vector(0,0,GAMEMODE.WaterConfig[game.GetMap()]["Height"]/skyboxscale), Angle(0,0,0), 1 )
				surface.SetDrawColor( GAMEMODE.WaterConfig["Color"].r,GAMEMODE.WaterConfig["Color"].g,GAMEMODE.WaterConfig["Color"].b,GAMEMODE.WaterConfig["Color"].a )
				surface.SetMaterial( watermat )
				surface.DrawTexturedRectUV( -16384, -16384, 32768, 32768, 0, 0, 512*skyboxscale, 512*skyboxscale )
			cam.End3D2D()
		end
	end
	]]--

local ent = LocalPlayer():GetNWEntity("Fish")

if ent and ent:IsValid() then --and ent:WaterLevel() > 2 then

	if (LocalPlayer():KeyDown(IN_ATTACK) or startopen and gape < 250) and canbite and nextbite < CurTime() then
			gape=gape+FrameTime()*150
			mouthopen = true
			startopen = true
	else
			canbite = false
			startopen = false
			gape=gape-FrameTime()*800
		if mouthopen then
			mouthopen = false
			nextbite = CurTime()+1
		end
		if gape <= 0 then
			canbite = true
		end
	end

if gape > 250 then gape = 250 elseif gape < 0 then gape = 0 end

cam.Start3D2D( ent:GetPos()+ent:GetForward()*64, Angle(ent:GetAngles().z,ent:GetAngles().y-90,-ent:GetAngles().x+90), .1+gape/6000 )
surface.SetDrawColor( 225, 225, 225, gape*2 )
	surface.SetMaterial( topicon ) -- If you use Material, cache it!
	surface.DrawTexturedRect( -256, -256-gape/2, 512, 512 )
	surface.SetMaterial( bottomicon ) -- If you use Material, cache it!
	surface.DrawTexturedRect( -256, -256+gape/2, 512, 512 )
cam.End3D2D()

cam.Start3D2D( ent:GetPos()+ent:GetForward()*64, Angle(-ent:GetAngles().z,ent:GetAngles().y-90+180,ent:GetAngles().x+90), .1+gape/6000 )
surface.SetDrawColor( 225, 225, 225, gape*2 )
	surface.SetMaterial( topicon ) -- If you use Material, cache it!
	surface.DrawTexturedRect( -256, -256-gape/2, 512, 512 )
	surface.SetMaterial( bottomicon ) -- If you use Material, cache it!
	surface.DrawTexturedRect( -256, -256+gape/2, 512, 512 )
cam.End3D2D()
end

end

function GM:CalcView( ply, pos, angles, fov )
	local view = {}

	if ply:GetNWEntity("Fish") and ply:GetNWEntity("Fish"):IsValid() then
	
	view.origin = ply:GetNWEntity("Fish"):GetPos()-angles:Forward()*300+angles:Up()*50
	view.angles = angles
	view.fov = fov+ply:GetNWEntity("Fish"):GetVelocity():Dot(ply:GetNWEntity("Fish"):GetForward())/40
	view.drawviewer = true
	
	elseif ply:GetNWEntity("Boat") and ply:GetNWEntity("Boat"):IsValid() then
	
	view.origin = ply:GetNWEntity("Boat"):GetPos()-angles:Forward()*200+angles:Up()*50
	view.angles = angles
	view.fov = fov+ply:GetNWEntity("Boat"):GetVelocity():Dot(ply:GetNWEntity("Boat"):GetForward())/40
	view.drawviewer = true
	
	end

	return view
end

surface.CreateFont( "PlayerTextFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 24,
	weight = 5000,
	antialias = true,
} )

net.Receive( "ClientRoundEndSound", function( len, ply )
surface.PlaySound("buttons/button19.wav")
end)

function GM:PostDrawOpaqueRenderables( ply )
	for k,v in pairs(player.GetAll()) do
		if v != LocalPlayer() or !v:IsLineOfSightClear(LocalPlayer()) then
		
				local ang = LocalPlayer():EyeAngles()
				
				local pos = v:GetPos()
				if v:GetNWEntity("Boat") and v:GetNWEntity("Boat"):IsValid() then
				pos = v:GetNWEntity("Boat"):GetPos()
				end
				if v:GetNWEntity("Fish") and v:GetNWEntity("Fish"):IsValid() then
				pos = v:GetNWEntity("Fish"):GetPos()
				end

				ang:RotateAroundAxis( ang:Forward(), 90 )
				ang:RotateAroundAxis( ang:Right(), 90 )
				
				
				local scale = math.Clamp(pos:Distance(EyePos())/1000,.5,4)
				if scale < 4 then
				
				local alpha = 255*(3-scale)
				
				local offset = Vector( 0, 0, 48+12*scale )

			cam.Start3D2D( pos+offset, Angle( 0, ang.y, 90 ), scale )
				draw.DrawText( v:Nick(), "PlayerTextFont", 0, 0, Color(255,255,255,alpha), TEXT_ALIGN_CENTER )
			cam.End3D2D()
			end

		end
	end
end