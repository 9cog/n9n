-- Simple test for torch libraries
usage = "test_torch"

function init(argv)
    sys = import("sys")
    
    sys.print("\n=== Testing Torch Libraries ===\n\n")
    
    -- Test torch.sys
    sys.print("Test 1: Loading torch.sys\n")
    local ok, torch_sys = pcall(require, 'torch.sys')
    if ok then
        sys.print("  ✓ torch.sys loaded successfully\n")
        sys.print("  OS: %s\n", torch_sys.OS)
        sys.print("  uname(): %s\n", torch_sys.uname())
        
        -- Test timing
        local t1 = torch_sys.clock()
        sys.sleep(100)  -- sleep 100ms
        local t2 = torch_sys.clock()
        sys.print("  clock() works: %.3f seconds elapsed\n", t2 - t1)
        
        -- Test split
        local parts = torch_sys.split("a,b,c", ",")
        sys.print("  split() works: %d parts\n", #parts)
    else
        sys.print("  ✗ Failed to load torch.sys: %s\n", torch_sys)
    end
    
    -- Test torch.class
    sys.print("\nTest 2: Loading torch.class\n")
    local ok2, torch_class = pcall(require, 'torch.class')
    if ok2 then
        sys.print("  ✓ torch.class loaded successfully\n")
        
        -- Create a simple class
        local Animal = torch_class('Animal')
        function Animal:__init(name)
            self.name = name
        end
        
        local dog = Animal("Buddy")
        sys.print("  Class creation works: %s\n", dog.name)
        sys.print("  type(dog): %s\n", torch_class.type(dog))
    else
        sys.print("  ✗ Failed to load torch.class: %s\n", torch_class)
    end
    
    -- Test torch.argcheck
    sys.print("\nTest 3: Loading torch.argcheck\n")
    local ok3, torch_argcheck = pcall(require, 'torch.argcheck')
    if ok3 then
        sys.print("  ✓ torch.argcheck loaded successfully\n")
        
        -- Create a simple function with argcheck
        local check = torch_argcheck{
            {name="x", type="number"},
            {name="y", type="number", default=0}
        }
        
        local function test_func(...)
            local x, y = check(...)
            return x + y
        end
        
        local result = test_func(5, 3)
        sys.print("  Argcheck works: 5 + 3 = %d\n", result)
    else
        sys.print("  ✗ Failed to load torch.argcheck: %s\n", torch_argcheck)
    end
    
    sys.print("\n=== All tests completed ===\n")
end
