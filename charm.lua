local charm = {
	_VERSION = 'charm',
	_DESCRIPTION = 'Layout library for LÖVE.',
	_LICENSE = [[
		MIT License

		Copyright (c) 2019 Andrew Minnich

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

local numberOfMouseButtons = 3

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
	local class = setmetatable({}, parent)
	class.__index = class
	class.get = setmetatable({}, {__index = parent and parent.get})
	class.preserve = setmetatable({}, {__index = parent and parent.preserve})
	return class
end

-- the function used for sorting elements while drawing
local function sortElements(a, b)
	return (a._z or 0) < (b._z or 0)
end

--[[
	-- Element classes --

	Each element class represents a type of element you can draw
	(i.e. rectangle, image, etc.). Each class provides:
	- a constructor function, used by ui.new
	- getters, used by ui.get and contained in class.get
	- setters and other functions that can be called via ui[functionName]
	- callback functions, such as drawSelf and stencil
]]

local Element = {}

--[[
	The base class is used by all other element classes. It provides
	a lot of functionality common to every element, such as
	position getting/setting and the main drawing and mouse event
	logic.
]]
Element.base = newElementClass()

--[[
	The preserve table defines keys that will not be niled out
	after a frame is drawn.
]]
Element.base.preserve.preserve = true
Element.base.preserve.ui = true
Element.base.preserve._stencilFunction = true

function Element.base:getState()
	return self.ui:getState(self)
end

function Element.base:new(x, y, width, height)
	self._x = x or 0
	self._y = y or 0
	self._z = 0
	self._width = width or 0
	self._height = height or 0
end

function Element.base:containsPoint(x, y)
	return x >= self._x and x <= self._x + self._width
		and y >= self._y and y <= self._y + self._height
end

function Element.base.get:x(anchor)
	anchor = anchor or 0
	return self._x + self._width * anchor
end

function Element.base.get:left() return self.get.x(self, 0) end
function Element.base.get:center() return self.get.x(self, .5) end
function Element.base.get:right() return self.get.x(self, 1) end

function Element.base.get:y(anchor)
	anchor = anchor or 0
	return self._y + self._height * anchor
end

function Element.base.get:top() return self.get.y(self, 0) end
function Element.base.get:middle() return self.get.y(self, .5) end
function Element.base.get:bottom() return self.get.y(self, 1) end

function Element.base.get:z() return self._z end

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
	self._anchorX = anchor
	self._x = x - self._width * anchor
end

function Element.base:left(x) return self:x(x, 0) end
function Element.base:center(x) return self:x(x, .5) end
function Element.base:right(x) return self:x(x, 1) end

function Element.base:y(y, anchor)
	anchor = anchor or 0
	self._anchorY = anchor
	self._y = y - self._height * anchor
end

function Element.base:top(y) return self:y(y, 0) end
function Element.base:middle(y) return self:y(y, .5) end
function Element.base:bottom(y) return self:y(y, 1) end

function Element.base:z(z)
	self._z = z
end

function Element.base:shift(dx, dy)
	self._x = self._x + (dx or 0)
	self._y = self._y + (dy or 0)
end

function Element.base:width(width, anchorX)
	anchorX = anchorX or self._anchorX or 0
	local previousX = self.get.x(self, anchorX)
	self._width = width
	self:x(previousX, anchorX)
end

function Element.base:height(height, anchorY)
	anchorY = anchorY or self._anchorY or 0
	local previousY = self.get.y(self, anchorY)
	self._height = height
	self:y(previousY, anchorY)
end

function Element.base:size(width, height, anchorX, anchorY)
	self:width(width, anchorX)
	self:height(height, anchorY)
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

-- Adjusts the element to perfectly surround all of its children (with an optional
-- amount of padding). Children's local positions will be adjusted so they have
-- the same position on screen after the wrap is complete.
function Element.base:wrap(padding)
	padding = padding or 0
	-- get the bounds of the children
	local left, top, right, bottom
	for _, child in ipairs(self._children) do
		left = left and math.min(left, child._x) or child._x
		top = top and math.min(top, child._y) or child._y
		right = right and math.max(right, child._x + child._width) or child._x + child._width
		bottom = bottom and math.max(bottom, child._y + child._height) or child._y + child._height
	end
	-- apply padding
	left = left - padding
	top = top - padding
	right = right + padding
	bottom = bottom + padding
	-- change the parent position and size
	self._x = left
	self._y = top
	self._width = right - left
	self._height = bottom - top
	-- adjust the children's positions
	for _, child in ipairs(self._children) do
		child._x = child._x - left
		child._y = child._y - top
	end
	return self
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
	local hovered = self:containsPoint(mouseX, mouseY)
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
		table.sort(self._children, sortElements)
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

function Element.rectangle:outlineColor(r, g, b, a)
	self._outlineColor = self._outlineColor or {}
	if type(r) == 'table' then
		for i = 1, 4 do self._outlineColor[i] = r[i] end
	else
		self._outlineColor[1] = r
		self._outlineColor[2] = g
		self._outlineColor[3] = b
		self._outlineColor[4] = a
	end
end

function Element.rectangle:outlineWidth(width)
	self._outlineWidth = width
end

function Element.rectangle:cornerRadiusX(radius)
	self._cornerRadiusX = radius
end

function Element.rectangle:cornerRadiusY(radius)
	self._cornerRadiusY = radius
end

function Element.rectangle:cornerRadius(radiusX, radiusY)
	self._cornerRadiusX = radiusX
	self._cornerRadiusY = radiusY
end

function Element.rectangle:cornerSegments(segments)
	self._cornerSegments = segments
end

function Element.rectangle:stencil()
	love.graphics.rectangle('fill', 0, 0, self._width, self._height,
		self._cornerRadiusX, self._cornerRadiusY, self._cornerSegments or 64)
end

function Element.rectangle:drawSelf()
	love.graphics.push 'all'
	if self._fillColor and #self._fillColor > 1 then
		love.graphics.setColor(self._fillColor)
		love.graphics.rectangle('fill', 0, 0, self._width, self._height,
			self._cornerRadiusX, self._cornerRadiusY, self._cornerSegments or 64)
	end
	if self._outlineColor and #self._outlineColor > 1 then
		love.graphics.setColor(self._outlineColor)
		love.graphics.setLineWidth(self._outlineWidth or 1)
		love.graphics.rectangle('line', 0, 0, self._width, self._height,
			self._cornerRadiusX, self._cornerRadiusY, self._cornerSegments)
	end
	love.graphics.pop()
end

Element.ellipse = newElementClass(Element.base)

function Element.ellipse:containsPoint(x, y)
	local cx, cy = self._x + self._width/2, self._y + self._height/2
	local rx, ry = self._width/2, self._height/2
	return ((x - cx) ^ 2) / (rx ^ 2) + ((y - cy) ^ 2) / (ry ^ 2) <= 1
end

function Element.ellipse:fillColor(r, g, b, a)
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

function Element.ellipse:outlineColor(r, g, b, a)
	self._outlineColor = self._outlineColor or {}
	if type(r) == 'table' then
		for i = 1, 4 do self._outlineColor[i] = r[i] end
	else
		self._outlineColor[1] = r
		self._outlineColor[2] = g
		self._outlineColor[3] = b
		self._outlineColor[4] = a
	end
end

function Element.ellipse:outlineWidth(width)
	self._outlineWidth = width
end

function Element.ellipse:segments(segments)
	self._segments = segments
end

function Element.ellipse:stencil()
	love.graphics.ellipse('fill', self._width/2, self._height/2,
		self._width/2, self._height/2, self._segments or 64)
end

function Element.ellipse:drawSelf()
	love.graphics.push 'all'
	if self._fillColor and #self._fillColor > 1 then
		love.graphics.setColor(self._fillColor)
		love.graphics.ellipse('fill', self._width/2, self._height/2,
			self._width/2, self._height/2, self._segments or 64)
	end
	if self._outlineColor and #self._outlineColor > 1 then
		love.graphics.setColor(self._outlineColor)
		love.graphics.setLineWidth(self._outlineWidth or 1)
		love.graphics.ellipse('line', self._width/2, self._height/2,
			self._width/2, self._height/2, self._segments or 64)
	end
	love.graphics.pop()
end

Element.image = newElementClass(Element.base)

function Element.image:new(image, x, y)
	self._image = image
	self._x = x or 0
	self._y = y or 0
	self._width = image:getWidth()
	self._height = image:getHeight()
end

function Element.image:scaleX(scaleX, anchorX)
	self:width(self._image:getWidth() * scaleX, anchorX)
end

function Element.image:scaleY(scaleY, anchorY)
	self:height(self._image:getHeight() * scaleY, anchorY)
end

function Element.image:scale(scaleX, scaleY, anchorX, anchorY)
	self:scaleX(scaleX or 1, anchorX)
	self:scaleY(scaleY or scaleX, anchorY)
end

function Element.image:color(r, g, b, a)
	self._color = self._color or {}
	if type(r) == 'table' then
		for i = 1, 4 do self._color[i] = r[i] end
	else
		self._color[1] = r
		self._color[2] = g
		self._color[3] = b
		self._color[4] = a
	end
end

function Element.image:drawSelf()
	love.graphics.push 'all'
	if self._color and #self._color > 0 then
		love.graphics.setColor(self._color)
	end
	love.graphics.draw(self._image, 0, 0, 0,
		self._width / self._image:getWidth(), self._height / self._image:getHeight())
	love.graphics.pop()
end

Element.text = newElementClass(Element.base)

function Element.text:new(font, text, x, y)
	self._font = font
	self._text = text
	self._x = x or 0
	self._y = y or 0
	self._width = font:getWidth(text)
	self._height = getTextHeight(font, text)
end

function Element.text:scaleX(scaleX, anchorX)
	self:width(self._font:getWidth(self._text) * scaleX, anchorX)
end

function Element.text:scaleY(scaleY, anchorY)
	self:height(getTextHeight(self._font, self._text) * scaleY, anchorY)
end

function Element.text:scale(scaleX, scaleY, anchorX, anchorY)
	self:scaleX(scaleX or 1, anchorX)
	self:scaleY(scaleY or scaleX, anchorY)
end

function Element.text:color(r, g, b, a)
	self._color = self._color or {}
	if type(r) == 'table' then
		for i = 1, 4 do self._color[i] = r[i] end
	else
		self._color[1] = r
		self._color[2] = g
		self._color[3] = b
		self._color[4] = a
	end
end

function Element.text:shadowColor(r, g, b, a)
	self._shadowColor = self._shadowColor or {}
	if type(r) == 'table' then
		for i = 1, 4 do self._shadowColor[i] = r[i] end
	else
		self._shadowColor[1] = r
		self._shadowColor[2] = g
		self._shadowColor[3] = b
		self._shadowColor[4] = a
	end
end

function Element.text:shadowOffsetX(offsetX)
	self._shadowOffsetX = offsetX
end

function Element.text:shadowOffsetY(offsetY)
	self._shadowOffsetY = offsetY
end

function Element.text:shadowOffset(offsetX, offsetY)
	self:shadowOffsetX(offsetX)
	self:shadowOffsetY(offsetY)
end

function Element.text:drawSelf()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	local sx = self._width / self._font:getWidth(self._text)
	local sy = self._height / getTextHeight(self._font, self._text)
	if self._shadowColor and #self._shadowColor > 0 then
		local offsetX = self._shadowOffsetX or 1
		local offsetY = self._shadowOffsetY or 1
		love.graphics.setColor(self._shadowColor)
		love.graphics.print(self._text, offsetX, offsetY, 0, sx, sy)
	end
	love.graphics.setColor(1, 1, 1)
	if self._color and #self._color > 0 then
		love.graphics.setColor(self._color)
	end
	love.graphics.print(self._text, 0, 0, 0, sx, sy)
	love.graphics.pop()
end

Element.paragraph = newElementClass(Element.base)

function Element.paragraph:new(font, text, limit, align, x, y)
	self._font = font
	self._text = text
	self._limit = limit
	self._align = align
	self._x = x or 0
	self._y = y or 0
	self._width = limit
	self._height = getParagraphHeight(font, text, limit)
end

function Element.paragraph:scaleX(scaleX, anchorX)
	self:width(self._limit * scaleX, anchorX)
end

function Element.paragraph:scaleY(scaleY, anchorY)
	self:height(getParagraphHeight(self._font, self._text, self._limit) * scaleY, anchorY)
end

function Element.paragraph:scale(scaleX, scaleY, anchorX, anchorY)
	self:scaleX(scaleX or 1, anchorX)
	self:scaleY(scaleY or scaleX, anchorY)
end

function Element.paragraph:color(r, g, b, a)
	self._color = self._color or {}
	if type(r) == 'table' then
		for i = 1, 4 do self._color[i] = r[i] end
	else
		self._color[1] = r
		self._color[2] = g
		self._color[3] = b
		self._color[4] = a
	end
end

function Element.paragraph:shadowColor(r, g, b, a)
	self._shadowColor = self._shadowColor or {}
	if type(r) == 'table' then
		for i = 1, 4 do self._shadowColor[i] = r[i] end
	else
		self._shadowColor[1] = r
		self._shadowColor[2] = g
		self._shadowColor[3] = b
		self._shadowColor[4] = a
	end
end

function Element.paragraph:shadowOffsetX(offsetX)
	self._shadowOffsetX = offsetX
end

function Element.paragraph:shadowOffsetY(offsetY)
	self._shadowOffsetY = offsetY
end

function Element.paragraph:shadowOffset(offsetX, offsetY)
	self:shadowOffsetX(offsetX)
	self:shadowOffsetY(offsetY)
end

function Element.paragraph:drawSelf()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	local sx = self._width / self._limit
	local sy = self._height / getParagraphHeight(self._font, self._text, self._limit)
	if self._shadowColor and #self._shadowColor > 0 then
		local offsetX = self._shadowOffsetX or 1
		local offsetY = self._shadowOffsetY or 1
		love.graphics.setColor(self._shadowColor)
		love.graphics.printf(self._text, offsetX, offsetY, self._limit, self._align, 0, sx, sy)
	end
	love.graphics.setColor(1, 1, 1)
	if self._color and #self._color > 0 then
		love.graphics.setColor(self._color)
	end
	love.graphics.printf(self._text, 0, 0, self._limit, self._align, 0, sx, sy)
	love.graphics.pop()
end

--[[
	-- UI class --

	The UI class is responsible for creating, storing, and drawing
	elements. Important things to note:
	- Element tables are reused whenever possible. This way,
	we can keep "creating" new elements wihout actually
	creating new tables and discarding old ones. This makes
	the garbage collector happier.
	- The core logic for arranging and drawing elements is in the
	base element class (see above), not here.
]]
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

--[[
	Gets the class table for the current element. If the
	element type is a string, the code will look for the
	built-in class with that name. If the class is a user-provided
	table, it'll use that directly.
]]
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

-- Resets the UI state after a draw has been completed.
-- Not called until a new element has been created.
function Ui:start()
	for i = #self._elements, 1, -1 do
		self._elements[i] = nil
	end
	for _, element in ipairs(self._elementPool) do
		element._used = false
	end
	self._selectedElement = nil
	self._previousElement = nil
	return self
end

--[[
	Clears out an element so it can be reused. Tables
	will be cleared out one level deep, but they'll
	be left in the element table so they can be reused.
]]
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
	return self
end

function Ui:new(className, ...)
	if self._finished then
		self:start()
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

--[[
	Gets an element by name or special keyword. If the element itself
	is passed to this function, it'll just return the element.
	This is done so that the other functions that use getElement
	can work with names or the element itself without having to
	write that check for each function.
]]
function Ui:getElement(name)
	if type(name) == 'table' then return name end
	name = name or '@current'
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

function Ui:get(elementName, propertyName, ...)
	local element = self:getElement(elementName)
	return element.get[propertyName](element, ...)
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
	return self
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

function charm.extend(parent)
	if type(parent) == 'string' then parent = Element[parent] end
	parent = parent or Element.base
	return newElementClass(parent)
end

return charm
