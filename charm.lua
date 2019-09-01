local charm = {}

local numberOfMouseButtons = 3


local function newElementClass(parent)
	local class = setmetatable({}, parent)
	class.__index = class
	class.get = setmetatable({}, {__index = parent and parent.get})
	return class
end

local Element = {}

Element.base = newElementClass()

Element.base.preserve = {
	ui = true,
	preserve = true,
	_stencilFunction = true,
}

function Element.base:getState()
	return self.ui:getState(self)
end

function Element.base:new(x, y, width, height)
	self._x = x or 0
	self._y = y or 0
	self._width = width or 0
	self._height = height or 0
end

function Element.base.get:x(anchor)
	anchor = anchor or 0
	return self._x + self._width * anchor
end

function Element.base.get:left() return self.get.x(self, 0) end
function Element.base.get:center() return self.get.x(self, .5) end
function Element.base.get:right() return self.get.x(self, 1) end

function Element.base.get:Y(anchor)
	anchor = anchor or 0
	return self._y + self._height * anchor
end

function Element.base.get:top() return self.get.y(self, 0) end
function Element.base.get:middle() return self.get.y(self, .5) end
function Element.base.get:bottom() return self.get.y(self, 1) end

function Element.base.get:width() return self._width end
function Element.base.get:height() return self._height end

function Element.base.get:size()
	return self.get.width(self), self.get.height(self)
end

function Element.base.get:hovered()
	local state = self:getState()
	return state and state.hovered
end

function Element.base.get:entered()
	local state = self:getState()
	return state and state.entered
end

function Element.base.get:exited()
	local state = self:getState()
	return state and state.exited
end

function Element.base.get:held(button)
	button = button or 1
	local state = self:getState()
	return state and state.held and state.held[button]
end

function Element.base.get:pressed(button)
	button = button or 1
	local state = self:getState()
	return state and state.pressed and state.pressed[button]
end

function Element.base.get:released(button)
	button = button or 1
	local state = self:getState()
	return state and state.released and state.released[button]
end

function Element.base.get:dragged(button)
	button = button or 1
	local state = self:getState()
	if not (state and state.held and state.held[button]) then
		return false
	end
	if self.ui._mouseX == self.ui._mouseXPrevious and self.ui._mouseY == self.ui._mouseYPrevious then
		return false
	end
	return true, self.ui._mouseX - self.ui._mouseXPrevious, self.ui._mouseY - self.ui._mouseYPrevious
end

function Element.base:x(x, anchor)
	anchor = anchor or 0
	self._x = x - self._width * anchor
end

function Element.base:left(x) return self:x(x, 0) end
function Element.base:center(x) return self:x(x, .5) end
function Element.base:right(x) return self:x(x, 1) end

function Element.base:y(y, anchor)
	anchor = anchor or 0
	self._y = y - self._height * anchor
end

function Element.base:top(y) return self:y(y, 0) end
function Element.base:middle(y) return self:y(y, .5) end
function Element.base:bottom(y) return self:y(y, 1) end

function Element.base:width(width)
	self._width = width
end

function Element.base:height(height)
	self._height = height
end

function Element.base:size(width, height)
	self:width(width)
	self:height(height)
end

function Element.base:name(name)
	self._name = name
end

function Element.base:clip()
	self._clip = true
end

function Element.base:transparent()
	self._transparent = true
end

function Element.base:opaque()
	self._transparent = false
end

function Element.base:onAddChild(element)
	self._children = self._children or {}
	table.insert(self._children, element)
end

function Element.base:stencil()
	love.graphics.rectangle('fill', 0, 0, self._width, self._height)
end

