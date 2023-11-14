--copied from my friend lammas123 that makes reading/writing json easier

function read(file)
  local f = fs.open("/"..file..".json", "r")
  local c = textutils.unserialiseJSON(f.readAll())
  f.close()
  return c
end

function save(file, d)
  local f = fs.open("/"..file..".json", "w")
  f.write(textutils.serialiseJSON(d))
  f.close()
end

return {
  read = read,
  save = save
}
