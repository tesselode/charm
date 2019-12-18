local charm = {}

-- gets the total number of lines in a string
local function numberOfLines(s)
	local _, newlines = s:gsub('\n', '\n')
	return newlines + 1
end

-- gets the total height of a text string drawn with a certain font
local function getTextHeight(font, text)
	return font:getHeight() * font:getLineHeight() * numberOfLines(text)
end

--[[
	gets the total height of a text string drawn with a certain font
	and maximum width.

	note:
	currently this uses love's built in function for getting
	wrapping info, which returns a table. since getParagraphHeight
	is called every frame, this creates a lot of garbage, so it would be
	nice to find another way to do this.
]]
local function getParagraphHeight(font, text, limit)
	local _, lines = font:getWrap(text, limit)
	return #lines * font:getHeight() * font:getLineHeight()
end

local function newElementClass(parent)
	local class = {
		parent = parent,
		get = setmetatable({}, {__index = parent and parent.get}),
		preserve = setmetatable({}, {__index = parent and parent.preserve}),
	}
	class.__index = class
	setmetatable(class, {__index = parent})
	return class
end

local Element = newElementClass()

Element.preserve._stencilFunction = true

function Element:new(x, y, width, height)
	self._x = x
	self._y = y
	self._width = width
	self._height = height
end

function Element:setColor(propertyName, r, g, b, a)
	if type(r) == 'table' then
		self[propertyName] = r
	else
		self[propertyName] = self[propertyName] or {}
		self[propertyName][1] = r
		self[propertyName][2] = g
		self[propertyName][3] = b
		self[propertyName][4] = a
	end
end

function Element:isColorSet(color)
	return color and #color > 0
end

function Element.get:x(anchor)
	anchor = anchor or 0
	return (self._x or 0) + self.get.width(self) * anchor
end

function Element.get:left() return self.get.x(self, 0) end
function Element.get:center() return self.get.x(self, .5) end
function Element.get:right() return self.get.x(self, 1) end

function Element.get:y(anchor)
	anchor = anchor or 0
	return (self._y or 0) + self.get.height(self) * anchor
end

function Element.get:top() return self.get.y(self, 0) end
function Element.get:middle() return self.get.y(self, .5) end
function Element.get:bottom() return self.get.y(self, 1) end

function Element.get:width() return self._width or 0 end
function Element.get:height() return self._height or 0 end

function Element.get:size()
	return self.get.width(self), self.get.height(self)
end

function Element.get:childrenBounds()
	if not self._children then return end
	local left, top, right, bottom
	for _, child in ipairs(self._children) do
		local childLeft = child.get.left(child)
		local childTop = child.get.top(child)
		local childRight = child.get.right(child)
		local childBottom = child.get.bottom(child)
		left = left and math.min(left, childLeft) or childLeft
		top = top and math.min(top, childTop) or childTop
		right = right and math.max(right, childRight) or childRight
		bottom = bottom and math.max(bottom, childBottom) or childBottom
	end
	return left, top, right, bottom
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

function Element:shift(dx, dy)
	self:x(self.get.x(self) + (dx or 0))
	self:y(self.get.y(self) + (dy or 0))
end

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

function Element:clip()
	self._clip = true
end

function Element:addChild(child)
	self._children = self._children or {}
	table.insert(self._children, child)
end

function Element:onBeginChildren(...) end

function Element:onAddChild(child)
	self:addChild(child)
end

function Element:onEndChildren(...) end

function Element:shiftChildren(dx, dy)
	if not self._children then return end
	for _, child in ipairs(self._children) do
		child:shift(dx, dy)
	end
end

function Element:wrap(padding)
	if not self._children then return end
	padding = padding or 0
	-- get the bounds of the children
	local left, top, right, bottom = self.get.childrenBounds(self)
	-- apply padding
	left = left - padding
	top = top - padding
	right = right + padding
	bottom = bottom + padding
	-- change the parent position and size
	self:left(left)
	self:top(top)
	self:width(right - left)
	self:height(bottom - top)
	-- adjust the children's positions
	for _, child in ipairs(self._children) do
		child:shift(-left, -top)
	end
