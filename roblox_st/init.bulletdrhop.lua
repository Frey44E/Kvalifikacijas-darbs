local Bullet = {}
Bullet.__index = Bullet

local GRAVITY = 9.81
local AIR_DENSITY = 1.225

function Bullet.new(initialVelocity, mass, dragCoefficient, caliber)
    local self = setmetatable({}, Bullet)
    self.velocity = initialVelocity or 800
    self.mass = mass or 0.00465
    self.dragCoefficient = dragCoefficient or 0.295
    self.caliber = caliber or 0.00556
    self.crossSectionalArea = math.pi * (self.caliber / 2)^2
    
    self.position = {x = 0, y = 0, z = 0}
    self.velocityVector = {x = 0, y = 0, z = 0}
    
    return self
end

function Bullet:calculateDrag()
    local speed = math.sqrt(
        self.velocityVector.x^2 + 
        self.velocityVector.y^2 + 
        self.velocityVector.z^2
    )
    
    local dragForce = 0.5 * AIR_DENSITY * self.dragCoefficient * 
                      self.crossSectionalArea * speed^2
    
    return dragForce
end

function Bullet:update(deltaTime, angle)
    angle = angle or 0
    local angleRad = math.rad(angle)
    
    if self.velocityVector.x == 0 and self.velocityVector.z == 0 then
        self.velocityVector.x = self.velocity * math.cos(angleRad)
        self.velocityVector.y = self.velocity * math.sin(angleRad)
    end
    
    local speed = math.sqrt(
        self.velocityVector.x^2 + 
        self.velocityVector.y^2 + 
        self.velocityVector.z^2
    )
    
    if speed > 0 then
        local dragForce = self:calculateDrag()
        local dragAccel = dragForce / self.mass
        
        local dragFactor = dragAccel / speed
        
        self.velocityVector.x = self.velocityVector.x - (self.velocityVector.x * dragFactor * deltaTime)
        self.velocityVector.y = self.velocityVector.y - (self.velocityVector.y * dragFactor * deltaTime)
        self.velocityVector.z = self.velocityVector.z - (self.velocityVector.z * dragFactor * deltaTime)
    end
    
    self.velocityVector.y = self.velocityVector.y - (GRAVITY * deltaTime)
    
    self.position.x = self.position.x + (self.velocityVector.x * deltaTime)
    self.position.y = self.position.y + (self.velocityVector.y * deltaTime)
    self.position.z = self.position.z + (self.velocityVector.z * deltaTime)
end

function Bullet:getVelocity()
    return math.sqrt(
        self.velocityVector.x^2 + 
        self.velocityVector.y^2 + 
        self.velocityVector.z^2
    )
end

function Bullet:getDrop()
    return -self.position.y
end

function simulateTrajectory(bullet, angle, maxDistance, timeStep)
    print(string.format("Initial Velocity: %.2f m/s", bullet.velocity))
    print(string.format("Firing Angle: %.2f degrees", angle))
    print("\nDistance (m) | Velocity (m/s) | Drop (m) | Time (s)")
    print("--------------------------------------------------------")
    
    local time = 0
    local lastPrintDistance = 0
    
    while bullet.position.x < maxDistance and bullet.position.y >= 0 do
        bullet:update(timeStep, angle)
        time = time + timeStep
        
        if bullet.position.x >= lastPrintDistance + 100 then
            print(string.format("%11.1f | %13.2f | %8.2f | %7.2f", 
                bullet.position.x, 
                bullet:getVelocity(), 
                bullet:getDrop(),
                time))
            lastPrintDistance = math.floor(bullet.position.x / 100) * 100
        end
    end
end

local myBullet = Bullet.new(850, 0.00465, 0.295, 0.00556)
simulateTrajectory(myBullet, 0, 1000, 0.001)