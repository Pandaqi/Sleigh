# Sleigh (Devlog)

Welcome to the devlog ("developer diary") for my game **Sleigh** (@TODO: possibly different name). I'll briefly talk about the idea behind it, how I made it, any interesting problems and solutions, and anything else worth mentioning.

## What's the idea?

It's the third "One Button Game" I ever made. After making two for the typical Dutch holiday of Saint Nicholas---which were basically "guinea pigs" for the OBG framework---I made this one for Christmas the next month.

In the feast of Saint Nicholas, the "steam boat" is an important element. As the story goes, Saint Nicholas arrives in the Netherlands (from Spain) with a steam boat each year, carrying all the gifts and candy and whatnot he's going to give to children. As such, I made a game about _steering that boat together_, with everyone getting one button = one direction for steering.

It was a big success. Which is why I continued that idea for Sleigh: **you steer Santa Claus' sleigh together**. Everyone gets a button that only brings you in _one direction_, so you really need to cooperate and communicate to move efficiently.

But, of course, I didn't want to make a carbon copy of that first game. I wanted to evolve it and to stress test my OBG framework/idea more.

As such, I decided to **add an extra dimension**. The famous sleigh, as we all know, _flies_. So you're not only moving left/right/forward/backward ... but also upward and downward.

Instead of sailing the seas and avoiding islands, this time you're _flying over rooftops_ and trying to _land on buildings_. 

I also decided to change the objective. 

* The steam boat game is very "kind" in the sense that you just can't lose. Hitting islands just means you lose one gift that you already collected, but that's that. You just try to get the most gifts and find the finish as soon as possible.
* For this game, I wanted to try the opposite approach. You _are_ "damaged" if you crash into buildings, and your sleigh can be "total loss" and cause you to lose.

## How do we make that?

