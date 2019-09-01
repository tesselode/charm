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

-- the number of mouse buttons to check for (constant)
local numberOfMouseButtons = 3

-- for lua 5.2 compatibility
unpack = unpack or table.unpack -- luacheck: ignore

-- sets all of a table's values to nil
local function shallowClear(t)
	for k in pairs(t) do t[k] = nil end
end

--[[
	sets all of a table's values to nil, *except* for
	table values, which are deep cleared themselves.
	table values are not removed because they can
	be reused later.

	additional arguments are keys to only shallow clear
	(instead of deep clearing).
]]
local function deepClear(t, ...)
	for k, v in pairs(t) do
		local shouldDeepClear = true
		for i = 1, select('#', ...) do
			if k == select(i, ...) then
				shouldDeepClear = false
				break
			end
		end
		if type(v) == 'table' and shouldDeepClear then
			deepClear(v)
		else
			t[k] = nil
		end
	end
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

-- the function used for sorting elements while drawing
local function sortElements(a, b)
	return (a.z or 0) < (b.z or 0)
end

--[[
	-- Element classes --

	Each element class represents a type of element you can draw
	(i.e. rectangle, image, etc.). Each class provides:
	- a constructor function, used by ui.new
	- property setters, used by ui.set (optional)
	- a draw function, used to display the element on screen
]]

-- the default constructor for element classes
local function defaultConstructor(self, x, y, w, h)
	self.x = x or 0
	self.y = y or 0
	self.w = w or 0
	self.h = h or 0
end

local function defaultContainsPoint(self, x, y)
	return x >= 0 and x <= self.w and y >= 0 and y <= self.h
end

-- the default function used for drawing an element's stencil
-- if the element class doesn't provide a stencil function
local function defaultStencil(self)
	love.graphics.rectangle('fill', 0, 0, self.w, self.h)
end

local Element = {}

