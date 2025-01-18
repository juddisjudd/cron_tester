local testExpressions = {
    -- Time-based expressions (unchanged)
    ['*/15 * * * *'] = 'Every 15 minutes',
    ['*/7 * * * *'] = 'Every 7 minutes',
    ['0 */2 * * *'] = 'Every 2 hours',
    ['0 0 * * *'] = 'Every day at midnight',

    -- Weekday expressions (updated to be consistent)
    ['0 12 * * 1'] = 'Every Sunday at noon',        -- Sunday as 1
    ['0 18 * * 5'] = 'Every Friday at 6 PM',        -- Friday as 5
    ['30 8 * * 1'] = 'Every Sunday at 8:30 AM',     -- Changed from 0 to 1
    ['0 0 * * 6,1'] = 'Every Saturday and Sunday at midnight', -- Changed from 6,0 to 6,1
    ['*/5 9-17 * * 2-6'] = 'Every 5 minutes, 9 AM to 5 PM, Monday to Friday', -- Changed to 2-6 for Mon-Fri

    -- Month and day expressions
    ['0 0 1 * *'] = 'First day of every month at midnight',
    ['0 0 L * *'] = 'Last day of every month at midnight',
    ['0 0 1,15 * *'] = '1st and 15th of every month at midnight',
    ['0 0 29 2 *'] = 'Midnight on February 29th (leap year check)',
    
    -- Time ranges
    ['*/10 0-6 * * *'] = 'Every 10 minutes between midnight and 6 AM',
    ['0 9-17/2 * * *'] = 'Every 2 hours between 9 AM and 5 PM',
    
    -- Month ranges and lists
    ['0 12 1-10 6 *'] = '12 PM, first 10 days of June',
    ['0 0 1 */2 *'] = 'First day of every other month', -- Simplified from 1-11/2
    ['15 10 * 1,7 *'] = '10:15 AM in January and July',

    -- Named weekdays and months (new tests to verify name support)
    ['0 12 * * mon'] = 'Every Monday at noon',
    ['0 15 * jan,dec *'] = '3 PM in January and December',
    ['45 9 * * mon-fri'] = '9:45 AM Monday through Friday'
}

local invalidExpressions = {
    -- Time-based invalid expressions
    '0 25 * * *',          -- Invalid hour (25 is out of range)
    '0 24 * * *',          -- Invalid hour (24 is out of range)
    '60 * * * *',          -- Invalid minute (60 is out of range)
    '*/61 * * * *',        -- Invalid minute step (61 is out of range)
    
    -- Day/Month invalid expressions
    '0 0 32 * *',          -- Invalid day (32 is out of range)
    '0 0 0 * *',           -- Invalid day (0 is out of range)
    '0 0 * 13 *',          -- Invalid month (13 is out of range)
    '0 0 * 0 *',           -- Invalid month (0 is out of range)
    
    -- Weekday invalid expressions
    '0 0 * * 8',           -- Invalid weekday (8 is out of range)
    '0 0 * * 1-8',         -- Invalid weekday range
    '*/5 9-17 * * 1-8',    -- Invalid weekday range
    
    -- Invalid format expressions (new)
    '0 0 * * mon-xxx',     -- Invalid weekday name
    '0 0 * invalid *',     -- Invalid month name
    '*/0 * * * *',         -- Invalid step value
    '1-5/0 * * * *'        -- Invalid range step
}

-- Command to test all predefined expressions
RegisterCommand('testallcron', function()
    print('^2=== Testing All Cron Expressions ===^7\n')

    local supported, unsupported = 0, 0
    local invalidCount = 0

    -- Test valid expressions
    for expression, description in pairs(testExpressions) do
        print('^3Testing: ^7' .. expression)
        print('^3Description: ^7' .. description)
        
        local success, error = pcall(function()
            lib.cron.new(expression, function(task)
                local nextRun = task:getAbsoluteNextTime()
                print('^2Next run time: ^7' .. os.date('%c', nextRun))
                task:stop()
            end, { debug = true })
        end)

        if success then
            supported = supported + 1
            print('^2Expression is supported!^7\n')
        else
            unsupported = unsupported + 1
            print('^1Error: ^7' .. tostring(error) .. '\n')
        end
    end

    -- Test invalid expressions
    print('^2=== Testing Invalid Cron Expressions ===^7\n')

    for _, expression in ipairs(invalidExpressions) do
        print('^3Testing Invalid Expression: ^7' .. expression)

        local success, error = pcall(function()
            lib.cron.new(expression, function(task)
                -- This should not execute
                error('Invalid expression was accepted', 2)
            end, { debug = true })
        end)

        if success then
            print('^1Error: Invalid expression was unexpectedly supported!^7\n')
        else
            invalidCount = invalidCount + 1
            print('^2Invalid expression was correctly rejected.^7\n')
        end
    end

    -- Summary
    print('^2=== Testing Complete ===^7')
    print('^2Supported valid expressions: ^7' .. supported)
    print('^1Unsupported valid expressions: ^7' .. unsupported)
    print('^2Correctly rejected invalid expressions: ^7' .. invalidCount)
end, true)