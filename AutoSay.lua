--[[
    Author: NaerQAQ / Wink
    Version: 1.1.2
    Script Name: AutoSay

    Description:
        Usage:

        You need to place the message to be sent in the spam folder under the configuration file folder and name it arbitrarily.
        You can click the Open Settings Folder button in the Settings module's Advanced section to open the configuration file folder.

    Github: https://github.com/NaerQAQ/AutoSay
]]

-- MISC
local msc_ref = gui.Reference("MISC", "Part 1");

-- Checkbox for enabling the script
local as_is_enabled = gui.Checkbox(
    msc_ref, "as_is_enabled", "Enable", false
);

-- Checkbox for team messages
local as_is_team_msg = gui.Checkbox(
    msc_ref, "as_is_team_msg", "Team message", false
);

-- Checkbox for random selection
local as_is_random_selection = gui.Checkbox(
    msc_ref, "as_is_random_selection", "Random selection message", false
);

-- Checkbox for trim message spaces before and after
local as_is_trim_message_spaces = gui.Checkbox(
    msc_ref, "as_is_trim_message_spaces", "Trim message spaces before and after", true
);

-- Editbox for file name
local as_file_name = gui.Editbox(
    msc_ref, "as_file_name", "File name"
);

-- Slider for the interval between sending messages in game ticks
local as_wait_ticks_slider = gui.Slider(
    msc_ref,
    "as_wait_ticks_slider",
    "Wait ticks", 50.0, 0.0, 200.0, 0.5
);

-- Array to store each line of the file
local as_msg_lines = {}

-- Current line to be output
local as_current_line = 1

-- Last tick when a message was sent
local as_last_spam_tick = 0

---
-- Loads lines from a specified file into an array.
--
-- This function reads the content of the file specified by the file name,
-- and stores each line in an array. The array is cleared before each load, and the function exits if the file name is empty.
--
-- @param linesArray table The array to store the lines from the file.
-- @param fileName string The name of the file to load lines from.
local function LoadLinesFromFile(lines_array, file_name)
    -- Reset the array
    lines_array = {}

    -- Exit if the file name is empty
    if file_name == "" then
        return lines_array
    end

    -- Construct the file path
    local final_file_name = Trim("spam/" .. file_name)

    -- Read file content
    local file_content = file.Read(final_file_name) or ""

    -- Split the file content into lines and store them in the array
    for line in string.gmatch(file_content, "[^\r\n]+") do
        table.insert(lines_array, line)
    end
    
    return lines_array
end

---
-- Called on each frame draw to perform spam message output based on predefined settings.
--
-- This function retrieves user-configurable values, loads lines from a file, and outputs messages at specified intervals.
-- The spam behavior is controlled by user settings including enabling/disabling, file name, wait time, and team messaging.
--
local function OnDrawAutoSay()
    local is_enable_value = as_is_enabled:GetValue()
    local file_name_value = as_file_name:GetValue()

    -- Exit the function if not enabled or file name is empty
    if not is_enable_value or file_name_value == "" then
        return
    end

    -- Load lines from the file into the array
    as_msg_lines = LoadLinesFromFile(as_msg_lines, file_name_value)

    print(#as_msg_lines)

    -- Exit the function if the array is empty
    if #as_msg_lines == 0 then
        return
    end

    -- If the current line to be output is greater than the array length
    if as_current_line > #as_msg_lines then
        -- Reset the current line to be output and the last output time
        as_current_line = 1
        as_last_spam_tick = 0
    end

    -- If the current line to be output is less than or equal to the array length and enough time has passed since the last output
    if globals.TickCount() - as_last_spam_tick >= as_wait_ticks_slider:GetValue() then
        -- Retrieve information through an array
        local message = as_is_random_selection:GetValue()
            and as_msg_lines[math.random(1, #as_msg_lines)] or as_msg_lines[as_current_line]

        -- If the message starts with "[team]", consider it a team message; otherwise, retrieve the configuration
        local is_team = message:lower():find("^%[team%]") or as_is_team_msg:GetValue()

        -- Handle team messages separately for those starting with [team]
        if is_team then
            message = message.gsub(message, "^%[team%]", "")
        end

        -- Trim message if needed
        if as_is_trim_message_spaces:GetValue() then
            message = Trim(message)
        end

        -- Check if it's a team message
        if is_team then
            client.ChatTeamSay(message)
        else
            client.ChatSay(message)
        end

        -- Update the last output time and the current line to be output, ensuring looping
        as_last_spam_tick = globals.TickCount()
        as_current_line = (as_current_line % #as_msg_lines) + 1
    end
end

---
-- Removes leading and trailing whitespace from a given string.
--
-- @param string The string to be trimmed.
-- @return The string without leading and trailing whitespace.
--
function Trim(string)
    return (string:gsub("^%s*(.-)%s*$", "%1"))
end

-- Register the callback
callbacks.Register("Draw", "AutoSay", OnDrawAutoSay);
