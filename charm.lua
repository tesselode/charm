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
		-- keys that should not be cleared out when a new draw
		-- frame is started
		preserve = setmetatable({}, {
			__index = parent and parent.preserve,
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
		-- copy preserved keys
		for k, v in pairs(mixinClass.preserve) do
			class.preserve[k] = v
		end
	end
	return class
end

local Element = newElementClass 'Element'

Element.preserve._parent = true
Element.preserve._ui = true
Element.preserve._stencil = true

function Element:new(x, y, width, height)
	self._x = x
	self._y = y
	self._width = width
	self._height = height
end

function Element:initState(state) end

function Element:getState()
	return self._ui:getState(self)
end

function Element:pointInBounds(x, y)
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
	return self._ui:getName(self)
end

function Element.get:id()
	return self._ui:getId(self)
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
	origin = origin or 0
	return (self._x or 0) + self:get 'width' * origin
end

function Element.get:left() return self:get('x', 0) end
function Element.get:centerX() return self:get('x', .5) end
function Element.get:right() return self:get('x', 1) end

function Element.get:y(origin)
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
	button = button or 1
	local state = self:getState()
	return state.held[button]
end

function Element.get:clicked(button)
	button = button or 1
	local state = self:getState()
	return state.clicked[button]
end

function Element.get:dragged(button)
	button = button or 1
	local state = self:getState()
	return state.draggedX[button], state.draggedY[button]
end

function Element:origin(originX, originY)
	self._originX = originX
	self._originY = originY
end

function Element:width(width)
	local originX = self._originX or 0
	local x = self:get('x', originX)
	self._width = width
	self:x(x, originX)
end

function Element:height(height)
	local originY = self._originY or 0
	local y = self:get('y', originY)
	self._height = height
	self:y(y, originY)
end

function Element:size(width, height)
	self:width(width)
	self:height(height)
end

function Element:x(x, origin)
	origin = origin or 0
	self._originX = origin
	self._x = x - self:get 'width' * origin
end

function Element:left(x) self:x(x, 0) end
function Element:centerX(x) self:x(x, .5) end
function Element:right(x) self:x(x, 1) end

function Element:y(y, origin)
	origin = origin or 0
	self._originY = origin
	self._y = y - self:get 'height' * origin
end

function Element:top(y) self:y(y, 0) end
function Element:centerY(y) self:y(y, .5) end
function Element:bottom(y) self:y(y, 1) end

function Element:bounds(left, top, right, bottom)
	self._x = left
	self._y = top
	self._width = right - left
	self._height = bottom - top
end

function Element:rectangle(x, y, width, height)
	self._x = x
	self._y = y
	self._width = width
	self._height = height
end

function Element:shift(dx, dy)
	self._x = self._x + dx
	self._y = self._y + dy
end

function Element:shiftChildren(dx, dy)
	if not self:hasChildren() then return end
	for _, child in ipairs(self._children) do
		child:shift(dx, dy)
	end
end

function Element:wrap()
	if not self:hasChildren() then return end
	local left, top, right, bottom = self:get 'childrenBounds'
	self:bounds(left + self:get 'x', top + self:get 'y',
		right + self:get 'x', bottom + self:get 'y')
	self:shiftChildren(-left, -top)
end

function Element:padLeft(padding)
	self:shiftChildren(padding, 0)
	self:width(self:get 'width' + padding)
end

function Element:padTop(padding)
	self:shiftChildren(0, padding)
	self:height(self:get 'height' + padding)
end

function Element:padRight(padding)
	self:width(self:get 'width' + padding)
end

function Element:padBottom(padding)
	self:height(self:get 'height' + padding)
end

function Element:padHorizontal(padding)
	self:padLeft(padding)
	self:padRight(padding)
end

function Element:padVertical(padding)
	self:padTop(padding)
	self:padBottom(padding)
end

function Element:pad(padding)
	self:padHorizontal(padding)
	self:padVertical(padding)
end

function Element:clip()
	self._clip = true
end

function Element:transparent()
	self._transparent = true
end

function Element:opaque()
	self._transparent = false
end

function Element:addChild(child)
	self._children = self._children or {}
	table.insert(self._children, child)
end

function Element:onEnter(f)
	self._onEnter = self._onEnter or {}
	table.insert(self._onEnter, f)
end

function Element:onExit(f)
	self._onExit = self._onExit or {}
	table.insert(self._onExit, f)
end

function Element:onClick(f)
	self._onClick = self._onClick or {}
	table.insert(self._onClick, f)
end

function Element:onDrag(f)
	self._onDrag = self._onDrag or {}
	table.insert(self._onDrag, f)
end

function Element:drawBottom() end

function Element:drawTop() end

function Element:_processMouseEvents(x, y, dx, dy, pressed, released, blocked)
	local mouseInBounds = self:pointInBounds(x - self:get 'x', y - self:get 'y')
	-- if clipping is enabled, and the mouse is not within the parent
	-- element's bounds, then none of the children can be hovered
	if self._clip and not mouseInBounds then blocked = true end
	--[[
		process mouse events for each child, starting from the
		topmost one. if any child returns true, indicating that it's
		"taking" the mouse input, then no child below it or the parent
		element can be hovered.
	]]
	if self._children then
		for i = #self._children, 1, -1 do
			local child = self._children[i]
			if child:_processMouseEvents(x - self:get 'x', y - self:get 'y', dx, dy, pressed, released, blocked) then
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
	if state.entered and self._onEnter then
		for _, f in ipairs(self._onEnter) do f() end
	end
	-- the element is "exited" if it just started stopped hovered
	-- this frame
	state.exited = hoveredPrevious and not hovered
	if state.exited and self._onExit then
		for _, f in ipairs(self._onExit) do f() end
	end
	for button = 1, numMouseButtons do
		-- the element is "clicked" if it was held down and the button
		-- was released over the element this frame
		state.clicked[button] = hovered and state.held[button] and released[button]
		if state.clicked[button] and self._onClick then
			for _, f in ipairs(self._onClick) do f(button) end
		end
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
			for _, f in ipairs(self._onDrag) do f(button, dx, dy) end
		else
			state.draggedX[button] = false
			state.draggedY[button] = false
		end
	end
	-- return true if this element would block elements below it
	-- from receiving mouse input
	return blocked or (mouseInBounds and not self._transparent)
end

function Element:stencil() end

function Element:_drawChildren(stencilValue)
	if not self._children then return end
	-- if clipping is enabled, "push" a stencil to the "stack"
	if self.clip then
		self._stencil = self._stencil or function()
			self:stencil()
		end
		stencilValue = stencilValue + 1
		love.graphics.push 'all'
		love.graphics.stencil(self._stencil, 'increment', 1, true)
		love.graphics.setStencilTest('gequal', stencilValue)
	end
	for _, child in ipairs(self._children) do
		child:draw()
	end
	-- if clipping is enabled, "pop" a stencil from the "stack"
	if self.clip then
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
end

function Shape:outlineColor(r, g, b, a)
	self:setColor('_outlineColor', r, g, b, a)
end

function Shape:outlineWidth(outlineWidth)
	self._outlineWidth = outlineWidth
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
	self._cornerRadiusX = cornerRadiusX
	self._cornerRadiusY = cornerRadiusY or cornerRadiusX
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
	local rx, ry = self:get('width')/2, self:get('height')/2
	return ((x - rx) ^ 2) / (rx ^ 2) + ((y - ry) ^ 2) / (ry ^ 2) <= 1
end

--- Sets the number of segments used to draw the ellipse.
-- @number segments
function Ellipse:segments(segments)
	--checkArgument(1, segments, 'number')
	self._segments = segments
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
	--[[ checkCondition(select('#', ...) > 0, 'must specify at least one point')
	checkCondition(select('#', ...) % 2 == 0, 'must provide an even number of arguments. '
		.. 'The arguments represent a series of (x, y) coordinates.') ]]
	-- add the points to the table and get the bounds.
	-- these bounds will become the dimensions of the element.
	local minX, minY, maxX, maxY
	for i = 1, select('#', ...), 2 do
		local x, y = select(i, ...)
		--[[ checkArgument(i, x, 'number')
		checkArgument(i + 1, y, 'number') ]]
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
end

function Points:height(height)
	-- scale the points to match the new height
	local factor = height / self:get 'height'
	for i = 1, #self._points, 2 do
		self._points[i + 1] = self._points[i + 1] * factor
	end
	-- resize the element as usual
	Points.parent.height(self, height)
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
end

--- Sets the thickness of the line.
-- @number width
function Line:lineWidth(width)
	--checkArgument(1, width, 'number')
	self._lineWidth = width
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

Text.preserve._wrapInfo = true

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
	self._font = font
	self._text = text
	self._align = align or 'left'
	self._limit = limit
	self._x = x
	self._y = y
	self:_calculateSize()
end

function Text:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
end

function Text:shadowColor(r, g, b, a)
	self:setColor('_shadowColor', r, g, b, a)
end

function Text:shadowOffset(shadowOffsetX, shadowOffsetY)
	self._shadowOffsetX = shadowOffsetX
	self._shadowOffsetY = shadowOffsetY or shadowOffsetX
end

function Text:scale(scaleX, scaleY)
	self:width(self._textWidth * scaleX)
	self:height(self._textHeight * (scaleY or scaleX))
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
	self._image = image
	self._x = x
	self._y = y
	self._width, self._height = image:getDimensions()
end

function Image:color(r, g, b, a)
	self:setColor('_color', r, g, b, a)
end

function Image:scale(scaleX, scaleY)
	self:width(self._image:getWidth() * scaleX)
	self:height(self._image:getHeight() * (scaleY or scaleX))
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
		local selected = self._groups[self._currentGroup].selected
		selected[k](selected, ...)
		return self
	end
	return self._functionCache[k]
end

function Ui:_clear(element)
	for k, v in pairs(element) do
		if not element.preserve[k] then
			if type(v) == 'table' then
				for kk in pairs(v) do
					v[kk] = nil
				end
			else
				element[k] = nil
			end
		end
	end
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
	element = self:getElement(element)
	return element._name
end

function Ui:getId(element)
	element = self:getElement(element)
	local id = ''
	if element._parent then
		id = id .. self:getId(element._parent) .. ' > '
	end
	id = id .. self:getName(element)
	return id
end

function Ui:getState(element)
	element = self:getElement(element)
	return self._state[element:get 'id']
end

function Ui:get(element, propertyName, ...)
	element = self:getElement(element)
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
	local currentGroup = self._groups[self._currentGroup]
	currentGroup.previous = currentGroup.selected
	currentGroup.selected = self:getElement(element)
end

function Ui:new(class, ...)
	-- if we just finished drawing, start a new frame
	if self._finished then self:begin() end
	local parentGroup = self._groups[self._currentGroup - 1]
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
	element._ui = self
	element._name = self:_getNextElementName(element)
	if parentGroup then
		element._parent = parentGroup.selected
	end
	element:new(...)
	-- initialize the element state if needed
	local id = element:get 'id'
	self._stateUsed[id] = true
	if not self._state[id] then
		self._state[id] = {}
		element:initState(self._state[id])
	end
	-- add the element to the tree
	if parentGroup then
		parentGroup.selected:addChild(element)
	else
		table.insert(self._tree, element)
	end
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