Element.rectangle = {
	set = {
		fillColor = function(self, r, g, b, a)
			self.fillColor = self.fillColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.fillColor[i] = r[i] end
			else
				self.fillColor[1] = r
				self.fillColor[2] = g
				self.fillColor[3] = b
				self.fillColor[4] = a
			end
		end,
		outlineColor = function(self, r, g, b, a)
			self.outlineColor = self.outlineColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.outlineColor[i] = r[i] end
			else
				self.outlineColor[1] = r
				self.outlineColor[2] = g
				self.outlineColor[3] = b
				self.outlineColor[4] = a
			end
		end,
		radius = function(self, radiusX, radiusY)
			self.radiusX = radiusX
			self.radiusY = radiusY or self.radiusX
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		if self.fillColor and #self.fillColor > 0 then
			love.graphics.setColor(unpack(self.fillColor))
			love.graphics.rectangle('fill', 0, 0, self.w, self.h,
				self.radiusX or 0, self.radiusY or 0, self.segments or 64)
		end
		if self.outlineColor and #self.outlineColor > 0 then
			love.graphics.setColor(unpack(self.outlineColor))
			love.graphics.setLineWidth(self.lineWidth or 1)
			love.graphics.rectangle('line', 0, 0, self.w, self.h,
				self.radiusX or 0, self.radiusY or 0, self.segments or 64)
		end
		love.graphics.pop()
	end,
	stencil = function(self)
		love.graphics.rectangle('fill', 0, 0, self.w, self.h,
			self.radiusX or 0, self.radiusY or 0, self.segments or 64)
	end,
}

Element.ellipse = {
	containsPoint = function(self, x, y)
		local cx, cy = self.w/2, self.h/2
		local rx, ry = self.w/2, self.h/2
		return ((x - cx) ^ 2) / (rx ^ 2) + ((y - cy) ^ 2) / (ry ^ 2) <= 1
	end,
	set = {
		fillColor = function(self, r, g, b, a)
			self.fillColor = self.fillColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.fillColor[i] = r[i] end
			else
				self.fillColor[1] = r
				self.fillColor[2] = g
				self.fillColor[3] = b
				self.fillColor[4] = a
			end
		end,
		outlineColor = function(self, r, g, b, a)
			self.outlineColor = self.outlineColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.outlineColor[i] = r[i] end
			else
				self.outlineColor[1] = r
				self.outlineColor[2] = g
				self.outlineColor[3] = b
				self.outlineColor[4] = a
			end
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		if self.fillColor and #self.fillColor > 0 then
			love.graphics.setColor(unpack(self.fillColor))
			love.graphics.ellipse('fill', self.w/2, self.h/2, self.w/2, self.h/2, self.segments or 64)
		end
		if self.outlineColor and #self.outlineColor > 0 then
			love.graphics.setColor(unpack(self.outlineColor))
			love.graphics.setLineWidth(self.lineWidth or 1)
			love.graphics.ellipse('line', self.w/2, self.h/2, self.w/2, self.h/2, self.segments or 64)
		end
		love.graphics.pop()
	end,
	stencil = function(self)
		love.graphics.ellipse('fill', self.w/2, self.h/2, self.w/2, self.h/2, self.segments or 64)
	end,
}

Element.image = {
	new = function(self, image, x, y)
		self.image = image
		self.x = x or 0
		self.y = y or 0
		self.w = image:getWidth()
		self.h = image:getHeight()
	end,
	set = {
		scaleX = function(self, sx)
			self.w = self.image:getWidth() * sx
		end,
		scaleY = function(self, sy)
			self.h = self.image:getHeight() * sy
		end,
		scale = function(self, sx, sy)
			self.w = self.image:getWidth() * sx
			self.h = self.image:getHeight() * (sy or sx)
		end,
		color = function(self, r, g, b, a)
			self.color = self.color or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.color[i] = r[i] end
			else
				self.color[1] = r
				self.color[2] = g
				self.color[3] = b
				self.color[4] = a
			end
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		if self.color and #self.color > 0 then
			love.graphics.setColor(unpack(self.color))
		end
		local sx = self.w / self.image:getWidth()
		local sy = self.h / self.image:getHeight()
		love.graphics.draw(self.image, 0, 0, 0, sx, sy)
		love.graphics.pop()
	end
}

Element.text = {
	new = function(self, font, text, x, y)
		self.font = font
		self.text = text
		self.x = x or 0
		self.y = y or 0
		self.w = font:getWidth(text)
		self.h = getTextHeight(font, text)
		self.transparent = true
	end,
	set = {
		scaleX = function(self, sx)
			self.w = self.font:getWidth(self.text) * sx
		end,
		scaleY = function(self, sy)
			self.h = getTextHeight(self.font, self.text) * sy
		end,
		scale = function(self, sx, sy)
			self.w = self.font:getWidth(self.text) * sx
			self.h = getTextHeight(self.font, self.text) * (sy or sx)
		end,
		color = function(self, r, g, b, a)
			self.color = self.color or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.color[i] = r[i] end
			else
				self.color[1] = r
				self.color[2] = g
				self.color[3] = b
				self.color[4] = a
			end
		end,
		shadowColor = function(self, r, g, b, a)
			self.shadowColor = self.shadowColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.shadowColor[i] = r[i] end
			else
				self.shadowColor[1] = r
				self.shadowColor[2] = g
				self.shadowColor[3] = b
				self.shadowColor[4] = a
			end
		end,
		shadowOffset = function(self, offsetX, offsetY)
			self.shadowOffsetX = offsetX or 0
			self.shadowOffsetY = offsetY or 0
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		love.graphics.setFont(self.font)
		local sx = self.w / self.font:getWidth(self.text)
		local sy = self.h / getTextHeight(self.font, self.text)
		if self.shadowColor and #self.shadowColor > 0 then
			local offsetX = self.shadowOffsetX or 1
			local offsetY = self.shadowOffsetY or 1
			love.graphics.setColor(unpack(self.shadowColor))
			love.graphics.print(self.text, offsetX, offsetY, 0, sx, sy)
		end
		love.graphics.setColor(1, 1, 1)
		if self.color and #self.color > 0 then
			love.graphics.setColor(unpack(self.color))
		end
		love.graphics.print(self.text, 0, 0, 0, sx, sy)
		love.graphics.pop()
	end,
}

Element.paragraph = {
	new = function(self, font, text, limit, align, x, y)
		self.font = font
		self.text = text
		self.limit = limit
		self.align = align
		self.x = x or 0
		self.y = y or 0
		self.w = limit
		self.h = getParagraphHeight(font, text, limit)
	end,
	set = {
		scaleX = function(self, sx)
			self.w = self.limit * sx
		end,
		scaleY = function(self, sy)
			self.h = getParagraphHeight(self.font, self.text, self.limit) * sy
		end,
		scale = function(self, sx, sy)
			self.w = self.limit * sx
			self.h = getParagraphHeight(self.font, self.text, self.limit) * (sy or sx)
		end,
		color = function(self, r, g, b, a)
			self.color = self.color or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.color[i] = r[i] end
			else
				self.color[1] = r
				self.color[2] = g
				self.color[3] = b
				self.color[4] = a
			end
		end,
		shadowColor = function(self, r, g, b, a)
			self.shadowColor = self.shadowColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.shadowColor[i] = r[i] end
			else
				self.shadowColor[1] = r
				self.shadowColor[2] = g
				self.shadowColor[3] = b
				self.shadowColor[4] = a
			end
		end,
		shadowOffset = function(self, offsetX, offsetY)
			self.shadowOffsetX = offsetX or 0
			self.shadowOffsetY = offsetY or 0
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		love.graphics.setFont(self.font)
		local sx = self.w / self.limit
		local sy = self.h / getParagraphHeight(self.font, self.text, self.limit)
		if self.shadowColor and #self.shadowColor > 0 then
			local offsetX = self.shadowOffsetX or 1
			local offsetY = self.shadowOffsetY or 1
			love.graphics.setColor(unpack(self.shadowColor))
			love.graphics.printf(self.text, offsetX, offsetY, self.limit, self.align, 0, sx, sy)
		end
		love.graphics.setColor(1, 1, 1)
		if self.color and #self.color > 0 then
			love.graphics.setColor(unpack(self.color))
		end
		love.graphics.printf(self.text, 0, 0, self.limit, self.align, 0, sx, sy)
		love.graphics.pop()
	end,
}

--[[
	-- UI class --

	The UI class is where the magic happens - it's responsible
	for arranging and drawing elements. It tries to keep
	memory footprint low and avoid creating garbage, which means
	there's a few things that are important to keep in mind when
	reading the rest of this code:
	- Tables are only created when they're first needed - this is why
	  you'll see a lot of x = x or {}
	- Tables are never removed, they are just cleared out and reused
	  when needed (hence the deepClear function only clearing out tables
	  but not removing them)
	- The code doesn't rely on the number of element tables to know
	  how many elements are active in this draw frame, since some elements
	  may be left over from the previous draw. Instead, it uses the
	  _numElements variable to track how many elements should be drawn
	  and iterated through.
	- Some element properties, like colors, are represented as tables.
	  Since we never remove tables, just clear them, we assume that
	  an empty table is equivalent to a blank color property.
]]
local Ui = {}

function Ui:__index(k)
	if Ui[k] then return Ui[k] end
	self._cachedProperties[k] = self._cachedProperties[k] or function(_, ...)
		return self:set(k, ...)
	end
	return self._cachedProperties[k]
end

--[[
	Gets the class table for the current element. If the
	element type is a string, the code will look for the
	built-in class with that name. If the class is a user-provided
	table, it'll use that directly.
]]
function Ui:_getElementClass(element)
	if type(element.type) == 'string' then
		return Element[element.type]
	end
	return element.type
end

--[[
	Gets an element with the given name. There are three special
	names you can use to get elements, all prefixed with "@":
	- @current - the element currently being operated on
	- @previous - the element directly before the current element
	- @parent - the element the current element is a child of

	If the element itself is passed to this function, it'll just
	return the function. This is done so that the other functions
	that use getElement can work with names or the element itself
	without having to write that check for each function.
]]
function Ui:getElement(name)
	if type(name) == 'table' then return name end
	name = name or '@current'
	if name == '@current' then
		return self._selectedElement
	elseif name == '@previous' then
		return self._previousElement
	elseif name == '@parent' then
		return self._activeParents[#self._activeParents]
	end
	for i = self._numElements, 1, -1 do
		local element = self._elements[i]
		if element.name == name then
			return element
		end
	end
end

function Ui:select(name)
	local element = self:getElement(name)
	self._previousElement = self._selectedElement
	self._selectedElement = element
	return self
end

-- Creates a new element and starts operating on it
function Ui:new(elementType, ...)
	-- if we just finished a draw call, reset some UI state
	if self._finished then
		self._numElements = 0
		self._selectedElement = nil
		self._previousElement = nil
		self._finished = false
	end
	self._numElements = self._numElements + 1
	local element
	-- if there's already an element table at this index,
	-- reuse the table. otherwise, create a new one and add it
	-- to the elements list
	if self._elements[self._numElements] then
		element = self._elements[self._numElements]
		deepClear(element, 'type', 'parent')
	else
		element = {}
		table.insert(self._elements, element)
	end
	element.parent = self._activeParents[#self._activeParents]
	element.type = elementType
	local elementClass = self:_getElementClass(element)
	local constructor = elementClass.new or defaultConstructor
	constructor(element, ...)
	self:select(element)
	return self
end

--[[
	Gets the x position of a point on the element with the given name.
	Tne anchor specifies what point on the x-axis we want to get
	(0 = left, 0.5 = center, 1 = right)
]]
function Ui:getX(name, anchor)
	anchor = anchor or 0
	local element = self:getElement(name)
	return element.x + element.w * anchor
end

function Ui:getLeft(name) return self:getX(name, 0) end
function Ui:getCenter(name) return self:getX(name, .5) end
function Ui:getRight(name) return self:getX(name, 1) end

--[[
	Gets the y position of a point on the element with the given name.
	Tne anchor specifies what point on the y-axis we want to get
	(0 = top, 0.5 = middle, 1 = bottom)
]]
function Ui:getY(name, anchor)
	anchor = anchor or 0
	local element = self:getElement(name)
	return element.y + element.h * anchor
end

function Ui:getTop(name) return self:getY(name, 0) end
function Ui:getMiddle(name) return self:getY(name, .5) end
function Ui:getBottom(name) return self:getY(name, 1) end

-- Gets the z position of an element (defaults to 0)
function Ui:getZ(name)
	local element = self:getElement(name)
	return element.z or 0
end

function Ui:getWidth(name) return self:getElement(name).w end
function Ui:getHeight(name) return self:getElement(name).h end
function Ui:getSize(name) return self:getWidth(name), self:getHeight(name) end

-- Gets whether the mouse is hovering over this element
function Ui:isHovered(name)
	local state = self._buttonState[name]
	if not state then return end
	return state.hovered
end

-- Gets whether the mouse just started hovering over this element
function Ui:isEntered(name)
	local state = self._buttonState[name]
	if not state then return end
	return state.hovered and not state.hoveredPrevious
end

-- Gets whether the mouse just stopped hovering over this element
function Ui:isExited(name)
	local state = self._buttonState[name]
	if not state then return end
	return state.hoveredPrevious and not state.hovered
end

-- Gets whether the element is held
function Ui:isHeld(name, button)
	button = button or 1
	local state = self._buttonState[name]
	if not state then return end
	return state.held[button]
end

-- Gets whether the element was just clicked
function Ui:isPressed(name, button)
	button = button or 1
	local state = self._buttonState[name]
	if not state then return end
	return state.held[button] and not state.heldPrevious[button]
end

-- Gets whether the element was just released
function Ui:isReleased(name, button)
	button = button or 1
	local state = self._buttonState[name]
	if not state then return end
	return state.released[button]
end

function Ui:isDragged(name, button)
	button = button or 1
	if self._mouseX == self._mouseXPrevious and self._mouseY == self._mouseYPrevious then
		return false
	end
	if not self:isHeld(name, button) then return false end
	return true, self._mouseX - self._mouseXPrevious, self._mouseY - self._mouseYPrevious
end

-- These are all position/size setters, similar to the
-- getters except they always act on the current element
function Ui:x(x, anchor)
	anchor = anchor or 0
	local element = self._selectedElement
	element.x = x - element.w * anchor
	return self
end

function Ui:left(x) return self:x(x, 0) end
function Ui:center(x) return self:x(x, .5) end
function Ui:right(x) return self:x(x, 1) end

function Ui:y(y, anchor)
	anchor = anchor or 0
	local element = self._selectedElement
	element.y = y - element.h * anchor
	return self
end

function Ui:top(y) return self:y(y, 0) end
function Ui:middle(y) return self:y(y, .5) end
function Ui:bottom(y) return self:y(y, 1) end

function Ui:z(z)
	local element = self._selectedElement
	element.z = z
	return self
end

function Ui:shift(dx, dy)
	local element = self._selectedElement
	element.x = element.x + (dx or 0)
	element.y = element.y + (dy or 0)
	return self
end

function Ui:width(width)
	local element = self._selectedElement
	element.w = width
	return self
end

function Ui:height(height)
	local element = self._selectedElement
	element.h = height
	return self
end

function Ui:size(width, height)
	width, height = width or 0, height or 0
	self:width(width)
	self:height(height)
	return self
end

-- Sets the name of the current element
function Ui:name(name)
	local element = self._selectedElement
	element.name = name
	return self
end

-- Sets a property on the current element. What this does
-- depends on the element's class.
function Ui:set(property, ...)
	local element = self._selectedElement
	local elementClass = self:_getElementClass(element)
	if elementClass.set and elementClass.set[property] then
		elementClass.set[property](element, ...)
	else
		element[property] = select(1, ...)
	end
	return self
end

-- Enables child clipping for this element, meaning that children
-- will not be visible outside of the bounds of this element.
function Ui:clip()
	local element = self._selectedElement
	element.clip = true
	return self
end

-- Makes this child transparent, which means that the mouse can be
-- hovered over this element and lower elements simultaneously.
function Ui:transparent()
	local element = self._selectedElement
	element.transparent = true
	return self
end

function Ui:opaque()
	local element = self._selectedElement
	element.transparent = false
	return self
end

-- Pushes the current element onto the group stack so that newly
-- created elements will be children of this element.
function Ui:beginChildren()
	table.insert(self._activeParents, self._selectedElement)
	return self
end

-- Pops the topmost element from the group stack and selects
-- that element as the current element.
function Ui:endChildren()
	self:select(self._activeParents[#self._activeParents])
	table.remove(self._activeParents, #self._activeParents)
	return self
end

-- Adjusts the element to perfectly surround all of its children (with an optional
-- amount of padding). Children's local positions will be adjusted so they have
-- the same position on screen after the wrap is complete.
function Ui:wrap(padding)
	padding = padding or 0
	local parent = self._selectedElement
	-- get the bounds of current element's children
	local left, top, right, bottom
	for i = 1, self._numElements do
		local child = self._elements[i]
		if child.parent == parent then
			left = left and math.min(left, child.x) or child.x
			top = top and math.min(top, child.y) or child.y
			right = right and math.max(right, child.x + child.w) or child.x + child.w
			bottom = bottom and math.max(bottom, child.y + child.h) or child.y + child.h
		end
	end
	-- apply padding
	left = left - padding
	top = top - padding
	right = right + padding
	bottom = bottom + padding
	-- change the parent position and size
	parent.x = left
	parent.y = top
	parent.w = right - left
	parent.h = bottom - top
	-- adjust the children's positions
	for i = 1, self._numElements do
		local child = self._elements[i]
		if child.parent == parent then
			child.x = child.x - left
			child.y = child.y - top
		end
	end
	return self
end

function Ui:_updateMouseState()
	self._mouseXPrevious, self._mouseYPrevious = self._mouseX, self._mouseY
	self._mouseX, self._mouseY = love.mouse.getPosition()
	for button = 1, numberOfMouseButtons do
		self._mouseDownPrevious[button] = self._mouseDown[button]
		self._mouseDown[button] = love.mouse.isDown(button)
	end
end

--[[
	Gets a list of children to draw relative to a parent element
	(if there's no parent, elements that aren't children
	of any other element will be drawn.) The children are also
	sorted by their z position.

	The groupDepth argument is used to make sure we don't clobber
	a drawList table for a lower group, since we're reusing tables.
]]
function Ui:_getDrawList(groupDepth, parent)
	-- make a list of elements to draw in this group
	-- if a list for this group depth already exists, reuse it
	local drawList
	if self._drawList[groupDepth] then
		shallowClear(self._drawList[groupDepth])
	else
		self._drawList[groupDepth] = {}
	end
	drawList = self._drawList[groupDepth]
	-- add the elements in this group to the list and sort them
	-- by their z position
	for i = 1, self._numElements do
		local element = self._elements[i]
		if element.parent == parent then
			table.insert(drawList, element)
		end
	end
	-- sort the elements
	table.sort(drawList, sortElements)
	return drawList
end

--[[
	Gets whether the mouse is over a certain element. This does *not*
	take into account clipping and blocking.
]]
function Ui:_isMouseOver(element, dx, dy)
	local left, top = element.x + dx, element.y + dy
	local mouseX, mouseY = love.mouse.getPosition()
	local relativeMouseX, relativeMouseY = mouseX - left, mouseY - top
	local elementClass = self:_getElementClass(element)
	local containsPointFunction = elementClass.containsPoint or defaultContainsPoint
	return containsPointFunction(element, relativeMouseX, relativeMouseY)
end

--[[
	Tells are parent element that a child element is hovered,
	so parent elements should not be considered hovered,
	since the child is blocking them.
]]
function Ui:_blockParents(parent)
	while parent do
		local parentState = self._buttonState[parent.name]
		if parentState then parentState.hovered = false end
		parent = parent.parent
	end
end

-- Pushes a stencil onto the stack. Elements will only be visible
-- if they're within the union of all the stencils on the stack.
function Ui:_pushStencil(element)
	love.graphics.push 'all'
	self._stencilValue = self._stencilValue + 1
	self._stencilFunctionCache[element] = self._stencilFunctionCache[element] or function()
		local elementClass = self:_getElementClass(element)
		local stencilFunction = elementClass.stencil or defaultStencil
		stencilFunction(element)
	end
	love.graphics.stencil(self._stencilFunctionCache[element], 'increment', 1, true)
	love.graphics.setStencilTest('gequal', self._stencilValue)
end

-- Pops a stencil from the stack.
function Ui:_popStencil(element)
	self._stencilValue = self._stencilValue - 1
	love.graphics.stencil(self._stencilFunctionCache[element], 'decrement', 1, true)
	love.graphics.pop()
end

-- Draws all of the elements that have been placed on this frame,
-- and updates their button state (hovered, clicked, etc.).
function Ui:_draw(groupDepth, parent, dx, dy, mouseClipped)
	groupDepth = groupDepth or 1
	dx, dy = dx or 0, dy or 0
	local drawList = self:_getDrawList(groupDepth, parent)
	-- for each element in this group...
	for elementIndex, element in ipairs(drawList) do
		-- get whether the element is hovered by the mouse
		local hovered = self:_isMouseOver(element, dx, dy)
		-- if the element isn't hovered, and it clips its children, make sure
		-- children know the mouse is clipped
		if not hovered and element.clip then mouseClipped = true end
		if mouseClipped then hovered = false end
		-- if the element is hovered, block lower elements from being hovered
		if hovered and not element.transparent then
			-- block parents
			self:_blockParents(parent)
			-- block other children below this one
			for i = 1, elementIndex - 1 do
				local other = drawList[i]
				local otherState = self._buttonState[other.name]
				if otherState then otherState.hovered = false end
			end
		end
		-- if the element is named, update its button state
		if element.name then
			self._buttonState[element.name] = self._buttonState[element.name] or {
				hovered = false,
				hoveredPrevious = false,
				held = {},
				heldPrevious = {},
				released = {},
			}
			local state = self._buttonState[element.name]
			-- update hover state
			state.hoveredPrevious = state.hovered
			state.hovered = hovered
		end
		-- draw the element
		local elementClass = self:_getElementClass(element)
		love.graphics.push 'all'
		love.graphics.translate(element.x, element.y)
		elementClass.draw(element)
		if element.clip then self:_pushStencil(element) end
		self:_draw(groupDepth + 1, element, element.x + dx, element.y + dy, mouseClipped)
		if element.clip then self:_popStencil(element) end
		love.graphics.pop()
		-- update button state that depends on whether other elements blocked this one
		if element.name then
			local state = self._buttonState[element.name]
			-- update held state
			for button = 1, numberOfMouseButtons do
				state.heldPrevious[button] = state.held[button]
				state.released[button] = false
				local mouseClicked = self._mouseDown[button] and not self._mouseDownPrevious[button]
				if not state.held[button] and state.hovered and mouseClicked then
					state.held[button] = true
				end
				if state.held[button] and not self._mouseDown[button] then
					state.held[button] = false
					if state.hovered then state.released[button] = true end
				end
			end
		end
	end
end

function Ui:draw()
	self:_updateMouseState()
	self:_draw()
	self._finished = true
	return self
end

function charm.new()
	return setmetatable({
		_elements = {},
		_numElements = 0,
		_finished = false,
		_selectedElement = nil,
		_previousElement = nil,
		_activeParents = {},
		_drawList = {},
		_stencilFunctionCache = {},
		_stencilValue = 0,
		_buttonState = {},
		_mouseX = 0,
		_mouseY = 0,
		_mouseXPrevious = 0,
		_mouseYPrevious = 0,
		_mouseDown = {},
		_mouseDownPrevious = {},
		_cachedProperties = {},
	}, Ui)
end

return charm