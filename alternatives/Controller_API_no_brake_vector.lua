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
    local s = system
    local getAxis = s.getAxisValue
    local getTime = s.getArkTime
    
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
    
    local d = {0,0,0,0.05,0,0,0,0,0}
    local inputs = {getAxis(0),getAxis(1),getAxis(2),getRawThrottle(),getRawBrake(),getAxis(5),getAxis(6),getAxis(7),getAxis(8),getAxis(9)}
    local lastTimeCached = {0,0,0,0,0,0,0,0,0,0}
    local function setDeadzone(deadzoneIndex, value)
        if value >= 1 then
            d[deadzoneIndex] = 0.999
        elseif value <= 0 then
            d[deadzoneIndex] = 0
        else
            d[deadzoneIndex] = value
        end
    end
    
    function t.setRollDeadzone(newDeadzone) setDeadzone(0, newDeadzone) end
    function t.setPitchDeadzone(newDeadzone) setDeadzone(1, newDeadzone) end
    function t.setYawDeadzone(newDeadzone) setDeadzone(2, newDeadzone) end
    function t.setThrottleDeadzone(newDeadzone) setDeadzone(3, newDeadzone) end
    function t.setBrakeDeadzone(newDeadzone) setDeadzone(4, newDeadzone) end
    function t.setStafeDeadzone(newDeadzone) setDeadzone(5, newDeadzone) end
    function t.setVerticalDeadzone(newDeadzone) setDeadzone(6, newDeadzone) end
    function t.setAxis7Deadzone(newDeadzone) setDeadzone(7, newDeadzone) end
    function t.setAxis8Deadzone(newDeadzone) setDeadzone(8, newDeadzone) end
    function t.setAxis9Deadzone(newDeadzone) setDeadzone(9, newDeadzone) end
    
    local function handleCenterDeadzone(value, deadzone)
        if value < 0 then
            return value < -deadzone and (value + deadzone)*(1/(1-deadzone)) or 0
        else
            return value > deadzone and (value - deadzone)*(1/(1-deadzone)) or 0
        end
    end

    local function handleEdgeDeadzone(value, deadzone)
        value = value*(1/(1-deadzone))
        if value < 0 then
            return value > -1 and value or -1
        else
            return value < 1 and value or 1
        end
    end
    
    local function handleDeadzone(value, deadzone)
        if range then
            return handleEdgeDeadzone(value, deadzone)
        else
            return handleEdgeDeadzone(handleCenterDeadzone(value, deadzone), deadzone)
        end
    end
    
    local function getGenericInput(axisIndex)
        axisIndex = axisIndex + 1
        local newTime = getTime()
        if newTime - lastTimeCached[axisIndex] > 1/65 then
            lastTimeCached[axisIndex] = newTime
            local newinput = getAxis(axisIndex-1)
            local diff = inputs[axisIndex] - newinput
            if diff < 0.8 and diff > -0.8 then
                newInput = handleCenterDeadzone(newinput, d[axisIndex])
                inputs[axisIndex] = newInput
                return newInput
            end
        end
        return inputs[axisIndex]
    end
    
    local function getAdvancedInput(axisIndex, functionInput)
        axisIndex = axisIndex + 1
        local newTime = getTime()
        if newTime - lastTimeCached[axisIndex] > 1/65 then
            lastTimeCached[axisIndex] = newTime
            local currentInput = functionInput()
            local diff = currentInput - inputs[axisIndex]
            if diff < 0.8 and diff > -0.8 then
                currentInput = handleDeadzone(currentInput, d[axisIndex])
                inputs[axisIndex] = currentInput
                return currentInput
            end
        end
        return inputs[axisIndex]
    end
    
    function t.getRollInput() return getGenericInput(0) end
    function t.getPitchInput() return getGenericInput(1) end
    function t.getYawInput() return getGenericInput(2) end
    function t.getThrottleInput() return getAdvancedInput(3, getRawThrottle) end
    function t.getBrakeInput() return getAdvancedInput(4, getRawBrake) end
    function t.getStafeInput() return getGenericInput(5) end
    function t.getVerticalInput() return getGenericInput(6) end
    function t.getAxis7Input() return getGenericInput(7) end
    function t.getAxis8Input() return getGenericInput(8) end
    function t.getAxis9Input() return getGenericInput(9) end
    return t
end