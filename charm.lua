local charm = {}

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

local numMouseButtons = 3

local function shallowClear(t)
	for k in pairs(t) do t[k] = nil end
end

local function deepClear(t)
	for k, v in pairs(t) do
		if type(v) == 'table' then
			deepClear(v)
		else
			t[k] = nil
		end
	end
end

local function newElementClass(className, parent, ...)
	local class = setmetatable({
		-- every element class has a className string
		-- so we can automatically generate decent element names
		className = className,
		parent = parent,
		-- property getters
		get = setmetatable({}, {
			-- property getters fall back to parent property getters
			__index = parent and parent.get,
			-- allows for the self:get 'propertyName' shorthand
			__call = function(_, self, propertyName, ...)
				return self.get[propertyName](self, ...)
			end,
		}),
		-- customize how tables are cleared out
		clearMode = setmetatable({}, {
			__index = parent and parent.clearMode,
		}),
	}, {__index = parent})
	class.__index = class
	for i = 1, select('#', ...) do
		local mixinClass = select(i, ...)
		-- copy functions
		for k, v in pairs(mixinClass) do
			if type(v) == 'function' then
				class[k] = v
			end
		end
		-- copy properties
		for k, v in pairs(mixinClass.get) do
			class.get[k] = v
		end
		-- copy clear mode preferences
		for k, v in pairs(mixinClass.clearMode) do
			class.clearMode[k] = v
		end
	end
	return class
end

local Element = newElementClass 'Element'

Element.clearMode.ui = 'none'
Element.clearMode._parent = 'none'
Element.clearMode._stencil = 'none'
Element.clearMode._listeners = 'deep'

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

function Element:initState(state) end

function Element:getState()
	return self.ui:getState(self)
end

function Element:pointInBounds(x, y)
	checkArgument(1, x, 'number')
	checkArgument(2, y, 'number')
	return x >= 0 and x <= self:get 'width'
	   and y >= 0 and y <= self:get 'height'
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
	checkArgument(1, propertyName, 'string')
	checkArgument(2, r, 'number', 'table')
	checkOptionalArgument(3, g, 'number')
	checkOptionalArgument(4, b, 'number')
	checkOptionalArgument(5, a, 'number')
	--[[ if type(r) ~= 'table' then
		checkArgument(1, r, 'number', 'table')
		checkArgument(2, g, 'number')
		checkArgument(3, b, 'number')
		checkOptionalArgument(4, a, 'number')
	end ]]
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

function Element.get:name()
	return self.ui:getName(self)
end

function Element.get:id()
	return self.ui:getId(self)
end

function Element.get:width()
	return self._width or 0
end

function Element.get:height()
	return self._height or 0
end

function Element.get:size()
	return self:get 'width', self:get 'height'
end

function Element.get:x(origin)
	checkOptionalArgument(1, origin, 'number')
	origin = origin or 0
	return (self._x or 0) + self:get 'width' * origin
end

function Element.get:left() return self:get('x', 0) end
function Element.get:centerX() return self:get('x', .5) end
function Element.get:right() return self:get('x', 1) end

function Element.get:y(origin)
	checkOptionalArgument(1, origin, 'number')
	origin = origin or 0
	return (self._y or 0) + self:get 'height' * origin
end

function Element.get:top() return self:get('y', 0) end
function Element.get:centerY() return self:get('y', .5) end
function Element.get:bottom() return self:get('y', 1) end

function Element.get:bounds()
	return self:get 'left', self:get 'top', self:get 'right', self:get 'bottom'
end

function Element.get:rectangle()
	return self:get 'x', self:get 'y', self:get 'size'
end

function Element.get:childrenBounds()
	if not self:hasChildren() then return end
	local left, top, right, bottom
	for _, child in ipairs(self._children) do
		local childLeft, childTop, childRight, childBottom = child:get 'bounds'
		left = left and math.min(left, childLeft) or childLeft
		top = top and math.min(top, childTop) or childTop
		right = right and math.max(right, childRight) or childRight
		bottom = bottom and math.max(bottom, childBottom) or childBottom
	end
	return left, top, right, bottom
