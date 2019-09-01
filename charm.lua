local charm = {}

local function newElementClass(parent)
	local class = setmetatable({}, parent)
	class.__index = class
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
	self.x = x or 0
	self.y = y or 0
	self.width = width or 0
	self.height = height or 0
end

function Element.base:onAddChild(element)
	self.children = self.children or {}
	table.insert(self.children, element)
end

function Element.base:stencil()
	love.graphics.rectangle('fill', 0, 0, self.width, self.height)
end

function Element.base:draw(stencilValue, dx, dy)
	stencilValue = stencilValue or 0
	dx, dy = dx or 0, dy or 0
	if self.beforeDraw then self:beforeDraw() end
	-- update mouse state
	local state = self:getState()
	if state then
		local mouseX, mouseY = love.mouse.getPosition()
		mouseX, mouseY = mouseX - dx, mouseY - dy
		state.hoveredPrevious = state.hovered
		state.hovered = mouseX >= self.x and mouseX <= self.x + self.width
			and mouseY >= self.y and mouseY <= self.y + self.height
	end
	-- draw self and children
	love.graphics.push 'all'
	love.graphics.translate(self.x, self.y)
	if self.drawSelf then self:drawSelf() end
	if self.children and #self.children > 0 then
		-- if clipping is enabled, push a stencil to the "stack"
		if self.clip then
			love.graphics.push 'all'
			self._stencilFunction = self._stencilFunction or function()
				self:stencil()
			end
			love.graphics.stencil(self._stencilFunction, 'increment', 1, true)
			love.graphics.setStencilTest('gequal', stencilValue + 1)
		end
		-- draw children
		for _, child in ipairs(self.children) do
			if child.draw then
				child:draw(stencilValue + 1, self.x + dx, self.y + dy)
			end
		end
		-- if clipping is enabled, pop a stencil from the "stack"
		if self.clip then
			love.graphics.stencil(self._stencilFunction, 'decrement', 1, true)
			love.graphics.pop()
		end
	end
	love.graphics.pop()
	if self.afterDraw then self:afterDraw() end
end

Element.rectangle = newElementClass(Element.base)

Element.rectangle.set = {}

function Element.rectangle.set:fillColor(r, g, b, a)
	self.fillColor = self.fillColor or {}
	if type(r) == 'table' then
		for i = 1, 4 do self.fillColor[i] = r[i] end
	else
		self.fillColor[1] = r
		self.fillColor[2] = g
		self.fillColor[3] = b
		self.fillColor[4] = a
	end
end

function Element.rectangle:drawSelf()
	love.graphics.push 'all'
	if self.fillColor and #self.fillColor > 1 then
		love.graphics.setColor(self.fillColor)
		love.graphics.rectangle('fill', 0, 0, self.width, self.height)
	end
	love.graphics.pop()
end

local Ui = {}

function Ui:__index(k)
	if Ui[k] then return Ui[k] end
	self._propertyCache[k] = self._propertyCache[k] or function(_, ...)
		return self:set(k, ...)
	end
	return self._propertyCache[k]
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

function Ui:select(element)
	local group = self._groups[self._currentGroup]
	group._previousElement = group._selectedElement
	group._selectedElement = element
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
		if element._used and element.name == name then
			return element
		end
	end
end

function Ui:getX(name, anchor)
	anchor = anchor or 0
	local element = self:getElement(name)
	return element.x + element.width * anchor
end

function Ui:getLeft(name) return self:getX(name, 0) end
function Ui:getCenter(name) return self:getX(name, .5) end
function Ui:getRight(name) return self:getX(name, 1) end

function Ui:getY(name, anchor)
	anchor = anchor or 0
	local element = self:getElement(name)
	return element.y + element.height * anchor
end

function Ui:getTop(name) return self:getY(name, 0) end
function Ui:getMiddle(name) return self:getY(name, .5) end
function Ui:getBottom(name) return self:getY(name, 1) end

function Ui:getWidth(name) return self:getElement(name).width end
function Ui:getHeight(name) return self:getElement(name).height end

function Ui:getSize(name)
	return self:getWidth(name), self:getHeight(name)
end

function Ui:getState(name)
	local element = self:getElement(name)
	if not element then return end
	if not element.name then return end
	self._state[element.name] = self._state[element.name] or {}
	return self._state[element.name]
end

function Ui:isHovered(name)
	local state = self:getState(name)
	if not state then return false end
	return state.hovered
end

function Ui:isEntered(name)
	local state = self:getState(name)
	if not state then return false end
	return state.hovered and not state.hoveredPrevious
end

function Ui:isExited(name)
	local state = self:getState(name)
	if not state then return false end
	return state.hoveredPrevious and not state.hovered
end

function Ui:x(x, anchor)
	anchor = anchor or 0
	local element = self:_getSelectedElement()
	element.x = x - element.width * anchor
	return self
end

function Ui:left(x) return self:x(x, 0) end
function Ui:center(x) return self:x(x, .5) end
function Ui:right(x) return self:x(x, 1) end

function Ui:y(y, anchor)
	anchor = anchor or 0
	local element = self:_getSelectedElement()
	element.y = y - element.height * anchor
	return self
end

function Ui:top(y) return self:y(y, 0) end
function Ui:middle(y) return self:y(y, .5) end
function Ui:bottom(y) return self:y(y, 1) end

function Ui:width(width)
	self:_getSelectedElement().width = width
	return self
end

function Ui:height(height)
	self:_getSelectedElement().height = height
	return self
end

function Ui:size(width, height)
	self:width(width)
	self:height(height)
	return self
end

function Ui:name(name)
	self:_getSelectedElement().name = name
	return self
end

function Ui:clip()
	self:_getSelectedElement().clip = true
	return self
end

function Ui:set(property, ...)
	local element = self:_getSelectedElement()
	if element.set and element.set[property] then
		element.set[property](element, ...)
	end
	return self
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
		_propertyCache = {},
	}, Ui)
end

return charm
