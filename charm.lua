--- Layout library for LÖVE.
local charm = {
	_VERSION = 'charm',
	_DESCRIPTION = 'Layout library for LÖVE.',
	_LICENSE = [[
		MIT License

		Copyright (c) 2020 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

-- gets the type of a value
-- also works with LOVE types
local function getType(value)
	return type(value) == 'userdata' and value.type and value:type() or type(value)
end

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
		if getType(argument) == select(i, ...) then return end
	end
	error(
		string.format(
			"bad argument #%i to '%s' (expected %s, got %s)",
			argumentIndex,
			getUserCalledFunctionName(),
			getAllowedTypesText(...),
			getType(argument)
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

local function sortChildren(a, b)
	return a:get 'z' < b:get 'z'
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

--- The base class for all elements.
-- @type Element
local Element = newElementClass()

--- A list of keys that should not be niled out at the end of a draw frame.
-- @table preserve
Element.preserve._stencilFunction = true

--- Initializes the element.
-- @number[opt=0] x the x position of the element
-- @number[opt=0] y the y position of the element
-- @number[opt=0] width the width of the element
-- @number[opt=0] height the height of the element
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

--- Returns whether the element has any children.
-- @treturn boolean
function Element:hasChildren()
	return self._children and #self._children > 0
end

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
	if type(r) ~= 'table' then
		checkArgument(1, r, 'number', 'table')
		checkArgument(2, g, 'number')
		checkArgument(3, b, 'number')
		checkOptionalArgument(4, a, 'number')
	end
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

--- Gets the x position of the element.
-- @number[opt=0] origin the origin to get the x position with respect to. 0 = left, .5 = center, 1 = right
-- @treturn number
function Element.get:x(origin)
	checkOptionalArgument(3, origin, 'number')
	origin = origin or 0
	return (self._x or 0) + self:get 'width' * origin
end

--- Gets the x position of the left edge of the element.
-- @treturn number
function Element.get:left() return self:get('x', 0) end

--- Gets the x position of the horizontal center of the element.
-- @treturn number
function Element.get:centerX() return self:get('x', .5) end

--- Gets the x position of the right edge of the element.
-- @treturn number
function Element.get:right() return self:get('x', 1) end

--- Gets the y position of the element.
-- @number[opt=0] origin the origin to get the y position with respect to. 0 = top, .5 = center, 1 = bottom
-- @treturn number
function Element.get:y(origin)
	checkOptionalArgument(3, origin, 'number')
	origin = origin or 0
	return (self._y or 0) + self:get 'height' * origin
end

--- Gets the y position of the top of the element.
-- @treturn number
function Element.get:top() return self:get('y', 0) end

--- Gets the y position of the vertical center of the element.
-- @treturn number
function Element.get:centerY() return self:get('y', .5) end

--- Gets the y position of the bottom of the element.
-- @treturn number
function Element.get:bottom() return self:get('y', 1) end

--- Gets the z position of the element.
-- @treturn number
function Element.get:z() return self._z or 0 end

--- Gets the width of the element.
-- @treturn number
function Element.get:width() return self._width or 0 end

--- Gets the height of the element.
-- @treturn number
function Element.get:height() return self._height or 0 end

--- Gets the width and height of the element.
-- @treturn number the width of the element
-- @treturn number the height of the element
function Element.get:size()
	return self:get 'width', self:get 'height'
end

--- Gets the bounds of the rectangle surrounding all of
-- the elements children (relative to the top-left corner
-- of the element).
-- @treturn number the left bound of the children
-- @treturn number the top bound of the children
-- @treturn number the right bound of the children
-- @treturn number the bottom bound of the children
function Element.get:childrenBounds()
	if not self:hasChildren() then return end
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

--- Sets the x position of the element.
-- @number x the new x position of the element
-- @number[opt=0] origin the origin to set the position with respect to. 0 = left, .5 = center, 1 = right
function Element:x(x, origin)
	checkArgument(1, x, 'number')
	checkOptionalArgument(2, origin, 'number')
	origin = origin or 0
	self._originX = origin
	self._x = x - self:get 'width' * origin
end

--- Moves the left edge of the element to the specified x position.
-- @number x
function Element:left(x) self:x(x, 0) end

--- Moves the horizontal center of the element to the specified x position.
-- @number x
function Element:centerX(x) self:x(x, .5) end

--- Moves the right edge of the element to the specified x position.
-- @number x
function Element:right(x) self:x(x, 1) end

--- Sets the y position of the element.
-- @number y the new y position of the element
-- @number[opt=0] origin the origin to set the position with respect to. 0 = top, .5 = center, 1 = bottom
function Element:y(y, origin)
	checkArgument(1, y, 'number')
	checkOptionalArgument(2, origin, 'number')
	origin = origin or 0
	self._originY = origin
	self._y = y - self:get 'height' * origin
end

--- Moves the top of the element to the specified y position.
-- @number y
function Element:top(y) self:y(y, 0) end

--- Moves the vertical center of the element to the specified y position.
-- @number y
function Element:centerY(y) self:y(y, .5) end

--- Moves the bottom of the element to the specified y position.
-- @number y
function Element:bottom(y) self:y(y, 1) end

--- Sets the z position of the element.
-- @number z
function Element:z(z) self._z = z end

--- Moves the element.
-- @number dx the amount to move the element horizontally
-- @number dy the amount to move the element vertically
function Element:shift(dx, dy)
	checkOptionalArgument(1, dx, 'number')
	checkOptionalArgument(2, dy, 'number')
	self._x = self:get 'x' + (dx or 0)
	self._y = self:get 'y' + (dy or 0)
end

--- Sets the width of the element.
-- @number width
function Element:width(width)
	checkArgument(1, width, 'number')
	local origin = self._originX or 0
	local x = self:get('x', origin)
	self._width = width
	self:x(x, origin)
end

--- Sets the height of the element.
-- @number height
function Element:height(height)
	checkArgument(1, height, 'number')
	local origin = self._originY or 0
	local y = self:get('y', origin)
	self._height = height
	self:y(y, origin)
end

--- Sets the width and height of the element.
-- @number width
-- @number height
function Element:size(width, height)
	self:width(width)
	self:height(height)
end

--- Sets the element's position and size to match the specified bounds.
-- @number left
-- @number top
-- @number right
-- @number bottom
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

--- Enables clipping for this element, meaning that children will be cropped
-- to the visible area of the element.
function Element:clip()
	self._clip = true
end

--- Adds a child to the element.
-- @tparam Element child
function Element:addChild(child)
	self._children = self._children or {}
	table.insert(self._children, child)
end

--- Called when a @{Layout} starts assigning children to this element.
-- @param ... additional arguments passed to layout.beginChildren
function Element:onBeginChildren(...) end

--- Called when a @{Layout} adds a child to this element.
-- @tparam Element child the child to add
function Element:onAddChild(child)
	self:addChild(child)
end

--- Called when a @{Layout} stops assigning children to this element.
-- @param ... additional arguments passed to layout.endChildren
function Element:onEndChildren(...) end

--- Moves the element's children.
-- @number dx the amount to move the children horizontally
-- @number dy the amount to move the children vertically
function Element:shiftChildren(dx, dy)
	checkOptionalArgument(1, dx, 'number')
	checkOptionalArgument(2, dy, 'number')
	if not self:hasChildren() then return end
	for _, child in ipairs(self._children) do
		child:shift(dx, dy)
	end
end

--- Expands the element to the left. Children's positions
-- will be adjusted as necessary to maintain their position
-- on screen.
-- @number padding the amount to expand the element
function Element:padLeft(padding)
	checkArgument(1, padding, 'number')
	self._x = self:get 'x' - padding
	self:shiftChildren(padding, 0)
	self._width = self:get 'width' + padding
end

--- Expands the element upward. Children's positions
-- will be adjusted as necessary to maintain their position
-- on screen.
-- @number padding the amount to expand the element
function Element:padTop(padding)
	checkArgument(1, padding, 'number')
	self._y = self:get 'y' - padding
	self:shiftChildren(0, padding)
	self._height = self:get 'height' + padding
end

--- Expands the element to the right.
-- @number padding the amount to expand the element
function Element:padRight(padding)
	checkArgument(1, padding, 'number')
	self._width = self:get 'width' + padding
end

--- Expands the element downward.
-- @number padding the amount to expand the element
function Element:padBottom(padding)
	checkArgument(1, padding, 'number')
	self._height = self:get 'height' + padding
end

--- Expands the element equally to the left and right.
-- Children's positions will be adjusted as necessary to
-- maintain their position on screen.
-- @number padding the amount to expand the element
function Element:padX(padding)
	checkArgument(1, padding, 'number')
	self:padLeft(padding)
	self:padRight(padding)
end

--- Expands the element equally upwards and downwards.
-- Children's positions will be adjusted as necessary to
-- maintain their position on screen.
-- @number padding the amount to expand the element
function Element:padY(padding)
	checkArgument(1, padding, 'number')
	self:padTop(padding)
	self:padBottom(padding)
end

--- Expands the element on all sides.
-- Children's positions will be adjusted as necessary to
-- maintain their position on screen.
-- @number padding the amount to expand the element
function Element:pad(padding)
	checkArgument(1, padding, 'number')
	self:padX(padding)
	self:padY(padding)
end

--- Grows an element until it contains all of its children.
-- The children's positions will be adjusted as necessary
-- to maintain the same position on screen.
function Element:expand()
	if not self:hasChildren() then return end
	local left, top, right, bottom = self:get 'childrenBounds'
	left = math.min(left, 0)
	top = math.min(top, 0)
	right = math.max(right, self:get 'width')
	bottom = math.max(bottom, self:get 'height')
	self:shiftChildren(-left, -top)
	self:shift(left, top)
	self._width = right - left
	self._height = bottom - top
end

--- Adjusts the element's dimensions so that it perfectly
-- surrounds its children. The children's positions will be
-- adjusted to maintain the same position on screen.
function Element:wrap()
	if not self:hasChildren() then return end
	local left, top, right, bottom = self:get 'childrenBounds'
	self:shiftChildren(-left, -top)
	self:shift(left, top)
	self._width = right - left
	self._height = bottom - top
end

--- Called before drawing the element's children.
function Element:drawBottom() end

--- Called after drawing the element's children.
function Element:drawTop() end

--- Defines the area to crop the element's children to
-- if clipping is enabled.
function Element:stencil() end

--- Draws the element. In most cases, you won't need
-- to manually call this function or override it in
-- custom element classes.
-- @number stencilValue the pixel value to use to mask the
-- element. This should increase by 1 for every nested
-- child element.
function Element:draw(stencilValue)
	stencilValue = stencilValue or 0
	love.graphics.push 'all'
	love.graphics.translate(self:get 'x', self:get 'y')
	self:drawBottom()
	if self._children then
		-- sort children
		if #self._children > 1 then
			table.sort(self._children, sortChildren)
		end
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
	self:drawTop()
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

--- Applies arbitrary transformations to child elements.
--
-- Extends the @{Element} class.
-- @type Transform
local Transform = newElementClass(Element)

Transform.preserve._transform = true

--- Initializes the element.
-- @number x the horizontal position of the transform
-- @number y the vertical position of the transform
function Transform:new(x, y)
	checkOptionalArgument(2, x, 'number')
	checkOptionalArgument(3, y, 'number')
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
	self._childrenShiftX = left
	self._childrenShiftY = top
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

--- Sets the angle of the transform.
-- @number angle
function Transform:angle(angle)
	checkArgument(1, angle, 'number')
	self._angle = angle
	self:_updateTransform()
end

--- Sets the horizontal scaling factor of the transform.
-- @number scale
function Transform:scaleX(scale)
	checkArgument(1, scale, 'number')
	self._scaleX = scale
	self:_updateTransform()
end

--- Sets the vertical scaling factor of the transform.
-- @number scale
function Transform:scaleY(scale)
	checkArgument(1, scale, 'number')
	self._scaleY = scale
	self:_updateTransform()
end

--- Sets the horizontal and vertical scaling factor of the transform.
-- @number scaleX
-- @number[opt=scaleX] scaleY
function Transform:scale(scaleX, scaleY)
	checkArgument(1, scaleX, 'number')
	checkOptionalArgument(2, scaleY, 'number')
	self._scaleX = scaleX
	self._scaleY = scaleY or scaleX
	self:_updateTransform()
end

--- Sets the horizontal shearing factor of the transform.
-- @number shear
function Transform:shearX(shear)
	checkArgument(1, shear, 'number')
	self._shearX = shear
	self:_updateTransform()
end

--- Sets the vertical shearing factor of the transform.
-- @number shear
function Transform:shearY(shear)
	checkArgument(1, shear, 'number')
	self._shearY = shear
	self:_updateTransform()
end

--- Sets the horizontal and vertical shearing factor of the transform.
-- @number shearX
-- @number[opt=shearX] shearY
function Transform:shear(shearX, shearY)
	checkArgument(1, shearX, 'number')
	checkOptionalArgument(2, shearY, 'number')
	self._shearX = shearX
	self._shearY = shearY or shearX
	self:_updateTransform()
end

function Transform:onEndChildren(...)
	self:_updateDimensions()
end

function Transform:draw(stencilValue)
	if not self:hasChildren() then return end
	love.graphics.push 'all'
	love.graphics.translate(self:get 'x', self:get 'y')
	love.graphics.translate(-self._childrenShiftX, -self._childrenShiftY)
	love.graphics.applyTransform(self._transform)
	for _, child in ipairs(self._children) do
		child:draw(stencilValue)
	end
	love.graphics.pop()
end

--- A base class for elements that draw love.graphics
-- primitives with a fill color and an outline color.
-- This class isn't useful on its own; it's meant to be
-- extended by custom classes.
--
-- Extends the @{Element} class.
-- @type Shape
local Shape = newElementClass(Element)

--- Sets the fill color of the shape.
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Shape:fillColor(r, g, b, a)
	self:setColor('_fillColor', r, g, b, a)
end

--- Sets the outline color of the shape.
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Shape:outlineColor(r, g, b, a)
	self:setColor('_outlineColor', r, g, b, a)
end

--- Sets the width of the shape's outline.
-- @number width
function Shape:outlineWidth(width)
	checkArgument(1, width, 'number')
	self._outlineWidth = width
end

--- Draws the shape. Override this to define how the shape
-- will be drawn.
-- @string mode the drawing mode for the shape. Will be either
-- "fill" or "line".
function Shape:drawShape(mode) end

function Shape:stencil() self:drawShape 'fill' end

function Shape:drawBottom()
	love.graphics.push 'all'
	if self:isColorSet(self._fillColor) then
		love.graphics.setColor(self._fillColor)
		self:drawShape 'fill'
	end
	love.graphics.pop()
end

function Shape:drawTop()
	love.graphics.push 'all'
	if self:isColorSet(self._outlineColor) then
		love.graphics.setColor(self._outlineColor)
		if self._outlineWidth then
			love.graphics.setLineWidth(self._outlineWidth)
		end
		self:drawShape 'line'
	end
	love.graphics.pop()
end

--- Draws a rectangle.
--
-- Extends the @{Shape} class.
-- @type Rectangle
local Rectangle = newElementClass(Shape)

--- Sets the radius of the corners of the rectangle.
-- @number radiusX the horizontal radius
-- @number[opt=radiusX] radiusY the vertical radius
function Rectangle:cornerRadius(radiusX, radiusY)
	checkArgument(1, radiusX, 'number')
	checkOptionalArgument(2, radiusY, 'number')
	self._cornerRadiusX = radiusX
	self._cornerRadiusY = radiusY or radiusX
end

--- Sets the number of segments used to draw the corners.
-- @number segments
function Rectangle:cornerSegments(segments)
	checkArgument(1, segments, 'number')
	self._cornerSegments = segments
end

function Rectangle:drawShape(mode)
	love.graphics.rectangle(mode, 0, 0, self:get 'width', self:get 'height',
		self._cornerRadiusX, self._cornerRadiusY, self._cornerSegments)
end

--- Draws an ellipse.
--
-- Extends the @{Shape} class.
-- @type Ellipse
local Ellipse = newElementClass(Shape)

--- Sets the number of segments used to draw the ellipse.
-- @number segments
function Ellipse:segments(segments)
	checkArgument(1, segments, 'number')
	self._segments = segments
end

function Ellipse:drawShape(mode)
	love.graphics.ellipse(mode,
		self:get 'width' / 2, self:get 'height' / 2,
		self:get 'width' / 2, self:get 'height' / 2,
		self._segments)
end

--- Draws an image.
--
-- Extends the @{Element} class.
-- @type Image
local Image = newElementClass(Element)

--- Initializes the image.
-- @tparam Image image the image to use
-- @number x the horizontal position of the image
-- @number y the vertical position of the image
function Image:new(image, x, y)
	checkArgument(2, image, 'Image')
	checkOptionalArgument(3, x, 'number')
	checkOptionalArgument(4, y, 'number')
	self._image = image
	self._naturalWidth = image:getWidth()
	self._naturalHeight = image:getHeight()
	self._x = x
	self._y = y
	self._width = self._naturalWidth
	self._height = self._naturalHeight
end

--- Sets the width of the image relative to its original width.
-- @number scale
function Image:scaleX(scale)
	checkArgument(1, scale, 'number')
	self:width(self._naturalWidth * scale)
end

--- Sets the height of the image relative to its original width.
-- @number scale
function Image:scaleY(scale)
	checkArgument(1, scale, 'number')
	self:height(self._naturalHeight * scale)
end

--- Sets the width and height of the image relative to its original dimensions.
-- @number scaleX
-- @number[opt=scaleX] scaleY
function Image:scale(scaleX, scaleY)
	checkArgument(1, scaleX, 'number')
	checkOptionalArgument(2, scaleY, 'number')
	self:scaleX(scaleX)
	self:scaleY(scaleY or scaleX)
end

--- Sets the blend color of the image.
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Image:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
end

function Image:drawBottom()
	love.graphics.push 'all'
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	end
	love.graphics.draw(self._image, 0, 0, 0,
		self:get 'width' / self._naturalWidth,
		self:get 'height' / self._naturalHeight)
	love.graphics.pop()
end

--- Draws text.
--
-- Extends the @{Element} class.
-- @type Text
local Text = newElementClass(Element)

--- Initializes the text.
-- @tparam Font font the font to use
-- @string text the text to draw
-- @number x the horizontal position of the text
-- @number y the vertical position of the text
function Text:new(font, text, x, y)
	checkArgument(2, font, 'Font')
	checkArgument(3, text, 'string')
	checkOptionalArgument(4, x, 'number')
	checkOptionalArgument(5, y, 'number')
	self._font = font
	self._text = text
	self._naturalWidth = font:getWidth(text)
	self._naturalHeight = getTextHeight(font, text)
	self._x = x
	self._y = y
	self._width = self._naturalWidth
	self._height = self._naturalHeight
end

--- Sets the width of the text relative to its original width.
-- @number scale
function Text:scaleX(scale)
	checkArgument(1, scale, 'number')
	self:width(self._naturalWidth * scale)
end

--- Sets the height of the text relative to its original width.
-- @number scale
function Text:scaleY(scale)
	checkArgument(1, scale, 'number')
	self:height(self._naturalHeight * scale)
end

--- Sets the width and height of the text relative to its original dimensions.
-- @number scaleX
-- @number[opt=scaleX] scaleY
function Text:scale(scaleX, scaleY)
	checkArgument(1, scaleX, 'number')
	checkOptionalArgument(2, scaleY, 'number')
	self:scaleX(scaleX)
	self:scaleY(scaleY or scaleX)
end

--- Sets the color of the text.
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Text:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
end

--- Sets the color of the text's shadow.
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Text:shadowColor(r, g, b, a)
	self:setColor('_shadowColor', r, g, b, a)
end

--- Sets the horizontal offset of the text's shadow.
-- @number offset
function Text:shadowOffsetX(offset)
	checkArgument(1, offset, 'number')
	self._shadowOffsetX = offset
end

--- Sets the vertical offset of the text's shadow.
-- @number offset
function Text:shadowOffsetY(offset)
	checkArgument(1, offset, 'number')
	self._shadowOffsetY = offset
end

--- Sets the horizontal and vertical offset of the text's shadow.
-- @number offsetX
-- @number[opt=offsetX] offsetY
function Text:shadowOffset(offsetX, offsetY)
	checkArgument(1, offsetX, 'number')
	checkOptionalArgument(2, offsetY, 'number')
	self:shadowOffsetX(offsetX)
	self:shadowOffsetY(offsetY or offsetX)
end

function Text:stencil()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	love.graphics.print(self._text, 0, 0, 0,
		self:get 'width' / self._naturalWidth,
		self:get 'height' / self._naturalHeight)
	love.graphics.pop()
end

function Text:drawBottom()
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

--- Draws a paragraph of text. In contrast to the @{Text}
-- element, this element automatically inserts line breaks
-- to stay within a certain width. It also supports
-- different align modes.
--
-- Extends the @{Element} class.
-- @type Paragraph
local Paragraph = newElementClass(Element)

--- Initializes the paragraph.
-- @tparam Font font the font to use
-- @string text the text to draw
-- @number limit the amount of horizontal space the text
-- can span before a line break occurs
-- @string align how to align the text. Can be "left", "center", "right", or "justify".
-- @number x the horizontal position of the paragraph
-- @number y the vertical position of the paragraph
function Paragraph:new(font, text, limit, align, x, y)
	checkArgument(2, font, 'Font')
	checkArgument(3, text, 'string')
	checkArgument(4, limit, 'number')
	checkOptionalArgument(5, align, 'string')
	checkOptionalArgument(6, x, 'number')
	checkOptionalArgument(7, y, 'number')
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

--- Sets the width of the paragraph relative to its original width.
-- @number scale
function Paragraph:scaleX(scale)
	checkArgument(1, scale, 'number')
	self:width(self._naturalWidth * scale)
end

--- Sets the height of the paragraph relative to its original width.
-- @number scale
function Paragraph:scaleY(scale)
	checkArgument(1, scale, 'number')
	self:height(self._naturalHeight * scale)
end

--- Sets the width and height of the paragraph relative to its original dimensions.
-- @number scaleX
-- @number[opt=scaleX] scaleY
function Paragraph:scale(scaleX, scaleY)
	checkArgument(1, scaleX, 'number')
	checkOptionalArgument(2, scaleY, 'number')
	self:scaleX(scaleX)
	self:scaleY(scaleY or scaleX)
end

--- Sets the color of the paragraph.
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Paragraph:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
end

--- Sets the color of the paragraph's shadow.
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Paragraph:shadowColor(r, g, b, a)
	self:setColor('_shadowColor', r, g, b, a)
end

--- Sets the horizontal offset of the paragraph's shadow.
-- @number offset
function Paragraph:shadowOffsetX(offset)
	checkArgument(1, offset, 'number')
	self._shadowOffsetX = offset
end

--- Sets the vertical offset of the paragraph's shadow.
-- @number offset
function Paragraph:shadowOffsetY(offset)
	checkArgument(1, offset, 'number')
	self._shadowOffsetY = offset
end

--- Sets the horizontal and vertical offset of the paragraph's shadow.
-- @number offsetX
-- @number[opt=offsetX] offsetY
function Paragraph:shadowOffset(offsetX, offsetY)
	checkArgument(1, offsetX, 'number')
	checkOptionalArgument(2, offsetY, 'number')
	self:shadowOffsetX(offsetX)
	self:shadowOffsetY(offsetY or offsetX)
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

function Paragraph:drawBottom()
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

--- Creates, manages, and draws elements.
-- @type Layout
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

function Layout:_validateElement(name)
	checkArgument(1, name, 'string', 'table')
	local element = self:getElement(name)
	local message = name == '@current' and 'No element is currently selected. Have you created any elements yet?'
		or name == '@previous' and 'no previous element to get'
		or name == '@parent' and 'No parent element to get. This keyword should be used '
			.. 'within layout:beginChildren() and layout:endChildren() calls.'
		or string.format("no element named '%s'", name)
	checkCondition(element, message)
end

--- Gets an element table.
-- @string name the name of the element to get
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

--[[
	A note to self about layout.get:

	It might be tempting to use a more compact syntax for
	layout.get, like

		layout.get 'elementName.propertyName'

	But this doesn't work when you need to get an element by its
	table and not its name! So don't make this mistake again!
	It's not a good API choice!
]]

--- Gets the value of an element's property.
-- @tparam string|table elementName the name of the element to get the property from, or the element table itself
-- @string propertyName the name of the property to get
-- @param ... additional arguments to pass to the element's property getter
-- @return the property value
function Layout:get(elementName, propertyName, ...)
	self:_validateElement(elementName)
	checkArgument(2, propertyName, 'string')
	local element = self:getElement(elementName)
	checkCondition(element.get[propertyName], string.format("element has no property named '%s'", propertyName))
	return element.get[propertyName](element, ...)
end

--- Selects an element for future operations to affect.
-- @tparam string|table name the name of the element to select, or the element table itself
function Layout:select(name)
	self:_validateElement(name)
	local element = self:getElement(name)
	local group = self._groups[self._currentGroupIndex]
	group.previous = group.current
	group.current = element
	return self
end

--- Adds an existing element to the element tree.
-- @tparam Element element
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

--- Creates a new element and adds it to the element tree.
-- @tparam string|table elementClass the type of element to create
-- @param ... additional arguments to pass to the new element's constructor
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

--- Names the currently selected element.
-- @string name
function Layout:name(name)
	checkArgument(1, name, 'string')
	self._named[name] = self:getElement '@current'
	return self
end

--- Starts adding children to the currently selected element.
-- @param ... additional arguments to pass to the parent element's onBeginChildren callback
function Layout:beginChildren(...)
	local element = self:getElement '@current'
	element:onBeginChildren(...)
	self._currentGroupIndex = self._currentGroupIndex + 1
	self._groups[self._currentGroupIndex] = self._groups[self._currentGroupIndex] or {}
	local group = self._groups[self._currentGroupIndex]
	for k in pairs(group) do group[k] = nil end
	group.parent = element
	return self
end

--- Finishes adding children to the current parent element.
-- @param ... additional arguments to pass to the parent element's onEndChildren callback
function Layout:endChildren(...)
	local group = self._groups[self._currentGroupIndex]
	group.parent:onEndChildren(...)
	self._currentGroupIndex = self._currentGroupIndex - 1
	return self
end

--- Draws and clears out the element tree.
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

--- @section end

--- Creates a new layout.
-- @treturn Layout
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

--- Creates a new element class.
-- @tparam[opt='base'] table|string parent the element class to extend from.
-- This can be the element class table itself, or the name of a built-in
-- element class.
-- @treturn table
function charm.extend(parent)
	if parent then validateElementClass(parent) end
	if type(parent) == 'string' then parent = elementClasses[parent] end
	parent = parent or elementClasses.element
	return newElementClass(parent)
end

return charm