end

function Element.get:childrenRectangle()
	local left, top, right, bottom = self:get 'childrenBounds'
	return left, top, right - left, bottom - top
end

function Element.get:hovered()
	local state = self:getState()
	return state.hovered
end

function Element.get:entered()
	local state = self:getState()
	return state.entered
end

function Element.get:exited()
	local state = self:getState()
	return state.exited
end

function Element.get:held(button)
	checkOptionalArgument(1, button, 'number')
	button = button or 1
	local state = self:getState()
	return state.held and state.held[button] or false
end

function Element.get:clicked(button)
	checkOptionalArgument(1, button, 'number')
	button = button or 1
	local state = self:getState()
	return state.clicked and state.clicked[button] or false
end

function Element.get:dragged(button)
	checkOptionalArgument(1, button, 'number')
	button = button or 1
	local state = self:getState()
	if not state then return false, false end
	return state.draggedX and state.draggedX[button] or false,
		state.draggedY and state.draggedY[button] or false
end

function Element:origin(originX, originY)
	checkArgument(1, originX, 'number')
	checkArgument(2, originY, 'number')
	self._originX = originX
	self._originY = originY
	return self
end

function Element:width(width)
	checkArgument(1, width, 'number')
	local originX = self._originX or 0
	local x = self:get('x', originX)
	self._width = width
	self:x(x, originX)
	return self
end

function Element:height(height)
	checkArgument(1, height, 'number')
	local originY = self._originY or 0
	local y = self:get('y', originY)
	self._height = height
	self:y(y, originY)
	return self
end

function Element:size(width, height)
	checkArgument(1, width, 'number')
	checkArgument(2, height, 'number')
	self:width(width)
	self:height(height)
	return self
end

function Element:x(x, origin)
	checkArgument(1, x, 'number')
	checkOptionalArgument(2, origin, 'number')
	origin = origin or 0
	self._originX = origin
	self._x = x - self:get 'width' * origin
	return self
end

function Element:left(x)
	self:x(x, 0)
	return self
end

function Element:centerX(x)
	self:x(x, .5)
	return self
end

function Element:right(x)
	self:x(x, 1)
	return self
end


function Element:y(y, origin)
	checkArgument(1, y, 'number')
	checkOptionalArgument(2, origin, 'number')
	origin = origin or 0
	self._originY = origin
	self._y = y - self:get 'height' * origin
	return self
end

function Element:top(y)
	self:y(y, 0)
	return self
end

function Element:centerY(y)
	self:y(y, .5)
	return self
end

function Element:bottom(y)
	self:y(y, 1)
	return self
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
	return self
end

function Element:rectangle(x, y, width, height)
	checkArgument(1, x, 'number')
	checkArgument(2, y, 'number')
	checkArgument(3, width, 'number')
	checkArgument(4, height, 'number')
	self._x = x
	self._y = y
	self._width = width
	self._height = height
	return self
end

function Element:shift(dx, dy)
	checkArgument(1, dx, 'number')
	checkArgument(2, dy, 'number')
	self._x = self._x + dx
	self._y = self._y + dy
	return self
end

function Element:addChild(child)
	checkArgument(1, child, 'table')
	self._children = self._children or {}
	table.insert(self._children, child)
	return child
end

function Element:onAddChild(child)
	self:addChild(child)
end

function Element:shiftChildren(dx, dy)
	checkArgument(1, dx, 'number')
	checkArgument(2, dy, 'number')
	if not self:hasChildren() then return end
	for _, child in ipairs(self._children) do
		child:shift(dx, dy)
	end
	return self
end

function Element:expand()
	if not self:hasChildren() then return end
	local _, _, right, bottom = self:get 'childrenBounds'
	self._width = math.max(self:get 'width', right)
	self._height = math.max(self:get 'height', bottom)
	return self
end

function Element:wrap()
	if not self:hasChildren() then return end
	local left, top, right, bottom = self:get 'childrenBounds'
	self:bounds(left + self:get 'x', top + self:get 'y',
		right + self:get 'x', bottom + self:get 'y')
	self:shiftChildren(-left, -top)
	return self
