# Roblox Camera Fix!
![image](https://github.com/saint-deity/Roblox-Camera-Fix/assets/59446525/f9816255-474e-4c08-b481-f92c48b17866)

This repository is an absolute (don't quote me on that 😭) fix to the behavior of cameras allowing players to clip said cameras through walls, revealing content that should otherwise not be visible without it being released by the developer or the player finding/unlocking that content themselves. No more players shiftlocking through walls to reveal secrets you are yet to unveil! Camera glitches, gone! (kind of).

## How To Use
You can either set it up yourself (not recommended) or you can download the repository and import the file labelled [`Deities-Custom-Camera.rbxm`](https://github.com/saint-deity/Roblox-Camera-Fix/blob/main/Deities-Custom-Camera.rbxm), following all the instructions carefully provided within the README script to set it up.
![image](https://github.com/saint-deity/Roblox-Camera-Fix/assets/59446525/2a74fdde-85ee-442a-9910-973f720c6f5c)

## Known Issues
* No known issues.

## Attributes
You can pause the script without disabling the script as a whole during runtime by changing the attribute `cameraeditable` (`[scriptobject]:SetAttribute (cameraeditable, [boolean])`) to false, and resume the fix by changing that same attribute back to true, though this isn't necessary as my own version uses it for something else, and thus in this version; doing so will have the same effect as disabling the script.

Additionally, changing the max camera zoom distance during runtime by changing the attribute `maxrange` (`[scriptobject]:SetAttribute (maxrange, [newrange])`) to  the new range you want to limit the player to. The max camera zoom defaults to whatever the players `CameraMaxZoomDistance` is set to (you can change this pre runtime and during runtime via `game.Players[playerobject].CameraMaxZoomDistance`.


## More Important (Legally Binding ✨Bizzaz✨), But Still Lastly Mentioned
This repository (https://github.com/saint-deity/Roblox-Camera-Fix), and the files within it are subject to the MIT License. Please review it if you have any doubts on permissability, or contact me on Discord (username is stdeity) for questions or advice (DONT ASK TO ASK (https://dontasktoask.com/), IF YOU ARE GOING TO DM ME, JUST ASK THE QUESTION YOU HAVE FOR THE LOVE OF ALL THAT IS HOLY) (IF YOU WANNA ASK IF SOMETHING MIGHT WORK, JUST TRY IT AND SEE!!!!! (https://tryitands.ee/)).

Is credit necessary? Yes :> I would really like to be credited wherever possible, also the license is an MIT License and not MIT-0, so the license itself suggests attribution should be provided where possible.
