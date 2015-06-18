local luagi = require( "luagi" )
local asciify = require("dottodo_asciify")
local FILENAME = ".todo"

local function find_and_open()
   local path = nil
   local file = nil

   repeat
      if path then
         path =  "../"..path
      else
         path = "./"
      end

      file, err = io.open( path..FILENAME )

      print( path,  err )
   until file

   local repo, err = luagi.open( path )
   if not repo then return nil, err end

   if repo:is_bare() or repo:is_head_detached() then
      return nil, "repo is unusable, set it up"
   end

   return file, repo
end

local function append( tag, todo )
end

local function delete( regexp )
end

local function print_todos()
   local file, err = find_and_open()
   if file then
      print( file:read("*a"))
   elseif err then
      print( err )
   else
      print( "you're done, there is nothing left to do" )
   end
end

return {
   append = append,
   delete = delete,
   print = print_todos,
}