end

function Element:padLeft(padding)
	checkArgument(1, padding, 'number')
	self:shiftChildren(padding, 0)
	self:width(self:get 'width' + padding)
	return self
end

function Element:padTop(padding)
	checkArgument(1, padding, 'number')
	self:shiftChildren(0, padding)
	self:height(self:get 'height' + padding)
	return self
end

function Element:padRight(padding)
	checkArgument(1, padding, 'number')
	self:width(self:get 'width' + padding)
	return self
end

function Element:padBottom(padding)
	checkArgument(1, padding, 'number')
	self:height(self:get 'height' + padding)
	return self
end

function Element:padHorizontal(padding)
	checkArgument(1, padding, 'number')
	self:padLeft(padding)
	self:padRight(padding)
	return self
end

function Element:padVertical(padding)
	checkArgument(1, padding, 'number')
	self:padTop(padding)
	self:padBottom(padding)
	return self
end

function Element:pad(padding)
	checkArgument(1, padding, 'number')
	self:padHorizontal(padding)
	self:padVertical(padding)
	return self
end

function Element:clip()
	self._clip = true
	return self
end

function Element:transparent()
	self._transparent = true
	return self
end

function Element:opaque()
	self._transparent = false
	return self
end

function Element:on(event, f)
	self._listeners = self._listeners or {}
	self._listeners[event] = self._listeners[event] or {}
	table.insert(self._listeners[event], f)
	return self
end

function Element:emit(event, ...)
	if not self._listeners then return end
	if not self._listeners[event] then return end
	for _, f in ipairs(self._listeners[event]) do
		f(...)
	end
	return self
end

function Element:beforeDraw() end
function Element:drawBottom() end
function Element:drawTop() end
function Element:afterDraw() end

function Element:_processMouseEvents(x, y, dx, dy, pressed, released, blocked, clipped)
	--[[
		call the beforeDraw callback. this isn't related to processing mouse events,
		i just needed to call this somewhere before event handling happens.
	]]
	self:beforeDraw()
	local mouseInBounds = self:pointInBounds(x - self:get 'x', y - self:get 'y')
	-- if clipping is enabled, and the mouse is not within the parent
	-- element's bounds, then none of the children can be hovered
	local childrenClipped = self._clip and not mouseInBounds
	--[[
		process mouse events for each child, starting from the
		topmost one. if any child returns true, indicating that it's
		"taking" the mouse input, then no child below it or the parent
		element can be hovered.
	]]
	if self._children then
		for i = #self._children, 1, -1 do
			local child = self._children[i]
			if child:_processMouseEvents(x - self:get 'x', y - self:get 'y',
					dx, dy, pressed, released, blocked, childrenClipped) then
				blocked = true
			end
		end
	end
	local hovered = mouseInBounds and not blocked
	local state = self:getState()
	--[[
		create the held and clicked tables if they don't already
		exist. i could do this in Element.initState, but then
		every other element class that overrides initState would
		have to make sure it calls Element.initState so that
		these tables are initialized properly. kind of a pain
		for the end user.
	]]
	state.held = state.held or {}
	state.clicked = state.clicked or {}
	state.draggedX = state.draggedX or {}
	state.draggedY = state.draggedY or {}
	local hoveredPrevious = state.hovered
	-- the element is hovered if the mouse is over the element
	-- and another element isn't blocking this one
	state.hovered = hovered
	-- the element is "entered" if it just started being hovered
	-- this frame
	state.entered = hovered and not hoveredPrevious
	if state.entered then self:emit 'enter' end
	-- the element is "exited" if it just started stopped hovered
	-- this frame
	state.exited = hoveredPrevious and not hovered
	if state.exited then self:emit 'exit' end
	for button = 1, numMouseButtons do
		-- the element is "clicked" if it was held down and the button
		-- was released over the element this frame
		state.clicked[button] = hovered and state.held[button] and released[button]
		if state.clicked[button] then self:emit('click', button) end
		-- the element starts being "held" when the button is pressed
		-- over the element, and it continues being held until
		-- the mouse button is released (even if the mouse leaves
		-- the element in the meantime)
		if hovered and pressed[button] then
			state.held[button] = true
		end
		if released[button] then
			state.held[button] = false
		end
		-- the element is "dragged" if it's held and the mouse moved
		-- this frame
		if state.held[button] and (dx ~= 0 or dy ~= 0) then
			state.draggedX[button] = dx
			state.draggedY[button] = dy
			self:emit('drag', button, dx, dy)
		else
			state.draggedX[button] = false
			state.draggedY[button] = false
		end
	end
	-- return true if this element would block elements below it
	-- from receiving mouse input
	return (blocked or (mouseInBounds and not self._transparent)) and not clipped
