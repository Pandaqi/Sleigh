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
* Rotation in 3D sucks :p You can rotate directions around many different axes. Which one do we choose? Which one is easiest to communicate to players? Which one leads to the fewest physics/perspective troubles?

I felt obligated to at least look for a better solution. Change the UI/input scheme for this game so it allows some more freedom. (As I said before: work smarter, not harder/longer.) 

I looked ... and I looked ... and I didn't find anything :p At some point I just have to start doing work again instead of looking for something better.

But allowing myself to think a little longer already revealed some more practical approaches.

* There are 4 directions that are perfectly in line with our side-view perspective: right, down, left, up. 
  * Those are easy to show clearly, which also makes them the ideal candidate to _rotate_ around the sleigh.
  * And when they rotate, the "down" direction becomes useful again. Because what is down _now_ ... will not be pointing down anymore in a few seconds. So no player is stuck with a direction that is often useless.
* This leaves the other 2 directions: FORWARD and BACKWARD.
  * I decided to simply show _both_ at the front of the sleigh. One with a clear arrow pointing to you, one with an arrow pointing back.
  * Like the rotating arrows, they simply FLIP on a timer. (So forward is now backward, and vice versa.)
  * And to _reinforce_ this, those same icons/buttons appear on the front/back of the _minimap_. (This is a very direct way to show what they do exactly.)

Now you can play with 2 players if one person simply has one of the rotating arrows, and the other one of the flipping arrows. With more players, the other directions are simply filled in and you can move more easily/freely.

So, I implemented that, and it was horrible!

There's just no way to control the movement in X and Y direction with _one button_ and rotating arrows. It's just too hard. You have to stay in the air, but you're only pointing up 25% of the time at all! So you just fall down and can barely get up and you die and it's not fun.

What we _really_ need, I realized now, was for buttons to "sway". Like a metronome or pendulum. Go a bit to the left, then a bit to the right, swinging around that up direction. This actually makes flight in 2 directions possible with _one_ button for the up-direction. And because the metronome is quite smooth, the movement becomes surprisingly smooth too.

In practice, this just meant rotating the arrows with a sine wave: `set_rotation(sin(time_variable_that_counts_up_every_frame))`. By tweaking the speed of that, and making sure the up arrow never becomes completely flat (at the extremes), you can actually properly move the sleigh with 2 players now. 

Okay, granted, it's still a silly way to move. And it requires some skill/practice. But that's almost the whole point of a party game like this.

All of this made me wonder though: can we do the other movement (Z-axis; forward/backward) with a "sway" too? It would be more consistent and perhaps more intuitive. Well, we can. We can just make the arrow there go left/right with a sine too. If it's on one half of the sleigh at the moment, you go forward. If it's on the other half, you go backward.

This works, though it's not that big of a change from the old system (of just "flipping" you to the other side every 4--5 seconds). Still, I kept this because it's more consistent and smooth as a whole.

Hmm. I guess this shows, again, that you just can't think your way through problems. Just take 5 minutes to make random ideas and immediately see if they are garbage in practice or not. I would have _never_ come up with the smooth swaying movement we have now just by writing down ideas or thinking about different movement systems.

Anyway, it works great now.

## Wait, why not add a 2D mode?

I had to take a break from this project for a few weeks to meet a few other (external) deadlines. As usual, when you come back with fresh eyes, two things have happened.

* Your brain has continued thinking about this project and now has a few things to say about it.
* You are completely out of the project's flow and ideas, and it takes a while before you're reacquainted with it.

When I get back to an old project, the first hour or two is just me reading back my notes and TODOs and figuring out exactly what needed to be done. I usually start doing a few things ... only to scrap them 10 minutes later because I did them in a stupid way, because my brain wasn't in "project mode" yet.

The first and biggest realization, though, was that this game did not need to be exclusively 3D. Yes, that's the fun gimmick I wanted to experiment with and turn into the unique feature for this game. (Especially compared to earlier One Button Games.) But there's no reason to _only_ offer that mode, when a simpler 2D mode is just around the corner!

With a few changes, you can also simply play with a flat city and without that third dimension.

