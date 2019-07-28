local charm = {}

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

	additional arguments are keys to skip clearing out.
]]
local function deepClear(t, ...)
	for k, v in pairs(t) do
		local shouldClear = true
		for i = 1, select('#', ...) do
			if k == select(i, ...) then
				shouldClear = false
				break
			end
		end
		if shouldClear then
			if type(v) == 'table' then
				deepClear(v)
			else
				t[k] = nil
			end
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

-- the default function used for drawing an element's stencil
-- if the element class doesn't provide a stencil function
local function defaultStencil(self)
	love.graphics.rectangle('fill', 0, 0, self.w, self.h)
end

--[[
	-- Element classes --

	Each element class represents a type of element you can draw
	(i.e. rectangle, image, etc.). Each class provides:
	- a constructor function, used by ui.new
	- property setters, used by ui.set (optional)
	- a draw function, used to display the element on screen
]]
local Element = {}

Element.rectangle = {
	new = function(self, x, y, w, h)
		self.x = x or 0
		self.y = y or 0
		self.w = w or 0
		self.h = h or 0
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
Ui.__index = Ui

--[[
	Gets an element with the given name. There are three special
	names you can use to get elements, all prefixed with "@":
	- @current - the element currently being operated on
	- @previous - the element directly before the current element
	- @parent - the element the current element is a child of
]]
function Ui:_getElement(name)
	if name == '@current' then
		return self._elements[self._selectedElementIndex]
	elseif name == '@previous' then
		return self._elements[self._selectedElementIndex - 1]
	elseif name == '@parent' then
		return self._elements[self._activeParents[#self._activeParents]]
	end
	for i = self._numElements, 1, -1 do
		local element = self._elements[i]
		if element.name == name then
			return element
		end
	end
end

-- Gets the element currently being operated on
function Ui:_getSelectedElement()
	return self._elements[self._selectedElementIndex]
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

-- Creates a new element and starts operating on it
function Ui:new(elementType, ...)
	-- if we just finished a draw call, reset some UI state
	if self._finished then
		self._numElements = 0
		self._selectedElementIndex = 0
		self._finished = false
	end
	self._numElements = self._numElements + 1
	self._selectedElementIndex = self._numElements
	local element
	-- if there's already an element table at this index,
	-- reuse the table. otherwise, create a new one and add it
	-- to the elements list
	if self._elements[self._selectedElementIndex] then
		element = self._elements[self._selectedElementIndex]
		deepClear(element, 'type')
	else
		element = {}
		table.insert(self._elements, element)
	end
	element.parentIndex = self._activeParents[#self._activeParents]
	element.type = elementType
	local elementClass = self:_getElementClass(element)
	elementClass.new(element, ...)
	return self
end

--[[
	Gets the x position of a point on the element with the given name.
	Tne anchor specifies what point on the x-axis we want to get
	(0 = left, 0.5 = center, 1 = right)
]]
function Ui:getX(name, anchor)
	anchor = anchor or 0
	local element = self:_getElement(name)
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
	local element = self:_getElement(name)
	return element.y + element.h * anchor
end

function Ui:getTop(name) return self:getY(name, 0) end
function Ui:getMiddle(name) return self:getY(name, .5) end
function Ui:getBottom(name) return self:getY(name, 1) end

-- Gets the z position of an element (defaults to 0)
function Ui:getZ(name)
	local element = self:_getElement(name)
	return element.z or 0
end

function Ui:getWidth(name) return self:_getElement(name).w end
function Ui:getHeight(name) return self:_getElement(name).h end
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
function Ui:isHeld(name)
	local state = self._buttonState[name]
	if not state then return end
	return state.held
end

-- Gets whether the element was just clicked
function Ui:isPressed(name)
	local state = self._buttonState[name]
	if not state then return end
	return state.held and not state.heldPrevious
end

-- Gets whether the element was just released
function Ui:isReleased(name)
	local state = self._buttonState[name]
	if not state then return end
	return state.released
end

-- These are all position/size setters, similar to the
-- getters except they always act on the current element
function Ui:x(x, anchor)
	anchor = anchor or 0
	local element = self:_getSelectedElement()
	element.x = x - element.w * anchor
	return self
end

function Ui:left(x) return self:x(x, 0) end
function Ui:center(x) return self:x(x, .5) end
function Ui:right(x) return self:x(x, 1) end

function Ui:y(y, anchor)
	anchor = anchor or 0
	local element = self:_getSelectedElement()
	element.y = y - element.h * anchor
	return self
end

function Ui:top(y) return self:y(y, 0) end
function Ui:middle(y) return self:y(y, .5) end
function Ui:bottom(y) return self:y(y, 1) end

function Ui:z(z)
	local element = self:_getSelectedElement()
	element.z = z
	return self
end

function Ui:width(width)
	local element = self:_getSelectedElement()
	element.w = width
	return self
end

function Ui:height(height)
	local element = self:_getSelectedElement()
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
	local element = self:_getSelectedElement()
	element.name = name
	return self
end

-- Sets a property on the current element. What this does
-- depends on the element's class.
function Ui:set(property, ...)
	local element = self:_getSelectedElement()
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
	local element = self:_getSelectedElement()
	element.clip = true
	return self
end

-- Makes this child transparent, which means that the mouse can be
-- hovered over this element and lower elements simultaneously.
function Ui:transparent()
	local element = self:_getSelectedElement()
	element.transparent = true
	return self
end

function Ui:opaque()
	local element = self:_getSelectedElement()
	element.transparent = false
	return self
end

-- Pushes the current element onto the group stack so that newly
-- created elements will be children of this element.
function Ui:beginChildren()
	table.insert(self._activeParents, self._selectedElementIndex)
	return self
end

-- Pops the topmost element from the group stack and selects
-- that element as the current element.
function Ui:endChildren()
	self._selectedElementIndex = self._activeParents[#self._activeParents]
	table.remove(self._activeParents, #self._activeParents)
	return self
end

-- Adjusts the element to perfectly surround all of its children (with an optional
-- amount of padding). Children's local positions will be adjusted so they have
-- the same position on screen after the wrap is complete.
function Ui:wrap(padding)
	padding = padding or 0
	local parent = self:_getSelectedElement()
	local parentIndex = self._selectedElementIndex
	-- get the bounds of current element's children
	local left, top, right, bottom
	for i = 1, self._numElements do
		local child = self._elements[i]
		if child.parentIndex == parentIndex then
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
		if child.parentIndex == parentIndex then
			child.x = child.x - left
			child.y = child.y - top
		end
	end
	return self
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
		if self._elements[element.parentIndex] == parent then
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
	local right, bottom = left + element.w, top + element.h
	local mouseX, mouseY = love.mouse.getPosition()
	return mouseX >= left and mouseX <= right
	   and mouseY >= top and mouseY <= bottom
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
		parent = self._elements[parent.parentIndex]
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
	-- update mouse button state
	self._mouseDownPrevious = self._mouseDown
	self._mouseDown = love.mouse.isDown(1)
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
				held = false,
				heldPrevious = false,
				released = false,
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
			state.heldPrevious = state.held
			state.released = false
			if not state.held and state.hovered and self._mouseDown and self._mouseDownPrevious then
				state.held = true
			end
			if state.held and not self._mouseDown then
				state.held = false
				if state.hovered then state.released = true end
			end
		end
	end
end

function Ui:draw()
	self:_draw()
	self._finished = true
	return self
end

function charm.new()
	return setmetatable({
		_elements = {},
		_numElements = 0,
		_finished = false,
		_selectedElementIndex = 0,
		_activeParents = {},
		_drawList = {},
		_stencilFunctionCache = {},
		_stencilValue = 0,
		_buttonState = {},
		_mouseDown = false,
		_mouseDownPrevious = false,
	}, Ui)
end

return charm
