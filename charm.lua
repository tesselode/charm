local charm = {}

-- gets the error level needed to make an error appear
-- in the user's code, not the library code
local function getUserErrorLevel()
	local source = debug.getinfo(1).source
	local level = 1
	while debug.getinfo(level).source == source do
		level = level + 1
	end
	--[[
		we return level - 1 here and not just level
		because the level was calculated one function
		deeper than the function that will actually
		use this value. if we produced an error *inside*
		this function, level would be correct, but
		for the function calling this function, level - 1
		is correct.
	]]
	return level - 1
end

-- gets the name of the function that the user called
-- that eventually caused an error
local function getUserCalledFunctionName()
	return debug.getinfo(getUserErrorLevel() - 1).name
end

local function checkCondition(condition, message)
	if condition then return end
	error(message, getUserErrorLevel())
end

-- changes a list of types into a human-readable phrase
-- i.e. string, table, number -> "string, table, or number"
local function getAllowedTypesText(...)
	local numberOfArguments = select('#', ...)
	if numberOfArguments >= 3 then
		local text = ''
		for i = 1, numberOfArguments - 1 do
			text = text .. string.format('%s, ', select(i, ...))
		end
		text = text .. string.format('or %s', select(numberOfArguments, ...))
		return text
	elseif numberOfArguments == 2 then
		return string.format('%s or %s', select(1, ...), select(2, ...))
	end
	return select(1, ...)
end

-- checks if an argument is of the correct type, and if not,
-- throws a "bad argument" error consistent with the ones
-- lua and love produce
local function checkArgument(argumentIndex, argument, ...)
	for i = 1, select('#', ...) do
		if type(argument) == select(i, ...) then
			return
		end
	end
	error(
		string.format(
			"bad argument #%i to '%s' (expected %s, got %s)",
			argumentIndex,
			getUserCalledFunctionName(),
			getAllowedTypesText(...),
			type(argument)
		),
		getUserErrorLevel()
	)
end

local function checkOptionalArgument(argumentIndex, argument, ...)
	if argument == nil then return end
	checkArgument(argumentIndex, argument, ...)
end

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
		get = setmetatable({}, {
			__index = parent and parent.get,
			__call = function(_, self, propertyName, ...)
				return self.get[propertyName](self, ...)
			end
		}),
		preserve = setmetatable({}, {__index = parent and parent.preserve}),
	}
	class.__index = class
	setmetatable(class, {__index = parent})
	return class
end

--[[
	A note on how data is managed in Charm:

	Charm aims to be as memory-efficient as possible. You'll
	see a couple of principles throughout the code:
	- Tables are only created when they're first needed
	- Tables are cleared out and reused whenever possible

	This is how the Layout class is able to recreate the
	element tree every frame without creating a lot of
	garbage - a pool of previously created element tables
	is kept around, and when a frame is finished, they're
	cleared out and reused. Nested tables are also
	cleared out one level deep.

	What this means for the code for element classes:
	- We cannot rely on a value still being there next frame
	(unless the key is listed in the preserve table)
	- We treat empty tables or nonexistent tables as being "unset"
]]
local Element = newElementClass()

Element.preserve._stencilFunction = true

function Element:new(x, y, width, height)
	checkOptionalArgument(2, x, 'number')
	checkOptionalArgument(3, y, 'number')
	checkOptionalArgument(4, width, 'number')
	checkOptionalArgument(5, height, 'number')
	self._x = x
	self._y = y
	self._width = width
	self._height = height
end

function Element:setColor(propertyName, r, g, b, a)
	checkArgument(1, r, 'number', 'table')
	checkOptionalArgument(2, g, 'number')
	checkOptionalArgument(3, b, 'number')
	checkOptionalArgument(4, a, 'number')
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

function Element.get:x(origin)
	checkOptionalArgument(3, origin, 'number')
	origin = origin or 0
	return (self._x or 0) + self:get 'width' * origin
end

function Element.get:left() return self:get('x', 0) end
function Element.get:centerX() return self:get('x', .5) end
function Element.get:right() return self:get('x', 1) end

function Element.get:y(origin)
	checkOptionalArgument(3, origin, 'number')
	origin = origin or 0
	return (self._y or 0) + self:get 'height' * origin
end

function Element.get:top() return self:get('y', 0) end
function Element.get:centerY() return self:get('y', .5) end
function Element.get:bottom() return self:get('y', 1) end

function Element.get:width() return self._width or 0 end
function Element.get:height() return self._height or 0 end

function Element.get:size()
	return self:get 'width', self:get 'height'
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

function Element:x(x, origin)
	checkArgument(1, x, 'number')
	checkOptionalArgument(2, origin, 'number')
	origin = origin or 0
	self._originX = origin
	self._x = x - self:get 'width' * origin
end

function Element:left(x) self:x(x, 0) end
function Element:centerX(x) self:x(x, .5) end
function Element:right(x) self:x(x, 1) end

function Element:y(y, origin)
	checkArgument(1, y, 'number')
	checkOptionalArgument(2, origin, 'number')
	origin = origin or 0
	self._originY = origin
	self._y = y - self:get 'height' * origin
