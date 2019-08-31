local charm = {}

local function newElementClass(parent)
	local class = setmetatable({}, parent)
	class.__index = class
	return class
end

local Element = {}

Element.base = newElementClass()

function Element.base:new(x, y, width, height)
	self.x = x or 0
	self.y = y or 0
	self.width = width or 0
	self.height = height or 0
end

function Element.base:draw()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

Element.rectangle = newElementClass(Element.base)

local Ui = {}
Ui.__index = Ui

function Ui:_getElementClass(className)
	if type(className) == 'table' then return className end
	return Element[className]
end

function Ui:new(className, ...)
	local element
	for _, e in ipairs(self._elementPool) do
		if not e._used then
			element = e
			break
		end
	end
	if not element then
		element = {}
		table.insert(self._elementPool, element)
	end
	element._used = true
	setmetatable(element, self:_getElementClass(className))
	if element.new then element:new(...) end
	table.insert(self._elements, element)
	return self
end

function Ui:_draw()
	for _, element in ipairs(self._elements) do
		if element.draw then element:draw() end
	end
end

function Ui:_finish()
	for elementIndex = #self._elements, 1, -1 do
		self._elements[elementIndex] = nil
	end
	for _, element in ipairs(self._elementPool) do
		element._used = false
	end
end

function Ui:draw()
	self:_draw()
	self:_finish()
end

function charm.new()
	return setmetatable({
		_elements = {},
		_elementPool = {},
	}, Ui)
end

return charm
