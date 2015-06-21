local luagi = require( "luagi" )
local lfs = require( "lfs" )
local asciify = require("dottodo_asciify")

local FILENAME = ".todo"
local SUFFIX = "\n# "
local EOF = "\n$"

local function get_section_position( content, path )
   -- far too manual
   local pattern = "# "..path..".-"
   local s, e = content:find( pattern..SUFFIX ) 
   if s then
      e = e - #SUFFIX
   else
      s, e = content:find( pattern..EOF )
   end
   return s, e
end

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
   ret.content = ret.file:read("*a")

   ret.section_start, ret.section_end = get_section_position( ret.content, ret.relative_path ) 

   lfs.chdir( original_dir )

   return ret, err
end

local function append( tag, todo )
   local t, err = find_and_open( "." )
   if t and t.content then
            
   else
      print( err )
   end
end

local function delete( regexp )
end

local function print_todos( path )
   local t, err = find_and_open( path )
   if t and t.content then
      if t.relative_path == "." then 
         print( t.content )
      else
         if t.section_start then
            print( t.content:sub( t.section_start, t.section_end ) )
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
