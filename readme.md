Charm <!-- omit in toc -->
=====
Charm is a library for LÖVE that makes it easier to arrange and draw graphics, such as shapes, images, and text. It excels at relative positioning, which can become cumbersome as a layout gets more complex. It also handles mouse events, so it can be used for basic UI tasks, like creating buttons.

This library is similar to [Boxer](https://github.com/tesselode/boxer), but it's **immediate mode**, which means that instead of creating objects that represent each graphic you want to draw, you simply tell Charm what you want to draw on each frame.

Table of contents <!-- omit in toc -->
-----------------

Installation
------------
To use Charm, place charm.lua in your project, and then `require` it in each file where you need to use it:

```lua
local charm = require 'charm' -- if your charm.lua is in the root directory
local charm = require 'path.to.charm' -- if it's in subfolders
```

API
---

### charm
The main module that lets you create new `Ui` objects and element classes.

#### Functions

##### `local ui = charm.new()`
Creates a new `Ui` object.

##### `local ElementClass = charm.extend(parent)`
Creates a new element class.

Parameters:
- `parent` (`ElementClass` or `string`) (optional, defaults to `'base'`) - the element class the new class should inherit from

Returns:
- `elementClass` (`ElementClass`) - the new element class

### Ui
Manages and draws graphical elements.

#### Functions

##### `Ui:beginChildren()`
Starts adding children to the currently selected element.

##### `Ui:draw()`
Draws the previously added elements and updates their state. After `draw` is called, the next `new` call will clear out the existing elements.

##### `Ui:endChildren()`
Stops adding children to the current parent element and re-selects the parent element.

##### `local value = Ui:get(element, propertyName, ...)`
Gets the value of an element property.

Parameters:
- `element` (`Element` or `string`) - the element or name of the element to get the property from
- `propertyName` (`string`) - the name of the property to get the value of
- `...` - additional arguments to pass to the property getter function

Returns:
- `value` - the value of the property

##### `local element = Ui:getElement(name)`
Gets the table representing an element.

Parameters:
- `name` (`string`) - the name of the element, or one of the following keywords:
  - `'@current'` - the currently selected element
  - `'@previous'` - the previously selected element
  - `'@parent'` - the parent of the currently selected element (if there is one)

Returns:
- `element` (`Element` or `nil`) - the element table, or `nil` if there's no element with the given name or no element that matches the given keyword

##### `local elementState = Ui:getState(element)`
Gets the persistent state table for an element.

Parameters:
- `element` (`Element` or `string`) - the element or name of the element to get the state of

Returns:
- `elementState` (`table` or `nil`) - the persistent state of the element, or `nil` if the element doesn't have a persistent state

##### `Ui:new(elementClass, ...)`
Adds a new element to be drawn this frame.

Parameters:
- `elementClass` (`ElementClass` or `string`) - the type of element to add
- `...` - additional arguments to pass to the element class' constructor

Returns:
- `self` (`Ui`) - itself

##### `Ui:select(element)`
Sets the element that subsequent function calls should modify.

Parameters:
- `element` (`Element`) - the element to select


Contributing
------------
Charm is in very early development. Feel free to request features, point out bugs, and even make some pull requests! If you use this library in a game, let me know how it goes.
