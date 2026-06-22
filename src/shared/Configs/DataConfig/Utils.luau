local Utils = {}

function Utils:DeepFreeze(t)
	if type(t) ~= "table" then return t end

    for _, v in t do
        if type(v) == "table" then self:DeepFreeze(v) end
    end

    if not table.isfrozen(t) then table.freeze(t) end

    return t
end

return Utils