end

function Element:top(y) self:y(y, 0) end
function Element:centerY(y) self:y(y, .5) end
function Element:bottom(y) self:y(y, 1) end

function Element:shift(dx, dy)
	checkOptionalArgument(1, dx, 'number')
	checkOptionalArgument(2, dy, 'number')
	self._x = self:get 'x' + (dx or 0)
	self._y = self:get 'y' + (dy or 0)
end

function Element:width(width)
	checkArgument(1, width, 'number')
	local origin = self._originX or 0
	local x = self:get('x', origin)
	self._width = width
	self:x(x, origin)
end

function Element:height(height)
	checkArgument(1, height, 'number')
	local origin = self._originY or 0
	local y = self:get('y', origin)
	self._height = height
	self:y(y, origin)
end

function Element:size(width, height)
	self:width(width)
	self:height(height)
end

function Element:bounds(left, top, right, bottom)
	checkArgument(1, left, 'number')
	checkArgument(2, top, 'number')
	checkArgument(3, right, 'number')
	checkArgument(4, bottom, 'number')
	self._x = left
	self._y = top
	self._width = right - left
	self._height = bottom - top
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
	checkOptionalArgument(1, dx, 'number')
	checkOptionalArgument(2, dy, 'number')
	if not self._children then return end
	for _, child in ipairs(self._children) do
		child:shift(dx, dy)
	end
end

function Element:padLeft(padding)
	checkArgument(1, padding, 'number')
	self._x = self:get 'x' - padding
	self:shiftChildren(padding, 0)
	self._width = self:get 'width' + padding
end

function Element:padTop(padding)
	checkArgument(1, padding, 'number')
	self._y = self:get 'y' - padding
	self:shiftChildren(0, padding)
	self._height = self:get 'height' + padding
end

function Element:padRight(padding)
	checkArgument(1, padding, 'number')
	self._width = self:get 'width' + padding
end

function Element:padBottom(padding)
	checkArgument(1, padding, 'number')
	self._height = self:get 'height' + padding
end

function Element:padX(padding)
	checkArgument(1, padding, 'number')
	self:padLeft(padding)
	self:padRight(padding)
end

function Element:padY(padding)
	checkArgument(1, padding, 'number')
	self:padTop(padding)
	self:padBottom(padding)
end

function Element:pad(padding)
	checkArgument(1, padding, 'number')
	self:padX(padding)
	self:padY(padding)
end

function Element:expand()
	if not self._children then return end
	local childrenLeft, childrenTop, childrenRight, childrenBottom = self:get 'childrenBounds'
	local left = math.min(self:get 'left', childrenLeft)
	local top = math.min(self:get 'top', childrenTop)
	local right = math.max(self:get 'right', childrenRight)
	local bottom = math.max(self:get 'bottom', childrenBottom)
	self:shiftChildren(self:get 'left' - left, self:get 'top' - top)
	self:bounds(left, top, right, bottom)
end

function Element:wrap()
	if not self._children then return end
	local left, top, right, bottom = self:get 'childrenBounds'
	self:shiftChildren(-left, -top)
	self:bounds(left, top, right, bottom)
end

function Element:drawSelf() end

function Element:stencil() end

function Element:render(ui) end

function Element:draw(stencilValue)
	stencilValue = stencilValue or 0
	love.graphics.push 'all'
	love.graphics.translate(self:get 'x', self:get 'y')
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

--[[
	Transform elements do two things:
	- Apply an arbitrary transformation to a set of child elements
	- Make a bounding box around the transformed child elements

	When the scaling, shearing, or angle are changed or new children
	are added, the transform element takes the following steps:
	1. Get the rectangle around the children pre-transformation, including
	any empty space above or to the left of the children
	2. Get the corners of the rectangle
	3. Transform each of those points
	4. Make a new rectangle that contains the transformed points
	5. Move and resize the transform element to match that rectangle
	6. Set some variables to translate the children in the drawing phase
	to compensate for the transform element's changed position (note
	that this translation has to happen after the scaling/shearing/rotating,
	otherwise the post-transform bounds of the children would change again.
	This is also why we don't change the position of the children elements
	using shiftChildren.)
]]
local Transform = newElementClass(Element)

Transform.preserve._transform = true

function Transform:new(x, y)
	self._x = x
	self._y = y
	self._transform = self._transform or love.math.newTransform()
	self._transform:reset()
	self._childrenShiftX = 0
	self._childrenShiftY = 0
end