end

function Element:stencil()
	love.graphics.rectangle('fill', self:get 'rectangle')
end

function Element:_drawChildren(stencilValue)
	if not self._children then return end
	-- if clipping is enabled, "push" a stencil to the "stack"
	if self._clip then
		self._stencil = self._stencil or function()
			self:stencil()
		end
		stencilValue = stencilValue + 1
		love.graphics.push 'all'
		love.graphics.stencil(self._stencil, 'increment', 1, true)
		love.graphics.setStencilTest('gequal', stencilValue)
	end
	for _, child in ipairs(self._children) do
		child:draw(stencilValue)
	end
	-- if clipping is enabled, "pop" a stencil from the "stack"
	if self._clip then
		love.graphics.stencil(self._stencil, 'decrement', 1, true)
		love.graphics.pop()
	end
end

function Element:draw(stencilValue)
	stencilValue = stencilValue or 0
	love.graphics.push 'all'
	love.graphics.translate(self:get 'x', self:get 'y')
	self:drawBottom()
	self:_drawChildren(stencilValue)
	self:drawTop()
	love.graphics.pop()
	self:afterDraw()
end

function Element:drawDebug()
	love.graphics.push 'all'
	love.graphics.translate(self:get 'x', self:get 'y')
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle('line', 0, 0, self:get 'size')
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(self:get 'id')
	if self._children then
		for _, child in ipairs(self._children) do
			child:drawDebug()
		end
	end
	love.graphics.pop()
end

local Shape = newElementClass('Shape', Element)

function Shape:fillColor(r, g, b, a)
	self:setColor('_fillColor', r, g, b, a)
	return self
end

function Shape:outlineColor(r, g, b, a)
	self:setColor('_outlineColor', r, g, b, a)
	return self
end

function Shape:outlineWidth(outlineWidth)
	checkArgument(1, outlineWidth, 'number')
	self._outlineWidth = outlineWidth
	return self
end

function Shape:drawShape(mode) end

function Shape:stencil()
	self:drawShape 'fill'
end

function Shape:drawBottom()
	if not self:isColorSet(self._fillColor) then return end
	love.graphics.push 'all'
	love.graphics.setColor(self._fillColor)
	self:drawShape 'fill'
	love.graphics.pop()
end

function Shape:drawTop()
	if not self:isColorSet(self._outlineColor) then return end
	love.graphics.push 'all'
	love.graphics.setColor(self._outlineColor)
	love.graphics.setLineWidth(self._outlineWidth or 1)
	self:drawShape 'line'
	love.graphics.pop()
end

local Rectangle = newElementClass('Rectangle', Shape)

function Rectangle:cornerRadius(cornerRadiusX, cornerRadiusY)
	checkArgument(1, cornerRadiusX, 'number')
	checkOptionalArgument(2, cornerRadiusY, 'number')
	self._cornerRadiusX = cornerRadiusX
	self._cornerRadiusY = cornerRadiusY or cornerRadiusX
	return self
end

function Rectangle:drawShape(mode)
	love.graphics.rectangle(mode, 0, 0, self:get 'width', self:get 'height',
		self._cornerRadiusX, self._cornerRadiusY)
end

--- Draws an ellipse.
--
-- Extends the @{Shape} class.
-- @type Ellipse
local Ellipse = newElementClass('Ellipse', Shape)

