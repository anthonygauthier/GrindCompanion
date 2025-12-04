-- Test Helper Utilities
-- Provides common utilities and setup for test suite

local TestHelper = {}

-- Assertion helpers
function TestHelper.assertTableEquals(expected, actual, message)
    message = message or "Tables are not equal"
    
    if type(expected) ~= "table" or type(actual) ~= "table" then
        error(message .. ": both arguments must be tables")
    end
    
    for k, v in pairs(expected) do
        if type(v) == "table" then
            TestHelper.assertTableEquals(v, actual[k], message .. " (key: " .. tostring(k) .. ")")
        else
            if actual[k] ~= v then
                error(message .. ": expected[" .. tostring(k) .. "] = " .. tostring(v) .. 
                      ", actual[" .. tostring(k) .. "] = " .. tostring(actual[k]))
            end
        end
    end
    
    for k, v in pairs(actual) do
        if expected[k] == nil then
            error(message .. ": unexpected key in actual: " .. tostring(k))
        end
    end
end

-- Number comparison with tolerance
function TestHelper.assertAlmostEquals(expected, actual, tolerance, message)
    tolerance = tolerance or 0.01
    message = message or "Numbers are not almost equal"
    
    if math.abs(expected - actual) > tolerance then
        error(message .. ": expected " .. tostring(expected) .. 
              ", actual " .. tostring(actual) .. 
              " (tolerance: " .. tostring(tolerance) .. ")")
    end
end

-- Check if value is in range
function TestHelper.assertInRange(value, min, max, message)
    message = message or "Value is not in range"
    
    if value < min or value > max then
        error(message .. ": " .. tostring(value) .. 
              " not in range [" .. tostring(min) .. ", " .. tostring(max) .. "]")
    end
end

-- String contains check
function TestHelper.assertContains(haystack, needle, message)
    message = message or "String does not contain expected substring"
    
    if type(haystack) ~= "string" then
        error(message .. ": haystack must be a string")
    end
    
    if not string.find(haystack, needle, 1, true) then
        error(message .. ": '" .. haystack .. "' does not contain '" .. needle .. "'")
    end
end

-- Check if table contains value
function TestHelper.assertTableContains(table, value, message)
    message = message or "Table does not contain expected value"
    
    for _, v in pairs(table) do
        if v == value then
            return
        end
    end
    
    error(message .. ": " .. tostring(value) .. " not found in table")
end

-- Deep copy utility for test data
function TestHelper.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[TestHelper.deepCopy(orig_key)] = TestHelper.deepCopy(orig_value)
        end
        setmetatable(copy, TestHelper.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Generate random test data
function TestHelper.randomInt(min, max)
    return math.random(min, max)
end

function TestHelper.randomFloat(min, max)
    return min + (math.random() * (max - min))
end

function TestHelper.randomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = {}
    for i = 1, length do
        local idx = math.random(1, #chars)
        result[i] = chars:sub(idx, idx)
    end
    return table.concat(result)
end

-- Setup/teardown helpers
function TestHelper.setup()
    -- Initialize random seed for consistent test runs
    math.randomseed(12345)
end

function TestHelper.teardown()
    -- Cleanup after tests
end

return TestHelper
