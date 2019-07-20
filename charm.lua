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
		lineWidth = function(self, width) self.lineWidth = width end,
	},
	draw = function(self)
		love.graphics.push 'all'
		if self.fillColor then
			love.graphics.setColor(unpack(self.fillColor))
			love.graphics.rectangle('fill', 0, 0, self.w, self.h)
		end
		if self.outlineColor then
			love.graphics.setColor(unpack(self.outlineColor))
			love.graphics.setLineWidth(self.lineWidth or 1)
			love.graphics.rectangle('line', 0, 0, self.w, self.h)
		end
		love.graphics.pop()
	end,
}

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

function Ui:_getElementClass(element)
	if type(element.type) == 'string' then
		return Element[element.type]
	end
	return element.type
end

function Ui:_getNewElement()
	self._activeElements = self._activeElements + 1
	local element
	if self._elements[self._activeElements] then
		element = self._elements[self._activeElements]
		deepClear(element)
	else
		element = {}
		table.insert(self._elements, element)
	end
	if self._currentGroup > 0 then
		self._groupQueue[self._currentGroup] = self._groupQueue[self._currentGroup] or {}
		table.insert(self._groupQueue[self._currentGroup], element)
	end
	return element
end

function Ui:new(type, ...)
	local element = self:_getNewElement()
	element.type = type
	local elementClass = self:_getElementClass(element)
	elementClass.new(element, ...)
	return self
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

function Ui:getWidth(name) return self:_getElement(name).w end
function Ui:getHeight(name) return self:_getElement(name).h end
function Ui:getSize(name) return self:getWidth(name), self:getHeight(name) end

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

function Ui:width(width)
	local element = self:_getCurrentElement()
	element.w = width
	return self
end

function Ui:height(height)
	local element = self:_getCurrentElement()
	element.h = height
	return self
end

function Ui:size(width, height)
	width, height = width or 0, height or 0
	self:width(width)
	self:height(height)
	return self
end

function Ui:shift(dx, dy)
	dx, dy = dx or 0, dy or 0
	local element = self:_getCurrentElement()
	element.x = element.x + dx
	element.y = element.y + dy
	return self
end

function Ui:name(name)
	local element = self:_getCurrentElement()
	element.name = name
	return self
end

function Ui:set(property, ...)
	local element = self:_getCurrentElement()
	local elementClass = self:_getElementClass(element)
	elementClass.set[property](element, ...)
	return self
end

function Ui:beginGroup()
	self._currentGroup = self._currentGroup + 1
	return self
end

function Ui:endGroup(padding)
	padding = padding or 0
	local queue = self._groupQueue[self._currentGroup]
	self._currentGroup = self._currentGroup - 1
	-- get the bounds of the group
	local left = queue[1].x
	local top = queue[1].y
	local right = queue[1].x + queue[1].w
	local bottom = queue[1].y + queue[1].h
	for i = 2, #queue do
		left = math.min(left, queue[i].x)
		top = math.min(top, queue[i].y)
		right = math.max(right, queue[i].x + queue[i].w)
		bottom = math.max(bottom, queue[i].y + queue[i].h)
	end
	-- apply padding
	left = left - padding
	top = top - padding
	right = right + padding
	bottom = bottom + padding
	-- make the new rectangle
	self:new('rectangle', left, top, right - left, bottom - top)
	-- add the grouped elements as children of the rectangle
	for _, element in ipairs(queue) do
		element.parentIndex = self._activeElements
		element.x = element.x - left
		element.y = element.y - top
	end
	-- clear the group queue
	shallowClear(queue)
	return self
end

function Ui:draw(parentIndex)
	for i = 1, self._activeElements do
		local element = self._elements[i]
		local elementClass = self:_getElementClass(element)
		if element.parentIndex == parentIndex then
			love.graphics.push 'all'
			love.graphics.translate(element.x, element.y)
			elementClass.draw(element)
			self:draw(i)
			love.graphics.pop()
		end
	end
	self._activeElements = 0
	-- reset groups
	while self._currentGroup > 0 do
		shallowClear(self._groupQueue[self._currentGroup])
		self._currentGroup = self._currentGroup - 1
	end
	return self
end

function charm.new()
	return setmetatable({
		_elements = {},
		_activeElements = 0,
		_currentGroup = 0,
		_groupQueue = {},
	}, Ui)
end

return charm