function Ellipse:pointInBounds(x, y)
	checkArgument(1, x, 'number')
	checkArgument(2, y, 'number')
	local rx, ry = self:get('width')/2, self:get('height')/2
	return ((x - rx) ^ 2) / (rx ^ 2) + ((y - ry) ^ 2) / (ry ^ 2) <= 1
end

--- Sets the number of segments used to draw the ellipse.
-- @number segments
function Ellipse:segments(segments)
	checkArgument(1, segments, 'number')
	self._segments = segments
	return self
end

function Ellipse:drawShape(mode)
	love.graphics.ellipse(mode,
		self:get 'width' / 2, self:get 'height' / 2,
		self:get 'width' / 2, self:get 'height' / 2,
		self._segments)
end

--- A base class for elements that are made up of a set
-- of points. This class isn't useful on its own;
-- it's meant to be extended by custom classes.
--
-- Extends the @{Element} class.
-- @type Points
local Points = newElementClass('Points', Element)

function Points:new(...)
	self._points = self._points or {}
	checkCondition(select('#', ...) > 0, 'must specify at least one point')
	checkCondition(select('#', ...) % 2 == 0, 'must provide an even number of arguments. '
		.. 'The arguments represent a series of (x, y) coordinates.')
	-- add the points to the table and get the bounds.
	-- these bounds will become the dimensions of the element.
	local minX, minY, maxX, maxY
	for i = 1, select('#', ...), 2 do
		local x, y = select(i, ...)
		checkArgument(i, x, 'number')
		checkArgument(i + 1, y, 'number')
		minX = minX and math.min(minX, x) or x
		minY = minY and math.min(minY, y) or y
		maxX = maxX and math.max(maxX, x) or x
		maxY = maxY and math.max(maxY, y) or y
		table.insert(self._points, x)
		table.insert(self._points, y)
	end
	-- adjust the points to be with respect to the position
	-- of the element
	for i = 1, #self._points, 2 do
		self._points[i] = self._points[i] - minX
		self._points[i + 1] = self._points[i + 1] - minY
	end
	self._x = minX
	self._y = minY
	self._width = maxX - minX
	self._height = maxY - minY
end

function Points:width(width)
	-- scale the points to match the new width
	local factor = width / self:get 'width'
	for i = 1, #self._points, 2 do
		self._points[i] = self._points[i] * factor
	end
	-- resize the element as usual
	Points.parent.width(self, width)
	return self
end

function Points:height(height)
	-- scale the points to match the new height
	local factor = height / self:get 'height'
	for i = 1, #self._points, 2 do
		self._points[i + 1] = self._points[i + 1] * factor
	end
	-- resize the element as usual
	Points.parent.height(self, height)
	return self
end

--- Draws a line.
--
-- Extends the @{Points} class.
-- @type Line
local Line = newElementClass('Line', Points)

--- Sets the color of the line.
-- @tparam table|number r the red component of the color, or a table containing all of the color components
-- @number[opt] g the green component of the color
-- @number[opt] b the blue component of the color
-- @number[opt] a the alpha component of the color
function Line:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
	return self
end

--- Sets the thickness of the line.
-- @number width
function Line:lineWidth(width)
	checkArgument(1, width, 'number')
	self._lineWidth = width
	return self
end

function Line:_drawLine()
	love.graphics.push 'all'
	love.graphics.setLineWidth(self._lineWidth)
	love.graphics.line(self._points)
	love.graphics.pop()
end

function Line:stencil()
	self:_drawLine()
end

function Line:drawBottom()
	love.graphics.push 'all'
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	end
	self:_drawLine()
	love.graphics.pop()
end

--- Draws an polygon.
--
-- Extends the @{Points} class and the @{Shape} class.
-- @type Polygon
local Polygon = newElementClass('Polygon', Points, Shape)

function Polygon:drawShape(mode)
	love.graphics.polygon(mode, self._points)
end

local Text = newElementClass('Text', Element)

Text.clearMode._wrapInfo = 'none'

