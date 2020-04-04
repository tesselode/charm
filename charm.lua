local charm = {}

local function newElementClass(className, parent)
	local class = setmetatable({
		-- every element class has a className string
		-- so we can automatically generate decent element names
		className = className,
		parent = parent,
		-- property getters
		get = setmetatable({}, {
			-- property getters fall back to parent property getters
			__index = parent and parent.get,
			-- allows for the self:get 'propertyName' shorthand
			__call = function(_, self, propertyName, ...)
				return self.get[propertyName](self, ...)
			end,
		}),
		-- keys that should not be cleared out when a new draw
		-- frame is started
		preserve = setmetatable({}, {
			__index = parent and parent.preserve,
		}),
	}, {__index = parent})
	class.__index = class
	return class
end

local Element = newElementClass 'Element'

Element.preserve._parent = true
Element.preserve._ui = true

function Element:new(x, y, width, height)
	self._x = x
	self._y = y
	self._width = width
	self._height = height
end

function Element:initState(state) end

--- Returns whether a color is set.
-- @string color the name of the color to check
-- @treturn boolean
function Element:isColorSet(color)
	return color and #color > 0
end

--- Sets a color property on an element.
-- @string propertyName the name of the property to set
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Element:setColor(propertyName, r, g, b, a)
	--[[ if type(r) ~= 'table' then
		checkArgument(1, r, 'number', 'table')
		checkArgument(2, g, 'number')
		checkArgument(3, b, 'number')
		checkOptionalArgument(4, a, 'number')
	end ]]
	self[propertyName] = self[propertyName] or {}
	if type(r) == 'table' then
		--[[
			You might be wondering, if r is already a table,
			why not just set self[propertyName] to r?
			The color table gets cleared after each draw.
			If we make self[propertyName] a reference to the
			table the user provided, then we'll end up
			clearing that table. The user might actually
			want to keep that table. So to avoid clobbering
			the user's data, we just copy the values from their
			table to our own.
		]]
		self[propertyName][1] = r[1]
		self[propertyName][2] = r[2]
		self[propertyName][3] = r[3]
		self[propertyName][4] = r[4]
	else
		self[propertyName][1] = r
		self[propertyName][2] = g
		self[propertyName][3] = b
		self[propertyName][4] = a
	end
end

function Element.get:name()
	return self._ui:getName(self)
end

function Element.get:id()
	return self._ui:getId(self)
end

function Element:getState()
	return self._ui:getState(self)
end

function Element.get:width()
	return self._width or 0
end

function Element.get:height()
	return self._height or 0
end

function Element.get:size()
	return self:get 'width', self:get 'height'
end

function Element.get:x(origin)
	origin = origin or 0
	return (self._x or 0) + self:get 'width' * origin
end

function Element.get:y(origin)
	origin = origin or 0
	return (self._y or 0) + self:get 'height' * origin
end

function Element.get:rectangle()
	return self:get 'x', self:get 'y', self:get 'size'
end

function Element:width(width)
	self._width = width
end

function Element:height(height)
	self._height = height
end

function Element:x(x, origin)
	origin = origin or 0
	self._x = x - self:get 'width' * origin
end

function Element:y(y, origin)
	origin = origin or 0
	self._y = y - self:get 'height' * origin
end

function Element:addChild(child)
	self._children = self._children or {}
	table.insert(self._children, child)
end

function Element:drawBottom() end

function Element:drawTop() end

function Element:draw()
	love.graphics.push 'all'
	love.graphics.translate(self:get 'x', self:get 'y')
	self:drawBottom()
	if self._children then
		for _, child in ipairs(self._children) do
			child:draw()
		end
	end
	self:drawTop()
	love.graphics.pop()
end

function Element:drawDebug()
	love.graphics.push 'all'
	love.graphics.translate(self:get 'x', self:get 'y')
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle('line', 0, 0, self:get 'size')
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(self:get 'id')
	if self._children then
		for _, child in ipairs(self._children) do
			child:drawDebug()
		end
	end
	love.graphics.pop()
end

local Shape = newElementClass('Shape', Element)

function Shape:fillColor(r, g, b, a)
	self:setColor('_fillColor', r, g, b, a)
end

function Shape:outlineColor(r, g, b, a)
	self:setColor('_outlineColor', r, g, b, a)
end

function Shape:outlineWidth(outlineWidth)
	self._outlineWidth = outlineWidth
end

function Shape:drawShape(mode) end

function Shape:drawBottom()
	if not self:isColorSet(self._fillColor) then return end
	love.graphics.push 'all'
	love.graphics.setColor(self._fillColor)
	self:drawShape 'fill'
	love.graphics.pop()
end

function Shape:drawTop()
	if not self:isColorSet(self._outlineColor) then return end
	love.graphics.push 'all'
	love.graphics.setColor(self._outlineColor)
	love.graphics.setLineWidth(self._outlineWidth or 1)
	self:drawShape 'line'
	love.graphics.pop()
end

local Rectangle = newElementClass('Rectangle', Shape)

function Rectangle:cornerRadius(cornerRadiusX, cornerRadiusY)
	self._cornerRadiusX = cornerRadiusX
	self._cornerRadiusY = cornerRadiusY or cornerRadiusX
end

function Rectangle:drawShape(mode)
	love.graphics.rectangle(mode, 0, 0, self:get 'width', self:get 'height',
		self._cornerRadiusX, self._cornerRadiusY)
