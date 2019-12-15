local charm = {}

local function newElementClass(parent)
	local class = {
		get = setmetatable({}, {__index = parent and parent.get})
	}
	class.__index = class
	setmetatable(class, {__index = parent})
	return class
end

local Element = newElementClass()

function Element:new(x, y, width, height)
	self._x = x
	self._y = y
	self._width = width
	self._height = height
end

function Element.get:x(anchor)
	anchor = anchor or 0
	return (self._x or 0) + (self._width or 0) * anchor
end

function Element.get:left() return self.get.x(self, 0) end
function Element.get:center() return self.get.x(self, .5) end
function Element.get:right() return self.get.x(self, 1) end

function Element.get:y(anchor)
	anchor = anchor or 0
	return (self._y or 0) + (self._height or 0) * anchor
end

function Element.get:top() return self.get.y(self, 0) end
function Element.get:middle() return self.get.y(self, .5) end
function Element.get:bottom() return self.get.y(self, 1) end

function Element.get:width() return self._width or 0 end
function Element.get:height() return self._height or 0 end

function Element.get:size()
	return self.get.width(self), self.get.height(self)
end

function Element:x(x, anchor)
	anchor = anchor or 0
	self._anchorX = anchor
	self._x = x - self.get.width(self) * anchor
end

function Element:left(x) self:x(x, 0) end
function Element:center(x) self:x(x, .5) end
function Element:right(x) self:x(x, 1) end

function Element:y(y, anchor)
	anchor = anchor or 0
	self._anchorY = anchor
	self._y = y - self.get.height(self) * anchor
end

function Element:top(y) self:y(y, 0) end
function Element:middle(y) self:y(y, .5) end
function Element:bottom(y) self:y(y, 1) end

function Element:width(width)
	local anchor = self._anchorX or 0
	local x = self.get.x(self, anchor)
	self._width = width
	self:x(x, anchor)
end

function Element:height(height)
	local anchor = self._anchorY or 0
	local y = self.get.y(self, anchor)
	self._height = height
	self:y(y, anchor)
end

function Element:size(width, height)
	self:width(width)
	self:height(height)
end

function Element:drawSelf() end

function Element:draw()
	love.graphics.push 'all'
	love.graphics.translate(self.get.x(self), self.get.y(self))
	self:drawSelf()
	love.graphics.pop()
end

local Shape = newElementClass(Element)

function Shape:fillColor(r, g, b, a)
	if type(r) == 'table' then
		self._fillColor = r
	else
		self._fillColor = self._fillColor or {}
		self._fillColor[1] = r
		self._fillColor[2] = g
		self._fillColor[3] = b
		self._fillColor[4] = a
	end
end

function Shape:outlineColor(r, g, b, a)
	if type(r) == 'table' then
		self._outlineColor = r
	else
		self._outlineColor = self._outlineColor or {}
		self._outlineColor[1] = r
		self._outlineColor[2] = g
		self._outlineColor[3] = b
		self._outlineColor[4] = a
	end
end

function Shape:outlineWidth(width) self._outlineWidth = width end

function Shape:drawShape(mode) end

function Shape:drawSelf()
	love.graphics.push 'all'
	if self._fillColor and #self._fillColor > 0 then
		love.graphics.setColor(self._fillColor)
		self:drawShape 'fill'
	end
	if self._outlineColor and #self._outlineColor > 0 then
		love.graphics.setColor(self._outlineColor)
		if self._outlineWidth then
			love.graphics.setLineWidth(self._outlineWidth)
		end
		self:drawShape 'line'
	end
	love.graphics.pop()
end

local Rectangle = newElementClass(Shape)

function Rectangle:cornerRadius(radiusX, radiusY)
	self._cornerRadiusX = radiusX
	self._cornerRadiusY = radiusY
end

function Rectangle:cornerSegments(segments) self._cornerSegments = segments end

function Rectangle:drawShape(mode)
	love.graphics.rectangle(mode, 0, 0, self.get.width(self), self.get.height(self),
		self._cornerRadiusX, self._cornerRadiusY, self._cornerSegments)
end

local elementClasses = {
	element = Element,
	shape = Shape,
	rectangle = Rectangle,
}

local Layout = {}

function Layout:__index(k)
	if Layout[k] then return Layout[k] end
	self._functionCache[k] = self._functionCache[k] or function(_, ...)
		local element = self:_getSelectedElement()
		element[k](element, ...)
		return self
	end
	return self._functionCache[k]
end

function Layout:_clearElement(element)
	for key, value in pairs(element) do
		if type(value) == 'table' then
			for k in pairs(value) do value[k] = nil end
		elseif type(value) ~= 'function' then
			element[key] = nil
		end
	end
end

function Layout:_getSelectedElement()
	return self._groups[self._currentGroupIndex].current
end

function Layout:getElement(name)
	if type(name) == 'table' then return name end
end

function Layout:get(elementName, propertyName, ...)
	local element = self:getElement(elementName)
	return element.get[propertyName](element, ...)
end

function Layout:select(name)
	local element = self:getElement(name)
	local group = self._groups[self._currentGroupIndex]
	group.previous = group.current
	group.current = element
	return self
end

function Layout:new(elementClass, ...)
	-- get the appropriate element class
	if type(elementClass) == 'string' then
		elementClass = elementClasses[elementClass]
	end
	local element
	-- try to reuse an unused element
	for _, e in ipairs(self._elementPool) do
		if not e._used then
			self:_clearElement(e)
			element = e
		end
	end
	-- if there are none, create a new one and add it to the pool
	if not element then
		element = {}
		table.insert(self._elementPool, element)
	end
	-- initialize the element
	element._used = true
	setmetatable(element, elementClass)
	element:new(...)
	-- add it to the tree and select it
	table.insert(self._elements, element)
	self:select(element)
	return self
end

function Layout:draw()
	for elementIndex, element in ipairs(self._elements) do
		element:draw()
		element._used = false
		self._elements[elementIndex] = nil
	end
	return self
end

function charm.new()
	return setmetatable({
		_elementPool = {},
		_elements = {},
		_groups = {{}},
		_currentGroupIndex = 1,
		_functionCache = {},
	}, Layout)
end

return charm
