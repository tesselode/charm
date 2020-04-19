## v0.4 - in progress
This release brings back mouse events and is generally aimed at polishing the parts of Charm that worked well in previous versions.

Changes:
- The `preserve` table in element classes is replaced with `clearMode` for more customization over how fields are cleared
- Elements have internal state again, but with some changes:
	- Elements must be named *before* they're created
	- Elements that aren't named will be automatically assigned a name. This means that all elements can have internal state, even if the user didn't set a name.
- Re-added mouse event functionality
	- Elements now have a very simple "event" system where they can emit events, triggering functions that were registered to the event on that frame. This is mainly to provide a nicer syntax for checking for mouse events.
- Removed the `Transform` element, as it was buggy and confusing
- Consolidated the `Text` and `Paragraph` elements into one `Text` element, which can optionally have a horizontal limit and line wrapping. The new `Text` element is also more memory efficient than the old `Paragraph` element.
- For now, you can no longer get an element by name. The names are purely for tracking the state of elements between frames.
- Added the `drawDebug` for displaying useful debugging info about elements

## v0.3 - 2/9/20
This release is aimed at refocusing Charm on being a good library for drawing and arranging graphics.

Main changes:
- Removed support for mouse events
- Removed element state
- Added the transform element for applying arbitrary transformations to child elements, like rotation and scaling
- Added `Shape` and `Points` base classes to make it easier to write certain kinds of custom elements
- Added `Line` and `Polygon` elements
- Renamed `Ui` to `Layout`

## v0.2 - 12/6/19
This release is aimed at making Charm more extensible.

Main changes:
- The element types are now full fledged classes, and you can make your own classes that inherit from the built-in ones
- Much of the behavior of Charm now lives in the element classes. For example, `x`, `middle`, `wrap`, etc. are all functions on the base element class, and the `Ui` object just forwards function calls to the currently selected element
  - Instead of using `Ui.getX`, you use `Ui:get('@current', 'x')`, which calls the property getter named `x` that lives in the element class
  - Element classes now manage their own state, and they can add anything they want to the state table
- There's some new callbacks, like `onAddChild`

## v0.1 - 8/29/19
Commit arbitrarily chosen to be the "first release"
