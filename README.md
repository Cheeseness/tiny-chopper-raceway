# Tiny Chopper Raceway
Tiny Chopper Raceway is an example top down drifting/racing game made using the MIT licenced [Godot engine](http://godotengine.org/). This game was initially made in two hours as part of a talk on making games quickly for the Tasmanian Linux User Group in March 2016. A little additional polish was added, but it still has a number of rough edges. Wear gloves when handling!

Big thanks to Attitude for his work on music and audio, and a special thank you to all my Patreon supporters (see SUPPORTERS.md for details).

In this file, you can find:

* Licence information for code, assets and third party assets
* Instructions for playing the game
* Instructions for editing and/or running the game 
* Notes on how to navigate the game's codebase and resources
* Some helpful/related URLs

I hope you find something useful from playing Tiny Chopper Raceway and exploring its code!

-Cheese


## Licences
All source code within this repository is licenced under the [GNU Lesser General Public Licence 3.0](http://www.gnu.org/licenses/lgpl.txt), allowing you to use, share, and modify any or all parts of the codebase so long as they retain this licence and that you make source changes available to anybody you distribute modified versions to. See the file COPYING for the full licence. Yay!

Excluding the files noted below, all assets are were created by Josh "Cheeseness" Bush and released into the public domain via the [Creative Commons 0](http://creativecommons.org/publicdomain/zero/1.0/) dedication. Under these terms, you are free to do whatever you like with the assets in this repository (the items noted below are subject to their own licence requirements - or not, they're all CC0 too!). Yay!

### Third Party Sound Effects
The timing, length and volume of these samples has been modified to suit Tiny Chopper Raceway.

* [bang-04-clean](http://freesound.org/people/Eelke/sounds/170424/) Eelke, available  via [Creative Commons 0](http://creativecommons.org/publicdomain/zero/1.0/)
* [HQ Explosion](http://freesound.org/people/Quaker540/sounds/245372/) Quaker540, available  via [Creative Commons 0](http://creativecommons.org/publicdomain/zero/1.0/)
* [Crowd.Yay.Applause.25ppl.Long.wav](http://freesound.org/people/jessepash/sounds/139973/) jessepash, available  via [Creative Commons 0](http://creativecommons.org/publicdomain/zero/1.0/)
* [crash.wav](http://freesound.org/people/sagetyrtle/sounds/40158/) sagetyrtle, available via [Creative Commons 0](http://creativecommons.org/publicdomain/zero/1.0/)

### Third Party Fonts
This font has been rendered to a bitmap FNT font.

* [NASDAQER](https://fontlibrary.org/en/font/nasdaqer) (used as nasdaqer.fnt) Gustavo Paz, licenced under Creative Commons: [Attribution-ShakeAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/)


## Play Instructions
Guide your helicopter around tracks and through obstacle courses to get the fastest time.

* Up, W, Z, Keypad 8, Left stick up: Increase throttle
* Down, S, O, Keypad 2, Left stick down: Decrease throttle
* Left, A, Q, Keypad 4, Right stick left: Steer counter-clockwise
* Right, D, E, Keypad 6, Right stick right: Steer clockwise
* Escape: Pause


## Running The Game
If you have downloaded a pre-packaged version of the game for Linux, Mac OS or Windows from the Tiny Chopper Raceway [GitHub repository](https://github.com/Cheeseness/tiny-chopper-raceway/releases) or [Itch.io page](http://cheeseness.itch.io/tiny-chopper-raceway). Extract the relevant archive for your platform and run it!

If you have downloaded [the game's source](https://github.com/Cheeseness/tiny-chopper-raceway), you can select the "godot" folder from the _Godot Project Manager_ and click the _Run_ button on the right to run it.


## Editing The Game In Godot
If you have downloaded [the game's source](https://github.com/Cheeseness/tiny-chopper-raceway) to experiment with yourself, you can select the _godot_ folder from the _Godot Project Manager_ and click the _Edit_ button on the right to open Tiny Chopper Raceway in the Godot editor.


## Understanding The Godot Project and Source Code
The Tiny Chopper Raceway Godot project can be found in the _godot_ folder. There are very few code comments (this may change in the future!). Here are some notes to help you navigate the codebase and resources.

### Folder Structure

* The **godot/fonts** folder contains the font used by the game
* The **godot/levels** folder contains Godot scenes that represent a playable level (a root node plus a TileMap)
* The **godot/menus** folder contains Godot scenes that represent each of the game's GUI menus
* The **godot/music** folder contains music used by the game in OGG format
* The **godot/objects** folder contains Godot scenes that represent individual game objects (checkpoints obstacles, pickups, the player's chopper) as well as the in-game HUD
* The **godot/scripts** folder contains all of the gdscript code files
* The **godot/sounds** folder contains all of the sound samples used by the game in WAV or OGG format as well as an XML file containing the Godot sample library used by the game
* The **godot/sprites** folder contains all the 2D sprites used by the game in PNG format
* The **godot/tilemaps** folder contains a Godot scene used as a template for the TileMap, the TileMap, and all of the tile images used by the TileMap

### Code Files
The game's code is stored in the _godot/scripts_ folder and consists of the following scripts:

* **checkpoint.gd** includes a checkpoint_id variable and collision handler that calls the advance_checkpoint() function in player_chopper.gd
* **level_loader.gd** includes code to programmatically instantiate and unload levels, as well as code to replace TileMap tiles with more complex objects
* **menu.gd** contains the list of available levels, shows/hides submenus, has code to handle interactions between menus and the level_loader and has code to toggle the windowed/fullscreen state
* **menu_credits.gd** consists of code to load text data from credits.txt
* **menu_level_chooser.gd** includes code to populate a list with the names of available levels and launch the desired one
* **menu_level_end.gd** contains code for formatting and displaying end-of-level data (play time, fastest lap, deaths, etc.)
* **menu_options.gd** contains code to interact with the rest of the game based on the player's selections
* **pickup.gd** includes code for randomly selecting a pickup type and colouring it accordingly, as wel as a collision handler that calls the apply_pickup() function in player_chopper.gd
* **player_chopper.gd** includes code for handling user input, managing chopper state, keeping track of statistics and displaying checkpoint indicators
* **player_hud.gd** includes code for formatting and displaying current data (play time, laps, health, fuel and current pickup effect)

### Asset Sources and Extra Stuff
Along with the game itself, which can be found in the _godot_ folder, the [Tiny Chopper Raceway repository](https://github.com/Cheeseness/tiny-chopper-raceway) also includes a copy of the presentation on making a Godot game in 2 hours (presentation.odp) and sources for all of the assets that were pre-created for it.

More information can be found in _sources/readme.md_


## Helpful URLs
* [More information on Tiny Chopper Raceway](http://cheeseness.itch.io/tiny-chopper-raceway)
* [Tiny Chopper Raceway Source Code and Assets](https://github.com/Cheeseness/tiny-chopper-raceway)
* [Godot Documentation](http://docs.godotengine.org/)
* [Support Cheese Making Games](http://patreon.com/cheeseness)
