# PICO-8 Game Jam Quest


## Game Overview
**Game Designer:** Connie Xu\
**Game Title:** Snooze Quest\
**GitLab Repository Link:** https://coursework.cs.duke.edu/computer-game-design-spring-2025/connie-xu/pico8gamejam

### Elevator Pitch
Snooze Quest is a game about battling insomnia in a mind overstimulated by caffeine consumption. As the embodiment of consciousness, the player navigates a world reminiscent of a brain, collecting and disposing of caffeinated drinks while silencing disruptive melodies through meditation. The player's goal is restore peace and finally drift into sleep.

### Theme Interpretation
Snooze Quest is about the difficulty of falling asleep and captures the feeling of being mentally trapped, stuck in an overactive mind while longing for rest. The game’s closed rectangular map, designed as a maze-like brain with no exit, reinforces the sense of being unable to escape racing thoughts such as vibrant, jittery music notes playing stimulating tunes throughout the map. To achieve sleep and successfully beat the game, the player must silence disruptive melodies through meditation after collecting and disposing of caffeinated drinks that fuel the notes' erratic movement and bright colors. Removing a music note and disposing of an item contribute to the game's drowsiness level. Only by reaching maximum drowsiness can the player achieve a fully quiet mind and escape into sleep. 

### Controls
List the controls for your game (e.g., arrow keys for movement, Z for action).

- Right/Left Arrow Keys: Move right/left.
- Up Arrow Key: Float up.
- Down Arrow Key:  Move down purposefully (not just floating down due to gravity).
- X: Meditate
- Z: Copy Sound

## MDA Framework

### Aesthetics
Snooze Quest primarily emphasizes the discovery aesthetic, encouraging players to explore the maze-like brain map in search of collectibles. 

Information about player actions is not explicitly provided through direct instructions. Instead, movement is inferred from common input keys (arrow keys), allowing players to discover controls naturally. The two primary actions beyond movement, meditation and sound copying, are introduced through context in the game's intro (e.g., "...meditating silences the mind temporarily..."), encouraging players to experiment and uncover their full effects during gameplay. 

Players must interact with different-colored music notes to realize that each color corresponds to a distinct sound and is linked to a specific caffeinated item. Experimenting with actions near these music notes helps players uncover how they can either mute or mimic the sounds—reflecting how focusing can temporarily quiet the mind, yet it's easy to fall into the loop of racing thoughts. Through trial and exploration, players learn that collecting and disposing of caffeinated items in the single trash can near the spawn point removes the associated liquid from the map, weakens the corresponding music notes, and ultimately allows meditation to silence them permanently. This gradual process of discovery, which involves understanding the purpose of actions and collectibles, reinforces the theme of gradually figuring out the mechanics of a restless mind in order to finally achieve sleep.

### Dynamics
Snooze Quest encourages exploration, experimentation, and strategic map traversal through its mechanics.

Players must navigate open passages of the map and encounter different music notes to understand how sound interacts with their actions. The presence of discordant, intrusive music notes encourages players to explore ways to control and manipulate sound. By experimenting with meditation (X) and sound copying (Z), players learn that meditation can temporarily or permanently silence music notes, while copying sounds allows them to engage with the game’s auditory elements in a playful, interactive way.

The game’s collectible system of caffeinated drinks (matcha, boba, and coffee) must be learned by hands-on experimentation. Players will notice these items scattered across the map and, through their color association, recognize their connection to specific groups of music notes and liquid spills. Since the disposal bin is located near the spawn point, players will naturally encounter it early on and have the idea that these items need to be disposed of there. Touching a collectible allows the player to pick it up, causing it to follow them as they move. This visual cue signals that the item requires further action, leading the player to realize that it must be taken to the disposal bin to be tossed away. Some collectibles are blocked by liquid spills, requiring players to remove other items first to access them. This progression encourages strategic decision-making, as players must determine the best order to collect and dispose of items while navigating the map to find those items and find subdued music notes that can now be eliminated.

The game has a time limit (12 AM - 9 AM). While not overly restrictive, the countdown prevents indefinite wandering, keeping players focused on their main objective of reaching 100% drowsiness. The interplay between exploration, sound experimentation, strategic map movement and time management ensures that players remain engaged as they work towards their goal of falling asleep.

### Mechanics
Snooze Quest combines movement, location-based sound, and resource collection to create an engaging gameplay experience. 

The player moves left and right with the arrow keys and floats upward with the up arrow, gradually drifting downward when not pressing it, reinforcing the idea of being a wisp of consciousness. The maze-like brain map has walls and spills that cannot be passed through. While the player moves, music notes within range begin playing their sounds, which are discordant and intrusive when they are not subdued (they are colorful) and slower and muted when they are (they are grey).The player can meditate (X) to temporarily quiet active music notes and permanently remove subdued ones if their corresponding caffeinated item has been disposed of. Copying sounds (Z) allows the player to mimic nearby music notes.

Scattered throughout the map are three caffeinated collectibles (matcha, boba, and coffee) which can be picked up one at a time by touching them. These collectibles cause the music notes’ erratic movement and are responsible for liquid spills throughout the map. To counter their effects, the player must carry each item to the single trash can for disposal, which removes its spills and slows the corresponding music notes, making them less stimulating. Disposing of items and meditating to remove subdued music notes both increase drowsiness, bringing the player closer to sleep. The time limit from 12 AM to 9 AM is long and therefore only adds a minor sense of urgency, requiring players to reach 100% drowsiness before time runs out. Together, these mechanics encourage experimentation with movement and sound and engages the player both visually and aurally, with the time constraint keeping them focused on the main objective of disposing of caffeinated drinks and eliminating music notes.

## External Resources

### Assets
No external assets were used.

### Code
- Pico8Platformer: Used as the base framework of the game, including collision detection, animations, and game loop physics. 
  - Author: Enichan
  - Date: October 31, 2019
  - URL: https://github.com/Enichan/Pico8Platformer
  - Software License: MIT License
- Pico-8 Color Fade Generator: Used to create the fade transition effect from the game map to the game over screen. 
  - Author: kometbomb
  - URL: http://kometbomb.net/pico8/fadegen.html


## Code Documentation
You do not need to modify the Code Documentation section of the readme. This seciton serves as a reminder to make sure that your in-code documentation is clear and informative. Important sections such as function or files should be accompanied by comments describing their purpose and functionality.  

Example:  
```lua
-- Handles sprite movement based on arrow key input
function move_sprite()
  if btn(0) then player.x -= 1 end  -- Move left
  if btn(1) then player.x += 1 end  -- Move right
end