* The city generator only places buildings in a straight line. (Plus it allows placing gifts above buildings, instead of only in "empty columns", as now there are too few of those.)
* I only add the 2D arrows around the sleigh, not the ones going forward/backward. (I did add _more_ arrows, though, because now diagonals are fine and allow a higher player count.)
* I completely hide the minimap and ignore everything related to it.
* Some finetuning in terms of sizes, speeds, etcetera to make this version as playable as possible.

Ta da! A 2D version! A much simpler version where you're just moving the sleigh left/right and up/down. Because the game is still "actually 3D", though, I still get a lot of benefits for free: realistic lighting, collisions, etcetera. The buildings and sleigh actually have a thickness equal to 1 grid cell, so I didn't need to change anything there to make the 2D version work 100%.

As expected, it's a much simpler version. The sleigh is slightly easier to control and the city is smaller. There is no third dimension to track: if you see your sleigh landing on a building, then it _is_ doing that. The game needs no tutorial at all because it's so intuitive now. This version is absolutely playable with very young kids too.

And so I decided to make this the "default" mode. It's very easy to get started and play, to understand the general idea. _Once you're familiar with the 2D mode_, moving on to the 3D mode is just a "next step". You get a minimap and an extra button (forward/backward), everything else stays the same.

In fact, as it so often happens, I think I prefer the 2D version. It's so easy (as a creator/creative person) to get caught up in a shiny new idea, that you often make it too complicated or intricate for the usual, casual, regular person who might try that game. The 3D version is great unique challenge ... but the 2D version is just much simpler and more accessible. Usually, after a few iterations, games end up at a more "streamlined" and "distilled" version of the original idea.

## The Weird Final Step: UI

Everything is in the game now. 

* I added some simple backgrounds (trees/distant homes at the bottom, stars at the top) and spread them to fill the entire screen no matter your screen size.
* I "randomly generate" actual buildings now. That is, it places a flat roof on top, and random windows/bricks/decoration inside the building. 
  * I think there are two interesting improvements here worth mentioning.
  * First: I realized I could **tint** the entire building now, because all its sprites and everything were in my control/generated. This makes the game MUCH more colorful _and_ clear, because now you can see "red package -> must go to big red building".
  * Second: I realized I could **animate** the individual parts now. It looks much more distinct and fun to make the _individual windows_ rotate/popup/react when you collide with a building, as opposed to flashing or animating the entire building rectangle.
* This game barely needs sound effects, so I could copy most of them from the previous OBG. I wanted to create my own background music, but due to circumstances (horrible home renovations and other stuff) I can't record anything. So I asked AI to give me some generic Christmassy tune and it turned out fine.
* I spent a bit more time on particles, though. Like, add a trail of stars to the sleigh and some "stardust" explosion when you land on buildings. Add a twinkle to presents waiting to be grabbed. It's still _very_ simple and small, but makes the game feel so much more alive. 
* I added the custom settings for this game, such as controlling the size of your map or how many gifts to deliver.

I left one strange element for last, though, which was the **UI (user interface)**. I normally never do that because it's such a crucial part of any game. The thing that shows how many gifts you've delivered and how much damage you've taken. And the thing that should "hold" the minimap and make it look nicer. 

I ignored that because I had **no inspiration for how to create a good one**. I could _not_ figure it out! I accidentally made a game that has really strange requirements/limitations for the UI. 

* The minimap takes up a lot of space. It looks weird off in one corner ( + would block touchscreen areas), while it would block too much of the actual map and your sleigh if centered at the bottom. It basically had to go the top.
* If I add the other UI elements somewhere else, then the UI takes up even _more_ space and it looks disjointed. I'd much rather keep it all together in one group.
* But that means I need to find a very efficient way to display GIFTS DELIVERED (/TO DELIVER) and HEALTH LEFT around the minimap. A look that _also works in 2D mode_, when the minimap is gone!
* Just creating a text label for this and sticking it next to it is simple, yes, but it looks horrible _and_ young kids playing it won't understand that. I wanted a _textless_ way to indicate progress.