At first, I wanted to simply do "fake 3D". If you sort 2D sprites correctly (sprites are behind what's lower on the screen), and keep track of a fake third dimension yourself (just changing a third number), you can get very far.

But as I woke up the next day, ready to start this project, I immediately knew this was a bad idea.

* It's crucial to know where buildings are and how tall they are. With overlapping 2D sprites, buildings can "hide" behind those closer to you and make it annoying/near impossible to play with.
* Calculating whether you "collide" with a building, and bouncing off correctly, gets a whole lot harder when you have to add a fake third dimension. At that point, it's much easier to just ... go 3D.

And so the game became 3D, but it's really "2.5D". Yes, it's 3D, and it uses a 3D (orthographic) camera and 3D lights and stuff. But everything in the game is still just a _flat sprite_ (`Sprite3D` node) that's simply _always facing the camera_.

It's how games like _Rayman: Legends_ and _Enter The Gungeon_ do it too. The game _is_ 3D, but looks completely 2D. But, as stated, this approach makes collisions, light effects, perspective, etc a whole lot easier.

## Generating A City

I really like grid-based approaches for most random map generation. It just makes things look better and more "neat", it's easy to control and modify, and it fits well with most game ideas (such as _square buildings_).

As such, the map generation algorithm is basically,

* Create an empty grid (about 20x10 cells)
* Randomly place buildings in empty cells. (Buildings can be bigger than 1x1, like 2x1 or 2x2, so check if _all_ cells they need are empty.)
* When done, place gifts in all remaining cells. (These gifts must be collected by your sleigh, and then delivered to the right building. They can't be inside buildings, because then you could never see/reach them!)
* Finally, place the sleigh in a random cell completely at the front (and _not_ inside a building too).

As usual, there's some more detail and finetuning here, but this is the gist of it. (For example: Buildings that are _further back_ are _higher_, and when placing a building I disallow all cells in the same line. Things like that just make visibility much better when looking from a side view.)

## Grabbing/Dropping Gifts

After all those years I've learned the value of "work smarter, not harder". I was about to create a more complicated system for tracking gifts, placing them inside the sleigh realistically, then dropping them on rooftops.

Then I thought: no, let's try a simpler approach first.

* Gifts are placed randomly, literally floating in the air.
* When you get close, you "grab" them automatically. I use a simple `PinJoint3D` to _pin_ them to your sleigh immediately. (This means your angle of approach + distance decides how exactly it pins to you, so there's some variation and strategy there too if you want.)
* All buildings have a simple `Area3D` on top. If you _land_ there, and you have gifts attached to you of the right type, you immediately deliver them. The gifts are just destroyed, removed from the game.

This worked first try, but more importantly, it had a benefit I would have never seen if I hadn't just made it. The physics simulation in the game is completely realistic, I'm not modifying anything. As such ... when you pin the packages to you, they will swing around you as you move. Which looks funny, first of all, but also _shifts your center of mass_. The more packages you're carrying, the slower you are, and the harder it is to control the sleigh with everything attached to you.

This happens automatically! I got this for free! And it's way more fun and challenging than my old plan, so I kept it like that.

Of course, it did require some finetuning.

* I made gifts much lighter than the sleigh, so you can carry ~6 of them before you can barely move anymore.
* I made gifts not interact with anything else while attached to your sleigh. Otherwise they'd drag you off buildings, hit the edge of the world, and do other slightly annoying stuff.

## Closing The Game Loop

Okay, so you win if you bring all gifts to the right buildings. That part works.

Now let's make it a bit more interesting by adding scoring and a lose condition.

* If you touch a building, I send a signal. First, I check if you're on top of the building (which is fine---you're delivering stuff). If not, it's a bad collision and your sleigh is weakened.
* If your sleigh ever breaks down, you lose the game.
* The more packages you deliver _without_ hitting anything/losing more health, though, the more you score per delivered package.

This makes the game a bit more replayable. Because you can optimize several things: least damage, quickest time, highest score. (At the risk of focusing _too much_ on that and not ever reaching the finish line at all ...)

And with that final step, the game is "playable". You can play a game from start to finish, then restart. But of course, it still looks ugly and lots of features and images are missing.

Most notably ... I haven't actually added the OBG system yet. (I start without it, just playing with arrow keys myself.) Which led me to the following problem I hadn't foreseen ...

## 3D Movement on a 2D UI

In that steamboat game, the map is 2D and directions are "simple". Players simply get one of the 8 compass directions, the boat moves exactly in the direction it points, intuitive and simple to code. Those directions automatically _rotate_ too, which is easy to see and code, but solves a lot of problems as well.

But now, in 3D, this doesn't work anymore.

* We need to show an arrow that means "forward" or "backward" ... but especially the backward one is (realistically/normally) hidden behind the sleigh!
* There's no use adding a "down" key (because gravity takes you down already) ... which would mean the game "only" supports 5 players at most. Because there are only 5 different directions that actually mean something and can be shown clearly.
* Rotation in 3D sucks :p You can rotate directions around many different axes. Which one do we choose? Which one is easiest to communicate to players?

I felt obligated to at least look for a better solution. Change the UI/input scheme for this game so it allows some more freedom. (As I said before: work smarter, not harder/longer.) 









TODO:

* Figure out the input HOW/BUTTONS
* Record marketing footage Stoomboten/Pepernotenfabriek?


**AI TRANSLATION PROMPT (worked great in Copilot):** I've attached a .csv file with the translations/localization for a video game made with the Godot Engine. It currently contains two columns ("en" for English, "nl" for Dutch). Can you add more columns with the proper translations (from English) in Spanish-Spain, French, German, Portuguese-Brazil and Italian? Please output them in valid CSV-file format (NOT a table), so I can immediately copy it into the file. Please make sure all translations are accurate and concise, taking the video game context into account.

(Most common other languages are Simplified Chinese, Japanese, Russian, Turkish/Thai. But they all require extra fonts and I _really_ can't check those, so let them be.)



VISUALS:

* UI ARROWS: Show correctly + attach key hints  ----> Think about WHAT you actually control and HOW we display/change that (because "rotating" makes no sense now)
* UI: show gifts delivered / left to deliver + sleigh damage
  * **Have two christmas trees extend from the sides of the minimap!** (either horizontal or vertical, depends on what looks best)
  * Alternatively, **CHRISTMAS BAUBLES** (and progress just means that more of them light up) --> maybe baubles _around_ the entire minimap?
  * Best to neatly collect these around the minimap, to make it look really good and conserve space
  * **REMEMBER** I already created the signals for this in `ui.gd`, all set up
* Buildings should just randomly generate windows/doors/balconies on them (and CHRISTMAS LIGHTS!)
  * For extra clarity, buildings should just receive their own little accented color scheme (also in minimap)
* BG should just be a repeating vague texture of a starry sky and stuff
  * HOW = Need to create material, set sampler to repeat, then increase the UV coordinates
* (At the bottom we can have trees / other unvisitable buildings though)
* GAME OVER = add actual screen + message with statistics

POLISHING:

* Animations: Collide (Sleigh + Building), Deliver Gift, Grab Gift, Move/Lift/Takeoff, (Taking Damage, floor is lava?)
  * Make the gifts actually twinkle and rotate a little bit
* SFX: Collide (Sleigh + Building), Deliver Gift, Grab Gift, Move, Game Over (Good + Bad), MAIN THEME CHRISTMASSY
* Game Icon + Menu BG Image


COLLISION LAYERS:

* 1 = all
* 2 = gifts