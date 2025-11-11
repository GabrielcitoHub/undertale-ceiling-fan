return function() local self = {}
    self.repo = "github.com/GabrielcitoHub/undertale-ceiling-big-fan"
    self.https = require "objects.https" ()
    function self:isLatest()
        local latestVersion = nil
        self.https:getResponse(self.repo.."/releases/latest.com", "GET", {}, nil, function(response, code, status)
            if code == 200 then
                local tag = response:match('tag_name%s-=%s-"(.-)"')
                latestVersion = tag
            end
        end)
        if latestVersion then
            if latestVersion == VERSION then
                return true
            else
                return false, latestVersion
            end
        else
            return nil
        end
    end
    self.latest = self:isLatest()
    function self:draw()
        if self.https:checkCompatibility() then
            if self.latest then
                love.graphics.printf("You are using the latest version!", 0, 10, 640, "center")
            else
                local latestVersion = select(2, self.latest)
                love.graphics.printf("A new version is available: "..(latestVersion or "NAN").."\nPlease update at "..self.repo, 0, 10, 640, "center")
            end
        else
            love.graphics.printf("HTTPS requests are not supported on " .. PLATFORM .. ".\nCannot check for updates.", 0, 10, 640, "center")
        end
    end
    function self:update(dt)
        self.https:update(dt)
    end
return self end