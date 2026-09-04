# What is Polygon Souls? 
This little game made in Godot 3.4.4, and now improved to Godot 4.7, was my Bachelor's Thesis to finish my degree in
[Computer Sciente at Universitat Autònoma de Barcelona](https://www.uab.cat/web/estudiar/listado-de-grados/informacion-general/informatica-y-servicios-escuela-adscrita-1216708258897.html?cid=1216708258897&d=Touch&pagename=UAB%2FPage%2FTemplatePageDetallGrauUAB_F4&param1=1231314915546&utm_source=google&utm_medium=cpc&utm_campaign=23989029816&utm_content=&utm_term=&gad_source=1&gad_campaignid=23989080621&gclid=Cj0KCQjw2OnUBhC2ARIsACKyfaFbXhsn8lYNkLK66jxQTiyBN-x1UoqZ8ki0LYuAb3AzakQ_BPm4Y6UaAmxYEALw_wcB)
at 2021/22. I inherited the project from another student who made the base game (v1.0) and I continued his legacy with other targets in mind.<br/>
<img width="1144" height="640" alt="Screenshot of the game" src="https://github.com/user-attachments/assets/3323e7bb-4a53-46dd-a6c7-6bdcb889130d" />
<br/>If you want to see the end result, this was the [final report of the thesis (in spanish)](https://github.com/user-attachments/files/31833094/TFG.Articulo.5.0.pdf), although 
don't expect much of it 🤠  
<br>_As a note: I didn't use AI to code or do my job or even write this. During this week, I used it like two dozen times to ask about how to do certain things, analyse code 
and propose improvements to things I've already coded myself. The main objective of this project was to learn and show how much I've grown, so I feel that there's no sense 
in using AI to separate me from the chance of learning._

## Objectives
The previous student made a game inspired in roguelike and soulslike games. The first one is evident due to the gameplay and camera and the second one is
more prevalent due to the difficulty of the game and the appearance of firepits 💀🔥  
Nevertheless, my project wasn't just to continue the development or improve it as I saw fit. The main target of the project was to analyse and improve
the algorithms of the game to upgrade the logic. On the other hand, the player experience was also an objetive to improve, although a secondary one.  
In this regard, both objectives were fulfilled and the game was improved in different ways.

## Regrets
The project was a success and the final mark was a 9 out of 10. Pretty good, right? 🤔  
Nonetheless, something was off, because even if the outside shell looked good, I knew that the inside was a total mess.  
I'm not complaining about me working badly because the code is bad or I didn't know how to work properly in Godot 3.4.4. Many
games are badly coded or the workflow of their teams are flawed, but at the end of the day they're still fun to play and good games, since the player
doesn't need to know how the things in the backstage work 😶‍🌫️  

## Confession
My issue, and my confession if you please, is that I didn't properly learn Godot to develop it 😭. I saw as some colleages were having super interesting 
projects and were learning a lot, and having hard, but good times researching while I was not. I was just f*cking around most of the time 🤠  
_~(I also know that some other friends were doing very little, just like me... but that's not the point!😠)~_  
I read too little, and learnt to few to know the tool, and, in consequence, my project was mostly done with my previous knowledge of general coding, rather than
researching and making a proper strategy to face the task.  

## Redemption
Because of that, now that I'm invested in learning how to develop games and I've been learning Godot 4 for almost a year, I wanted to redeem myself
by reopening the project, fixing it and giving it a good makeup layer 💅🏻💄. My mission is to make the project right. I do not intend to rework it completely, so some issues
will stay and not all the code will be refurbished, just the most blatant one.

## Results
I'll post lower in the readme a full explanation of the biggest issues I did and fixed (or not), but before that, let me show you my final thoughts to avoid 
breaking the rythm of the text.  
I spent about 10 days working on the code, scenes and more and now I can proudly show the project ✨. I know this is not a good game, but I know it's way better than before.  
So much code was deleted or rewritten, many scenes didn't share node types when they could, the folders were managed to be able to work way better, inheritance and 
classes were implemented to improve coding... And now it has sound and music! _(I'll credit every sound and sprite I can down below.)_ All in all, everything a newbie project 
could have. If you want to test it, you can download it here as Polygon Souls 3.0. _(Obviously, I recommend downloading the previous version to compare it!)_ But if you want to 
know the sins I did in this project, down the rabbit hole we go.

# Mistakes
Probably, my biggest crime is to not know how Godot worked👮🏼‍♀️  
I didn't even know how to create a proper scene, since I only watched introductions tutorials. Therefore, my strategy to create new enemies and so on was to copy
the already existing ones and change the nodes as I needed them. To a certain point, it is not that bad of a solution, until you see this:

## The moving canyon
<img width="1077" height="942" alt="image" src="https://github.com/user-attachments/assets/605fd721-0bf1-4f8d-80a9-f9cf2b88cb28" />
This is the boss battle I implemented. Something new and refreshing to the game, but what's wrong? 🧐  
Well, the thing is that I didn't know how the rooms were created and positioned, since I didn't invest enough time reading and understanding the previous code.
This shouldn't be that big of an issue, if I didn't want to make a three phase boss battle were, in each one, you must use one of the three attacks you can make.  
The main problem with that approach is that, in one of the phases, the boss creates a big ass hole (or wall) between it and the player and then it starts moving upwards and
downward. During that, this rift was supposed to be idle in the center of the room... right? Well, not mine. When this blocks appears in scene, it is attached to the boss, 
since I didn't know how to put it in the room. Therefore, the "hole in the ground" is constantly moving with the boss and I made it tall enough so the player doesn't see it moving.  
Definitely, this was the main thing that popped into my head and I wanted to fix 💀

## Double structures
<img width="366" height="532" alt="image" src="https://github.com/user-attachments/assets/c7dcf086-d9c5-4bf3-91dc-74861cfa5225" />
Other things I reworked was the scene trees. Some of them were because Godot 4 brang many changes, improvements and new functions to the tool, but other ones were because of 
the poorly implementation I did.  
For example, having Node2D inside Node2D. Having an Area2D as hitbox instead of detecting things through move_and_collide() or having a ton of timers in scene AND in code.

## None structures
<img width="563" height="148" alt="image" src="https://github.com/user-attachments/assets/9e88959c-e442-48fd-9676-7ee29bd2a4aa" />
I had a couple of scenes that were just like this: One or two nodes. No scripts. Just some properties changed. And the big idea of reusing this scene many times. _(I ended 
up only using this node like twice...)_ 🧍🏼

## Coding
Evidently, much code was badly implemented and repeated. After fixing some of it, some scripts have gone much smaller. Some scripts like room.gd have more declarations, more
data and functions, but they've shrinked from 300 lines of code to roughly 200. And all that while improving the readability of the code without comments and following the
naming conventions and coding recommendations of Godot 🧠  
Truth to be said, I can see it now this easily also because I've been coding for a couple of years, so this part is natural.

## Error handling and log reads
<img width="2125" height="1263" alt="image" src="https://github.com/user-attachments/assets/f07b2a97-8672-455f-9fca-dc93c3fee471" />

It's incredible how I blatantly ignored many errors and warnings that literally made the executable broken afterwards. And I didn't know where to find logs and didn't looked 
for them either, so "it worked in my PC". Now, the renewed game have zero warnings and zero error messages (or that's what I think). At least if there's an error it's because it
fell out of my sight, not because I looked another way.

# Conclusion
I've had a lot of fun doing this little project. I've been working on it like 5-10 hours a day _(some days 2-3h if I had any appointments, played games with friends and so on)_
and I woke up wanting to jump into the PC to implement new fixes.  
I know I still have a long and hard way before me. I have little to no experience doing real games, but I'm eager to endure this path and try to live out of making games, or die
trying 🌹  
Currently, I'm dedicating myself to learn and develop little things living out of my savings, so one day perhaps I'll be able create great games, the thing that
always stood with me throughout my life. Some games have marked me with great stories, fun gameplays and so much more, and I'd like to be able to pass that experience 
onto other people in the future. Because games are not only games, they can be art too! 🥰💖

# Credits
## Sound
- _Entering crypt (FEETHmn-Samsung Galaxy Smartphone_Walking Upstairs, Reverberant Hallway, Looped_Nicholas Judy_TDC):_ designerschoice - https://freesound.org/people/designerschoice/sounds/807870/
- _Opening crypt (Hidden Wall Opening):_ ertfelda - https://freesound.org/people/ertfelda/sounds/243699/
- _Setting checkpoint (Light Fire Sound):_ Wdomino - https://freesound.org/people/Wdomino/sounds/507724/
- _Healing (monologue splice 146):_ CVLTIV8R - https://freesound.org/people/CVLTIV8R/sounds/687614/
- _Boss theme (Boss Battle Loop 1 (155bpm)):_ kanaizo - https://freesound.org/people/kanaizo/sounds/739177/
- _Boss laugh (Evil Laugh MUAHAHA):_ WannyManny - https://freesound.org/people/WannyManny/sounds/626796/
- _Boss hit metal pipe (jixaw metal pipe falling sound):_ blitheringidiot - https://www.myinstants.com/en/instant/jixaw-metal-pipe-falling-sound-28270/
- _Game Won theme 1/2 (Victory Fanfare (8-Bit Thunder) 4):_ SilverIllusionist - https://freesound.org/people/SilverIllusionist/sounds/843046/
- _Game Won theme 2/2 (Victory At Last):_ RFM-1011 - https://pixabay.com/es/sound-effects/musical-victory-at-last-486385/
- _Game Over theme 1/2 (Game Over 07):_ LilMati - https://freesound.org/people/LilMati/sounds/524742/
- _Game Over theme 2/2 (karimba loop 140bpm):_ bilicho - https://freesound.org/people/bilicho/sounds/740147/?
- _Bouncer enemy death (Vaporize02):_ n_audioman - https://freesound.org/people/n_audioman/sounds/320368/
- _Spin Enemy death (Sci-Fi Soldier Death):_ Diasyl - https://freesound.org/people/Diasyl/sounds/792355/
- _Kamikaze death 1/2 (Loud Explosion):_ peter067 - https://www.myinstants.com/en/instant/loud-explosion-68511/
- _Kamikaze death 2/2 (Geiger Counter):_ SoundBible - https://soundbible.com/42-Geiger-Counter.html
- _Player hit (Retro Hurt 2):_ Driken5482 - https://pixabay.com/es/sound-effects/películas-y-efectos-especiales-retro-hurt-2-236675/
- _Turret break (Metal Breaking | SOUND EFFECT):_ Sound Finder - https://www.youtube.com/watch?v=W7VKQQPk7bg
- _Bouncer, Turret, Spin Enemy shots:_ castpixel - https://castpixel.itch.io/animevox
- _Player shots and slashes:_ castpixel - https://castpixel.itch.io/animevox
- _Rift explosion (Explosion Effect Sound):_ GreenBomb11QNn - https://pixabay.com/es/music/instrumental-explosion-effect-sound-567824/
- _Background music(mIRC 6.x kg):_ AAOCG: https://keygenmusic.tk

## Visuals
- _Game Over screen:_ Sven Roku - https://x.com/SvenRoku/status/2011510513914823020
- _Game Won screen:_ Coqueta - https://fr.pinterest.com/pin/1068901292820996819/
- _Buttons (FREE Controllers & Keyboard PROMPTS):_ Xelu - https://thoseawesomeguys.com/prompts/
- _Firepit (2D Pixel Art Forest Tent Tileset):_ ThomasWasTaken - https://thomaswastaken.itch.io/tileset
- All the other assets were inherited, thus from an unknown source, or made by me in GIMP.

## Fonts
- _Enchanted Lands:_ Dennis Ludlow - https://www.dafont.com/enchanted-land.font
- _Liberation fonts:_ Ascender(c) - https://releases.pagure.org/liberation-fonts/
- _RubikDistressed-Regular:_ Google Fonts - https://fonts.google.com/specimen/Rubik+Distressed?categoryFilters=Feeling:%2FExpressive%2FRugged