I ended up improving my OBG system so it supports "anchoring" the instructions to any side of the screen (not just top). This allowed moving it away so the minimap had more space there, and I could build that into one big beautiful UI element. (At least, that was the idea---there was an attempt.) Then I used a _progress bar_ made of Christmas lights/baubles set into the frame around the minimap to show your progress. When the minimap is gone, you only have that horizontal self-contained "bauble bar", so it still looks thematic and fine. (It literally just hides all other elements and allows only that one score bar to grow and fill the space.)

@TODO: IMAGE?

This experience did teach me a lot of new things about Godot's UI capabilities, though. And mistakes I should avoid next time. I feel like this is one of the marks of becoming more "professional" as a game developer :p You spend most of your time on settings, localization, UI, accessibility, etcetera, and the game's contents are almost an afterthought at some points. 

## A Playtest!

It's unfortunately rare that I get to actually let random groups of people test my games. Until I can pay people for professional beta testing and such, it's just how it is.

Anyway, at Christmas, people played my game. How did it go?

* The 2D version was perfect. Easy to get into, just hard enough to be a fun challenge, just instant fun for a (large) group.
* The 3D version was way too hard. This was partially just because the core idea requires more from you, but also because I'd made some mistakes and accidentally left some things turned on.

And so, on Christmas Eve just before midnight, I spent some 30 minutes simply fixing those issues. 

{{% remark %}}
I've learned to just fix it right then and there, otherwise I'll forget about it or forget _how_ I should fix it, and then it takes a while to remember later---if at all.

Think about it. I made the game "done" at the cost of going to bed 30 minutes later on Christmas Eve. If I hadn't, my first opportunity to work on it again would be once Christmas was over, and by that point I've forgotten the playtest and my mind is "out of the flow".
{{% /remark %}}

What exactly did I do?

* I limited the arrows shown to just _exactly the number of players_. This was a bug; it should've always been this way. With 5 players, you should NOT get 6 arrows and someone doubling :p
* I stopped "moving" the flipping arrows if both are present. That is, from 4(+) players, you have one player with FORWARD and one player with BACKWARD. There's no need to move them around over time (unlike the arrows rotating the sleigh). It's far simpler to use and understand if they're just fixed.
* I gave the minimap a softer blue background. (Instead of the unnecessarily stark/bright pure white it was before. Especially seeing the game on a huge screen revealed the minimap was drawing far too much attention.)
* I made the sleigh much bigger on the minimap, because some players struggled to see/find it (at least at first).

The 3D version is still hard because, well, it has an extra dimension and requires even tighter collaboration. But now it's not unnecessarily hard anymore because of bugs and things not being as clear/obvious as they could be.

Additionally, as stated elsewhere in this devlog, over time the 2D version simply became "the main version". That 3D version is now just a nice "bonus" added into the game for free. That's how these things go!

## A Finished Game

And there you have it. The third One Button Game ever is done, just before Christmas.

My honest thoughts are that the game could have been prettier and a bit "more" than this. At the same time, I actually made the idea I set out to make, it works and looks fine, and players had a lot of fun. So I think that's mostly just the perfectionist artist inside me talking.

I learned a lot about mixing 2D and 3D with this sort of "2.5D" style, as well as more advanced UI tricks and traps. Most of all, I learned---again---that simpler is better and that iterating on an idea actually makes the streamlined core shine through. Your initial idea is usually either impractical, too complicated, or too simplistic ("not actually a game yet"). 

But take some days off, return with fresh eyes, and you might see the obvious solution. Such as simply creating two modes (2D and 3D), which made this game _much_ better and took only 30 minutes to do. The 2D mode is just plain couch coop fun for everyone, while the 3D mode is an actual challenge and test of teamwork and spatial awareness. 

All of it simple enough that I actually prepared a tutorial ... and then realized it was no use displaying such a tiny obvious tutorial! No, no, I don't believe players will magically know how the game works from the start. There _will_ be a first few minutes in which players discover the handful of rules and interactions in the game. And that is _fine_. If a game can teach itself quickly while playing like that, I would always opt to do _that_ and not break the flow with some text tutorial.

It's not an _amazing_ game, but I do think it's good enough to put on the online store and sell for a low price. 

{{% remark %}}
Though the long-term plan is to make these tiny OBGs free anyway, if I have enough other income to sustain that. I _want_ to offer these little local multiplayer toys for free!
{{% /remark %}}

Until next time,

Pandaqi
