#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- torch.class Example - Object-Oriented Programming
--
-- This example demonstrates the usage of torch.class library for:
-- - Class definition and instantiation
-- - Inheritance and polymorphism
-- - Type checking with istype
-- - Constructor and methods
--------------------------------------------------------------------------------

local class = require('torch.class')

print("=" .. string.rep("=", 70))
print("torch.class - Object-Oriented Programming Example")
print("=" .. string.rep("=", 70))

-- Example 1: Basic Class Definition
print("\n1. Basic Class Definition")
print("-" .. string.rep("-", 70))

local Vehicle = class('Vehicle')

function Vehicle:__init(brand, model)
    self.brand = brand
    self.model = model
    self.speed = 0
end

function Vehicle:start()
    print(self.brand .. " " .. self.model .. " started")
end

function Vehicle:accelerate(amount)
    self.speed = self.speed + amount
    print(string.format("%s %s accelerating to %d km/h", self.brand, self.model, self.speed))
end

function Vehicle:getInfo()
    return string.format("%s %s (Speed: %d km/h)", self.brand, self.model, self.speed)
end

-- Create instances
local car1 = Vehicle("Toyota", "Camry")
local car2 = Vehicle("Honda", "Civic")

car1:start()
car1:accelerate(50)
car1:accelerate(30)
print("Car 1: " .. car1:getInfo())

car2:start()
car2:accelerate(60)
print("Car 2: " .. car2:getInfo())

-- Example 2: Inheritance
print("\n2. Inheritance")
print("-" .. string.rep("-", 70))

local ElectricCar = class('ElectricCar', 'Vehicle')

function ElectricCar:__init(brand, model, batteryCapacity)
    Vehicle.__init(self, brand, model)
    self.batteryCapacity = batteryCapacity
    self.charge = batteryCapacity
end

function ElectricCar:start()
    if self.charge > 0 then
        print(self.brand .. " " .. self.model .. " started (Battery: " .. self.charge .. "%)")
    else
        print(self.brand .. " " .. self.model .. " - Battery depleted!")
    end
end

function ElectricCar:charge_battery(amount)
    self.charge = math.min(self.charge + amount, self.batteryCapacity)
    print(string.format("%s %s charged to %d%%", self.brand, self.model, self.charge))
end

function ElectricCar:getInfo()
    return string.format("%s %s (Speed: %d km/h, Battery: %d%%)", 
                         self.brand, self.model, self.speed, self.charge)
end

local tesla = ElectricCar("Tesla", "Model S", 100)
tesla:start()
tesla:accelerate(80)
print("Tesla: " .. tesla:getInfo())

-- Simulate battery drain
tesla.charge = 50
tesla:charge_battery(30)
print("Tesla after charging: " .. tesla:getInfo())

-- Example 3: Type Checking
print("\n3. Type Checking")
print("-" .. string.rep("-", 70))

print("Type of car1: " .. class.type(car1))
print("Type of tesla: " .. class.type(tesla))

print("\nChecking types:")
print("  car1 is Vehicle: " .. tostring(class.istype(car1, 'Vehicle')))
print("  car1 is ElectricCar: " .. tostring(class.istype(car1, 'ElectricCar')))
print("  tesla is Vehicle: " .. tostring(class.istype(tesla, 'Vehicle')))
print("  tesla is ElectricCar: " .. tostring(class.istype(tesla, 'ElectricCar')))

-- Example 4: More Complex Hierarchy
print("\n4. Complex Class Hierarchy")
print("-" .. string.rep("-", 70))

local Shape = class('Shape')

function Shape:__init(name)
    self.name = name
end

function Shape:area()
    error("Subclass must implement area()")
end

function Shape:describe()
    return string.format("%s with area %.2f", self.name, self:area())
end

-- Rectangle class
local Rectangle = class('Rectangle', 'Shape')

function Rectangle:__init(width, height)
    Shape.__init(self, "Rectangle")
    self.width = width
    self.height = height
end

function Rectangle:area()
    return self.width * self.height
end

-- Circle class
local Circle = class('Circle', 'Shape')

function Circle:__init(radius)
    Shape.__init(self, "Circle")
    self.radius = radius
end

function Circle:area()
    return math.pi * self.radius * self.radius
end

-- Create shapes
local rect = Rectangle(5, 3)
local circ = Circle(4)

print("Rectangle: " .. rect:describe())
print("Circle: " .. circ:describe())

print("\nType hierarchy:")
print("  rect is Shape: " .. tostring(class.istype(rect, 'Shape')))
print("  rect is Rectangle: " .. tostring(class.istype(rect, 'Rectangle')))
print("  circ is Shape: " .. tostring(class.istype(circ, 'Shape')))
print("  circ is Circle: " .. tostring(class.istype(circ, 'Circle')))

-- Example 5: Real-World Use Case - Logger
print("\n5. Real-World Use Case - Logger System")
print("-" .. string.rep("-", 70))

local Logger = class('Logger')

function Logger:__init(name)
    self.name = name
    self.messages = {}
end

function Logger:log(level, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local entry = string.format("[%s] %s - %s", timestamp, level, message)
    table.insert(self.messages, entry)
    print(entry)
end

function Logger:info(message)
    self:log("INFO", message)
end

function Logger:warning(message)
    self:log("WARN", message)
end

function Logger:error(message)
    self:log("ERROR", message)
end

function Logger:getHistory()
    return table.concat(self.messages, "\n")
end

-- File logger extends Logger
local FileLogger = class('FileLogger', 'Logger')

function FileLogger:__init(name, filename)
    Logger.__init(self, name)
    self.filename = filename
end

function FileLogger:log(level, message)
    Logger.log(self, level, message)
    -- In a real implementation, this would write to a file
    -- For demo purposes, we just note it would be written
end

-- Use the logger
local logger = Logger("AppLogger")
logger:info("Application started")
logger:warning("Low memory detected")
logger:error("Failed to connect to database")

local fileLogger = FileLogger("FileLogger", "app.log")
fileLogger:info("Using file logger")

print("\n" .. string.rep("=", 70))
print("Example completed successfully!")
print(string.rep("=", 70))
