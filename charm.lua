local charm = {}

unpack = unpack or table.unpack -- luacheck: ignore

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

local draw = {}

function draw:rectangle()
	love.graphics.push 'all'
	if self.fillColor then
		love.graphics.setColor(unpack(self.fillColor))
		love.graphics.rectangle('fill', 0, 0, self.w, self.h)
	end
	love.graphics.pop()
end

local Ui = {}
Ui.__index = Ui

function Ui:_getElement(name)
	if name == '@previous' then
		return self._elements[self._activeElements - 1]
	end
	for i = self._activeElements, 1, -1 do
		local element = self._elements[i]
		if element.name == name then
			return element
		end
	end
end

function Ui:_getCurrentElement()
	return self._elements[self._activeElements]
end

function Ui:_getNewElement(type)
	self._activeElements = self._activeElements + 1
	local element
	if self._elements[self._activeElements] then
		element = self._elements[self._activeElements]
		deepClear(element)
	else
		element = {}
		table.insert(self._elements, element)
	end
	element.type = type
	if self._grouping then
		table.insert(self._toBeGrouped, element)
	end
	return element
end

function Ui:getX(name, anchor)
	anchor = anchor or 0
	local element = self:_getElement(name)
	return element.x + element.w * anchor
end

function Ui:getLeft(name) return self:getX(name, 0) end
function Ui:getCenter(name) return self:getX(name, .5) end
function Ui:getRight(name) return self:getX(name, 1) end

function Ui:getY(name, anchor)
	anchor = anchor or 0
	local element = self:_getElement(name)
	return element.y + element.h * anchor
end

function Ui:getTop(name) return self:getY(name, 0) end
function Ui:getMiddle(name) return self:getY(name, .5) end
function Ui:getBottom(name) return self:getY(name, 1) end

function Ui:x(x, anchor)
	local element = self:_getCurrentElement()
	element.x = x - element.w * anchor
	return self
end

function Ui:left(x) return self:x(x, 0) end
function Ui:center(x) return self:x(x, .5) end
function Ui:right(x) return self:x(x, 1) end

function Ui:y(y, anchor)
	local element = self:_getCurrentElement()
	element.y = y - element.h * anchor
	return self
end

function Ui:top(y) return self:y(y, 0) end
function Ui:middle(y) return self:y(y, .5) end
function Ui:bottom(y) return self:y(y, 1) end

function Ui:name(name)
	local element = self:_getCurrentElement()
	element.name = name
	return self
end

function Ui:fillColor(r, g, b, a)
	local element = self._elements[self._activeElements]
	element.fillColor = element.fillColor or {}
	if type(r) == 'table' then
		for i = 1, 4 do element.fillColor[i] = r[i] end
	else
		element.fillColor[1] = r
		element.fillColor[2] = g
		element.fillColor[3] = b
		element.fillColor[4] = a
	end
	return self
end

function Ui:beginGroup()
	self._grouping = true
	return self
end

function Ui:endGroup(padding)
	padding = padding or 0
	self._grouping = false
	-- get the bounds of the group
	local left = self._toBeGrouped[1].x
	local top = self._toBeGrouped[1].y
	local right = self._toBeGrouped[1].x + self._toBeGrouped[1].w
	local bottom = self._toBeGrouped[1].y + self._toBeGrouped[1].h
	for i = 2, #self._toBeGrouped do
		left = math.min(left, self._toBeGrouped[i].x)
		top = math.min(top, self._toBeGrouped[i].y)
		right = math.max(right, self._toBeGrouped[i].x + self._toBeGrouped[i].w)
		bottom = math.max(bottom, self._toBeGrouped[i].y + self._toBeGrouped[i].h)
	end
	-- apply padding
	left = left - padding
	top = top - padding
	right = right + padding
	bottom = bottom + padding
	-- make the new rectangle
	self:rectangle(left, top, right - left, bottom - top)
	-- add the grouped elements as children of the rectangle
	for _, element in ipairs(self._toBeGrouped) do
		element.parentIndex = self._activeElements
		element.x = element.x - left
		element.y = element.y - top
	end
	-- clear the group queue
	shallowClear(self._toBeGrouped)
	return self
end

function Ui:rectangle(x, y, w, h)
	local element = self:_getNewElement 'rectangle'
	element.x = x or 0
	element.y = y or 0
	element.w = w or 0
	element.h = h or 0
	return self
end

function Ui:draw(parentIndex)
	for i = 1, self._activeElements do
		local element = self._elements[i]
		if element.parentIndex == parentIndex then
			love.graphics.push 'all'
			love.graphics.translate(element.x, element.y)
			draw[element.type](element)
			self:draw(i)
			love.graphics.pop()
		end
	end
	self._activeElements = 0
	self._grouping = false
	shallowClear(self._toBeGrouped)
	return self
end

function charm.new()
	return setmetatable({
		_elements = {},
		_activeElements = 0,
		_grouping = false,
		_toBeGrouped = {},
	}, Ui)
end

return charm
