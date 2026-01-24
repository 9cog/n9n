#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- torch.argcheck Example - Function Argument Validation
--
-- This example demonstrates the usage of torch.argcheck library for:
-- - Type checking and validation
-- - Default values
-- - Optional arguments
-- - Named arguments
-- - Custom validation functions
--------------------------------------------------------------------------------

local argcheck = require('torch.argcheck')

print("=" .. string.rep("=", 70))
print("torch.argcheck - Function Argument Validation Example")
print("=" .. string.rep("=", 70))

-- Example 1: Basic Type Checking
print("\n1. Basic Type Checking")
print("-" .. string.rep("-", 70))

local greet = argcheck{
    {name="name", type="string"},
    {name="age", type="number"},
    call = function(name, age)
        print(string.format("Hello %s, you are %d years old", name, age))
    end
}

greet("Alice", 25)
greet("Bob", 30)

-- This would error:
-- print(greet("Charlie", "thirty")) -- Error: bad argument #2 (number expected, got string)

-- Example 2: Default Values
print("\n2. Default Values")
print("-" .. string.rep("-", 70))

local connect = argcheck{
    {name="host", type="string", default="localhost"},
    {name="port", type="number", default=8080},
    {name="timeout", type="number", default=30},
    call = function(host, port, timeout)
        print(string.format("Connecting to %s:%d (timeout: %ds)", host, port, timeout))
    end
}

connect()
connect("example.com")
connect("api.server.com", 3000)
connect("db.server.com", 5432, 60)

-- Example 3: Optional Arguments
print("\n3. Optional Arguments")
print("-" .. string.rep("-", 70))

local createUser = argcheck{
    {name="username", type="string"},
    {name="email", type="string"},
    {name="phone", type="string", opt=true},
    {name="bio", type="string", opt=true},
    call = function(username, email, phone, bio)
        local result = string.format("User: %s <%s>", username, email)
        if phone then
            result = result .. string.format(", Phone: %s", phone)
        end
        if bio then
            result = result .. string.format(", Bio: %s", bio)
        end
        print(result)
    end
}

createUser("alice", "alice@example.com")
createUser("bob", "bob@example.com", "555-1234")
createUser("charlie", "charlie@example.com", nil, "Software developer")

-- Example 4: Named Arguments
print("\n4. Named Arguments")
print("-" .. string.rep("-", 70))

local sendEmail = argcheck{
    {name="to", type="string"},
    {name="subject", type="string"},
    {name="body", type="string"},
    {name="cc", type="string", opt=true},
    {name="bcc", type="string", opt=true},
    {name="priority", type="string", default="normal"},
    call = function(to, subject, body, cc, bcc, priority)
        print(string.format("%s\t%s\t%s\t%s\t%s", 
            to, subject, body, cc or "", priority))
    end
}

print("Email 1:")
sendEmail{
    to = "alice@example.com",
    subject = "Hello",
    body = "Just wanted to say hi!"
}

print("\nEmail 2:")
sendEmail{
    to = "team@company.com",
    subject = "Meeting Tomorrow",
    body = "Don't forget about the meeting at 10 AM",
    cc = "manager@company.com",
    priority = "high"
}

-- Example 5: Multiple Function Signatures
print("\n5. Multiple Function Signatures")
print("-" .. string.rep("-", 70))

-- Different functions for different types
local processStr = argcheck{
    {name="data", type="string"},
    call = function(data)
        print("Processing string: " .. data)
    end
}

local processTbl = argcheck{
    {name="data", type="table"},
    call = function(data)
        print("Processing table with " .. #data .. " elements")
    end
}

local processNum = argcheck{
    {name="data", type="number"},
    call = function(data)
        print("Processing number: " .. data)
    end
}

processStr("hello")
processTbl({1, 2, 3, 4, 5})
processNum(42)

-- Example 6: Custom Validation
print("\n6. Custom Validation")
print("-" .. string.rep("-", 70))

local registerUser = argcheck{
    {name="username", type="string", check=function(x)
        return #x >= 3 and #x <= 20
    end},
    {name="password", type="string", check=function(x)
        return #x >= 8
    end},
    {name="age", type="number", check=function(x)
        return x >= 18 and x <= 120
    end},
    call = function(username, password, age)
        print(string.format("Registered user '%s' (age %d)", username, age))
    end
}

registerUser("alice123", "securepass123", 25)
registerUser("bob_jones", "mypassword", 30)

-- These would error:
-- print(registerUser("ab", "pass", 25))  -- username too short
-- print(registerUser("alice", "short", 25))  -- password too short
-- print(registerUser("alice", "password123", 15))  -- age < 18

-- Example 7: Default from Function
print("\n7. Dynamic Default Values")
print("-" .. string.rep("-", 70))

local logEntry = argcheck{
    {name="message", type="string"},
    {name="timestamp", type="string", defaultf=function()
        return os.date("%Y-%m-%d %H:%M:%S")
    end},
    {name="level", type="string", default="INFO"},
    call = function(message, timestamp, level)
        print(string.format("%s\t%s\t%s", message, timestamp, level))
    end
}

logEntry("Application started")
logEntry("Processing data", os.date("%Y-%m-%d %H:%M:%S"), "DEBUG")
logEntry("Error occurred", nil, "ERROR")

-- Example 8: Real-World Use Case - Configuration
print("\n8. Real-World Use Case - Server Configuration")
print("-" .. string.rep("-", 70))

local createServer = argcheck{
    {name="host", type="string", default="0.0.0.0"},
    {name="port", type="number", default=8080, check=function(x)
        return x > 0 and x <= 65535
    end},
    {name="workers", type="number", default=4, check=function(x)
        return x > 0 and x <= 128
    end},
    {name="maxConnections", type="number", default=1000},
    {name="ssl", type="boolean", default=false},
    {name="certPath", type="string", opt=true},
    {name="keyPath", type="string", opt=true},
    call = function(host, port, workers, maxConnections, ssl, certPath, keyPath)
        print(string.format(
            "Server Configuration:\n" ..
            "  Host: %s\n" ..
            "  Port: %d\n" ..
            "  Workers: %d\n" ..
            "  Max Connections: %d\n" ..
            "  SSL: %s",
            host, port, workers, maxConnections, tostring(ssl)
        ))
        if ssl and certPath and keyPath then
            print(string.format("  Certificate: %s\n  Key: %s", certPath, keyPath))
        end
    end
}

createServer()
print()
createServer{port = 3000, workers = 8}
print()
createServer{
    host = "api.example.com",
    port = 443,
    workers = 16,
    maxConnections = 5000,
    ssl = true,
    certPath = "/etc/ssl/cert.pem",
    keyPath = "/etc/ssl/key.pem"
}

print("\n" .. string.rep("=", 70))
print("Example completed successfully!")
print(string.rep("=", 70))