function Text:_calculateSize()
	local limit = self._limit or math.huge
	self._wrapInfo = self._wrapInfo or {}
	self._wrapInfo[self._font] = self._wrapInfo[self._font] or {}
	self._wrapInfo[self._font][self._text] = self._wrapInfo[self._font][self._text] or {}
	self._wrapInfo[self._font][self._text][limit] = self._wrapInfo[self._font][self._text][limit] or {
		self._font:getWrap(self._text, limit)
	}
	local info = self._wrapInfo[self._font][self._text][limit]
	self._textWidth = self._limit or info[1]
	self._textHeight = #info[2] * self._font:getHeight() * self._font:getLineHeight()
	self:width(self._textWidth)
	self:height(self._textHeight)
end

function Text:new(font, text, align, limit, x, y)
	checkArgument(2, font, 'Font')
	checkArgument(3, text, 'string', 'number')
	checkOptionalArgument(4, align, 'string')
	checkOptionalArgument(5, limit, 'number')
	checkOptionalArgument(6, x, 'number')
	checkOptionalArgument(7, y, 'number')
	self._font = font
	self._text = text
	self._align = align or 'left'
	self._limit = limit
	self._x = x
	self._y = y
	self:_calculateSize()
	self:transparent()
end

function Text:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
	return self
end

function Text:shadowColor(r, g, b, a)
	self:setColor('_shadowColor', r, g, b, a)
	return self
end

function Text:shadowOffset(shadowOffsetX, shadowOffsetY)
	checkArgument(1, shadowOffsetX, 'number')
	checkOptionalArgument(2, shadowOffsetY, 'number')
	self._shadowOffsetX = shadowOffsetX
	self._shadowOffsetY = shadowOffsetY or shadowOffsetX
	return self
end

function Text:scale(scaleX, scaleY)
	checkArgument(1, scaleX, 'number')
	checkOptionalArgument(2, scaleY, 'number')
	self:width(self._textWidth * scaleX)
	self:height(self._textHeight * (scaleY or scaleX))
	return self
end

function Text:drawBottom()
	love.graphics.push 'all'
	love.graphics.setFont(self._font)
	if self:isColorSet(self._shadowColor) then
		love.graphics.setColor(self._shadowColor)
		love.graphics.printf(
			self._text,
			self._shadowOffsetX or 1, self._shadowOffsetY or 1,
			self._textWidth,
			self._align,
			0,
			self:get 'width' / self._textWidth, self:get 'height' / self._textHeight
		)
	end
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.printf(
		self._text,
		0, 0,
		self._textWidth,
		self._align,
		0,
		self:get 'width' / self._textWidth, self:get 'height' / self._textHeight
	)
	love.graphics.pop()
end

local Image = newElementClass('Image', Element)

function Image:new(image, x, y)
	checkArgument(2, image, 'Image')
	checkOptionalArgument(3, x, 'number')
	checkOptionalArgument(4, y, 'number')
	self._image = image
	self._x = x
	self._y = y
	self._width, self._height = image:getDimensions()
end

function Image:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
	return self
end

function Image:scale(scaleX, scaleY)
	checkArgument(1, scaleX, 'number')
	checkOptionalArgument(2, scaleY, 'number')
	self:width(self._image:getWidth() * scaleX)
	self:height(self._image:getHeight() * (scaleY or scaleX))
	return self
end

function Image:drawBottom()
	love.graphics.push 'all'
	if self:isColorSet(self._color) then
		love.graphics.setColor(self._color)
	end
	love.graphics.draw(self._image, 0, 0, 0, self._width / self._image:getWidth(),
		self._height / self._image:getHeight())
	love.graphics.pop()
end

local elementClasses = {
	element = Element,
	ellipse = Ellipse,
	image = Image,
	line = Line,
	points = Points,
	polygon = Polygon,
	rectangle = Rectangle,
	shape = Shape,
	text = Text,
}

local function validateElementClass(argumentIndex, class)
	checkArgument(argumentIndex, class, 'string', 'table')
	if type(class) == 'string' then
		checkCondition(elementClasses[class], string.format("no built-in element class called '%s'", class))
	end
