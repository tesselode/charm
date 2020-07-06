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
	self.width = width or 0
	self.height = height or 0
end

function Element:layout(minWidth, minHeight, maxWidth, maxHeight)
	return clamp(self.width, minWidth, maxWidth), clamp(self.height, minHeight, maxHeight)
end

function Element:drawDebug(width, height)
	love.graphics.push 'all'
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle('line', 0, 0, width, height)
	love.graphics.pop()
end

local elementClasses = {
	element = Element,
}

local Ui = {}
Ui.__index = Ui

function Ui:new(class, x, y, ...)
	local element = setmetatable({}, elementClasses[class])
	element:new(...)
	table.insert(self._elements, element)
	self._x[element] = x
	self._y[element] = y
	return self
end

function Ui:_layout()
	for _, element in ipairs(self._elements) do
		self._width[element], self._height[element] = element:layout(0, 0, math.huge, math.huge)
	end
end

function Ui:_drawDebug()
	for _, element in ipairs(self._elements) do
		love.graphics.push()
			love.graphics.translate(self._x[element], self._y[element])
			element:drawDebug(self._width[element], self._height[element])
		love.graphics.pop()
	end
end

function Ui:draw()
	self:_layout()
	self:_drawDebug()
end

function charm.new()
	return setmetatable({
		_elements = {},
		_x = {},
		_y = {},
		_width = {},
		_height = {},
	}, Ui)
end

return charm
