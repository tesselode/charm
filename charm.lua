local charm = {}

unpack = unpack or table.unpack -- luacheck: ignore

local function clear(t)
	for k, v in pairs(t) do
		if type(v) == 'table' then
			clear(v)
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
		love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
	end
	love.graphics.pop()
end

local Ui = {}
Ui.__index = Ui

function Ui:_getElement(name)
	if name == '@current' then
		return self._elements[self._activeElements]
	elseif name == '@previous' then
		return self._elements[self._activeElements - 1]
	end
	for i = self._activeElements, 1, -1 do
		local element = self._elements[i]
		if element.name == name then
			return element
		end
	end
end

function Ui:_getNewElement(type)
	self._activeElements = self._activeElements + 1
	local element
	if self._elements[self._activeElements] then
		element = self._elements[self._activeElements]
		clear(element)
	else
		element = {}
		table.insert(self._elements, element)
	end
	element.type = type
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
	local element = self:_getElement '@current'
	element.x = x - element.w * anchor
	return self
end

function Ui:left(x) return self:x(x, 0) end
function Ui:center(x) return self:x(x, .5) end
function Ui:right(x) return self:x(x, 1) end

function Ui:y(y, anchor)
	local element = self:_getElement '@current'
	element.y = y - element.h * anchor
	return self
end

function Ui:top(y) return self:y(y, 0) end
function Ui:middle(y) return self:y(y, .5) end
function Ui:bottom(y) return self:y(y, 1) end

function Ui:name(name)
	local element = self:_getElement '@current'
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

function Ui:rectangle(x, y, w, h)
	local element = self:_getNewElement 'rectangle'
	element.x = x or 0
	element.y = y or 0
	element.w = w or 0
	element.h = h or 0
	return self
end

function Ui:draw()
	for i = 1, self._activeElements do
		local element = self._elements[i]
		draw[element.type](element)
	end
	self._activeElements = 0
	return self
end

function charm.new()
	return setmetatable({
		_elements = {},
		_activeElements = 0,
	}, Ui)
end

return charm