end

local Ui = {}

function Ui:__index(k)
	if Ui[k] then return Ui[k] end
	self._functionCache[k] = self._functionCache[k] or function(_, ...)
		local element = self:getElement '@current'
		checkCondition(element, string.format("no element to call function '%s' on", k))
		checkCondition(element[k], string.format("currently selected element has no function '%s'", k))
		element[k](element, ...)
		return self
	end
	return self._functionCache[k]
end

function Ui:_clear(element)
	for k, v in pairs(element) do
		local clearMode = element.clearMode[k] or 'shallow'
		if clearMode ~= 'none' then
			if type(v) == 'table' then
				if clearMode == 'shallow' then
					shallowClear(v)
				elseif clearMode == 'deep' then
					deepClear(v)
				end
			else
				element[k] = nil
			end
		end
	end
end

function Ui:_validateElement(name)
	checkArgument(1, name, 'string', 'table')
	local element = self:getElement(name)
	local message = name == '@current' and 'No element is currently selected. Have you created any elements yet?'
		or name == '@previous' and 'no previous element to get'
		or name == '@parent' and 'No parent element to get. This keyword should be used '
			.. 'within ui:beginChildren() and ui:endChildren() calls.'
		or string.format("element must be an element table or the keyword '@current', '@previous', or '@parent'")
	checkCondition(element, message)
end

function Ui:_pushGroup()
	self._currentGroup = self._currentGroup + 1
	-- create a new group table if needed
	if not self._groups[self._currentGroup] then
		self._groups[self._currentGroup] = {}
	end
	local group = self._groups[self._currentGroup]
	-- reset the group table
	group.elementCount = group.elementCount or {}
	for k in pairs(group.elementCount) do
		group.elementCount[k] = nil
	end
	group.selected = nil
end

function Ui:_popGroup()
	self._currentGroup = self._currentGroup - 1
end

function Ui:_getNextElementName(element)
	-- if the user set a name for the next element, use that name
	if self._nextElementName then
		local name = self._nextElementName
		self._nextElementName = false
		return name
	end
	--[[
		otherwise, autogenerate the name [elementClassName][number],
		where number is how many unnamed elements of that type
		there have been so far (e.g. rectangle1, image3)
	]]
	local className = element.className
	local group = self._groups[self._currentGroup]
	group.elementCount[className] = group.elementCount[className] or 0
	group.elementCount[className] = group.elementCount[className] + 1
	return className .. group.elementCount[className]
end

function Ui:getElement(element)
	checkOptionalArgument(1, element, 'string', 'table')
	element = element or '@current'
	if type(element) == 'table' then return element end
	if element == '@current' then
		return self._groups[self._currentGroup].selected
	elseif element == '@previous' then
		return self._groups[self._currentGroup].previous
	elseif element == '@parent' then
		local parentGroup = self._groups[self._currentGroup - 1]
		return parentGroup.selected
	end
end

function Ui:getName(element)
	self:_validateElement(element)
	element = self:getElement(element)
	return element._name
end

function Ui:getId(element)
	self:_validateElement(element)
	element = self:getElement(element)
	local id = ''
	if element._parent then
		id = id .. self:getId(element._parent) .. ' > '
	end
	id = id .. self:getName(element)
	return id
end

function Ui:getState(element)
	self:_validateElement(element)
	element = self:getElement(element)
	return self._state[element:get 'id']
end

function Ui:get(element, propertyName, ...)
	self:_validateElement(element)
	checkArgument(2, propertyName, 'string')
	element = self:getElement(element)
	checkCondition(element.get[propertyName], string.format("element has no property named '%s'", propertyName))
	return element:get(propertyName, ...)
end

function Ui:begin()
	-- clear the tree
	for i in ipairs(self._tree) do
		self._tree[i] = nil
	end
	-- mark all elements as unused
	for _, element in ipairs(self._pool) do
		element._used = false
	end
	-- remove unused element state
	for id in pairs(self._state) do
		if not self._stateUsed[id] then
			self._state[id] = nil
		end
	end
	for id in pairs(self._stateUsed) do
		self._stateUsed[id] = nil
	end
	-- reset the group stack
	self._currentGroup = 0
	self:_pushGroup()
	self._finished = false
