---@diagnostic disable: undefined-global

--[[
    Author: NaerQAQ / Wink
    Version: 1.0
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
local is_enable = gui.Checkbox(
    msc_ref, "is_enable", "Enable", false
);

-- Checkbox for team messages
local is_team_msg = gui.Checkbox(
    msc_ref, "is_team_msg", "Is team message", false
);

-- Editbox for file name
local file_name = gui.Editbox(
    msc_ref, "file_name", "File name"
);

-- Slider for the interval between sending messages in game ticks
local wait_ticks_slider = gui.Slider(
    msc_ref,
    "wait_ticks_slider",
    "Wait ticks", 50.0, 0.0, 200.0, 0.5
);

-- Array to store each line of the file
local lines = {}

-- Current line to be output
local current_line = 1

-- Last tick when a message was sent
local last_spam_tick = 0

-- Last read content of the file
local last_file_content = ""

--- Load lines from the file into the array
local function LoadLinesFromFile()
    local file_name_value = file_name:GetValue()

    -- Construct the file path
    local final_file_name = "spam/" .. file_name_value

    -- Exit if the file name is empty
    if file_name_value == "" then
        return
    end

    -- Read file content
    local file_content = file.Read(final_file_name, "r") or ""

    -- Exit if the file content is the same as the last time
    if file_content == last_file_content then
        return
    end

    -- Reset the array
    lines = {}

    -- Split the file content into lines and store them in the array
    for line in string.gmatch(file_content, "[^\r\n]+") do
        table.insert(lines, line)
    end

    -- Update the last file content
    last_file_content = file_content
end

--- Called on each frame draw
local function OnDraw()
    local is_enable_value = is_enable:GetValue()
    local file_name_value = file_name:GetValue()

    -- Exit the function if not enabled or file name is empty
    if not is_enable_value or file_name_value == "" then
        return
    end

    -- Load lines from the file into the array
    LoadLinesFromFile()

    -- Exit the function if the array is empty
    if #lines == 0 then
        return
    end

    -- If the current line to be output is less than or equal to the array length and enough time has passed since the last output
    if current_line <= #lines and
        globals.TickCount() - last_spam_tick >= wait_ticks_slider:GetValue() then
        -- Output the message
        local message = lines[current_line]
        local is_team_msg_value = is_team_msg:GetValue()

        -- Check if it's a team message
        if is_team_msg_value then
            client.ChatTeamSay(message)
        else
            client.ChatSay(message)
        end

        -- Update the last output time and the current line to be output, ensuring looping
        last_spam_tick = globals.TickCount()
        current_line = (current_line % #lines) + 1
    -- If the current line to be output is greater than the array length
    elseif current_line > #lines then
        -- Reset the current line to be output and the last output time
        current_line = 1
        last_spam_tick = 0
    end
end

-- Register the callback
callbacks.Register("Draw", "AutoSay", OnDraw);
