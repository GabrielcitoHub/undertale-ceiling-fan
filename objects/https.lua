return function()
    local self = {}
    self.time = 0
    self.channelName = "http_response_" .. tostring(math.random(1, 999999))
    self.channel = love.thread.getChannel(self.channelName)

    --- Performs an async HTTPS request.
    --- @param point (string) URL path without "https://"
    --- @param method (string) HTTP method (GET, POST, etc.)
    --- @param headers (table) Optional headers
    --- @param body (string) Optional body
    --- @param callback (function) Function to call when done: callback(response, code, status, err)
    function self:getResponse(point, method, headers, body, callback)
        if not self:checkCompatibility() then return end
        self.callback = callback
        local url = "https://" .. point

        -- Pack request data
        local req = {
            url = url,
            method = method or "GET",
            headers = headers or {},
            body = body or ""
        }

        -- Thread code (runs in a separate Lua state)
        local threadCode = ([[
            local http = require("socket.http")
            local ltn12 = require("ltn12")
            local req, channelName = ...
            local channel = love.thread.getChannel(channelName)

            local ok, res, code, response_headers, status, response = pcall(function()
                local response_body = {}
                local res, code, response_headers, status = http.request{
                    url = req.url,
                    method = req.method,
                    headers = req.headers,
                    source = ltn12.source.string(req.body or ""),
                    sink = ltn12.sink.table(response_body)
                }
                return res, code, response_headers, status, table.concat(response_body)
            end)

            if not ok then
                channel:push({ error = res })
            else
                channel:push({ response = response, code = code, status = status })
            end
        ]])

        -- Start the thread
        local thread = love.thread.newThread(threadCode)
        thread:start(req, self.channelName)
    end

    --- Internal: handle new messages from the thread
    function self:timeupdate(dt)
        local msg = self.channel:pop()
        if msg then
            if msg.error then
                self.callback(nil, nil, nil, msg.error)
            else
                self.callback(msg.response, msg.code, msg.status)
            end
        end
    end

    --- Periodically check for new HTTP results
    function self:update(dt)
        self.time = self.time + dt
        if self.time >= 0.1 then -- every 0.1s
            self.time = 0
            self:timeupdate(dt)
        end
    end

    --- Compatibility check (skip if platform is Wii)
    function self:checkCompatibility()
        return PLATFORM ~= "Wii"
    end

    return self
end