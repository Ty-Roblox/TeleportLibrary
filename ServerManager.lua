local HttpService = game:GetService("HttpService")
local ServerManager = {}
ServerManager.__index = ServerManager

function ServerManager.new() 
    local This = {}
    return setmetatable(This, ServerManager)
end

function ServerManager:GetServerPage(PlaceId, Cursor)
    if not PlaceId then
        PlaceId=game.PlaceId
    end
    local Request=syn.request({
        Url=string.format('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100%s', tostring(PlaceId), (Cursor and string.format('cursor=%s', Cursor)) or '');
        Method='GET';
    })
    if Request and Request.Success then
        return HttpService:JSONDecode(Request.Body)
    end
end

function ServerManager:GetAllServers(PlaceId, FastMode)
    local Servers = {}
    local Cursor
    local Idx = 0
    while true do
        local Page = self:GetServerPage(PlaceId, Cursor)
        if Page and Page.data then
            Idx += 1
            for i,v in ipairs(Page.data) do
                table.insert(Servers,v)
            end
            if (FastMode and Idx > 5) then
                break
            end
            if Page.nextPageCursor then
                Cursor = Page.nextPageCursor
            else
                break
            end
        else    
            rconsoleprint'Missing TP Data?\n'
            break
        end
        if FastMode then
			task.wait()
		else
			task.wait(1)
		end
    end
    return Servers
end

return ServerManager