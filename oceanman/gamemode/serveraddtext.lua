AddCSLuaFile()

if SERVER then
util.AddNetworkString( "ServerAddText" )

	local mply = FindMetaTable("Player")
	function mply:AddText(table)
	
		net.Start( "ServerAddText" )
		net.WriteTable(table)
		net.Send( self )
	
	end
	
else

	net.Receive( "ServerAddText", function()
		local table = net.ReadTable()
		chat.AddText(unpack(table))
	end )

end

local playerMeta = FindMetaTable('Player')
 
function playerMeta:isGroup(group)
    return self:IsUserGroup(string.lower(group))
end
 
