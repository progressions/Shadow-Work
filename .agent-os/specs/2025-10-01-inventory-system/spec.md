# Spec Requirements Document

> Spec: Inventory System
> Created: 2025-10-01

## Overview

Implement a comprehensive keyboard-navigable inventory screen featuring equipment loadouts, character stats, paper doll visualization, and companion management. This system will allow players to manage weapons, armor, consumables, and quest items across dual loadouts (melee/ranged) with intuitive keyboard controls and visual feedback.

## User Stories

### Equipment Management

As a player, I want to open my inventory and see all my items in a grid, so that I can quickly assess what I'm carrying and equip items to customize my character's loadout.

The player presses I to open the inventory screen. They see four main panels: character stats (left), paper doll with equipped armor (center-left), a 4x4 grid of inventory items (center-right), and companion slots (right). Using arrow keys, they navigate between the 16 inventory slots. When they select a sword and press E, it equips into their melee loadout's right hand slot, replacing any previously equipped weapon and returning it to inventory.

### Loadout Switching

As a player, I want to switch between melee and ranged combat stances seamlessly, so that I can adapt to different combat situations without opening menus mid-battle.

The player has a sword and shield equipped in their melee loadout, and a bow in their ranged loadout. When they press Q in-game, their character switches from wielding the sword/shield to wielding the bow. The HUD updates to show the active weapon. They can also press I to open inventory, press Q to preview the loadout swap, then close inventory with I to return to the game with the new loadout active.

### Visual Feedback

As a player, I want to see what armor and weapons I have equipped on my character, so that I understand my current combat capabilities at a glance.

The inventory screen displays a paper doll showing the player character with visual representations of equipped head, torso, and legs armor scaled 4x for visibility. The character panel shows both melee and ranged loadout slots with weapon/shield icons, with an [ACTIVE] indicator showing which loadout is currently in use. When items are equipped, their sprites appear in the appropriate slots.

## Spec Scope

1. **Inventory Grid Navigation** - Arrow key navigation through 16 inventory slots with visual selection cursor
2. **Dual Loadout System** - Separate melee and ranged equipment loadouts with Q-key swapping in-game and in-menu
3. **Smart Equip System** - E-key auto-detection of item type and routing to correct slot (weapons to loadouts, armor to paper doll)
4. **Two-Handed Weapon Handling** - Automatic left-hand clearing when equipping two-handed weapons from inventory
5. **Arrow Resource Tracking** - Separate 0-25 arrow counter display (not occupying inventory slot)
6. **Item Scaling System** - Context-aware sprite scaling (1x/2x/4x) based on item type and display location
7. **Panel Rendering** - Four distinct UI panels (character, paper doll, inventory grid, companions) with sprite-based frames
8. **Keyboard-Only Controls** - Complete inventory management without mouse (I/Esc to open/close, E to equip, D to drop, Q to swap loadouts)

## Out of Scope

- Companion recruitment or management functionality (slots displayed but empty)
- Stats calculation display (XP, level, traits shown as placeholders only)
- Quest item filtering or special handling
- Different arrow types (fire arrows, ice arrows)
- Drag-and-drop mouse controls
- Inventory sorting or filtering
- Item tooltips or detailed stat comparisons
- Quick-use potion hotkeys (number keys 1-4)

## Expected Deliverable

1. Press I to open inventory screen showing all four panels with correct sprite positioning and 16 empty inventory slots
2. Arrow keys navigate inventory grid with visible selection cursor, wrapping at edges
3. Add items to player inventory (via debug command), see them rendered in grid at 2x scale (1x for large items)
4. Press E on selected item to equip: weapons route to correct loadout, armor appears on paper doll at 4x scale
5. Press Q in inventory screen to swap active loadout indicator between melee/ranged
6. Press Q in-game to swap between melee/ranged loadouts with character sprite updating to show active weapon
7. Two-handed weapon equipping clears left hand slot and returns displaced item to inventory
8. Arrow counter displays current arrow count (0-25) below ranged loadout, updates when arrows picked up