function Element.base:draw(stencilValue, dx, dy, mouseClipped)
	stencilValue = stencilValue or 0
	dx, dy = dx or 0, dy or 0
	-- call the beforeDraw callback
	if self.beforeDraw then self:beforeDraw() end
	-- check if the element is hovered
	local mouseX, mouseY = love.mouse.getPosition()
	mouseX, mouseY = mouseX - dx, mouseY - dy
	local hovered = mouseX >= self._x and mouseX <= self._x + self._width
		and mouseY >= self._y and mouseY <= self._y + self._height
	--[[
		if clipping is enabled, tell children that the mouse is
		outside the parent's visible region so they know
		they're not hovered
	]]
	if self._clip and not hovered then mouseClipped = true end
	-- draw self and children
	love.graphics.push 'all'
	love.graphics.translate(self._x, self._y)
	if self.drawSelf then self:drawSelf() end
	if self._children and #self._children > 0 then
		-- if clipping is enabled, push a stencil to the "stack"
		if self._clip then
			love.graphics.push 'all'
			self._stencilFunction = self._stencilFunction or function()
				self:stencil()
			end
			love.graphics.stencil(self._stencilFunction, 'increment', 1, true)
			love.graphics.setStencilTest('gequal', stencilValue + 1)
		end
		-- draw children
		for _, child in ipairs(self._children) do
			if child.draw then
				local childHovered = child:draw(stencilValue + 1, self._x + dx, self._y + dy, mouseClipped)
				--[[
					if the child is hovered and not transparent, then it should block
					the parent from being hovered
				]]
				if childHovered and not child._transparent then
					hovered = false
				end
			end
		end
		-- if clipping is enabled, pop a stencil from the "stack"
		if self._clip then
			love.graphics.stencil(self._stencilFunction, 'decrement', 1, true)
			love.graphics.pop()
		end
	end
	love.graphics.pop()
	-- update mouse state
	-- if the parent tells us the mouse is clipped,
	-- we know we aren't hovered
	if mouseClipped then hovered = false end
	-- update the persistent state (if available)
	local state = self:getState()
	if state then
		local mouseDown = self.ui._mouseDown
		local mouseDownPrevious = self.ui._mouseDownPrevious
		-- update hovered/entered/exited state
		state.entered = false
		state.exited = false
		if hovered and not state.hovered then
			state.hovered = true
			state.entered = true
		end
		if state.hovered and not hovered then
			state.hovered = false
			state.exited = true
		end
		-- update held/pressed/released state
		state.held = state.held or {}
		state.pressed = state.pressed or {}
		state.released = state.released or {}
		for i = 1, numberOfMouseButtons do
			state.pressed[i] = false
			state.released[i] = false
			if hovered and mouseDown[i] and not mouseDownPrevious[i] then
				state.held[i] = true
				state.pressed[i] = true
			end
			if state.held[i] and not mouseDown[i] then
				state.held[i] = false
				if hovered then
					state.released[i] = true
				end
			end
		end
	end
	-- call the afterDraw callback
	if self.afterDraw then self:afterDraw() end
	-- tell any parent element if this element is hovered or not
	return hovered
end

Element.rectangle = newElementClass(Element.base)

function Element.rectangle:fillColor(r, g, b, a)
	self._fillColor = self._fillColor or {}
	if type(r) == 'table' then
		for i = 1, 4 do self._fillColor[i] = r[i] end
	else
		self._fillColor[1] = r
		self._fillColor[2] = g
		self._fillColor[3] = b
		self._fillColor[4] = a
	end
end

function Element.rectangle:drawSelf()
	love.graphics.push 'all'
	if self._fillColor and #self._fillColor > 1 then
		love.graphics.setColor(self._fillColor)
		love.graphics.rectangle('fill', 0, 0, self._width, self._height)
	end
	love.graphics.pop()
end

local Ui = {}

function Ui:__index(k)
	if Ui[k] then return Ui[k] end
	self._functionCache[k] = self._functionCache[k] or function(_, ...)
		local element = self:_getSelectedElement()
		element[k](element, ...)
		return self
	end
	return self._functionCache[k]
end

function Ui:_getElementClass(className)
	if type(className) == 'table' then return className end
	return Element[className]
