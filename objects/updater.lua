return function()
    local self = {}
    self.debug = require "objects.debug" ()
    self.repo = "GabrielcitoHub/undertale-ceiling-big-fan"
    self.api = "api.github.com/repos/" .. self.repo
    self.https = require "objects.https" ()
    self.latestVersion = nil
    self.checked = false

    local headers = { ["User-Agent"] = "LOVE-Updater" } -- GitHub requires this

    function self:checkReleases()
        self.debug:print("Checking for latest release...")
        self.https:getResponse(self.api .. "/releases/latest", "GET", headers, nil, function(response, code, status, err)
            self.debug:print("Release check callback received! code=" .. tostring(code))

            if err then
                self.debug:print("HTTPS Error: " .. tostring(err))
                self.checked = "error"
                return
            end

            if code == 200 then
                local tag = response:match('"tag_name"%s*:%s*"([^"]+)"')
                if tag then
                    self.debug:print("Latest release tag: " .. tag)
                    self.latestVersion = tag
                    if tag == VERSION then
                        self.checked = "up_to_date"
                    else
                        self.checked = "outdated"
                    end
                else
                    self.debug:print("No tag_name found in release JSON.")
                    self.checked = "error"
                end
            elseif code == 404 then
                self.debug:print("No releases found, falling back to commit check.")
                self:checkCommits()
            else
                self.debug:print("Unexpected HTTP code: " .. tostring(code))
                self.checked = "error"
            end
        end)
    end

    function self:checkCommits()
        self.debug:print("Checking latest commit...")
        self.https:getResponse(self.api .. "/commits", "GET", headers, nil, function(response, code, status, err)
            self.debug:print("Commit check callback received! code=" .. tostring(code))

            if err then
                self.debug:print("HTTPS Error: " .. tostring(err))
                self.checked = "error"
                return
            end

            if code == 200 then
                local sha = response:match('"sha"%s*:%s*"([^"]+)"')
                if sha then
                    self.debug:print("Latest commit SHA: " .. sha)
                    if sha == (VERSION or "") then
                        self.checked = "up_to_date"
                    else
                        self.latestVersion = sha:sub(1, 7)
                        self.checked = "outdated"
                    end
                else
                    self.debug:print("No SHA found in commit JSON.")
                    self.checked = "error"
                end
            else
                self.debug:print("Unexpected HTTP code: " .. tostring(code))
                self.checked = "error"
            end
        end)
    end

    function self:checkLatest()
        if not self.https:checkCompatibility() then
            self.debug:print("HTTPS not supported on this platform.")
            self.checked = "error"
            return
        end
        self:checkReleases()
    end

    function self:draw()
        if not self.https:checkCompatibility() then
            love.graphics.printf("HTTPS not supported on " .. PLATFORM, 0, 10, 640, "center")
            return
        end

        local msg
        if not self.checked then
            msg = "Checking for updates..."
        elseif self.checked == "up_to_date" then
            msg = "You are using the latest version!"
        elseif self.checked == "outdated" then
            msg = "New version available: " .. (self.latestVersion or "???") ..
                  "\nUpdate at https://github.com/" .. self.repo
        else
            msg = "Failed to check for updates."
        end

        love.graphics.printf(msg, 0, 10, 640, "center")
        self.debug:draw()
    end

    function self:update(dt)
        self.https:update(dt)
        self.debug:update(dt)
    end

    -- Kick off the check once
    self:checkLatest()

    return self
end