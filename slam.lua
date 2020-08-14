-- Music Path in get_files("MUSIC PATH HERE")
local songPath = "C:\\Users\\Username\\Documents\\wavmusic";

local songTable = filesystem.get_files(songPath, ".wav");
local guiEnabled = false;
local cachedTime = globalvars.realtime;
local mousePos;
local mouseDown = false;
local mouseDownPos = vector2d.new(0, 0);
local guiPos = vector2d.new(0, 0);
local guiSize = vector2d.new(550, 350);
local colors = { color.new(20, 20, 20, 255), color.new(30, 30, 30, 255), color.new(90, 90, 90, 255), color.new(255, 255, 255, 255), color.new(45, 45, 45, 255), color.new(38, 38, 38, 255), color.new(37, 217, 61, 255) };
local fonts;
local initialRun = true;
local isDragging = { false, 0, 0 };
local scrSize = engine.screen_size();
local song;
local skippedSongs = 0;
local maxVisible = 0;

local function songStepper(increase)
    if (increase) then
        if (skippedSongs + 1 <= #songTable - maxVisible) then
            skippedSongs = skippedSongs + 1;
        end
    else
        if (skippedSongs ~= 0) then
            skippedSongs = skippedSongs - 1;
        end
    end
end

local function splitPath(str, index)
    if (str ~= nil) then
        local path, file, extension = string.match(str, "(.-)([^\\]-([^\\%.]+))$")
        local pathArray = { path, file, extension };
        return pathArray[index];
    end
end

local function drawButton(x, y, font, text)
    if (text ~= nil and font ~= nil) then
        local textSize = renderer.get_text_size(text, font);
        local w, h = textSize.x + 14, textSize.y + 12;

        renderer.rect(x - (w / 2), y - (h / 2), w, h, colors[2]);
        renderer.filled_rect((x - (w / 2)) + 1, (y - (h / 2)) + 1, w - 2, h - 2, colors[6]);
        renderer.rect((x - (w / 2)) + 3, (y - (h / 2)) + 3, w - 6, h - 6, colors[2]);
        renderer.filled_rect((x - (w / 2)) + 4, (y - (h / 2)) + 4, w - 8, h - 8, colors[1]);

        if (mouseDown and mouseDownPos.x >= (x - (w / 2)) and mouseDownPos.x <= (x - (w / 2))  + w and mouseDownPos.y >= (y - (h / 2)) and mouseDownPos.y <= (y - (h / 2)) + h) then
            renderer.filled_rect((x - (w / 2)) + 4, (y - (h / 2)) + 4, w - 8, h - 8, colors[2]);

            if (globalvars.realtime - cachedTime >= 0.15) then
                renderer.text(x - (w / 2) + 7, y - (h / 2) + 6, text, colors[4], font);
                cachedTime = globalvars.realtime;
                return true;
            end
        end

        renderer.text(x - (w / 2) + 7, y - (h / 2) + 6, text, colors[4], font);
        
        return false;
    end

    return false;
end

local function handleMouse()
    mousePos = keys.get_mouse();

    if (keys.key_down(0x01)) then
        if (mouseDown == false) then
            mouseDown = not mouseDown;
            mouseDownPos = vector2d.new(mousePos.x, mousePos.y);
        end
    else
        if (mouseDown) then
            mouseDown = not mouseDown;
            isDragging[0] = false;
        end
    end

    if (keys.key_pressed(0x4D)) then
        guiEnabled = not guiEnabled;
    end

    if (guiEnabled) then
        if (isDragging[0]) then
            guiPos = vector2d.new(mousePos.x - isDragging[1], mousePos.y - isDragging[2]);
        elseif (mouseDownPos.x >= guiPos.x and mouseDownPos.x <= guiPos.x + guiSize.x and mouseDownPos.y >= guiPos.y and mouseDownPos.y <= guiPos.y + 20) then
            if (mouseDown) then
                isDragging[0] = not isDragging[0];
                isDragging[1] = mouseDownPos.x - guiPos.x;
                isDragging[2] = mouseDownPos.y - guiPos.y;
            end
        end
    end
end

local function drawSong(name, usedY)
    if (usedY + 30 <= guiSize.y) then
        local size;
        local songName = splitPath(name, 2);

        if (mousePos.x >= guiPos.x and mousePos.x <= guiPos.x + guiSize.x - 150 and mousePos.y >= guiPos.y + usedY and mousePos.y <= guiPos.y + usedY + 30) then
            if (mouseDown == false) then
                renderer.filled_rect(guiPos.x, guiPos.y + usedY, guiSize.x - 150, 30, colors[2]);
            elseif (mouseDownPos.x >= guiPos.x and mouseDownPos.x <= guiPos.x + guiSize.x - 150 and mouseDownPos.y >= guiPos.y + usedY and mouseDownPos.y <= guiPos.y + usedY + 30) then
                renderer.filled_rect(guiPos.x, guiPos.y + usedY, guiSize.x - 150, 30, colors[6]);
                audio.play_voice(name);
                audio.play_sound(name);

                song = songName;
            end
        end

        renderer.rect(guiPos.x, guiPos.y + usedY, guiSize.x - 150, 30, colors[3]);
        size = renderer.get_text_size(songName, fonts[2]);
        renderer.text(guiPos.x + 10, (guiPos.y + usedY + 15) - (size.y / 2), songName, colors[4], fonts[2]);
        return 30;
    else
        return 0;
    end
end

local function drawGUI()
    if (guiEnabled) then
        renderer.filled_rect(guiPos.x, guiPos.y, guiSize.x, guiSize.y, colors[1])
        renderer.filled_rect(guiPos.x, guiPos.y, guiSize.x, 20, colors[2])
        renderer.rect(guiPos.x, guiPos.y, guiSize.x, guiSize.y, colors[3])
        renderer.rect(guiPos.x, guiPos.y + 20, guiSize.x - 150, guiSize.y - 20, colors[3])
        renderer.rect(guiPos.x, guiPos.y, guiSize.x, 20, colors[3])

        local usedHeight = 20;
        maxVisible = math.floor((guiSize.y - 20) / 30);

        for i = 1, #songTable do
            if (i > skippedSongs) then
                usedHeight = usedHeight + drawSong(songTable[i], usedHeight);
            end
        end

        if (drawButton(guiPos.x + guiSize.x - 75, guiPos.y + 40, fonts[2], "Stop")) then
            audio.stop_playback();
            song = nil;
        end

        if (drawButton(guiPos.x + guiSize.x - 75, guiPos.y + 70, fonts[2], "Scroll Up")) then
            songStepper(false);
        end

        if (drawButton(guiPos.x + guiSize.x - 75, guiPos.y + 100, fonts[2], "Scroll Down")) then
            songStepper(true);
        end

        if (drawButton(guiPos.x + guiSize.x - 75, guiPos.y + 130, fonts[2], "Refresh")) then
            songTable = filesystem.get_files(songPath, ".wav");
        end

        if (keys.key_pressed(0x26)) then
            songStepper(false);
        elseif (keys.key_pressed(0x28)) then
            songStepper(true);
        end

        textSize = renderer.get_text_size("Skipped: " .. skippedSongs, fonts[2])
        renderer.text((guiPos.x + guiSize.x - 75) - (textSize.x / 2), guiPos.y + 160 - (textSize.y / 2), "Skipped: " .. skippedSongs, colors[4], fonts[2]);
        skipY = textSize.y;
        textSize = renderer.get_text_size("Songs: " .. #songTable, fonts[2])
        renderer.text((guiPos.x + guiSize.x - 75) - (textSize.x / 2), guiPos.y + 160 - (textSize.y / 2) + skipY, "Songs: " .. #songTable, colors[4], fonts[2]);
    elseif (song ~= nil) then
        text = "Song: " .. song;
        textSize = renderer.get_text_size(text, fonts[2])

        if (textSize.x + 10 < 150) then
            textSize = vector2d.new(150, textSize.y);
        else
            textSize = vector2d.new(textSize.x + 10, textSize.y);
        end

        renderer.filled_rect(scrSize.x / 2 - (textSize.x / 2), 20, textSize.x, 40, colors[1])
        renderer.rect(scrSize.x / 2 - (textSize.x / 2), 20, textSize.x, 40, colors[3])
        renderer.filled_rect(scrSize.x / 2 - (textSize.x / 2) - 2, 22, 1, 36, colors[7])
        renderer.text(scrSize.x / 2 - (textSize.x / 2) + 4, 40 - (textSize.y / 2), text, colors[4], fonts[2]);
    end
end

function on_render()
    if (initialRun) then
        initialRun = not initialRun;
        fonts = { renderer.create_font("Verdana", 10, false), renderer.create_font("Verdana", 12, false) }
    end

    drawGUI();
    handleMouse();
end
