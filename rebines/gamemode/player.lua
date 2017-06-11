local ply = FindMetaTable("Player")

local teams = {}

teams[1] = {name = "Rebels", color = Vector( .2, 1, .2 ) }
teams[2] = {name = "Combines", color = Vector( .2, .2, 1 ) }

function ply:SetGamemodeTeam( n )
	if not teams[n] then return end
	
	self:SetTeam( math.random( 1, 2 ) )
	
	self:SetPlayerColor( teams[n].color )
	
	return true
end