local clang = require 'clang'
local index = clang.Index()
local unit = index:parse('x.c', {'-Wall'}, {['x.c']='int f;int main() {int v;return 0;}'})
local cursor = unit.cursor
print('Root cursor:', cursor.kind.string, cursor.spelling)
cursor:visit(function(cursor)
    print('Visiting:', cursor.kind.string, cursor.spelling)
    return cursor.visit_recurse -- or clang.Cursor.visit_recurse
end)
for i, v in ipairs(cursor:get_children()) do
    print('Child:', v.kind.string, v.spelling)
end