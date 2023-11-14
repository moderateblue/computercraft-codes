--automates a tree farm (with refueling)

package.path = "../libs/?.lua;" .. package.path

local db = require("DB")
local refuel = require("refuel")
local data = db.read("treefarm/data")

-- turn left
-- east = +x
-- north = -z
-- west = -x
-- south = +z

function save_dir(dir)
  data.direction = dir
  save("treefarm/data", data)
end

function go_home()
  local cx, cy, cz = gps.locate()

  local x = data.home[1]
  local y = data.home[2]
  local z = data.home[3]
  local dir = data.direction

  if cx < x then
    turtle.forward()
  elseif cx ~= x or cy ~= y or cz ~= z or dir ~= "east" then
    if cy > 64 then
      for i = 0, cy - 64 - 1, 1 do
        turtle.digDown()
        turtle.down()
      end
    elseif cy < 64 then
      turtle.digUp()
      turtle.up()
    end
    
    if cz == z - 1 then
      change_dir("west")
    elseif cz == z then
      change_dir("north")
      turtle.dig()
      turtle.forward()
      change_dir("west")
    elseif cz == z - 2 then
      change_dir("north")
      turtle.dig()
      turtle.forward()
      turtle.dig()
      turtle.forward()
      change_dir("west")
    end

    for i = 0, cx - x - 1, 1 do
      turtle.dig()
      turtle.forward()
    end

    turtle.turnLeft()
    save_dir("south")
    turtle.forward()
    turtle.turnLeft()
    save_dir("east")
    turtle.down()
  end

  data.athome = true
  save("treefarm/data", data)
end

function change_dir(direct)
  local dir = data.direction
  local dir_int = get_dir_int(dir)
  local direct_int = get_dir_int(direct)

  if dir == direct then
    return
  else
    local diff = math.abs(dir_int - direct_int)
    if diff == 2 then
      turtle.turnLeft()
      save_dir(direct)
      turtle.turnLeft()
      save_dir(direct)
    elseif dir_int - direct_int < 0 then
      if diff < 2 then
        turtle.turnLeft()
        save_dir(direct)
      else
        turtle.turnRight()
        save_dir(direct)
      end
    else 
      if diff < 2 then
        turtle.turnRight()
        save_dir(direct)
      else
        turtle.turnLeft()
        save_dir(direct)
      end
    end
  end
end

function get_dir_int(dir_string)
  if dir_string == "east" then
    return 1
  elseif dir_string == "north" then
    return 2
  elseif dir_string == "west" then
    return 3
  elseif dir_string == "south" then
    return 4
  end
end

function test_up()
  local hasBlock, data = turtle.inspectUp()
  if(hasBlock and data["name"] == "minecraft:spruce_log") then
      return true
  else
      return false
  end
end

function cut_tree()
  local y = 0

  turtle.dig()
  turtle.forward()

  while test_up() do
    turtle.dig()
    turtle.digUp()
    turtle.up()
    y = y + 1
  end

  turtle.turnRight()
  save_dir("south")
  turtle.dig()
  turtle.forward()
  turtle.turnLeft()
  save_dir("east")

  for i = y, 1, -1 do
    turtle.digDown()
    turtle.down()
    turtle.dig()
  end

  turtle.turnLeft()
  save_dir("north")
  turtle.forward()
  turtle.turnRight()
  save_dir("east")
  turtle.forward()
end

function drop_fuel()
  if data.athome == true then
    for i = 1, 16, 1 do
      turtle.select(i)
      local table = turtle.getItemDetail(i, false)
      if table ~= nil and table["name"] == "minecraft:spruce_log" then
        turtle.dropDown()
        break
      end
    end
  else 
    go_home()
    drop_fuel()
  end
end

function pick_up_fuel()
  if data.athome == true then
    turtle.turnLeft()
    data.athome = false
    save("treefarm/data", data)
    save_dir("north")
    turtle.forward()
    for i = 1, 5, 1 do
      turtle.suckDown()
    end
    refuel.refuel()
    turtle.back()
    turtle.turnRight()
    data.athome = true
    save("treefarm/data", data)
    save_dir("east")
  else
    go_home()
    pick_up_fuel()
  end
end

function deposit_misc()
  if data.athome == true then
    turtle.back()
    data.athome = false
    save("treefarm/data", data)
    for i = 1, 16, 1 do
      turtle.select(i)
      local table = turtle.getItemDetail(i, false)
      if table ~= nil and table["name"] ~= "minecraft:spruce_log" then
        turtle.dropDown()
      end
    end
    turtle.forward()
    data.athome = true
    save("treefarm/data", data)
  else
    go_home()
    deposit_misc()
  end
end

function deposit_logs()
  if data.athome == true then
    turtle.turnRight()
    data.athome = false
    save("treefarm/data", data)
    save_dir("south")
    turtle.forward()
    for i = 1, 16, 1 do
      turtle.select(i)
      local table = turtle.getItemDetail(i, false)
      if table ~= nil and table["name"] == "minecraft:spruce_log" then
        turtle.dropDown()
      end
    end
    turtle.back()
    turtle.turnLeft()
    data.athome = true
    save("treefarm/data", data)
    save_dir("east")
  else
    go_home()
    deposit_logs()
  end
end

-- functions

-- save_dir(dir)
-- go_home()
-- change_dir(direct)
-- get_dir_int(dir_string)
-- test_up()
-- cut_tree()
-- drop_fuel()
-- pick_up_fuel()
-- deposit_misc()
-- deposit_logs()

go_home()

while true do
  term.clear()
  term.setCursorPos(1,1)
  print("are trees ready for choppin? (y/n) ")
  local input = io.read()
  if input == "y" then
    data.athome = false
    save("treefarm/data", data)
    for i = 1, 4, 1 do
      for i = 1, 4, 1 do
        turtle.dig()
        turtle.forward()
      end

      cut_tree()
    end

    go_home()

    deposit_misc()
    drop_fuel()
    deposit_logs()
    pick_up_fuel()
  else
    term.clear()
    term.setCursorPos(1,1)
  end
end
