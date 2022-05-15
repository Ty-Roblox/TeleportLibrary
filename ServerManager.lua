local HttpService = game:GetService("HttpService")
local ServerManager = {}
ServerManager.__index = ServerManager

function ServerManager.new(Options)
    if not Options then
        Options = {}
    end
    local This = {}
    This.Settings = {}
    for i,v in pairs(Options) do
        This.Settings[i] = v
    end
    return setmetatable(This, ServerManager)
end

function ServerManager:GetServerPage(Cursor)
    local Request=syn.request({
        Url=string.format('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100%s', tostring(self.Settings.PlaceId), self.Settings.Method, (Cursor and string.format('cursor=%s', Cursor)) or '');
        Method='GET';
    })
    if Request and Request.Success then
        return HttpService:JSONDecode(Request.Body)
    end
end

function ServerManager:GetAllServers()
    local Servers = {}
    local Cursor
    local Idx = 0
    while true do
        local Page = self:GetServerPage(self.Settings.PlaceId, Cursor)
        if Page and Page.data then
            Idx += 1
            for i,v in ipairs(Page.data) do
                table.insert(Servers,v)
            end
            if (self.Settings.FastMode and Idx > 5) then
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
        if self.Settings.FastMode then
			task.wait()
		else
			task.wait(self.Settings.RequestInterval)
		end
    end
    return Servers
end

return ServerManager