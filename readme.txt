Rockman X2 Speedrunner Practice Edition, version 1.30
by Myria and Total, 2014-2016


About

Rockman X2 Speedrunner Practice Edition is a ROM hack that allows speedrunners
of the game to more easily practice individual levels of the game for their
speed runs.  It's especially nice for players who play on real consoles, where
there are no saved states.


Feature Guide

*   When you start the game, the title screen will ask which of the three
    supported routes you are playing.

*   When you choose a stage, you will have the weapons and items appropriate
    to where you would be in the route you selected on the title screen.

*   To choose one of the five final stages of the game, hold the Select button
    while selecting one of the top five icons at stage select.  The X, which
    normally only turns on/off flavor text, becomes Agile's stage while
    holding Select.

*   The Counter-Hunter icon is the intro stage, if you want to play it.

*   Press Select+R to save your current state.  Press Select+L to load it.

*   Press Select+Start to kill yourself.

*   When choosing the "Teleporter" stage or "Sigma" stage by holding Select,
    you will be given the Shoryuken, as all the routes acquire it on Agile's
    stage during their runs as any other item.

*   In the "Teleporter" stage, killing a boss doesn't disable its teleporter.
    This allows you to fight a boss as many times as you want to practice the
    Shoryuken Rush part of the game.

*   You have infinite lives.

*   The Exit option on the pause screen always functions, and on all levels.

*   The ending has been disabled--after defeating Sigma, you will return to
    stage select after a password screen.

*   Certain other minor cutscenes after levels have been disabled.


Patching

Any standard .ips patcher will work for patching, provided that you patch
against a "headerless" Japanese Rockman X2 ROM with the following MD5:

Before: 42aecc0aa8a369ab42056ebd4c7d0ac4

Following patching, it will have:

After:  4a4c41523d9424906ca206294559d123


Not-So-Frequently-Asked Questions

Q. Does this run on a real SNES?

A. Yes, if you have a flash cart capable of CX4 games, such as SD2SNES.


Q. How do I build the source code?

A. Get byuu's "bass" assembler, name the executable bass.exe, put an
   unmodified original copy of the Rockman X2 ROM named
   "Rockman X 2 (J).smc" into the source directory, and run make.bat.


Q. What's the source code license?

A. Since ROM hacks are a legal gray area anyway, I don't see the point of
   stating a license for this.  You can consider it public-domain.


Credits

Assembly hacking by Myria and Total.
Saved state data by Myria, Luiz Miguel and Trogdor.
Moral support by Domalix and Luiz Miguel.  <3 both


Version History

1.30:  2016/04/25  4a4c41523d9424906ca206294559d123
*   Replaced 100% with Low% by request.

1.21:  2015/09/19  03186c9a4c7ef344b45a9be7d8b3171d
*   Rewrote the saved state code to be much more stable.

1.20:  2015/09/03  (unreleased)
*   Added Total's saved state code to the game.

1.10:  2015/01/19  451800aa842228d6c5c931c65cd0213c
*   In the "Teleporter" stage, killing a boss doesn't disable its teleporter.

1.00:  2015/01/04  6dd26486788a565d8a7c7460c10da4a0
*   Marked 1.00 for first release.

0.30:  2015/01/04
*   Added the "Any% Ostrich 3rd" route, courtesy Luiz Miguel once again.

0.20:  2015/01/03
*   Added the "100% Ostrich 3rd" route, thanks to Luiz Miguel.
*   Removed the ending from the game.

0.12:  2015/01/02
*   Implemented route selection menu at title screen, even though the other
    two routes aren't in the game yet.
*   Implemented infinite lives.
