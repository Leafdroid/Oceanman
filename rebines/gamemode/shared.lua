GM.Name = "Rebines"
GM.Author = "Leafdroid"
GM.Email = "Leafdroids@gmail.com"
GM.Website = "N/A"

team.SetUp( 1, "Rebels", Color(0, 150, 0) )
team.SetUp( 2, "Combines", Color(0, 0, 150) )

function GM:Initialize()
	self.BaseClass.Initialize( self )
end

timeleft = 0
distanco = 0

hook.Add( "Think", "CheckPos", function()
end )

if CLIENT then

---- COLORS ----------
local baseframes = Color(75,75,75,255)
local slotframes = Color(75,75,75,255)
local bases = Color(50,50,50,255)
local slots = Color(50,50,50,255)
local armorbar = Color(75,100,150,255)
local healthbar = Color(150,75,75,255)
local armorbartext = Color(100,125,175,255)
local healthbartext = Color(175,100,100,255)
------------------------

function DrawName( ply )
 
	if !ply:Alive() then return end
 
	local offset = Vector( 0, 0, 80 )
	local ang = LocalPlayer():EyeAngles()
	local pos = ply:GetPos() + offset + ang:Up()
	local namelength = string.len( ply:GetName() )
 
	ang:RotateAroundAxis( ang:Forward(), 0 )
	ang:RotateAroundAxis( ang:Right(), 0 )
 
	cam.Start3D2D( ply:GetPos()+Vector(0.45,0,92), Angle( 0, -0, 90 ), 0.10 )
		draw.RoundedBox(8, -15-namelength*20.25, 110, namelength*41+30, 105, Color(125,125,125,255)) -- Base Frame
		draw.RoundedBox(8, 0-namelength*20.25, 125, namelength*41, 75, Color(50,50,50,255)) -- Base
		
		draw.RoundedBox(8, -15-namelength*20.25, 10, namelength*41+30, 110, Color(125,125,125,255)) -- Base Frame
		draw.RoundedBox(8, 0-namelength*20.25, 25, namelength*41, 35, Color(50,50,50,255)) -- Base
		draw.RoundedBox(8, 0-namelength*20.25, 75, namelength*41, 35, Color(50,50,50,255)) -- Base
		
		draw.RoundedBox(8, 0-namelength*20.25, 25, namelength*ply:Armor()*0.41, 35, armorbar) -- HP Bar
		draw.RoundedBox(8, 0-namelength*20.25, 75, namelength*ply:Health()*0.41, 35, healthbar) -- AP Bar
		

	cam.End3D2D()
 
	cam.Start3D2D( ply:GetPos()+Vector(0.45,0,86.25), Angle( 0, -0, 90 ), 0.25 )
		draw.DrawText( ply:Health(), "Trebuchet24", 2, 2, Color(175,100,100,255), TEXT_ALIGN_CENTER )
	cam.End3D2D()
 
	cam.Start3D2D( ply:GetPos()+Vector(0.45,0,91.25), Angle( 0, -0, 90 ), 0.25 )
		draw.DrawText( ply:Armor(), "Trebuchet24", 2, 2, Color(100,125,175,255), TEXT_ALIGN_CENTER )
	cam.End3D2D()
	
	
	cam.Start3D2D( ply:GetPos()+Vector(0.45,0,81), Angle( 0, -0, 90 ), 0.25 )
		draw.DrawText( ply:GetName(), "font", 2, 2, Color(255,255,255,200), TEXT_ALIGN_CENTER )
	cam.End3D2D()
 
end
hook.Add( "PostPlayerDraw", "DrawName", DrawName )

surface.CreateFont("font", { font="Trebuchet24", size=35}) --Create our font.

function ShowDerma()
     local DermaPanel = vgui.Create( "DFrame" ) -- Creates the frame itself
     DermaPanel:SetPos( 50,50 ) -- Position on the players screen
     DermaPanel:SetSize( 1000, 900 ) -- Size of the frame
     DermaPanel:SetTitle( "Testing Derma Stuff" ) -- Title of the frame
     DermaPanel:SetVisible( true )
     DermaPanel:SetDraggable( true ) -- Draggable by mouse?
     DermaPanel:ShowCloseButton( true ) -- Show the close button?
     DermaPanel:MakePopup() -- Show the frame
end

local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudWeaponSelection = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end
end )

