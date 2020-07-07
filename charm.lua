local charm = {}

local function clear(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

local function clamp(x, min, max)
	return x < min and min or x > max and max or x
end

local function shrinkConstraints(minWidth, minHeight, maxWidth, maxHeight, offsetX, offsetY)
	return math.max(minWidth - offsetX, 0),
		math.max(minHeight - offsetY, 0),
		math.max(maxWidth - offsetX, 0),
		math.max(maxHeight - offsetY, 0)
end

local function constrain(width, height, minWidth, minHeight, maxWidth, maxHeight)
	return clamp(width, minWidth, maxWidth), clamp(height, minHeight, maxHeight)
end

local function newElementClass(parent)
	local class = setmetatable({}, {__index = parent})
	class.__index = class
	return class
end

local Element = newElementClass()

function Element:init()
	self.children = self.children or {}
	self.childX = self.childX or {}
	self.childY = self.childY or {}
	self.childWidth = self.childWidth or {}
	self.childHeight = self.childHeight or {}
end

function Element:getChildX(child)
	return self.childX[child]
end

function Element:getChildY(child)
	return self.childY[child]
end

function Element:getChildPosition(child)
	return self:getChildX(child), self:getChildY(child)
end

function Element:setChildX(child, x)
	self.childX[child] = x
end

function Element:setChildY(child, y)
	self.childY[child] = y
end

function Element:setChildPosition(child, x, y)
	self:setChildX(child, x)
	self:setChildY(child, y)
end

function Element:shiftChildren(dx, dy)
	for _, child in ipairs(self.children) do
		self.childX[child] = self.childX[child] + dx
		self.childY[child] = self.childY[child] + dy
	end
end

function Element:add(x, y, element)
	table.insert(self.children, element)
	self:setChildPosition(element, x, y)
	return self
end

function Element:layoutChildren(minWidth, minHeight, maxWidth, maxHeight)
	for _, child in ipairs(self.children) do
		self.childWidth[child], self.childHeight[child] = child:layout(
			shrinkConstraints(minWidth, minHeight, maxWidth, maxHeight, self:getChildPosition(child))
		)
	end
end

function Element:layout(minWidth, minHeight, maxWidth, maxHeight)
	self:layoutChildren(minWidth, minHeight, maxWidth, maxHeight)
	return minWidth, minHeight
end

function Element:drawDebug(width, height)
	love.graphics.push 'all'
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle('line', 0, 0, width, height)
		for _, child in ipairs(self.children) do
			love.graphics.push()
				love.graphics.translate(self.childX[child], self.childY[child])
				child:drawDebug(self.childWidth[child], self.childHeight[child])
			love.graphics.pop()
		end
	love.graphics.pop()
end

local Box = newElementClass(Element)

function Box:init(width, height)
	self.width = width
	self.height = height
	Element.init(self)
end

function Box:layout(minWidth, minHeight, maxWidth, maxHeight)
	self:layoutChildren(minWidth, minHeight, maxWidth, maxHeight)
	return constrain(self.width, self.height, minWidth, minHeight, maxWidth, maxHeight)
end

local Wrapper = newElementClass(Element)

function Wrapper:init()
	self.paddingLeft = 0
	self.paddingTop = 0
	self.paddingRight = 0
	self.paddingBottom = 0
	Element.init(self)
end

function Wrapper:padLeft(amount)
	self.paddingLeft = amount
	return self
end

function Wrapper:padTop(amount)
	self.paddingTop = amount
	return self
end

function Wrapper:padRight(amount)
	self.paddingRight = amount
	return self
end

function Wrapper:padBottom(amount)
	self.paddingBottom = amount
	return self
end

function Wrapper:padHorizontal(amount)
	return self:padLeft(amount):padRight(amount)
end

function Wrapper:padVertical(amount)
	return self:padTop(amount):padBottom(amount)
end

function Wrapper:pad(amount)
	return self:padHorizontal(amount):padVertical(amount)
end

function Wrapper:layout(minWidth, minHeight, maxWidth, maxHeight)
	self:shiftChildren(self.paddingLeft, self.paddingTop)
	self:layoutChildren(minWidth - self.paddingRight, minHeight - self.paddingBottom,
		maxWidth - self.paddingRight, maxHeight - self.paddingBottom)
	local width, height = 0, 0
	for _, child in ipairs(self.children) do
		width = math.max(width, self.childX[child] + self.childWidth[child])
		height = math.max(height, self.childY[child] + self.childHeight[child])
	end
	width = width + self.paddingRight
	height = height + self.paddingBottom
	return width, height
end

local Row = newElementClass(Element)

function Row:init(distributeMode, width, height)
	self.distributeMode = distributeMode or 'stack'
	self.spacing = 0
	self.width = width
	self.height = height
	Element.init(self)
end

function Row:setSpacing(spacing)
	self.spacing = spacing
	return self
end

function Row:add(element)
	Element.add(self, 0, 0, element)
	return self
end

function Row:getChildrenTotalWidth()
	local width = 0
	for _, child in ipairs(self.children) do
		width = width + self.childWidth[child]
	end
	return width
end

function Row:distribute()
	if self.distributeMode == 'stack' then
		local nextX = 0
		for _, child in ipairs(self.children) do
			self.childX[child] = nextX
			nextX = self.childX[child] + self.childWidth[child] + self.spacing
		end
	end
end

function Row:layout(minWidth, minHeight, maxWidth, maxHeight)
	local width, height = constrain(self.width or maxWidth, self.height or maxHeight,
		minWidth, minHeight, maxWidth, maxHeight)
	-- first, get the desired width of each child given no constraints
	self:layoutChildren(0, 0, math.huge, height)
	-- shrink the children proportionally to fit the parent if necessary
	local totalWidth = self:getChildrenTotalWidth()
	local availableWidth = width
	if self.distributeMode == 'stack' then
		availableWidth = availableWidth - self.spacing * #self.children - 1
		availableWidth = math.max(availableWidth, 0)
	end
	if totalWidth > availableWidth then
		for _, child in ipairs(self.children) do
			self.childWidth[child] = self.childWidth[child] * availableWidth / totalWidth
		end
	end
	self:distribute()
	return width, height
end

local elementClasses = {
	element = Element,
	box = Box,
	wrapper = Wrapper,
	row = Row,
}

local Ui = {}
Ui.__index = Ui

function Ui:begin()
	clear(self._children)
	for _, element in ipairs(self._elementPool) do
		self._isElementUsed[element] = nil
	end
	self._finished = false
end

function Ui:_clearElement(element)
	for k, v in pairs(element) do
		if type(v) == 'table' then
			clear(v)
		else
			element[k] = nil
		end
	end
end

function Ui:_getUnusedElement()
	for _, element in ipairs(self._elementPool) do
		if not self._isElementUsed[element] then
			self._isElementUsed[element] = true
			self:_clearElement(element)
			return element
		end
	end
	local element = {}
	table.insert(self._elementPool, element)
	self._isElementUsed[element] = true
	return element
end

function Ui:new(class, ...)
	local element = self:_getUnusedElement()
	setmetatable(element, elementClasses[class])
	element:init(...)
	return element
end

function Ui:add(x, y, element)
	if self._finished then self:begin() end
	table.insert(self._children, element)
	self._childX[element] = x
	self._childY[element] = y
	return self
end

function Ui:_layout()
	for _, element in ipairs(self._children) do
		self._childWidth[element], self._childHeight[element] = element:layout(0, 0, math.huge, math.huge)
	end
end

function Ui:_drawDebug()
	for _, element in ipairs(self._children) do
		love.graphics.push()
			love.graphics.translate(self._childX[element], self._childY[element])
			element:drawDebug(self._childWidth[element], self._childHeight[element])
		love.graphics.pop()
	end
end

function Ui:draw()
	self:_layout()
	self:_drawDebug()
	self._finished = true
end

function charm.new()
	return setmetatable({
		_elementPool = {},
		_isElementUsed = {},
		_children = {},
		_childX = {},
		_childY = {},
		_childWidth = {},
		_childHeight = {},
		_finished = false,
	}, Ui)
end

return charm
