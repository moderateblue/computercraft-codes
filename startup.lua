--runs when computer is turned on i think i forgor

package.path = "./libs/?.lua;" .. package.path

local db = require("DB")
local refuel = require("refuel")
local data = db.read("treefarm/data")

refuel.refuel()

shell.run("treefarm/farmtree.lua")