hook.Add( "InitPostEntity", "some_unique_name", function()
gui.EnableScreenClicker( true )

----------------------------------------------------
local mudel = "models/effects/portalrift.mdl"
local icon = vgui.Create( "DModelPanel", Panel )
icon:SetSize( 70, 70 )
icon:SetPos(ScrW()/2-360, ScrH()-90)
icon:SetModel( mudel )
icon.DoClick = function()
LocalPlayer():SelectWeapon( "weapon_stunstick" )
end

local icon = vgui.Create( "DModelPanel", Panel )
icon:SetSize( 70, 70 )
icon:SetPos(ScrW()/2-360+90, ScrH()-90)
icon:SetModel( mudel )
icon.DoClick = function()
LocalPlayer():SelectWeapon( "weapon_357" )
end

local icon = vgui.Create( "DModelPanel", Panel )
icon:SetSize( 70, 70 )
icon:SetPos(ScrW()/2-360+90+90, ScrH()-90)
icon:SetModel( mudel )
icon.DoClick = function()
LocalPlayer():SelectWeapon( "weapon_ar2" )
end

local icon = vgui.Create( "DModelPanel", Panel )
icon:SetSize( 70, 70 )
icon:SetPos(ScrW()/2-360+650-90-90, ScrH()-90)
icon:SetModel( mudel )
icon.DoClick = function()
LocalPlayer():SelectWeapon( "weapon_crossbow" )
end

local icon = vgui.Create( "DModelPanel", Panel )
icon:SetSize( 70, 70 )
icon:SetPos(ScrW()/2-360+650-90, ScrH()-90)
icon:SetModel( mudel )
icon.DoClick = function()
LocalPlayer():SelectWeapon( "weapon_frag" )
end

local icon = vgui.Create( "DModelPanel", Panel )
icon:SetSize( 70, 70 )
icon:SetPos(ScrW()/2-360+650, ScrH()-90)
icon:SetModel( mudel )
icon.DoClick = function()
LocalPlayer():SelectWeapon( "weapon_bugbait" )
end
----------------------------------------------------

local DermaButton = vgui.Create( "DButton" ) -- Left button
DermaButton:SetText( "Shop" )
DermaButton:SetPos( ScrW()/2-85, ScrH()-55 )
DermaButton:SetSize( 75, 35 )
DermaButton.DoClick = function()
LocalPlayer():EmitSound("buttons/button4.wav")
LocalPlayer():ChatPrint("The shop is not done yet!")
end

local DermaButton = vgui.Create( "DButton" ) -- Right button
DermaButton:SetText( "End Turn" )
DermaButton:SetPos( ScrW()/2+10, ScrH()-55 )
DermaButton:SetSize( 75, 35 )
DermaButton.DoClick = function()

local ender = LocalPlayer()

LocalPlayer():EmitSound("buttons/button4.wav")
end

end )

hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()

local money = LocalPlayer():GetNWInt( "money" )
local health = LocalPlayer():Health()
local armor = LocalPlayer():Armor()


--distanco = 400

draw.RoundedBox(8, ScrW()/2-365+730, ScrH()-95, 90, 80, slotframes) -- Right side frame
draw.RoundedBox(8, ScrW()/2-360+730, ScrH()-90, 80, 70, slots) -- Right side 
draw.DrawText( distanco, "font", ScrW()/2-360+775, ScrH()-75, Color(255/distanco*160,100,100,255), TEXT_ALIGN_CENTER ) -- Left side Text


draw.RoundedBox(8, ScrW()/2-455, ScrH()-95, 90, 80, slotframes) -- Left side frame
draw.RoundedBox(8, ScrW()/2-450, ScrH()-90, 80, 70, slots) -- Left side 
draw.DrawText( timeleft, "font", ScrW()/2-415, ScrH()-75, Color(255/timeleft*6,100,100,255), TEXT_ALIGN_CENTER ) -- Left side Text

draw.RoundedBox(8, ScrW()/2-380, ScrH()-170, 760, 55, baseframes) -- Health&Armor Frame

draw.RoundedBox(8, ScrW()/2-375, ScrH()-165, 750, 20, bases) -- Armor Base
draw.RoundedBox(8, ScrW()/2-375, ScrH()-140, 750, 20, bases) -- Health Base

draw.RoundedBox(8, ScrW()/2-375, ScrH()-165, armor*7.5, 20, armorbar) -- Armor Bar
draw.DrawText( armor, "Trebuchet24", ScrW() * 0.5, ScrH()-167.25, armorbartext, TEXT_ALIGN_CENTER ) -- Armor Text

draw.RoundedBox(8, ScrW()/2-375, ScrH()-140, health*7.5, 20, healthbar) -- Health Bar
draw.DrawText( health, "Trebuchet24", ScrW() * 0.5, ScrH()-142.5, healthbartext, TEXT_ALIGN_CENTER ) -- Health Text

