local HttpService = game:GetService("HttpService")
local ServerManager = {}
ServerManager.__index = ServerManager

local function Print(...)
    local Str = ''
    local Idx = 0
    for i,v in pairs({...}) do
        if Idx == 0 then
            Str = string.format('%s', tostring(v))
        else

            Str = string.format('%s   %s', Str, tostring(v))
        end
        Idx = Idx + 1
    end
    rconsoleprint(string.format('%s\n', Str))
end

local function DumpTable(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. DumpTable(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

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
        Url = string.format('https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100%s', self.Settings.PlaceId, 'Desc', (Cursor and string.format('cursor=%s', Cursor)) or '');
        Method = 'GET';
    })
    if self.Settings.Debug then
        Print('DEBUG GETSERVERPAGE', string.format('https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100%s', self.Settings.PlaceId, self.Settings.Method, (Cursor and string.format('cursor=%s', Cursor)) or ''))
    end
    if Request and Request.Success then
        if self.Settings.Debug then
            Print("DEBUG GetServerPage", #HttpService:JSONDecode(Request.Body).data)
        end
        return HttpService:JSONDecode(Request.Body)
    else
        if self.Settings.Debug then
            Print("DEBUG GetServerPage", "REQUEST FAILED 1")
        end
    end
    Print("DEBUG GetServerPage", "REQUEST FAILED 2")
end

function ServerManager:GetAllServers()
    local Servers = {}
    local Cursor
    local Idx = 0
    while true do
        local Page = self:GetServerPage(Cursor)
        if self.Settings.Debug then
            Print("DEBUG Page.data", self.Settings.PlaceId, self.Settings.Method, Idx, ":", #Page.data)
            Print(DumpTable(Page))
        end
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
