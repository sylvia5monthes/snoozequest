# PICO-8 Game Jam Quest


## Game Overview
**Game Designer:** [Your Name]\
**Game Title:** [Insert Game Title]\
**GitLab Repository Link:** [Insert Link]

### Elevator Pitch
Provide a concise 1-3 sentence summary of your game, highlighting its core concept and what makes it unique.

### Theme Interpretation
Explain how your game aligns with the given theme. Describe your creative interpretation and how it is reflected through gameplay mechanics, narrative, or visuals.

### Controls
List the controls for your game (e.g., arrow keys for movement, Z for action).


## MDA Framework

### Aesthetics
Identify the **primary** aesthetic(s) of your game and explain how the elements contribute to it. Consider aspects such as visuals, sound, and gameplay elements that support the intended player experience.

### Dynamics
Outline the core interactions and player experiences that emerge from the mechanics. How does the game encourage specific behaviors, strategies, or engagement over time?

### Mechanics
Detail the core mechanics that define your game, such as movement, player actions, obstacles, and unique features. Explain how these mechanics work together to create an engaging gameplay experience.

## External Resources

### Assets
List any external assets used (e.g., sprite graphics, sound effects, music) and their sources. Provide proper attribution.

### Code
List any external code used, including tutorials or example projects. Provide links and proper citations.


## Code Documentation
You do not need to modify the Code Documentation section of the readme. This seciton serves as a reminder to make sure that your in-code documentation is clear and informative. Important sections such as function or files should be accompanied by comments describing their purpose and functionality.  

Example:  
```lua
-- Handles sprite movement based on arrow key input
function move_sprite()
  if btn(0) then player.x -= 1 end  -- Move left
  if btn(1) then player.x += 1 end  -- Move right
end