end

function Ui:select(element)
	self:_validateElement(element)
	local currentGroup = self._groups[self._currentGroup]
	currentGroup.previous = currentGroup.selected
	currentGroup.selected = self:getElement(element)
end

function Ui:create(class, ...)
	validateElementClass(1, class)
	-- if we just finished drawing, start a new frame
	if self._finished then self:begin() end
	-- get the element class if a name was provided
	if type(class) == 'string' then
		class = elementClasses[class]
	end
	-- reuse an existing element if possible
	local element
	for _, e in ipairs(self._pool) do
		if not e._used then
			element = e
			break
		end
	end
	-- otherwise, create a new one
	if not element then
		element = {}
		table.insert(self._pool, element)
	end
	-- clear out the element
	self:_clear(element)
	-- initialize the element
	setmetatable(element, class)
	element._used = true
	element.ui = self
	element._name = self:_getNextElementName(element)
	local parentGroup = self._groups[self._currentGroup - 1]
	if parentGroup then
		element._parent = parentGroup.selected
	end
	-- initialize the element state if needed
	local id = element:get 'id'
	self._stateUsed[id] = true
	if not self._state[id] then
		self._state[id] = {}
		element:initState(self._state[id], ...)
	end
	element:new(...)
	return element
end

function Ui:add(element)
	checkArgument(1, element, 'table')
	local parentGroup = self._groups[self._currentGroup - 1]
	if parentGroup then
		parentGroup.selected:onAddChild(element)
	else
		table.insert(self._tree, element)
	end
	return self
end

function Ui:new(class, ...)
	local element = self:create(class, ...)
	self:add(element)
	self:select(element)
	return self
end

function Ui:name(name)
	self._nextElementName = name
	return self
end

function Ui:beginChildren()
	self:_pushGroup()
	return self
end

function Ui:endChildren()
	self:_popGroup()
	return self
end

function Ui:_processMouseEvents()
	local mouseX, mouseY = love.mouse.getPosition()
	local dx, dy = mouseX - self._mouseXPrevious, mouseY - self._mouseYPrevious
	self._mouseXPrevious, self._mouseYPrevious = mouseX, mouseY
	for button = 1, numMouseButtons do
		local down = love.mouse.isDown(button)
		self._mousePressed[button] = down and not self._mouseDownPrevious[button]
		self._mouseReleased[button] = self._mouseDownPrevious[button] and not down
		self._mouseDownPrevious[button] = down
	end
	for _, element in ipairs(self._tree) do
		element:_processMouseEvents(mouseX, mouseY, dx, dy, self._mousePressed, self._mouseReleased)
	end
end

function Ui:draw()
	self:_processMouseEvents()
	for _, element in ipairs(self._tree) do
		element:draw()
	end
	self._finished = true
	return self
end

function Ui:drawDebug()
	for _, element in ipairs(self._tree) do
		element:drawDebug()
	end
	return self
end

function charm.new()
	return setmetatable({
		_functionCache = {},
		_pool = {},
		_tree = {},
		_state = {},
		_stateUsed = {},
		_groups = {},
		_currentGroup = 1,
		_finished = true,
		_nextElementName = false,
		_mouseXPrevious = love.mouse.getX(),
		_mouseYPrevious = love.mouse.getY(),
		_mouseDownPrevious = {},
		_mousePressed = {},
		_mouseReleased = {},
	}, Ui)
end

function charm.extend(className, parent, ...)
	if parent then validateElementClass(2, parent) end
	if type(parent) == 'string' then parent = elementClasses[parent] end
	parent = parent or elementClasses.element
	local mixins = {...}
	for i, mixin in ipairs(mixins) do
		validateElementClass(2 + i, mixin)
		if type(mixin) == 'string' then
			mixins[i] = elementClasses[mixin]
		end
	end
	return newElementClass(className, parent, unpack(mixins))
end

return charm