end

function Ui:_getSelectedElement()
	return self._groups[self._currentGroup]._selectedElement
end

function Ui:_getPreviousElement()
	return self._groups[self._currentGroup]._previousElement
end

function Ui:_getParentElement()
	return self._groups[self._currentGroup]._parent
end

function Ui:_reset()
	for i = #self._elements, 1, -1 do
		self._elements[i] = nil
	end
	for _, element in ipairs(self._elementPool) do
		element._used = false
	end
	self._selectedElement = nil
	self._previousElement = nil
end

function Ui:_clearElement(element)
	for key, value in pairs(element) do
		if not element.preserve[key] then
			if type(value) == 'table' then
				for nestedKey in pairs(value) do
					value[nestedKey] = nil
				end
			else
				element[key] = nil
			end
		end
	end
end

function Ui:select(element)
	local group = self._groups[self._currentGroup]
	group._previousElement = group._selectedElement
	group._selectedElement = element
end

function Ui:new(className, ...)
	if self._finished then
		self:_reset()
		self._finished = false
	end
	local element
	-- if possible, reuse an unused element
	for _, e in ipairs(self._elementPool) do
		if not e._used then
			self:_clearElement(e)
			element = e
			break
		end
	end
	-- otherwise, create a new one and add it to the pool
	if not element then
		element = {}
		table.insert(self._elementPool, element)
	end
	-- initialize the element
	element.ui = self
	element._used = true
	setmetatable(element, self:_getElementClass(className))
	if element.new then element:new(...) end
	-- select the element
	self:select(element)
	-- add it to the elements tree
	local parent = self:_getParentElement()
	if parent then
		if parent.onAddChild then parent:onAddChild(element) end
	else
		table.insert(self._elements, element)
	end
	return self
end

function Ui:getElement(name)
	if type(name) == 'table' then return name end
	if name == '@current' then
		return self:_getSelectedElement()
	elseif name == '@previous' then
		return self:_getPreviousElement()
	elseif name == '@parent' then
		return self:_getParentElement()
	end
	for i = #self._elementPool, 1, -1 do
		local element = self._elementPool[i]
		if element._used and element._name == name then
			return element
		end
	end
end

function Ui:get(elementName, property, ...)
	local element = self:getElement(elementName)
	return element.get[property](element, ...)
end

function Ui:getState(name)
	local element = self:getElement(name)
	if not element then return end
	if not element._name then return end
	self._state[element._name] = self._state[element._name] or {}
	return self._state[element._name]
end

function Ui:beginChildren()
	local parent = self:_getSelectedElement()
	self._currentGroup = self._currentGroup + 1
	self._groups[self._currentGroup] = self._groups[self._currentGroup] or {}
	local group = self._groups[self._currentGroup]
	group._parent = parent
	group._selectedElement = nil
	group._previousElement = nil
	return self
end

function Ui:endChildren()
	self._currentGroup = self._currentGroup - 1
	return self
end

function Ui:draw()
	-- update mouse state
	self._mouseXPrevious, self._mouseYPrevious = self._mouseX, self._mouseY
	self._mouseX, self._mouseY = love.mouse.getPosition()
	for i = 1, numberOfMouseButtons do
		self._mouseDownPrevious[i] = self._mouseDown[i]
		self._mouseDown[i] = love.mouse.isDown(i)
	end
	-- draw elements
	for _, element in ipairs(self._elements) do
		if element.draw then element:draw() end
	end
	self._finished = true
end

function charm.new()
	return setmetatable({
		_finished = false,
		_elements = {},
		_elementPool = {},
		_groups = {{}},
		_currentGroup = 1,
		_state = {},
		_functionCache = {},
		_mouseDown = {},
		_mouseDownPrevious = {},
		_mouseX = nil,
		_mouseY = nil,
		_mouseXPrevious = nil,
		_mouseYPrevious = nil,
	}, Ui)
end

return charm