end

function Element:drawSelf() end

function Element:stencil() end

function Element:draw(stencilValue)
	stencilValue = stencilValue or 0
	love.graphics.push 'all'
	love.graphics.translate(self.get.x(self), self.get.y(self))
	self:drawSelf()
	if self._children then
		-- if clipping is enabled, push a stencil to the "stack"
		if self._clip then
			stencilValue = stencilValue + 1
			love.graphics.push 'all'
			self._stencilFunction = self._stencilFunction or function()
				self:stencil()
			end
			love.graphics.stencil(self._stencilFunction, 'increment', 1, true)
			love.graphics.setStencilTest('gequal', stencilValue)
		end
		-- draw children
		for _, child in ipairs(self._children) do
			child:draw(stencilValue)
		end
		-- if clipping is enabled, pop a stencil from the "stack"
		if self._clip then
			love.graphics.stencil(self._stencilFunction, 'decrement', 1, true)
			love.graphics.pop()
		end
	end
	love.graphics.pop()
end

local Transform = newElementClass(Element)

Transform.preserve._transform = true

function Transform:new(x, y)
	self._x = x
	self._y = y
	self._transform = self._transform or love.math.newTransform()
	self._childrenLeft = 0
	self._childrenTop = 0
end

function Transform:_updateTransform()
	self._transform:reset()
	self._transform:rotate(self._angle or 0)
	self._transform:scale(self._scaleX or 1, self._scaleY or 1)
	self._transform:shear(self._shearX or 0, self._shearY or 0)
end

