return function() local self = {}
    self.time = 0
    function self:getResponse(point, method, headers, body, callback)
        if not self:checkCompatibility() then return end
        self.callback = callback
        local url = "https://" .. point
        local req = {
            url = url,
            method = method,
            headers = headers,
            body = body
        }
        love.thread.newThread([[
            local http = require("socket.http")
            local ltn12 = require("ltn12")
            local req = ...
            local response_body = {}
            local res, code, response_headers, status = http.request{
                url = req.url,
                method = req.method,
                headers = req.headers,
                source = ltn12.source.string(req.body or ""),
                sink = ltn12.sink.table(response_body)
            }
            local response = table.concat(response_body)
            love.thread.getChannel("http_response"):push({response=response, code=code, status=status})
        ]]):start(req)
        --love.timer.sleep(0.1) -- give the thread some time to start
        self.channel = love.thread.getChannel("http_response")
    end
    function self:timeupdate(dt)
        local msg = self.channel:pop()
        if msg then
            self.callback(msg.response, msg.code, msg.status)
        else
            --love.timer.sleep(0.1)
        end
    end
    function self:update(dt)
        if self.time >= 1 then
            self.time = 0
            self:timeupdate(dt)
        end
        self.time = self.time + 1 * dt
    end
    function self:checkCompatibility()
        if PLATFORM ~= "Wii" then
            return true
        end
        return false
    end
return self end