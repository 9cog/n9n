#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Torch Libraries Integration Demo
--
-- This example demonstrates how to use all three torch libraries together:
-- - torch.sys: System utilities and timing
-- - torch.class: Object-oriented programming
-- - torch.argcheck: Argument validation
--------------------------------------------------------------------------------

local sys = require('torch.sys')
local class = require('torch.class')
local argcheck = require('torch.argcheck')

local c = sys.COLORS

print(c.cyan .. string.rep("=", 70) .. c.none)
print(c.cyan .. "Torch Libraries Integration Demo" .. c.none)
print(c.cyan .. "Combining sys, class, and argcheck" .. c.none)
print(c.cyan .. string.rep("=", 70) .. c.none)

--------------------------------------------------------------------------------
-- Example: Task Management System
--------------------------------------------------------------------------------

print("\n" .. c.yellow .. "Building a Task Management System" .. c.none)
print(string.rep("-", 70))

-- Task class using torch.class
local Task = class('Task')

function Task:__init(title, priority, dueDate)
    self.title = title
    self.priority = priority or "medium"
    self.dueDate = dueDate
    self.createdAt = os.date("%Y-%m-%d %H:%M:%S")
    self.completed = false
    self.duration = 0
end

function Task:start()
    if not self.completed then
        self.startTime = sys.clock()
        print(c.green .. "Started: " .. c.none .. self.title)
    end
end

function Task:complete()
    if not self.completed and self.startTime then
        self.duration = sys.clock() - self.startTime
        self.completed = true
        self.completedAt = os.date("%Y-%m-%d %H:%M:%S")
        print(c.green .. "Completed: " .. c.none .. self.title .. 
              string.format(" (%.2fs)", self.duration))
    end
end

function Task:getInfo()
    local status = self.completed and c.green .. "✓" .. c.none or c.red .. "✗" .. c.none
    local priority_color = self.priority == "high" and c.red or 
                           self.priority == "medium" and c.yellow or c.blue
    return string.format("%s [%s%s%s] %s", status, priority_color, 
                        string.upper(self.priority), c.none, self.title)
end

-- TaskManager class
local TaskManager = class('TaskManager', 'Task')

function TaskManager:__init(name)
    self.name = name
    self.tasks = {}
    self.stats = {
        total = 0,
        completed = 0,
        totalTime = 0
    }
end

-- Add task with basic validation
function TaskManager:addTask(title, priority, dueDate)
    priority = priority or "medium"
    
    -- Validate priority
    if priority ~= "low" and priority ~= "medium" and priority ~= "high" then
        error("Invalid priority: " .. priority)
    end
    
    -- Validate title
    if not title or #title == 0 then
        error("Title cannot be empty")
    end
    
    local task = Task(title, priority, dueDate)
    table.insert(self.tasks, task)
    self.stats.total = self.stats.total + 1
    print(c.cyan .. "Added task: " .. c.none .. title .. 
          " [" .. priority .. "]")
    return task
end

function TaskManager:executeTask(index)
    local task = self.tasks[index]
    if task and not task.completed then
        task:start()
        -- Simulate work
        sys.sleep(math.random(1, 3) * 0.1)
        task:complete()
        self.stats.completed = self.stats.completed + 1
        self.stats.totalTime = self.stats.totalTime + task.duration
    end
end

function TaskManager:listTasks()
    print("\n" .. c.cyan .. "Tasks in " .. self.name .. ":" .. c.none)
    for i, task in ipairs(self.tasks) do
        print(string.format("  %d. %s", i, task:getInfo()))
    end
end

function TaskManager:getStats()
    local completion_rate = self.stats.total > 0 and 
                           (self.stats.completed / self.stats.total * 100) or 0
    return string.format(
        "\n%sStatistics:%s\n" ..
        "  Total tasks: %d\n" ..
        "  Completed: %d\n" ..
        "  Completion rate: %.1f%%\n" ..
        "  Total time: %.2fs\n" ..
        "  Avg time per task: %.2fs",
        c.cyan, c.none,
        self.stats.total,
        self.stats.completed,
        completion_rate,
        self.stats.totalTime,
        self.stats.completed > 0 and (self.stats.totalTime / self.stats.completed) or 0
    )
end

--------------------------------------------------------------------------------
-- Demo Execution
--------------------------------------------------------------------------------

print("\n" .. c.yellow .. "Creating Task Manager" .. c.none)
print(string.rep("-", 70))

local manager = TaskManager("Project Tasks")

-- Add tasks with validation
print("\n" .. c.yellow .. "Adding Tasks" .. c.none)
print(string.rep("-", 70))

manager:addTask("Write documentation", "high")
manager:addTask("Fix bug in module", "high")
manager:addTask("Update dependencies", "medium")
manager:addTask("Refactor code", "low")
manager:addTask("Add unit tests", "medium")

-- List initial tasks
manager:listTasks()

-- Execute tasks with timing
print("\n" .. c.yellow .. "Executing Tasks" .. c.none)
print(string.rep("-", 70))

sys.tic()

for i = 1, #manager.tasks do
    manager:executeTask(i)
end

local total_time = sys.toc()
print(string.format("\n" .. c.green .. "All tasks completed in %.2fs" .. c.none, total_time))

-- Show updated task list
manager:listTasks()

-- Display statistics
print(manager:getStats())

--------------------------------------------------------------------------------
-- System Information
--------------------------------------------------------------------------------

print("\n" .. c.yellow .. "System Information" .. c.none)
print(string.rep("-", 70))

print("OS: " .. sys.uname())
print("Script: " .. (sys.fpath() or "unknown"))

-- Execute system command for additional info
if sys.OS == "linux" or sys.OS == "macos" then
    local hostname = sys.execute('hostname')
    print("Hostname: " .. hostname)
end

--------------------------------------------------------------------------------
-- Type Checking Demo
--------------------------------------------------------------------------------

print("\n" .. c.yellow .. "Type Checking" .. c.none)
print(string.rep("-", 70))

local task1 = manager.tasks[1]
print("task1 type: " .. class.type(task1))
print("task1 is Task: " .. tostring(class.istype(task1, 'Task')))
print("manager type: " .. class.type(manager))
print("manager is TaskManager: " .. tostring(class.istype(manager, 'TaskManager')))
print("manager is Task: " .. tostring(class.istype(manager, 'Task')))

print("\n" .. c.cyan .. string.rep("=", 70) .. c.none)
print(c.green .. "Demo completed successfully!" .. c.none)
print(c.cyan .. string.rep("=", 70) .. c.none)