draw.RoundedBox(8, ScrW()/2-380, ScrH()-110, 760, 110, baseframes) -- Base Frame
draw.RoundedBox(8, ScrW()/2-375, ScrH()-105, 750, 100, bases) -- Base

draw.DrawText( "$".. money, "font", ScrW() * 0.5, ScrH()-100, Color(125,125,125,255), TEXT_ALIGN_CENTER ) -- Money text

draw.RoundedBox(6, ScrW()/2-90, ScrH()-60, 85, 45, baseframes) -- 1st middlebutton frame
draw.RoundedBox(6, ScrW()/2-85, ScrH()-55, 75, 35, bases) -- 1st middlebutton

draw.RoundedBox(6, ScrW()/2+5, ScrH()-60, 85, 45, baseframes) -- 2nd middlebutton frame
draw.RoundedBox(6, ScrW()/2+10, ScrH()-55, 75, 35, bases) -- 2nd middlebutton

draw.RoundedBox(8, ScrW()/2-365, ScrH()-95, 80, 80, slotframes) -- Slot 1 Frame
draw.RoundedBox(8, ScrW()/2-360, ScrH()-90, 70, 70, slots) -- Slot 1 
surface.SetDrawColor(255,255,255)
surface.SetMaterial( Material("entities/weapon_stunstick.png") ) 
surface.DrawTexturedRect(ScrW()/2-360, ScrH()-90,70,70)

draw.RoundedBox(8, ScrW()/2-365+90, ScrH()-95, 80, 80, slotframes) -- Slot 2 Frame
draw.RoundedBox(8, ScrW()/2-360+90, ScrH()-90, 70, 70, slots) -- Slot 2 
surface.SetDrawColor(255,255,255)
surface.SetMaterial( Material("entities/weapon_357.png") ) 
surface.DrawTexturedRect(ScrW()/2-360+90, ScrH()-90,70,70)

draw.RoundedBox(8, ScrW()/2-365+180, ScrH()-95, 80, 80, slotframes) -- Slot 3 Frame
draw.RoundedBox(8, ScrW()/2-360+180, ScrH()-90, 70, 70, slots) -- Slot 3 
surface.SetDrawColor(255,255,255)
surface.SetMaterial( Material("entities/weapon_ar2.png") ) 
surface.DrawTexturedRect(ScrW()/2-360+180, ScrH()-90,70,70)

draw.RoundedBox(8, ScrW()/2-365+470, ScrH()-95, 80, 80, slotframes) -- Slot 4 Frame
draw.RoundedBox(8, ScrW()/2-360+470, ScrH()-90, 70, 70, slots) -- Slot 4
surface.SetDrawColor(255,255,255)
surface.SetMaterial( Material("entities/weapon_crossbow.png") ) 
surface.DrawTexturedRect(ScrW()/2-360+470, ScrH()-90,70,70)

draw.RoundedBox(8, ScrW()/2-365+560, ScrH()-95, 80, 80, slotframes) -- Slot 5 Frame
draw.RoundedBox(8, ScrW()/2-360+560, ScrH()-90, 70, 70, slots) -- Slot 5 
surface.SetDrawColor(255,255,255)
surface.SetMaterial( Material("entities/weapon_frag.png") ) 
surface.DrawTexturedRect(ScrW()/2-360+560, ScrH()-90,70,70)

draw.RoundedBox(8, ScrW()/2-365+650, ScrH()-95, 80, 80, slotframes) -- Slot 6 Frame
draw.RoundedBox(8, ScrW()/2-360+650, ScrH()-90, 70, 70, slots) -- Slot 6 
surface.SetDrawColor(255,255,255)
surface.SetMaterial( Material("entities/weapon_bugbait.png") ) 
surface.DrawTexturedRect(ScrW()/2-360+650, ScrH()-90,70,70)

end )

end


if SERVER then
money = {
	starting_money = 100, --Starting money	
	payday = false, --Enable paydays
	payday_money =  0, --How much money to add in a payday
	payday_time = 0 -- Time between paydays in seconds. 5 minutes(300 seconds.) by default.
} 

player_data = FindMetaTable("Player") --Gets all the functions that affect player.

function init_spawn( ply ) --Load money on player initial spawn.
	ply:money_load()
end
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", init_spawn )

function player_data:money_load()
	if self:GetPData( "money" ) == nil then -- See if there is data under "money" for the player
		self:SetPData( "money", money['starting_money'] ) -- If not, add money.
	end
	self:SetNWInt("money", self:GetPData("money")) --Set the network int so the client can grab the info.
