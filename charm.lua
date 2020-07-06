local charm = {}

local function clear(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

local function clamp(x, min, max)
	return x < min and min or x > max and max or x
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

function Element:add(x, y, element)
	table.insert(self.children, element)
	self.childX[element] = x
	self.childY[element] = y
	return self
end

function Element:layoutChildren(minWidth, minHeight, maxWidth, maxHeight)
	for _, child in ipairs(self.children) do
		local childX, childY = self.childX[child], self.childY[child]
		local childMinWidth = math.max(minWidth - childX, 0)
		local childMinHeight = math.max(minHeight - childY, 0)
		local childMaxWidth = math.max(maxWidth - childX, 0)
		local childMaxHeight = math.max(maxHeight - childY, 0)
		local childWidth, childHeight = child:layout(childMinWidth, childMinHeight, childMaxWidth, childMaxHeight)
		self.childWidth[child], self.childHeight[child] = childWidth, childHeight
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
	return clamp(self.width, minWidth, maxWidth), clamp(self.height, minHeight, maxHeight)
end

local Wrapper = newElementClass(Element)

function Wrapper:layout(minWidth, minHeight, maxWidth, maxHeight)
	self:layoutChildren(minWidth, minHeight, maxWidth, maxHeight)
	local width, height = 0, 0
	for _, child in ipairs(self.children) do
		width = math.max(width, self.childX[child] + self.childWidth[child])
		height = math.max(height, self.childY[child] + self.childHeight[child])
	end
	return width, height
end

local Aligner = newElementClass(Element)

function Aligner:init(width, height, alignX, alignY)
	if alignX == 'left' then alignX = 0 end
	if alignX == 'center' then alignX = .5 end
	if alignX == 'right' then alignX = 1 end
	if alignY == 'top' then alignY = 0 end
	if alignY == 'center' then alignY = .5 end
	if alignY == 'bottom' then alignY = 1 end
	self.width = width
	self.height = height
	self._alignX = alignX
	self._alignY = alignY
	Element.init(self)
end

function Aligner:layout(minWidth, minHeight, maxWidth, maxHeight)
	local width, height = clamp(self.width, minWidth, maxWidth), clamp(self.height, minHeight, maxHeight)
	self:layoutChildren(minWidth, minHeight, maxWidth, maxHeight)
	if self._alignX then
		local targetX = width * self._alignX
		for _, child in ipairs(self.children) do
			self.childX[child] = targetX - self.childWidth[child] * self._alignX
		end
	end
	if self._alignY then
		local targetY = height * self._alignY
		for _, child in ipairs(self.children) do
			self.childY[child] = targetY - self.childHeight[child] * self._alignY
		end
	end
	return width, height
end

local elementClasses = {
	element = Element,
	box = Box,
	wrapper = Wrapper,
	aligner = Aligner,
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
