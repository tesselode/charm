local charm = {}

local function clamp(x, min, max)
	return x < min and min or x > max and max or x
end

local function newElementClass(parent)
	local class = setmetatable({}, {__index = parent})
	class.__index = class
	return class
end

local Element = newElementClass()

function Element:new(width, height)
	self._width = width or 0
	self._height = height or 0
	self._children = self._children or {}
	self._childX = self._childX or {}
	self._childY = self._childY or {}
	self._childWidth = self._childWidth or {}
	self._childHeight = self._childHeight or {}
end

function Element:addChild(element, x, y)
	table.insert(self._children, element)
	self._childX[element] = x
	self._childY[element] = y
end

function Element:layout(minWidth, minHeight, maxWidth, maxHeight)
	local width, height = clamp(self._width, minWidth, maxWidth), clamp(self._height, minHeight, maxHeight)
	for _, child in ipairs(self._children) do
		local childX, childY = self._childX[child], self._childY[child]
		self._childWidth[child], self._childHeight[child] = child:layout(minWidth - childX, minHeight - childY,
			width - childX, height - childY)
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

function Ui:createElement(class, ...)
	local element = setmetatable({}, elementClasses[class])
	element:new(...)
	return element
end

function Ui:addChild(element, x, y)
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
end

function charm.new()
	return setmetatable({
		_children = {},
		_childX = {},
		_childY = {},
		_childWidth = {},
		_childHeight = {},
	}, Ui)
end

return charm
