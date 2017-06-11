include("shared.lua")

function GM:GUIMousePressed( mc )

	if ( mc == MOUSE_LEFT ) then
		RunConsoleCommand( "+attack", "" )
	end
	
end

function BlockedCommands( ply, bind, pressed )

	if ( bind == "+duck" ) and !ply:IsOnGround() then
			return true
	end
	
	if ( bind == "+jump" ) then
		if ( ply:KeyDown( IN_DUCK ) ) then
			return true
		else
			return false
		end
	end
	
	local blocked = {}
	
	for k, cmd in pairs( blocked ) do
		if ( string.find( bind, cmd ) ) then
			return true
		end
	end
	
end
hook.Add( "PlayerBindPress", "BlockCommands", BlockedCommands )

function GM:GUIMouseReleased( mc )

	if ( mc == MOUSE_LEFT ) then
		RunConsoleCommand( "-attack", "" )
	end

end
diry = 0
dir = 1
function GM:CreateMove( cmd )

	if dir == 1 then
	cmd:SetForwardMove( -cmd:GetSideMove() )
	cmd:SetForwardMove( cmd:GetSideMove() )
	cmd:SetViewAngles( Angle(diry, 0, 0) )
	cmd:SetSideMove( 0 )
	else
	cmd:SetForwardMove( cmd:GetSideMove() )
	cmd:SetForwardMove( -cmd:GetSideMove() )
	cmd:SetViewAngles( Angle(diry, 180, 0) )
	cmd:SetSideMove( 0 )
	end
	
end

usermessage.Hook( "ChangeOverview", ChangeOverview )

function GM:ShouldDrawLocalPlayer() return true end

function GM:CalcView( ply, origin, angles, fov )

	diry = gui.MouseY()/ScrH()*180-ScrH()/12
	
	if gui.MousePos() > ScrW()/2 then
	dir = 1
	else
	dir = 0
	end

	local view = {}

	local numPly = 0
	for k, v in pairs( player.GetAll() ) do
		numPly = numPly + 1
	end
	
	if ( numPly <= 1 and ply:Team() == TEAM_UNASSIGNED or ply:Team() == TEAM_SPECTATOR or !ply:Alive()) then
		view.origin = Vector( 0, -550, 64)
		view.angles = Angle( 0, 90, 0 )
		view.fov = 70
	else 
		view.origin = ply:GetPos() + Vector( 0, -450, 64 )
		view.angles = Angle( 0, 90, 0 )
		view.fov = 60
	end
	
	return view

end