function Transform:_getTransformedChildrenBounds()
	if not (self._children and #self._children > 0) then return end
	local childrenLeft, childrenTop, childrenRight, childrenBottom = self.get.childrenBounds(self)
	local x1, y1 = self._transform:transformPoint(childrenLeft, childrenTop)
	local x2, y2 = self._transform:transformPoint(childrenRight, childrenTop)
	local x3, y3 = self._transform:transformPoint(childrenRight, childrenBottom)
	local x4, y4 = self._transform:transformPoint(childrenLeft, childrenBottom)
	local left = math.min(x1, x2, x3, x4)
	local top = math.min(y1, y2, y3, y4)
	local right = math.max(x1, x2, x3, x4)
	local bottom = math.max(y1, y2, y3, y4)
	return left, top, right, bottom
end

function Transform:_updateDimensions()
	if not (self._children and #self._children > 0) then return end
	local left, top, right, bottom = self:_getTransformedChildrenBounds()
	self._childrenLeft = left
	self._childrenTop = top
	self:width(right - left)
	self:height(bottom - top)
end

function Transform:angle(angle)
	self._angle = angle
	self:_updateTransform()
end

function Transform:scaleX(scale)
	self._scaleX = scale
	self:_updateTransform()
end

function Transform:scaleY(scale)
	self._scaleY = scale
	self:_updateTransform()
end

function Transform:scale(scaleX, scaleY)
	self._scaleX = scaleX
	self._scaleY = scaleY or scaleX
	self:_updateTransform()
end

function Transform:shearX(shear)
	self._shearX = shear
	self:_updateTransform()
end

function Transform:shearY(shear)
	self._shearY = shear
	self:_updateTransform()
end

function Transform:shear(shearX, shearY)
	self._shearX = shearX
	self._shearY = shearY or shearX
	self:_updateTransform()
end

function Transform:onEndChildren(...)
	self:_updateDimensions()
end

function Transform:draw(stencilValue)
	if not self._children then return end
	love.graphics.push 'all'
	love.graphics.translate(self.get.x(self), self.get.y(self))
	love.graphics.translate(-self._childrenLeft, -self._childrenTop)
	love.graphics.applyTransform(self._transform)
	for _, child in ipairs(self._children) do
		child:draw(stencilValue)
	end
	love.graphics.pop()
end

local Shape = newElementClass(Element)

function Shape:fillColor(r, g, b, a)
	self:setColor('_fillColor', r, g, b, a)
end

function Shape:outlineColor(r, g, b, a)
	self:setColor('_outlineColor', r, g, b, a)
end

function Shape:outlineWidth(width) self._outlineWidth = width end

function Shape:drawShape(mode) end

function Shape:stencil() self:drawShape 'fill' end

function Shape:drawSelf()
	love.graphics.push 'all'
	if self:isColorSet(self._fillColor) then
		love.graphics.setColor(self._fillColor)
		self:drawShape 'fill'
	end
	if self:isColorSet(self._outlineColor) then
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

local Image = newElementClass(Element)

function Image:new(image, x, y)
	self._image = image
	self._naturalWidth = image:getWidth()
	self._naturalHeight = image:getHeight()
	self._x = x
	self._y = y
	self._width = self._naturalWidth
	self._height = self._naturalHeight
end

function Image:scaleX(scale)
	self:width(self._naturalWidth * scale)
end

function Image:scaleY(scale)
	self:height(self._naturalHeight * scale)
end

function Image:scale(scaleX, scaleY)
	self:scaleX(scaleX)
	self:scaleY(scaleY or scaleX)
end

function Image:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
end

function Image:drawSelf()
	love.graphics.push 'all'
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	end
	love.graphics.draw(self._image, 0, 0, 0,
		self.get.width(self) / self._naturalWidth,
		self.get.height(self) / self._naturalHeight)
	love.graphics.pop()
end

local Text = newElementClass(Element)

function Text:new(font, text, x, y)
	self._font = font
	self._text = text
	self._naturalWidth = font:getWidth(text)
	self._naturalHeight = getTextHeight(font, text)
	self._x = x
	self._y = y
	self._width = self._naturalWidth
	self._height = self._naturalHeight
end

function Text:scaleX(scale)
	self:width(self._naturalWidth * scale)
end

function Text:scaleY(scale)
	self:height(self._naturalHeight * scale)
end

function Text:scale(scaleX, scaleY)
	self:scaleX(scaleX)
	self:scaleY(scaleY)
end

function Text:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
end

function Text:shadowColor(r, g, b, a)
	self:setColor('_shadowColor', r, g, b, a)
end

function Text:shadowOffsetX(offset)
	self._shadowOffsetX = offset
end

function Text:shadowOffsetY(offset)
	self._shadowOffsetY = offset
end

function Text:shadowOffset(offsetX, offsetY)
	self:shadowOffsetX(offsetX)
	self:shadowOffsetY(offsetY)
end

function Text:stencil()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	love.graphics.print(self._text, 0, 0, 0,
		self.get.width(self) / self._naturalWidth,
		self.get.height(self) / self._naturalHeight)
	love.graphics.pop()
end

function Text:drawSelf()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	if self:isColorSet(self._shadowColor) then
		love.graphics.setColor(self._shadowColor)
		love.graphics.print(self._text, (self._shadowOffsetX or 1), (self._shadowOffsetY or 1), 0,
			self.get.width(self) / self._naturalWidth,
			self.get.height(self) / self._naturalHeight)
	end
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.print(self._text, 0, 0, 0,
		self.get.width(self) / self._naturalWidth,
		self.get.height(self) / self._naturalHeight)
	love.graphics.pop()
end

local Paragraph = newElementClass(Element)

function Paragraph:new(font, text, limit, align, x, y)
	self._font = font
	self._text = text
	self._limit = limit
	self._align = align
	self._naturalWidth = limit
	self._naturalHeight = getParagraphHeight(font, text, limit)
	self._x = x
	self._y = y
	self._width = self._naturalWidth
	self._height = self._naturalHeight
end

function Paragraph:scaleX(scale)
	self:width(self._naturalWidth * scale)
end

function Paragraph:scaleY(scale)
	self:height(self._naturalHeight * scale)
end

function Paragraph:scale(scaleX, scaleY)
	self:scaleX(scaleX)
	self:scaleY(scaleY)
end

function Paragraph:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
end

function Paragraph:shadowColor(r, g, b, a)
	self:setColor('_shadowColor', r, g, b, a)
end

function Paragraph:shadowOffsetX(offset)
	self._shadowOffsetX = offset
end

function Paragraph:shadowOffsetY(offset)
	self._shadowOffsetY = offset
end

function Paragraph:shadowOffset(offsetX, offsetY)
	self:shadowOffsetX(offsetX)
	self:shadowOffsetY(offsetY)
end

function Paragraph:stencil()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	love.graphics.printf(self._text, 0, 0,
		self._limit, self._align, 0,
		self.get.width(self) / self._naturalWidth,
		self.get.height(self) / self._naturalHeight)
	love.graphics.pop()
end

function Paragraph:drawSelf()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	if self:isColorSet(self._shadowColor) then
		love.graphics.setColor(self._shadowColor)
		love.graphics.printf(self._text, (self._shadowOffsetX or 1), (self._shadowOffsetY or 1),
			self._limit, self._align, 0,
			self.get.width(self) / self._naturalWidth,
			self.get.height(self) / self._naturalHeight)
	end
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.printf(self._text, 0, 0,
		self._limit, self._align, 0,
		self.get.width(self) / self._naturalWidth,
		self.get.height(self) / self._naturalHeight)
	love.graphics.pop()
end

local elementClasses = {
	element = Element,
	transform = Transform,
	shape = Shape,
	rectangle = Rectangle,
	image = Image,
	text = Text,
	paragraph = Paragraph,
}

local Layout = {}

function Layout:__index(k)
	if Layout[k] then return Layout[k] end
	self._functionCache[k] = self._functionCache[k] or function(_, ...)
		local element = self:getElement '@current'
		element[k](element, ...)
		return self
	end
	return self._functionCache[k]
end

function Layout:_clearElement(element)
	for key, value in pairs(element) do
		if not element.preserve[key] then
			if type(value) == 'table' then
				for k in pairs(value) do value[k] = nil end
			else
				element[key] = nil
			end
		end
	end
end

function Layout:getElement(name)
	name = name or '@current'
	if type(name) == 'table' then return name end
	if name == '@current' then
		return self._groups[self._currentGroupIndex].current
	elseif name == '@previous' then
		return self._groups[self._currentGroupIndex].previous
	elseif name == '@parent' then
		return self._groups[self._currentGroupIndex].parent
	end
	return self._named[name]
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
	local group = self._groups[self._currentGroupIndex]
	if group.parent then
		group.parent:onAddChild(element)
	else
		table.insert(self._elements, element)
	end
	self:select(element)
	return self
end

function Layout:name(name)
	self._named[name] = self:getElement '@current'
	return self
end

function Layout:beginChildren(name, ...)
	local element = self:getElement(name)
	element:onBeginChildren(...)
	self._currentGroupIndex = self._currentGroupIndex + 1
	self._groups[self._currentGroupIndex] = self._groups[self._currentGroupIndex] or {}
	local group = self._groups[self._currentGroupIndex]
	for k in pairs(group) do group[k] = nil end
	group.parent = element
	return self
end

function Layout:endChildren(...)
	local group = self._groups[self._currentGroupIndex]
	group.parent:onEndChildren(...)
	self._currentGroupIndex = self._currentGroupIndex - 1
	return self
end

function Layout:draw()
	-- draw each element and remove it from the tree
	for elementIndex, element in ipairs(self._elements) do
		element:draw()
		self._elements[elementIndex] = nil
	end
	-- mark all elements as unused
	for _, element in ipairs(self._elementPool) do
		element._used = false
	end
	-- clear named elements
	for name in pairs(self._named) do self._named[name] = nil end
	return self
end

function charm.new()
	return setmetatable({
		_elementPool = {},
		_elements = {},
		_groups = {{}},
		_currentGroupIndex = 1,
		_named = {},
		_functionCache = {},
	}, Layout)
end

return charm
