Class = {}

local private_mt = {
    __ext = 0,
    __pack = function() return '' end,
}

function Class.new(prototype)
    local class = {
        __index = prototype
    }

    function class.new(obj)
        if obj.private then
            setmetatable(obj.private, private_mt)
        end

        return setmetatable(obj, class)
    end

    return class
end