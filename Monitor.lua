-- Set package paths explicitly (optional if environment variables are set)
package.path = package.path .. ";C:\\Users\\tembo\\AppData\\Roaming\\luarocks\\share\\lua\\5.4\\?.lua;C:\\Users\\tembo\\AppData\\Roaming\\luarocks\\share\\lua\\5.4\\?\\init.lua"
package.cpath = package.cpath .. ";C:\\Users\\tembo\\AppData\\Roaming\\luarocks\\lib\\lua\\5.4\\?.dll"

local lfs = require("lfs")

-- Define download and move folder paths, to be set via the Python interface
local downloadFolder = arg[1] or "C:\\Users\\tembo\\Desktop\\New folder (2)\\anime land"
local moveFolder = downloadFolder

-- Ensure download and move folders exist, create them if they don't
local function ensureFoldersExist()
    if not lfs.attributes(downloadFolder, "mode") then
        os.execute('mkdir "' .. downloadFolder .. '"')
    end
    if not lfs.attributes(moveFolder, "mode") then
        os.execute('mkdir "' .. moveFolder .. '"')
    end
end

-- Call the function to ensure folders exist
ensureFoldersExist()

-- Define target folders for various file extensions
local targetFolders = {
    [".pdf"] = downloadFolder .. "\\Documents\\PDFs",
    [".txt"] = downloadFolder .. "\\Documents\\TextDoc",
    [".jpg"] = downloadFolder .. "\\Pictures",
    [".docx"] = downloadFolder .. "\\Documents\\WordDocs",
    [".png"] = downloadFolder .. "\\Pictures",
    [".gif"] = downloadFolder .. "\\Pictures",
    [".mp3"] = downloadFolder .. "\\Music",
    [".mp4"] = downloadFolder .. "\\Videos",
    [".pptx"] = downloadFolder .. "\\Documents\\Powerpoint",
    
    -- Add more entries for other extensions and target folders
}

-- Function for moving a file to its corresponding folder based on extension
local function moveFile(filePath)
    local fileName = string.match(filePath, "[^\\]+$")
    local fileExt = string.match(fileName, "%..+$")
    local targetFolder = targetFolders[fileExt]
    if targetFolder then
        -- Check if target folder exists, create it if not
        if not lfs.attributes(targetFolder, "mode") then
            os.execute('mkdir "' .. targetFolder .. '"')
        end
        -- Attempt to move the file
        local targetPath = targetFolder .. "\\" .. fileName
        local success, err = os.rename(filePath, targetPath)
        if success then
            print("Moved " .. fileName .. " to " .. targetFolder)
        else
            -- Handle error if move fails (e.g., permission issue)
            print("Error moving " .. fileName .. ": " .. err)
        end
    end
end

-- Function to scan the download folder for new files
local function scanFolder()
    for file in lfs.dir(downloadFolder) do
        if file ~= "." and file ~= ".." then
            local filePath = downloadFolder .. "\\" .. file
            local attr = lfs.attributes(filePath)
            if attr.mode == "file" then
                moveFile(filePath)
            end
        end
    end
end

-- Initial scan
scanFolder()

-- Polling loop to check for new files every 1 second
while true do
    scanFolder()
    os.execute("timeout /t 1 /nobreak >nul")
end

print("Download folder organization completed!")
