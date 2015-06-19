local luagi = require( "luagi" )
local lfs = require( "lfs" )
local asciify = require("dottodo_asciify")

local FILENAME = ".todo"
local SUFFIX = "\n# "
local EOF = "\n$"

local function find_and_open( path )
   lfs.chdir( path )

   local file = nil
   local ret = {}
   local original_dir = lfs.currentdir()
   local current_dir = original_dir
   repeat
      for iter, dir_obj in lfs.dir( current_dir ) do
         if iter == FILENAME then
            file = true
            break
         end
      end

      if not file then
         if not lfs.chdir("..") then return nil, "could not change dir" end
         current_dir = lfs.currentdir()
      end
   until file

   ret.repo, err = luagi.open( "." )
   if not ret.repo then return nil, err end

   if ret.repo:is_bare() or ret.repo:is_head_detached() then
      return nil, "repo is unusable, set it up"
   end

   ret.relative_path = original_dir:gsub( current_dir, "." )
   ret.file, err = io.open( FILENAME )

   lfs.chdir( original_dir )

   return ret, err
end

local function append( tag, todo )
end

local function delete( regexp )
end

local function print_todos( path )
   local t, err = find_and_open( path )
   if t and t.file then
      local content = t.file:read("*a")
      if t.relative_path == "." then 
         print( content )
      else
         -- far too manual
         local pattern = "# "..t.relative_path..".-"

         local s, e = content:find( pattern..SUFFIX ) 
         if s then
            e = e - #SUFFIX
         else
            s, e = content:find( pattern..EOF )
         end

         if s then
            print( content:sub( s, e ) )
         else
            print( "nothing to do in this section" )
         end
      end
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
