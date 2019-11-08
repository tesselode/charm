Charm <!-- omit in toc -->
=====
Charm is a library for LÖVE that makes it easier to arrange and draw graphics, such as shapes, images, and text. It excels at relative positioning, which can become cumbersome as a layout gets more complex. It also handles mouse events, so it can be used for basic UI tasks, like creating buttons.

This library is similar to [Boxer](https://github.com/tesselode/boxer), but it's **immediate mode**, which means that instead of creating objects that represent each graphic you want to draw, you simply tell Charm what you want to draw on each frame.

Table of contents <!-- omit in toc -->
-----------------
- [Installation](#installation)
- [API](#api)
  - [Base](#base)
    - [Properties](#properties)
      - [`Base.get` (table)](#baseget-table)
      - [`Base.preserve` (table)](#basepreserve-table)
    - [Functions](#functions)
      - [`Base:afterDraw()`](#baseafterdraw)
      - [`Base:beforeDraw()`](#basebeforedraw)
      - [`Base:bottom(y)`](#basebottomy)
      - [`Base:center(x)`](#basecenterx)
      - [`Base:clip()`](#baseclip)
      - [`local containsPoint = Base:containsPoint(x, y)`](#local-containspoint--basecontainspointx-y)
      - [`Base:drawSelf()`](#basedrawself)
      - [`local bottom = Base.get:bottom()`](#local-bottom--basegetbottom)
      - [`local center = Base.get:center()`](#local-center--basegetcenter)
      - [`local dragged = Base.get:dragged(button)`](#local-dragged--basegetdraggedbutton)
      - [`local entered = Base.get:entered()`](#local-entered--basegetentered)
      - [`local exited = Base.get:exited()`](#local-exited--basegetexited)
      - [`local height = Base.get:height()`](#local-height--basegetheight)
      - [`local held = Base.get:held(button)`](#local-held--basegetheldbutton)
      - [`local hovered = Base.get:hovered()`](#local-hovered--basegethovered)
      - [`local left = Base.get:left()`](#local-left--basegetleft)
      - [`local middle = Base.get:middle()`](#local-middle--basegetmiddle)
      - [`local pressed = Base.get:pressed(button)`](#local-pressed--basegetpressedbutton)
      - [`local released = Base.get:released(button)`](#local-released--basegetreleasedbutton)
      - [`local right = Base.get:right()`](#local-right--basegetright)
      - [`local width, height = Base.get:size()`](#local-width-height--basegetsize)
      - [`local top = Base.get:top()`](#local-top--basegettop)
      - [`local width = Base.get:width()`](#local-width--basegetwidth)
      - [`local x = Base.get:x(anchor)`](#local-x--basegetxanchor)
      - [`local y = Base.get:y(anchor)`](#local-y--basegetyanchor)
      - [`local z = Base.get:z()`](#local-z--basegetz)
      - [`local state = Base:getState()`](#local-state--basegetstate)
      - [`Base:height(height)`](#baseheightheight)
      - [`Base:left(x)`](#baseleftx)
      - [`Base:middle(y)`](#basemiddley)
      - [`Base:name(name)`](#basenamename)
      - [`Base:new(...)`](#basenew)
      - [`Base:onAddChild(element)`](#baseonaddchildelement)
      - [`Base:opaque()`](#baseopaque)
      - [`Base:right(x)`](#baserightx)
      - [`Base:size(width)`](#basesizewidth)
      - [`Base:shift(dx, dy)`](#baseshiftdx-dy)
      - [`Base:stencil()`](#basestencil)
      - [`Base:top(y)`](#basetopy)
      - [`Base:transparent()`](#basetransparent)
      - [`Base:width(width)`](#basewidthwidth)
      - [`Base:wrap(padding)`](#basewrappadding)
      - [`Base:x(x, anchor)`](#basexx-anchor)
      - [`Base:y(y, anchor)`](#baseyy-anchor)
      - [`Base:z(z)`](#basezz)
  - [charm](#charm)
    - [Functions](#functions-1)
      - [`local ElementClass = charm.extend(parent)`](#local-elementclass--charmextendparent)
      - [`local ui = charm.new()`](#local-ui--charmnew)
  - [Ui](#ui)
    - [Functions](#functions-2)
      - [`Ui:beginChildren()`](#uibeginchildren)
      - [`Ui:draw()`](#uidraw)
      - [`Ui:endChildren()`](#uiendchildren)
      - [`local value = Ui:get(element, propertyName, ...)`](#local-value--uigetelement-propertyname)
      - [`local element = Ui:getElement(name)`](#local-element--uigetelementname)
      - [`local elementState = Ui:getState(element)`](#local-elementstate--uigetstateelement)
      - [`Ui:new(elementClass, ...)`](#uinewelementclass)
      - [`Ui:select(element)`](#uiselectelement)
    - [`Ui:start()`](#uistart)
- [Contributing](#contributing)

Installation
------------
To use Charm, place charm.lua in your project, and then `require` it in each file where you need to use it:

```lua
local charm = require 'charm' -- if your charm.lua is in the root directory
local charm = require 'path.to.charm' -- if it's in subfolders
```

API
---

### Base
A definition for a type of element that a `Ui` can draw.

#### Properties

##### `Base.get` (table)
A table of functions that can be accessed via `Ui.get`. Additional arguments to `Ui.get` will be passed to these functions, and `Ui.get` will return whatever these functions return.

##### `Base.preserve` (table)
A list of all of the keys of an element instance that should not be cleared out when a new draw frame is started.

#### Functions

##### `Base:afterDraw()`
Called after the element is drawn.

##### `Base:beforeDraw()`
Called before the element is drawn.

##### `Base:bottom(y)`
Sets the y position of the bottom edge of the element.

Parameters:
- `y` (`number`) - the desired y position

Returns:
- `state` (`table`)

##### `Base:center(x)`
Sets the x position of the horizontal center of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:clip()`
Enables clipping for this element, causing child elements to be drawn cropped to this element's visible area.

##### `local containsPoint = Base:containsPoint(x, y)`
Gets whether a point is within the element's bounds.

Returns:
- `containsPoint` (`boolean`)

##### `Base:drawSelf()`
Defines the drawing operations used to display the element on screen.

##### `local bottom = Base.get:bottom()`
Returns the y position of the bottom edge of the element.

Returns:
- `bottom` (`number`)

##### `local center = Base.get:center()`
Returns the x position of the horizontal center of the element.

Returns:
- `center` (`number`)

##### `local dragged = Base.get:dragged(button)`
Returns whether the element was dragged by a certain mouse button this frame, and if so, how far it was dragged.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `dragged` (`boolean`)
- `dx` (`number` or `nil`) - the number of pixels the element was dragged horizontally, or `nil` if it wasn't dragged
- `dy` (`number` or `nil`) - the number of pixels the element was dragged vertically, or `nil` if it wasn't dragged

##### `local entered = Base.get:entered()`
Returns whether the element was entered by the mouse this frame.

Returns:
- `entered` (`boolean`)

##### `local exited = Base.get:exited()`
Returns whether the element was exited by the mouse this frame.

Returns:
- `exited` (`boolean`)

##### `local height = Base.get:height()`
Returns the height of the element.

Returns:
- `height` (`number`)

##### `local held = Base.get:held(button)`
Returns whether the element was held by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `held` (`boolean`)

##### `local hovered = Base.get:hovered()`
Returns whether the element was hovered by the mouse this frame.

Returns:
- `hovered` (`boolean`)

##### `local left = Base.get:left()`
Returns the x position of the left edge of the element.

Returns:
- `left` (`number`)

##### `local middle = Base.get:middle()`
Returns the y position of the vertical center of the element.

Returns:
- `middle` (`number`)

##### `local pressed = Base.get:pressed(button)`
Returns whether the element was pressed by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `pressed` (`boolean`)

##### `local released = Base.get:released(button)`
Returns whether the element was released by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `released` (`boolean`)

##### `local right = Base.get:right()`
Returns the x position of the right edge of the element.

Returns:
- `right` (`number`)

##### `local width, height = Base.get:size()`
Returns the width and height of the element.

Returns:
- `width` (`number`)
- `height` (`number`)

##### `local top = Base.get:top()`
Returns the y position of the top edge of the element.

Returns:
- `top` (`number`)

##### `local width = Base.get:width()`
Returns the width of the element.

Returns:
- `width` (`number`)

##### `local x = Base.get:x(anchor)`
Returns the x position of a certain point along the element's x-axis.

Parameters:
- `anchor` (`number`) (defaults to `0`) - the point along the x-axis to get (`0` is left, `.5` is center, `1` is right)

Returns:
- `x` (`number`)

##### `local y = Base.get:y(anchor)`
Returns the y position of a certain point along the element's y-axis.

Parameters:
- `anchor` (`number`) (defaults to `0`) - the point along the y-axis to get (`0` is top, `.5` is middle, `1` is bottom)

Returns:
- `y` (`number`)

##### `local z = Base.get:z()`
Returns the z position of the element.

Returns:
- `z` (`number`)

##### `local state = Base:getState()`
Gets the persistent state of the element.

##### `Base:height(height)`
Sets the height of the element.

Parameters:
- `height` (`number`)

##### `Base:left(x)`
Sets the x position of the left edge of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:middle(y)`
Sets the y position of the vertical center of the element.

Parameters:
- `y` (`number`) - the desired y position

##### `Base:name(name)`
Gives the element a name. This is required to use persistent state.

Parameters:
- `name` (`string`)

##### `Base:new(...)`
Called when the element is initialized. Additional arguments from `Ui.new` will be passed to this function.

##### `Base:onAddChild(element)`
Called when an element is added as this element's child.

Parameters:
- `element` (`Element`) - the child element

##### `Base:opaque()`
Sets the element to be opaque, meaning that this element will block mouse events from elements behind it.

##### `Base:right(x)`
Sets the x position of the right edge of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:size(width)`
Sets the width and height of the element.

Parameters:
- `width` (`number`)
- `height` (`number`)

##### `Base:shift(dx, dy)`
Shifts the element by a certain number of pixels horizontally and vertically.

Parameters:
- `dx` (`number`) (defaults to `0`) - the amount of the shift the element horizontally
- `dy` (`number`) (defaults to `0`) - the amount of the shift the element vertically

##### `Base:stencil()`
Defines the drawing operations used to crop child elements if clipping is enabled.

##### `Base:top(y)`
Sets the y position of the top edge of the element.

Parameters:
- `y` (`number`) - the desired y position

##### `Base:transparent()`
Sets the element to be transparent, meaning that mouse events can pass through this element to elements behind it.

##### `Base:width(width)`
Sets the width of the element.

Parameters:
- `width` (`number`)

##### `Base:wrap(padding)`
Adjusts the element to perfectly surround all of its children. The children's positions will be adjusted so they maintain the same position on screen.

Parameters:
- `padding` (`number`, defaults to `0`) - the amount of extra space to surround the children with

##### `Base:x(x, anchor)`
Sets the x position of a point along the element's x-axis.

Parameters:
- `x` (`number`) - the desired x position
- `anchor` (`number`) (defaults to `0`) - the position along the x-axis to set (`0` is left, `.5` is center, `1` is right)

##### `Base:y(y, anchor)`
Sets the y position of a point along the element's y-axis.

Parameters:
- `y` (`number`) - the desired y position
- `anchor` (`number`) (defaults to `0`) - the position along the y-axis to set (`0` is left, `.5` is center, `1` is right)

##### `Base:z(z)`
Sets the z position of the element.

Parameters:
- `z` (`number`)

### charm
The main module that lets you create new `Ui` objects and element classes.

#### Functions

##### `local ElementClass = charm.extend(parent)`
Creates a new element class.

Parameters:
- `parent` (`ElementClass` or `string`) (optional, defaults to `'base'`) - the element class the new class should inherit from

Returns:
- `elementClass` (`ElementClass`) - the new element class

##### `local ui = charm.new()`
Creates a new `Ui` object.

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

#### `Ui:start()`
Manually starts a new draw frame. Normally this is called automatically the first time you call `Ui:new()` after calling `Ui:draw()`.

Returns:
- `self` (`Ui`) - itself

Contributing
------------
Charm is in very early development. Feel free to request features, point out bugs, and even make some pull requests! If you use this library in a game, let me know how it goes.
