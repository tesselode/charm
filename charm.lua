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

function Ui:rectangle(x, y, w, h)
	local element = self:_getNewElement 'rectangle'
	element.x = x or 0
	element.y = y or 0
	element.w = w or 0
	element.h = h or 0
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
