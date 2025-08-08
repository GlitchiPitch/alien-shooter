# Alien Shooter (Roblox) - Minimal Prototype

This is a lightweight top-down alien horde shooter inspired by the classic "Alien Shooter", built for Roblox.

It includes:
- Top-down camera and WASD movement
- Click-to-shoot raycast weapon with tracers
- Server-side validation and damage
- Enemy waves with simple AI that chase and attack
- Auto-scaling difficulty per wave
- Leaderstats for Kills/Score


## How to set up in Roblox Studio

1) Create a new Place in Roblox Studio.

2) In Explorer, create the following Scripts and LocalScripts with these names and parents, then paste the matching files from this folder:

- ReplicatedStorage
  - Folder `Modules`
    - ModuleScript `Config` -> contents of `roblox/ReplicatedStorage/Modules/Config.lua`
    - ModuleScript `WeaponModule` -> contents of `roblox/ReplicatedStorage/Modules/WeaponModule.lua`
    - ModuleScript `EnemyModule` -> contents of `roblox/ReplicatedStorage/Modules/EnemyModule.lua`

- ServerScriptService
  - Script `Bootstrap` -> contents of `roblox/ServerScriptService/Bootstrap.server.lua`
  - Script `Combat` -> contents of `roblox/ServerScriptService/Combat.server.lua`
  - Script `EnemySpawner` -> contents of `roblox/ServerScriptService/EnemySpawner.server.lua`
  - Script `Leaderstats` -> contents of `roblox/ServerScriptService/Leaderstats.server.lua`

- StarterPlayer
  - StarterPlayerScripts
    - LocalScript `CameraController` -> contents of `roblox/StarterPlayer/StarterPlayerScripts/Client/CameraController.client.lua`
    - LocalScript `InputController` -> contents of `roblox/StarterPlayer/StarterPlayerScripts/Client/InputController.client.lua`
    - LocalScript `Crosshair` -> contents of `roblox/StarterPlayer/StarterPlayerScripts/Client/Crosshair.client.lua`

Note: Do NOT create the RemoteEvents manually; the `Bootstrap` script will create them.

3) Press Play. Enemies will spawn in waves around you. Left-click to fire. Survive as long as you can.


## Optional tweaks
- To adjust difficulty, edit `Config.lua` values under `Enemy` and `Spawn`.
- For weapon feel, adjust `Weapon` values (fire rate, damage, tracer lifetime/color).
- Replace the simple procedural alien with your own model: put a Model named `Alien` inside `ServerStorage` with a `Humanoid` and `HumanoidRootPart`. The system will prefer this over the procedural enemy.

## Notes
- This is a prototype designed to be easy to drop into a blank place. It focuses on server-authoritative combat and simplicity over polish.
- Pathfinding is simplified (MoveTo); replace with PathfindingService precomputed paths for complex maps.