end



--YOU DO NOT NEED TO CALL THIS FUNCTION. money_give and money_take DO ALL THE WORK. USE THOSE INSTEAD.
function player_data:money_interact( method, amount ) -- Add or take money
	local money = self:GetPData("money") --Gets the players money.
	
	if method == 1 then	-- Method 1 is give money, method 0 is take money.
		self:SetNWInt("money", money + amount) --Set the network int for the money. This way we can get it on the client.
		self:SetPData("money", money + amount) --Users money gets updated to what the currently have + the amount from interation
	else
		self:SetNWInt("money", money - amount) 
		self:SetPData("money", money - amount) 

	end
end

-- Call with money_give(amount), for example if you wanted to give the player
-- $200 you would say ply:money_give(200)
function player_data:money_give( amount )
	if amount > 0 then --Check if the amount is over 0 to prevent players sending or giving negative amounts.
		self:money_interact(1, amount) --Add money 
	end
end

-- Call with money_take(amount), for example if you wanted to take
-- $200 away from the player you would say ply:money_take(200)
function player_data:money_take( amount )
	if amount > 0 and self:money_enough(amount) then --Check if the amount is over 0 to prevent players sending or giving negative amounts.
	self:money_interact(0, amount)
end
end


--This is used to check if the player has enough money to do what he is requesting.
function player_data:money_enough( amount ) 		--Check if the player has enough money for an Action
	local money = tonumber(self:GetPData("money")) 	--If they do not the function will return false and if
	if money >= amount then 						--they do it will return true.
		return true;
	else
		return false;
	end
end


--You do not really need this, but it can be used to get the amount of money a player has.
function player_data:money_amount()
	return self:GetPData( "money" );
end

--Payday
if money['payday'] then

	timer.Create( "payday", money['payday_time'], 0, function() --Create a timer that will execute this function every how ever long set in the table.

			for k, v in pairs(player.GetAll()) do --Iterate over every player in the server.
				v:money_give(money['payday_money']) --give them the amount of money specified in the table.
				v:PrintMessage( HUD_PRINTTALK, "Payday! You were paid $" .. money['payday_money'] ) --Print to chat "Paid NAME $X"
			end

			end )
end


--[[
	This function gives the person you are looking at a specified amount of money.
	To use look at a player and type "/givemoney x" or "!givemoney x", alternatively you
	can use "give_money x" in console. x = amount of money you want to give.
	]]
	function player_data:give_player_money( amount )
	local target = self:GetEyeTrace().Entity --Get the entity the player is looking at.
	if target:IsPlayer() then --If the entity is a player do this
		if self:money_enough(tonumber(amount)) then	--If the player has enough money, continue.
			target:money_give(tonumber(amount)) --Give money to the player he is looking at.
			self:money_take(tonumber(amount)) --Take money from the player
			self:PrintMessage( HUD_PRINTTALK, "Paid " .. target:Nick() .. " $" .. amount ) --Print to chat "Paid NAME $X"
			target:PrintMessage( HUD_PRINTTALK, self:Nick() .. " paid you $" .. amount ) --This is untested. It should print to the targets chat
																						 --"PLAYER paid you $X"
																						else
			self:PrintMessage( HUD_PRINTTALK, "You do not have enough money!" ) --If the player does not have enough money print it to chat.
		end
	else
		self:PrintMessage( HUD_PRINTTALK, "Please aim at a player." ) --If the player is not aiming at player print to chat.
	end
end

--Creating the console command for give_player_money
function give_money( client, command, arguments )
	client:give_player_money(arguments[1])
end
concommand.Add("give_money", give_money)

--CHAT COMMANDS!
function chat_commands(ply, text)

	text = string.lower(text) -- Make the message sent lower case so the command is not case sensitive.
	text = string.Explode(" ", text) --Explode the string into a table on every space.
									 --We do this so we can get the arguments.

	if text[1] == "!givemoney" or text[1] == "/givemoney" then --If the first item in the list == !givemoney or /givemoney then
		ply:give_player_money(tonumber(text[2])) --Execute the give money function
	end
end
hook.Add("PlayerSay", "Chat_Commands", chat_commands) --Hook into PlayerSay so the function is called every time a player makes a chat message.

function add_money_on_kill(victim, weapon, killer)
		if killer:IsPlayer() and victim:IsPlayer() then
		killer:money_give(10) else return
	end
end
hook.Add("PlayerDeath", "add_money_on_kill", add_money_on_kill)
end