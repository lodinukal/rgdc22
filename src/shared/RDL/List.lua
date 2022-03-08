------------------------------------------------------------------------
-- List.lua
-- @version v1.0.0
-- @author Centau_ri
------------------------------------------------------------------------

--[[
      A wrapper for the linked list data structure.

      Technical info:
            FIFO.
            Lists are singly linked.
            List::Push will append the new value onto the tail of the list.
            List::Pop will remove and return the value at the head of the list.
            Popping an empty list will return nil.
]]

export type List = any; local List = {} do
      export type ListNode = Node; type Node = any
      type Iterator = (Node, number) -> (number, any)

      -- arrays used to save memory
      local HEAD  = 1
      local TAIL  = 2

      local NEXT  = 1
      local VALUE = 2

      local function list_iterator(state: Node, i: number): (number, any)
            local node = state[1][NEXT] -- uses custom state to keep track of node to avoid creating unique closures
            if node then
                  state[1] = node
                  return i+1, node[VALUE]
            end
      end

      local ListClass = {}
      ListClass.__index = ListClass
      ListClass.__metatable = "Locked"
      ListClass.__tostring = function() return "List" end

      function List.new(initializer_list: {any}?): List
            local head: Node, tail: Node;
            if initializer_list then
                  for i: number, v: any in ipairs(initializer_list) do
                        local node: Node = {nil, v}
                        if i > 1 then
                              tail[NEXT] = node
                        else
                              head = node
                        end
                        tail = node
                  end
            end
            return setmetatable({head, tail}, ListClass) :: List
      end

      -- appends element onto tail of list
      function ListClass:Push(v: any) -- appends to tail
            local node: Node = {nil, v}
            local tail: Node = self[TAIL]::Node
            if tail == nil then
                  self[HEAD] = node
            else
                  tail[NEXT] = node
            end
            self[TAIL] = node
      end

      -- removes and returns element at head of list
      function ListClass:Pop(): any -- pops from head
            local head: Node = self[HEAD]::Node
            if head == nil then return end

            local next: Node = head[NEXT]
            self[HEAD] = next

            if next == nil then self[TAIL] = nil end
            return head[VALUE]
      end

      -- returns element at head of list
      function ListClass:Front(): any
            return self[HEAD][VALUE]
      end

      -- returns elements at tail of list
      function ListClass:Back(): any
            return self[TAIL][VALUE]
      end

      -- returns a new array converted from the list
      function ListClass:ToArray(): ({any}, number)
            local array = {}
            local size: number = 0
            local node: Node = self[HEAD]::Node
            while node do
                  size += 1
                  array[size] = node[VALUE]
                  node = node[NEXT]
            end
            return array, size
      end

      -- return number of elements in list
      function ListClass:Size(): number
            local size: number = 0
            local node: Node = self[HEAD]::Node
            while node do
                  size += 1
                  node = node[NEXT]
            end
            return size
      end

      -- list iterator "list pairs"
      function List.lpairs(list: List): (Iterator, {Node}, number)
            return list_iterator, {list}, 0
      end

      -- expose indexes should the user want more control over list nodes
      List.Enum = table.freeze({
            Head  = HEAD,
            Tail  = TAIL,
            Next  = NEXT,
            Value = VALUE
      })

      table.freeze(List)
end

return List
