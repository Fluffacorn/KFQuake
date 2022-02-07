# KFQuake
***THIS IS NOT A REWRITE NOR WILL IT FUNDAMENTALLY CHANGE HOW KICKFLIP QUAKE WORKS. I retain no rights to this work as I did not create the original mod, I made this because I enjoy Kickflip Quake too much to leave minor annoyances in. Note that this was designed with FTEQuake in mind, and all releases will be intended for use with it. I will not provide assistance for other clients, I simply don't have the time to.***

***Free Melee.***

The original source code written by Michael 'Squirt' Buettner can be found at https://www.moddb.com/mods/kickflip-quake/downloads/source-code.

## Default controls

First Header  | Second Header
------------- | -------------
Help  | F1
Trick 1 (Indy Grab)  | Shift
Trick 2 (Pop Shove-it)  | Q
Trick 3 (360 Shove-it)  | E
Trick 4 (Backside 360)  | Shift + Q (Trick 1 + Trick 2)
Toggle Cam (First Person)  | C
Competition Start | M
**~~Add Bot~~**| **~~B~~**

**Don't enable the Add Bot bind, it is very, very unstable. It's disabled by default and commented out in the autoexec for a reason.**

## How to change keybinds

**These instructions for changing keybinds are directly applicable to FTEQuake, this guide is not intended for people using other engines. You can definitely change them in those engines, but I will not be the one providing a tutorial on how to do so.**

* Navigate to the KFQuake folder and find the `Autoexec.cfg` file. Open it in your text editor of choice.

* Change the keys under **//Skate Binds** to fit the layout you want.

* ***DO NOT CHANGE THE SKATE ALIASES. These are vital for the mod to work, no one should ever need to change these.***

## Changes from the original Kickflip Quake.

*- Removed the loss of stamina entirely.*

*- Removed the loss of health when failing a trick or falling from height (you can still lose health by being shot or falling in a hazardous liquid.)*

*- Fixed the misspelling of the trick names.*

*- Removed the credits message that displayed any time a level was loaded. Credits to Squirt have been moved to the Help message (viewed by pressing F1.)*

*- Changed the Help message to credit Squirt and provide instructions on how to rebind keys.*

*- You no longer instantly die in water, slime, or lava.*

*- Removed the penalty for not looking in the direction you're moving when landing.*

*- Removed both celebration sounds and both music tracks from the game.*

## Justifications for each change to the game.

It is highly unlikely that *anyone* has spent as much time in this mod as I have, as such, I feel like I understand well what makes this mod great. I will not fundamentally be changing what makes Kickflip Quake what it is, because in my opinion it's already fantastic. It's not an alternative to THPS, it's entirely a freestyle mod which encourages creativity over score. The score is still useless for this reason. Below are my justifications to each change in the source code.

`- Removed the loss of stamina entirely.`

Stamina has no reason to exist in this mod, it's an annoying feature that gets in the way of some tricks while not affecting others.

`- Removed the loss of health when failing a trick or falling from height (you can still lose health by being shot or falling in a hazardous liquid.)`

This also rarely comes into play, and is annoying. Your actual rate of healing is unaffected, you will still take normal damage from normal sources and will regenerate at the mod's intended rate.

`- Fixed the misspelling of the trick names.`

There's no shot anyone is upset with this change.

`- Removed the credits message that displayed anytime a level was loaded. Credits to Squirt have been moved to the Help message (viewed by pressing F1.)`

This mod is over two decades old at this point, and credits to Squirt remain in the game via the Help command. The issue is how long this message was on screen, you would have to wait it out every time a level was loaded. I did not like this, and I don't know anyone that did. I don't imagine Squirt still cares, wherever he is.

`- Changed the Help message to credit Squirt and provide instructions on how to rebind keys.`

Exactly what's written on the tin, the Help menu is now a bit more fleshed out. It was very annoying to learn how to bind keys before, that should no longer be the case.

`- You no longer instantly die in water, slime, or lava.`

You still take damage from slime and lava, water is still a bit odd to move in. I didn't see a reason for this to exist honestly.

`- Removed the penalty for not looking in the direction you're moving when landing.`

This is the most drastic change in my opinion. I believe it to be good though, it unlocks an interesting new piece of tech and makes certain tricks a bit more viable. It's also nice to not accidentally trigger this. 

`- Removed both celebration sounds and both music tracks from the game.`

You will generally be playing your own music when messing about with this mod, and the celebration sounds were annoying. The music is also very low quality, and may land me in copyright trouble. I don't want to deal with either of these issues, especially when I personally never listen to the music.

## Compiling from source.

There's a good chance you're smarter than me, maybe you can fix something broken. This is compiled in the same way as all other Quake 1 mods, I personally use FTEQCC which can be found at https://fte.triptohell.info. 

## Extra stuff :)

To hide the HUD, enter the `sizeup` command in Quake until the HUD disappears.
