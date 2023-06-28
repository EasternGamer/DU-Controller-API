function Controller(hybrid, hasbrake, range)
    
    local self = {}
    
    if hybrid == nil then
        hybrid = true
    end
    if hybrid then -- if in hybrid mode, it means there is no discrete brake and the range is in half mode.
        hasbrake = false
        range = false
    end
    if hasbrake == nil then
        hasbrake = false
    end
    if range == nil then
        range = true
    end
    local construct, system = construct, system
    local getVelocity = construct.getWorldVelocity
    local getAxis = system.getAxisValue
    local getMass = construct.getMass
    local getMaxBrake = construct.getMaxBrake
    local getTime = system.getArkTime
    
    
  
    
    -- return -1...1 if range is false or is hybrid
    -- returns 0...1 if range is true and not hybrid
    -- returns 0...0...1 if hybrid and none of the other conditions
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
    
    -- returns number 0...1
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
    
    
    function self.getRawRoll() return getAxis(0) end
    function self.getRawPitch() return getAxis(1) end
    function self.getRawYaw() return getAxis(2) end
    function self.getRawThrottle() return getRawThrottle() end
    function self.getRawBrake() return getRawBrake() end
    function self.getRawStrafe() return getAxis(5) end
    function self.getRawVertical() return getAxis(6) end
    
    function self.getRawAxis7() return getAxis(7) end
    function self.getRawAxis8() return getAxis(8) end
    function self.getRawAxis9() return getAxis(9) end
    
    -- deadzones between 0 and 1
    local deadzones = {0,0,0,0.05,0,0,0,0,0}
    local inputs = {self.getRawRoll(),self.getRawPitch(),self.getRawYaw(),self.getRawThrottle(),self.getRawBrake(),self.getRawStrafe(),self.getRawVertical(),self.getRawAxis7(),self.getRawAxis8(),self.getRawAxis9()}
    local lastTimeCached = {0,0,0,0,0,0,0,0,0,0}
    local function setDeadzone(deadzoneIndex, value)
        if value >= 1 then
            deadzone[deadzoneIndex] = 0.999
        elseif value <= 0 then
            deadzone[deadzoneIndex] = 0
        else
            deadzone[deadzoneIndex] = value
        end
    end
    
    function self.setRollDeadzone(newDeadzone) setDeadzone(0, newDeadzone) end
    function self.setPitchDeadzone(newDeadzone) setDeadzone(1, newDeadzone) end
    function self.setYawDeadzone(newDeadzone) setDeadzone(2, newDeadzone) end
    function self.setThrottleDeadzone(newDeadzone) setDeadzone(3, newDeadzone) end
    function self.setBrakeDeadzone(newDeadzone) setDeadzone(4, newDeadzone) end
    function self.setStafeDeadzone(newDeadzone) setDeadzone(5, newDeadzone) end
    function self.setVerticalDeadzone(newDeadzone) setDeadzone(6, newDeadzone) end
    function self.setAxis7Deadzone(newDeadzone) setDeadzone(7, newDeadzone) end
    function self.setAxis8Deadzone(newDeadzone) setDeadzone(8, newDeadzone) end
    function self.setAxis9Deadzone(newDeadzone) setDeadzone(9, newDeadzone) end
    
    -- Handles the deadzone and increases the range as needed.
    local function handleCenterDeadzone(value, deadzone)
        if value < 0 then
            return value < -deadzone and (value + deadzone)*(1/(1-deadzone)) or 0
        else
            return value > deadzone and (value - deadzone)*(1/(1-deadzone)) or 0
        end
    end
    -- Handles the deadzone and increases the range as needed, around the extremes of -1 and 1.
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
            local valueCentered = handleCenterDeadzone(value, deadzone)
            --system.print('Centered: ' .. valueCentered)
            local edged = handleEdgeDeadzone(valueCentered, deadzone)
            --system.print('Edged + centered: ' .. edged)
            --system.print('Just Edged: ' .. handleEdgeDeadzone(value, deadzone))
            return edged
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
                newInput = handleCenterDeadzone(newinput, deadzones[axisIndex])
                inputs[axisIndex] = newInput
                return newInput
            else
                return inputs[axisIndex]
            end
        else
            return inputs[axisIndex]
        end
    end
    
    function self.getRollInput() return getGenericInput(0) end
    
    function self.getPitchInput() return getGenericInput(1) end
    
    function self.getYawInput() return getGenericInput(2) end
    
    function self.getThrottleInput()
        local newTime = getTime()
        if newTime - lastTimeCached[4] > 1/65 then
            lastTimeCached[4] = newTime
            local currentThrottle = getRawThrottle()

            local diff = currentThrottle - inputs[4]
            if diff < 0.8 and diff > -0.8 then
                currentThrottle = handleDeadzone(currentThrottle, deadzones[4])
                inputs[4] = currentThrottle
                return currentThrottle
            else
                return inputs[4]
            end
        else
            return inputs[4]
        end
    end
    
    function self.getBrakeInput()
        local newTime = getTime()
        if newTime - lastTimeCached[5] > 1/65 then
            lastTimeCached[5] = newTime
            local currentBrake = getRawBrake()
            local diff = currentBrake - inputs[5]
            if diff < 0.8 and diff > -0.8 then
                currentBrake = handleDeadzone(currentBrake, deadzones[5])
                inputs[5] = currentBrake
                return currentBrake
            else
                return inputs[5]
            end
        else
            return inputs[5]
        end
    end
    
    function self.getStafeInput() return getGenericInput(5) end
    
    function self.getVerticalInput() return getGenericInput(6) end
    
    function self.getAxis7Input() return getGenericInput(7) end
    function self.getAxis8Input() return getGenericInput(8) end
    function self.getAxis9Input() return getGenericInput(9) end
    
    function self.getBrakeVectorUnpacked() -- experimental
        local velocity = getVelocity()
        local vx,vy,vz = velocity[1],velocity[2],velocity[3]
        local mag = (vx*vx + vy*vy + vz*vz)^0.5
        
        local maxAcc = getMaxBrake()/getMass()
        local brakeInput = -self.getBrakeInput()*maxAcc
        
        return brakeInput*vx/mag,brakeInput*vy/mag,brakeInput*vz/mag
    end
    
    function self.getBrakeVector() -- experimental
        return {self.getBrakeVectorUnpacked()}
    end
    
    return self
end