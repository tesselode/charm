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

function Element:init(width, height)
	self._width = width or 0
	self._height = height or 0
	self._children = self._children or {}
	self._childX = self._childX or {}
	self._childY = self._childY or {}
	self._childWidth = self._childWidth or {}
	self._childHeight = self._childHeight or {}
end

function Element:add(element, x, y)
	table.insert(self._children, element)
	self._childX[element] = x
	self._childY[element] = y
end

function Element:layout(minWidth, minHeight, maxWidth, maxHeight)
	local width, height = clamp(self._width, minWidth, maxWidth), clamp(self._height, minHeight, maxHeight)
	for _, child in ipairs(self._children) do
		local childX, childY = self._childX[child], self._childY[child]
		local childMinWidth = math.max(minWidth - childX, 0)
		local childMinHeight = math.max(minHeight - childY, 0)
		local childMaxWidth = math.max(maxWidth - childX, 0)
		local childMaxHeight = math.max(maxHeight - childY, 0)
		local childWidth, childHeight = child:layout(childMinWidth, childMinHeight, childMaxWidth, childMaxHeight)
		self._childWidth[child], self._childHeight[child] = childWidth, childHeight
	end
	return width, height
end

function Element:drawDebug(width, height)
	love.graphics.push 'all'
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle('line', 0, 0, width, height)
		for _, child in ipairs(self._children) do
			love.graphics.push()
				love.graphics.translate(self._childX[child], self._childY[child])
				child:drawDebug(self._childWidth[child], self._childHeight[child])
			love.graphics.pop()
		end
	love.graphics.pop()
end

local elementClasses = {
	element = Element,
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

function Ui:add(element, x, y)
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
