function Controller(hybrid, hasbrake, range)
    local t = {}
    if hybrid == nil then
        hybrid = true
    end
    if hybrid then
        hasbrake = false
        range = false
    end
    if hasbrake == nil then
        hasbrake = false
    end
    if range == nil then
        range = true
    end
    local getAxis = system.getAxisValue
    
    local function getRawThrottle()
        if range then
            return (getAxis(3) + 1)*0.5
        else
            local currentThrottle = getAxis(3)
            if not hybrid then
                return currentThrottle
            else
                if currentThrottle < 0 then
                    return 0
                else
                    return currentThrottle
                end
            end
        end
    end
    
    local function getRawBrake()
        if hasbrake then
            return (getAxis(4) + 1)*0.5
        elseif hybrid then
            local currentThrottle = -getAxis(3)
            if currentThrottle > 0 then
                return currentThrottle
            else
                return 0
            end
        end
        return 0
    end
    
    function t.getRawRoll() return getAxis(0) end
    function t.getRawPitch() return getAxis(1) end
    function t.getRawYaw() return getAxis(2) end
    function t.getRawThrottle() return getRawThrottle() end
    function t.getRawBrake() return getRawBrake() end
    function t.getRawStrafe() return getAxis(5) end
    function t.getRawVertical() return getAxis(6) end
    
    function t.getRawAxis7() return getAxis(7) end
    function t.getRawAxis8() return getAxis(8) end
    function t.getRawAxis9() return getAxis(9) end
    
    return t
end