function Transform:_getTransformedChildrenBounds()
	if not (self._children and #self._children > 0) then return end
	local childrenLeft, childrenTop, childrenRight, childrenBottom = self:get 'childrenBounds'
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
	left = math.min(left, 0)
	top = math.min(top, 0)
	self:shift(left, top)
	--[[
		I'm not sure why I have to shift the children twice as much
		as the amount the transform element moved. I would think that
		1x would be correct...if you understand this better than I do,
		please let me know.
	]]
	self._childrenShiftX = left * 2
	self._childrenShiftY = top * 2
	self:width(right - left)
	self:height(bottom - top)
end

function Transform:_updateTransform()
	self._transform:reset()
	self._transform:rotate(self._angle or 0)
	self._transform:scale(self._scaleX or 1, self._scaleY or 1)
	self._transform:shear(self._shearX or 0, self._shearY or 0)
	self:_updateDimensions()
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
	love.graphics.translate(self:get 'x', self:get 'y')
	love.graphics.translate(-self._childrenShiftX, -self._childrenShiftY)
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
	love.graphics.rectangle(mode, 0, 0, self:get 'width', self:get 'height',
		self._cornerRadiusX, self._cornerRadiusY, self._cornerSegments)
end

local Ellipse = newElementClass(Shape)

function Ellipse:segments(segments) self._segments = segments end

function Ellipse:drawShape(mode)
	love.graphics.ellipse(mode,
		self:get 'width' / 2, self:get 'height' / 2,
		self:get 'width' / 2, self:get 'height' / 2,
		self._segments)
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
		self:get 'width' / self._naturalWidth,
		self:get 'height' / self._naturalHeight)
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
		self:get 'width' / self._naturalWidth,
		self:get 'height' / self._naturalHeight)
	love.graphics.pop()
end

function Text:drawSelf()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	if self:isColorSet(self._shadowColor) then
		love.graphics.setColor(self._shadowColor)
		love.graphics.print(self._text, (self._shadowOffsetX or 1), (self._shadowOffsetY or 1), 0,
			self:get 'width' / self._naturalWidth,
			self:get 'height' / self._naturalHeight)
	end
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.print(self._text, 0, 0, 0,
		self:get 'width' / self._naturalWidth,
		self:get 'height' / self._naturalHeight)
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
		self:get 'width' / self._naturalWidth,
		self:get 'height' / self._naturalHeight)
	love.graphics.pop()
end

function Paragraph:drawSelf()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	if self:isColorSet(self._shadowColor) then
		love.graphics.setColor(self._shadowColor)
		love.graphics.printf(self._text, (self._shadowOffsetX or 1), (self._shadowOffsetY or 1),
			self._limit, self._align, 0,
			self:get 'width' / self._naturalWidth,
			self:get 'height' / self._naturalHeight)
	end
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.printf(self._text, 0, 0,
		self._limit, self._align, 0,
		self:get 'width' / self._naturalWidth,
		self:get 'height' / self._naturalHeight)
	love.graphics.pop()
end

local elementClasses = {
	element = Element,
	transform = Transform,
	shape = Shape,
	rectangle = Rectangle,
	ellipse = Ellipse,
	image = Image,
	text = Text,
	paragraph = Paragraph,
}

local function validateElementClass(class)
	checkArgument(1, class, 'string', 'table')
	if type(class) == 'string' then
		checkCondition(elementClasses[class], string.format("no built-in element class called '%s'", class))
	end
end

local Layout = {}

function Layout:__index(k)
	if Layout[k] then return Layout[k] end
	self._functionCache[k] = self._functionCache[k] or function(_, ...)
		local element = self:getElement '@current'
		checkCondition(element, string.format("no element to call function '%s' on", k))
		checkCondition(element[k], string.format("currently selected element has no function '%s'", k))
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

function Layout:_validateElement(name, additionalText)
	checkArgument(1, name, 'string', 'table')
	local element = self:getElement(name)
	local message = name == '@current' and 'No element is currently selected. Have you created any elements yet?'
		or name == '@previous' and 'no previous element to get'
		or name == '@parent' and 'No parent element to get. This keyword should be used '
			.. 'within layout:beginChildren() and layout:endChildren() calls.'
		or string.format("no element named '%s'", name)
	if additionalText then
		message = message .. additionalText
	end
	checkCondition(element, message)
end

function Layout:getElement(name)
	checkOptionalArgument(1, name, 'string', 'table')
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
	self:_validateElement(elementName, '\n\nThis function is for getting properties of elements. '
		.. 'If you meant to get the element itself, use layout.getElement.')
	checkArgument(2, propertyName, 'string')
	local element = self:getElement(elementName)
	checkCondition(element.get[propertyName], string.format("element has no property named '%s'", propertyName))
	return element.get[propertyName](element, ...)
end

function Layout:select(name)
	self:_validateElement(name)
	local element = self:getElement(name)
	local group = self._groups[self._currentGroupIndex]
	group.previous = group.current
	group.current = element
	return self
end

function Layout:add(element)
	checkArgument(1, element, 'table')
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

function Layout:new(elementClass, ...)
	validateElementClass(elementClass)
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
	self:add(element)
	return self
end

function Layout:name(name)
	checkArgument(1, name, 'string')
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
	-- allow each element to render new elements
	for _, element in ipairs(self._elements) do
		self:beginChildren(element)
		element:render(self)
		self:endChildren()
	end
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

function charm.extend(parent)
	validateElementClass(parent)
	if type(parent) == 'string' then parent = elementClasses[parent] end
	parent = parent or elementClasses.element
	return newElementClass(parent)
end

return charm
