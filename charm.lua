local charm = {}

local function newClass(parent)
	local class = setmetatable({parent = parent}, {
		__index = parent,
		__call = function(class, ...)
			local instance = setmetatable({}, class)
			instance:new(...)
			return instance
		end,
	})
	class.__index = class
	return class
end

local Element = newClass()

function Element:new(x, y, width, height)
	self._x = x or 0
	self._y = y or 0
	self._width = width or 0
	self._height = height or 0
	self._children = {}
	self._hovered = false
	self._hoveredPrevious = false
	self._events = {}
end

-- utilities (for internal use and custom classes) --
function Element:setColor(key, r, g, b, a)
	if type(r) == 'number' then
		self[key] = {r, g, b, a}
	else
		self[key] = r
	end
end

function Element:trigger(event, ...)
	local events = self._events[event]
	if events then
		for f in pairs(events) do f(self, ...) end
	end
	return self
end

function Element:emitToChildren(event, ...)
	for _, child in ipairs(self._children) do
		child:emit(event, ...)
	end
	return self
end

function Element:emit(event, ...)
	self:trigger(event, ...)
	self:emitToChildren(event, ...)
	return self
end

-- main API --
function Element:pointInBounds(x, y)
	return x >= self:getLeft()
	   and x <= self:getRight()
	   and y >= self:getTop()
	   and y <= self:getBottom()
end

function Element:getX(anchor)
	anchor = anchor or 0
	return self._x + self._width * anchor
end

function Element:getLeft() return self:getX(0) end
function Element:getCenterX() return self:getX(.5) end
function Element:getRight() return self:getX(1) end

function Element:getY(anchor)
	anchor = anchor or 0
	return self._y + self._height * anchor
end

function Element:getTop() return self:getY(0) end
function Element:getCenterY() return self:getY(.5) end
function Element:getBottom() return self:getY(1) end

function Element:getWidth() return self._width end
function Element:getHeight() return self._height end

function Element:getSize()
	return self:getWidth(), self:getHeight()
end

function Element:getRectangle()
	return self._x, self._y, self._width, self._height
end

function Element:isHovered() return self._hovered end

function Element:wasEntered()
	return self._hovered and not self._hoveredPrevious
end

function Element:wasExited()
	return self._hoveredPrevious and not self._hovered
end

function Element:x(x, anchor)
	anchor = anchor or 0
	self._x = x - self._width * anchor
	return self
end

function Element:left(x) return self:x(x, 0) end
function Element:centerX(x) return self:x(x, .5) end
function Element:right(x) return self:x(x, 1) end

function Element:y(y, anchor)
	anchor = anchor or 0
	self._y = y - self._height * anchor
	return self
end

function Element:top(y) return self:y(y, 0) end
function Element:centerY(y) return self:y(y, .5) end
function Element:bottom(y) return self:y(y, 1) end

function Element:width(width)
	self._width = width
	return self
end

function Element:height(height)
	self._height = height
	return self
end

function Element:size(width, height)
	self:width(width)
	self:height(height)
	return self
end

function Element:add(child)
	table.insert(self._children, child)
	return self
end

function Element:on(event, f)
	self._events[event] = self._events[event] or {}
	self._events[event][f] = true
	return self
end

function Element:off(event, f)
	local events = self._events[event]
	if events then events[f] = nil end
	return self
end

function Element:mousemoved(x, y, dx, dy, blocked)
	for i = #self._children, 1, -1 do
		local child = self._children[i]
		if child:mousemoved(x - self._x, y - self._y, dx, dy, blocked) then
			blocked = true
		end
	end
	self._hoveredPrevious = self._hovered
	self._hovered = not blocked and self:pointInBounds(x, y)
	if self:wasEntered() then self:trigger('enter', x, y) end
	if self:wasExited() then self:trigger('exit', x, y) end
	return self._hovered
end

function Element:drawBelowChildren() end
function Element:drawAboveChildren() end

function Element:draw()
	self:drawBelowChildren()
	love.graphics.push 'all'
		love.graphics.translate(self._x, self._y)
		for _, child in ipairs(self._children) do
			child:draw()
		end
	love.graphics.pop()
	self:drawAboveChildren()
end

function Element:drawDebug()
	love.graphics.push 'all'
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle('line', self:getRectangle())
	love.graphics.pop()
	love.graphics.push 'all'
		love.graphics.translate(self._x, self._y)
		for _, child in ipairs(self._children) do
			child:drawDebug()
		end
	love.graphics.pop()
end

local Shape = newClass(Element)

function Shape:fillColor(r, g, b, a)
	self:setColor('_fillColor', r, g, b, a)
	return self
end

function Shape:outlineColor(r, g, b, a)
	self:setColor('_outlineColor', r, g, b, a)
	return self
end

function Shape:outlineWidth(width)
	self._outlineWidth = width
	return self
end

function Shape:drawShape(mode) end

function Shape:drawBelowChildren()
	if not self._fillColor then return end
	love.graphics.push 'all'
		love.graphics.setColor(self._fillColor)
		self:drawShape 'fill'
	love.graphics.pop()
end

function Shape:drawAboveChildren()
	if not self._outlineColor then return end
	love.graphics.push 'all'
		love.graphics.setColor(self._outlineColor)
		love.graphics.setLineWidth(self._outlineWidth)
		self:drawShape 'line'
	love.graphics.pop()
end

local Rectangle = newClass(Shape)

function Rectangle:cornerRadius(radiusX, radiusY)
	self._cornerRadiusX = radiusX
	self._cornerRadiusY = radiusY
	return self
end

function Rectangle:cornerSegments(segments)
	self._cornerSegments = segments
	return self
end

function Rectangle:drawShape(mode)
	local x, y, width, height = self:getRectangle()
	love.graphics.rectangle(mode, x, y, width, height, self._cornerRadiusX, self._cornerRadiusY, self._cornerSegments)
end

charm.Element = Element
charm.Shape = Shape
charm.Rectangle = Rectangle

return charm