end

local elementClasses = {
	element = Element,
	rectangle = Rectangle,
	shape = Shape,
}

local Ui = {}

function Ui:__index(k)
	if Ui[k] then return Ui[k] end
	self._functionCache[k] = self._functionCache[k] or function(_, ...)
		local selected = self._groups[self._currentGroup].selected
		selected[k](selected, ...)
		return self
	end
	return self._functionCache[k]
end

function Ui:_clear(element)
	for k, v in pairs(element) do
		if not element.preserve[k] then
			if type(v) == 'table' then
				for kk in pairs(v) do
					v[kk] = nil
				end
			else
				element[k] = nil
			end
		end
	end
end

function Ui:_pushGroup()
	self._currentGroup = self._currentGroup + 1
	-- create a new group table if needed
	if not self._groups[self._currentGroup] then
		self._groups[self._currentGroup] = {}
	end
	local group = self._groups[self._currentGroup]
	-- reset the group table
	group.elementCount = group.elementCount or {}
	for k in pairs(group.elementCount) do
		group.elementCount[k] = nil
	end
	group.selected = nil
end

function Ui:_popGroup()
	self._currentGroup = self._currentGroup - 1
end

function Ui:_getNextElementName(element)
	-- if the user set a name for the next element, use that name
	if self._nextElementName then
		local name = self._nextElementName
		self._nextElementName = false
		return name
	end
	--[[
		otherwise, autogenerate the name [elementClassName][number],
		where number is how many unnamed elements of that type
		there have been so far (e.g. rectangle1, image3)
	]]
	local className = element.className
	local group = self._groups[self._currentGroup]
	group.elementCount[className] = group.elementCount[className] or 0
	group.elementCount[className] = group.elementCount[className] + 1
	return className .. group.elementCount[className]
end

function Ui:getElement(element)
	element = element or '@selected'
	if type(element) == 'table' then return element end
	if element == '@selected' then
		return self._groups[self._currentGroup].selected
	elseif element == '@previous' then
		return self._groups[self._currentGroup].previous
	elseif element == '@parent' then
		local parentGroup = self._groups[self._currentGroup - 1]
		return parentGroup.selected
	end
end

function Ui:getName(element)
	element = self:getElement(element)
	return element._name
end

function Ui:getId(element)
	element = self:getElement(element)
	local id = ''
	if element._parent then
		id = id .. self:getId(element._parent) .. ' > '
	end
	id = id .. self:getName(element)
	return id
end

function Ui:getState(element)
	element = self:getElement(element)
	return self._state[element:get 'id']
end

function Ui:get(element, propertyName, ...)
	element = self:getElement(element)
	return element:get(propertyName, ...)
end

function Ui:begin()
	-- clear the tree
	for i in ipairs(self._tree) do
		self._tree[i] = nil
	end
	-- mark all elements as unused
	for _, element in ipairs(self._pool) do
		element._used = false
	end
	-- remove unused element state
	for id in pairs(self._state) do
		if not self._stateUsed[id] then
			self._state[id] = nil
		end
	end
	for id in pairs(self._stateUsed) do
		self._stateUsed[id] = nil
	end
	-- reset the group stack
	self._currentGroup = 0
	self:_pushGroup()
	self._finished = false
end

function Ui:select(element)
	local currentGroup = self._groups[self._currentGroup]
	currentGroup.previous = currentGroup.selected
	currentGroup.selected = self:getElement(element)
end

function Ui:new(class, ...)
	-- if we just finished drawing, start a new frame
	if self._finished then self:begin() end
	local parentGroup = self._groups[self._currentGroup - 1]
	-- get the element class if a name was provided
	if type(class) == 'string' then
		class = elementClasses[class]
	end
	-- reuse an existing element if possible
	local element
	for _, e in ipairs(self._pool) do
		if not e._used then
			element = e
			break
		end
	end
	-- otherwise, create a new one
	if not element then
		element = {}
		table.insert(self._pool, element)
	end
	-- clear out the element
	self:_clear(element)
	-- initialize the element
	setmetatable(element, class)
	element._used = true
	element._ui = self
	element._name = self:_getNextElementName(element)
	if parentGroup then
		element._parent = parentGroup.selected
	end
	element:new(...)
	-- initialize the element state if needed
	local id = element:get 'id'
	self._stateUsed[id] = true
	if not self._state[id] then
		self._state[id] = {}
		element:initState(self._state[id])
	end
	-- add the element to the tree
	if parentGroup then
		parentGroup.selected:addChild(element)
	else
		table.insert(self._tree, element)
	end
	self:select(element)
	return self
end

function Ui:name(name)
	self._nextElementName = name
	return self
end

function Ui:beginChildren()
	self:_pushGroup()
	return self
end

function Ui:endChildren()
	self:_popGroup()
	return self
end

function Ui:draw()
	for _, element in ipairs(self._tree) do
		element:draw()
	end
	self._finished = true
	return self
end

function Ui:drawDebug()
	for _, element in ipairs(self._tree) do
		element:drawDebug()
	end
	self._finished = true
	return self
end

function charm.new()
	return setmetatable({
		_functionCache = {},
		_pool = {},
		_tree = {},
		_state = {},
		_stateUsed = {},
		_groups = {},
		_currentGroup = 1,
		_finished = true,
		_nextElementName = false,
	}, Ui)
end

return charm
