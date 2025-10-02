# Implementation Phases

This document breaks down the inventory system implementation into tiny, testable steps that can be completed incrementally.

## Phase 1: Grid Selection System (Foundation)

**Goal**: Arrow key navigation through empty 16-slot grid with visual cursor

### Tasks:
1. Add `selected_slot` variable to `obj_inventory_controller` Create event (default: 0)
2. In Step event, detect arrow key input and update `selected_slot` (with wrapping at edges)
3. In Draw_64 event, draw selection cursor sprite at calculated position based on `selected_slot`
4. Test: Open inventory, use arrow keys, see cursor move through all 16 slots

**Acceptance**: Cursor wraps from right edge to left, bottom to top, responds instantly to arrow input

---

## Phase 2: Display Existing Inventory Items

**Goal**: Show items from player's inventory array in grid at correct scale

### Tasks:
1. In Draw_64 event, loop through `inventory` array
2. For each item, draw `spr_items` at frame index `item.definition.world_sprite_frame`
3. Apply 2x scale to all items (temporarily, before adding large_sprite logic)
4. Add debug command to give player test items (sword, potion, helmet)
5. Test: Add items via debug, see them appear in grid

**Acceptance**: Items render centered in slots, scaled 2x, don't overlap slot borders

---

## Phase 3: Item Scaling System

**Goal**: Context-aware scaling (1x for large items, 2x for normal items in grid)

### Tasks:
1. Create `get_item_scale(_item_def, _context)` function in `scr_inventory_system.gml`
2. Add `large_sprite: true` property to greatsword, greataxe, bow, crossbow in item database
3. Update inventory grid rendering to call `get_item_scale()` for each item
4. Test: Add greatsword and sword to inventory, verify greatsword renders at 1x, sword at 2x

**Acceptance**: Large weapons don't overflow slot boundaries, normal items are clearly visible

---

## Phase 4: Equip to Armor Slots

**Goal**: Press E on armor to equip to paper doll at 4x scale

### Tasks:
1. Create `equip_selected_item()` function that checks item type
2. If item is helmet/armor/boots, move from inventory to `equipped.head/torso/legs`
3. In Draw_64, render equipped armor on paper doll at 4x scale at fixed positions
4. If slot already occupied, return old item to inventory
5. Test: Equip helmet, see it appear on paper doll, equip different helmet, see swap

**Acceptance**: Armor appears on correct body part, old armor returns to inventory slot

---

## Phase 5: Dual Loadout Data Structure

**Goal**: Create melee/ranged loadout variables and active loadout tracker

### Tasks:
1. In `obj_player` Create event, initialize `melee_loadout` struct (right_hand, left_hand)
2. Initialize `ranged_loadout` struct (weapon, left_hand)
3. Add `active_loadout = "melee"` variable
4. Add debug commands to manually set loadout contents for testing
5. Test: Set loadouts via debug, verify struct contents in debugger

**Acceptance**: Loadout structs exist, can be populated, active_loadout tracks state

---

## Phase 6: Display Loadout Slots

**Goal**: Show weapons in loadout slots on character panel at 2x scale

### Tasks:
1. In Draw_64, add rendering code for melee loadout slots (right_hand, left_hand)
2. Draw weapon sprites from `melee_loadout.right_hand/left_hand` if they exist
3. Add rendering code for ranged loadout weapon slot
4. Draw `[ACTIVE]` indicator next to active loadout
5. Test: Populate loadouts via debug, see weapons rendered, verify active indicator

**Acceptance**: Both loadouts visible, weapons render at 2x, active indicator shows correctly

---

## Phase 7: Equip Weapons to Melee Loadout

**Goal**: Press E on one-handed weapon to equip to melee right hand

### Tasks:
1. In `equip_selected_item()`, detect if item is one-handed melee weapon
2. Move item from inventory to `melee_loadout.right_hand`
3. If right_hand already occupied, return old weapon to inventory
4. Update character panel rendering to show newly equipped weapon
5. Test: Equip sword, see it in right hand slot, equip axe, see sword return to grid

**Acceptance**: Weapons equip to right hand, old weapon swaps back to inventory

---

## Phase 8: Two-Handed Weapon Force-Clear

**Goal**: Equipping two-handed weapon clears both hands, returns items to inventory

### Tasks:
1. In `equip_selected_item()`, detect if weapon has `handedness == WeaponHandedness.two_handed`
2. Return both `right_hand` and `left_hand` items to inventory if they exist
3. Equip two-handed weapon to `right_hand`, set `left_hand = undefined`
4. In Draw_64, render grayed/blocked indicator for left hand when two-hander equipped
5. Test: Equip sword+shield, then equip greatsword, verify both return to inventory

**Acceptance**: Two-handed equip clears both hands, left slot shows as blocked

---

## Phase 9: Equip Shields to Left Hand

**Goal**: Press E on shield to equip to melee left hand (if not blocked)

### Tasks:
1. In `equip_selected_item()`, detect if item is shield
2. Check if `melee_loadout.right_hand` is two-handed weapon (if so, show error/refuse)
3. Move shield from inventory to `melee_loadout.left_hand`
4. Return old left_hand item to inventory if exists
5. Test: Equip shield to left hand, verify it renders, try to equip with two-hander active

**Acceptance**: Shield equips to left hand, refuses if two-hander active

---

## Phase 10: Equip Ranged Weapons

**Goal**: Press E on bow/crossbow to equip to ranged loadout

### Tasks:
1. In `equip_selected_item()`, detect if weapon has `is_ranged: true` property
2. Move weapon from inventory to `ranged_loadout.weapon`
3. Return old ranged weapon to inventory if exists
4. Render ranged weapon in ranged loadout slot
5. Test: Equip bow, see it in ranged slot, equip crossbow, see bow return

**Acceptance**: Ranged weapons equip to ranged slot, old weapon swaps to inventory

---

## Phase 11: Loadout Swap in Inventory (Q Key)

**Goal**: Press Q in inventory screen to toggle active loadout indicator

### Tasks:
1. In `obj_inventory_controller` Step event, detect Q key press when `is_open == true`
2. Toggle `obj_player.active_loadout` between "melee" and "ranged"
3. Update `[ACTIVE]` indicator rendering to reflect new active loadout
4. Test: Open inventory, press Q multiple times, see indicator move between loadouts

**Acceptance**: Q key toggles indicator, change persists when closing/reopening inventory

---

## Phase 12: Loadout Swap in-Game (Q Key)

**Goal**: Press Q in-game to switch active weapon sprite

### Tasks:
1. In `obj_player` Step event, detect Q key press when inventory closed
2. Call `swap_active_loadout()` function
3. Update `wielded_sprite` variable based on active loadout weapon
4. Test: Equip sword (melee) and bow (ranged), press Q in-game, see weapon sprite change

**Acceptance**: Q swaps weapon sprite instantly, loadout state syncs with inventory screen

---

## Phase 13: Arrow Counter Display

**Goal**: Show arrow count (0-25) below ranged loadout, not in inventory grid

### Tasks:
1. Add `arrow_count = 0` variable to `obj_player` Create event
2. In Draw_64, render "Arrows: X/25" text below ranged loadout slots
3. Add debug command to increment/decrement arrow count
4. Test: Change arrow_count via debug, verify display updates

**Acceptance**: Arrow count renders correctly, updates in real-time, not in grid

---

## Phase 14: Arrow Pickup Logic

**Goal**: Picking up arrow item increments counter (max 25), doesn't occupy slot

### Tasks:
1. Add `item_id: "arrows"` item definition to database with `is_ammo: true` flag
2. In pickup collision code, detect if item is arrows
3. Increment `arrow_count` (cap at 25), don't add to inventory array
4. Show "Arrows +5" pickup message
5. Test: Place arrow pickup in world, walk over it, verify count increases

**Acceptance**: Arrows picked up increment counter, don't appear in inventory grid

---

## Phase 15: Drop Item from Inventory (D Key)

**Goal**: Press D on selected item to remove from inventory and spawn in world

### Tasks:
1. In Step event, detect D key press when inventory open
2. Create `drop_selected_item()` function
3. Spawn `obj_item_world` instance at player position with dropped item definition
4. Remove item from inventory array at `selected_slot`
5. Test: Drop various items, see them appear in world, pick up to re-add

**Acceptance**: Items drop at player feet, can be picked up again, slot becomes empty

---

## Phase 16: Companion Panel Structure (Placeholder)

**Goal**: Display 3 empty companion slots with circular frames

### Tasks:
1. In Draw_64, render 3 instances of `spr_companion_slot` sprite vertically
2. Add text labels: "Companion 1", "Companion 2", "Companion 3"
3. Leave slots empty (no portraits or aura info yet)
4. Test: Open inventory, verify 3 slots visible on right panel

**Acceptance**: Three empty companion slots render, positioned correctly, no functionality

---

## Phase 17: Stats Display (Placeholder)

**Goal**: Show HP bar, XP bar, level, tags, traits as placeholder graphics/text

### Tasks:
1. In Draw_64, render HP bar at top of character panel using existing bar sprites
2. Render XP bar below HP bar
3. Draw level text: "Level: X"
4. Draw placeholder text: "Tags: [Fire] [Tank]" and "Traits: Fireborne"
5. Test: Open inventory, verify all elements visible

**Acceptance**: All stat elements render, use real player HP/XP values, rest is placeholder

---

## Phase 18: Stack Count Display

**Goal**: Show item count number on stackable items in inventory grid

### Tasks:
1. In Draw_64 inventory grid loop, check if `item.count > 1`
2. Draw count number in bottom-right corner of slot using `draw_text()`
3. Set text color to white with black outline for visibility
4. Test: Add stackable potions (count: 5), verify "5" appears on slot

**Acceptance**: Stack count renders on multi-item stacks, doesn't show for count = 1

---

## Phase 19: Inventory Full Handling

**Goal**: Prevent equipping items when inventory full (16/16 slots)

### Tasks:
1. In `equip_selected_item()`, before moving old item to inventory, check if array is full
2. If full, show message "Inventory full! Drop an item first" and cancel equip
3. Test: Fill all 16 slots, try to equip weapon, verify refusal message

**Acceptance**: Can't equip if no room for swapped item, message explains why

---

## Phase 20: Close Inventory and Resume Game

**Goal**: Press I or Esc to close inventory and return to gameplay with active loadout

### Tasks:
1. In Step event, detect I or Esc key press
2. Set `is_open = false`
3. Resume player movement (unpause game state if paused)
4. Verify active loadout weapon is wielded in-game
5. Test: Open inventory, equip items, close with I, verify game resumes

**Acceptance**: Inventory closes instantly, player can move, equipped items persist

---

## Phase 21: Selection Cursor Visual Polish

**Goal**: Animated or highlighted cursor sprite for selected slot

### Tasks:
1. Create `spr_selection_cursor` sprite with pulsing animation or glow effect
2. Update Draw_64 to render cursor at selected slot position
3. Add subtle animation (scale pulse or color shift)
4. Test: Navigate grid, verify cursor is clearly visible against all backgrounds

**Acceptance**: Selected slot is obvious, cursor doesn't obscure item underneath

---

## Phase 22: Loadout Indicator Visual Polish

**Goal**: Highlight active loadout slots with border or glow

### Tasks:
1. Create `spr_loadout_active_border` sprite (bright outline)
2. In Draw_64, draw border around active loadout section
3. Dim inactive loadout slots (alpha 0.6) to create contrast
4. Test: Swap loadouts, verify visual distinction is clear

**Acceptance**: Active loadout stands out, inactive is visually de-emphasized

---

## Phase 23: Integration Testing

**Goal**: Test all systems together in realistic gameplay scenario

### Tasks:
1. Start game, pick up items (weapons, armor, arrows)
2. Open inventory, equip full loadout (sword+shield melee, bow ranged)
3. Equip armor to all slots
4. Swap loadouts in inventory and in-game multiple times
5. Drop items, pick up different items, re-equip
6. Fill inventory to 16/16, try to equip, verify refusal
7. Close and reopen inventory, verify persistence

**Acceptance**: All features work together, no crashes, state persists correctly

---

## Phase 24: Edge Case Testing

**Goal**: Identify and fix edge cases and rare bugs

### Tasks:
1. Test equipping two-handed weapon when both hands have items
2. Test equipping shield with two-handed weapon active (should refuse)
3. Test rapid Q-key presses (loadout swap spam)
4. Test navigation cursor at grid boundaries (ensure wrapping works)
5. Test equipping items of unknown type (should fail gracefully)
6. Test dropping items with full inventory (verify drop success)
7. Test closing inventory while cursor on different slots

**Acceptance**: No crashes, all edge cases handled with appropriate feedback

---

## Phase 25: Performance Testing

**Goal**: Verify inventory screen runs at 60fps with full inventory

### Tasks:
1. Fill all 16 inventory slots with different items
2. Equip full loadouts and armor
3. Open/close inventory repeatedly while monitoring FPS
4. Navigate rapidly through grid
5. Profile draw event execution time

**Acceptance**: Consistent 60fps, draw event under 2ms, no frame drops

---

## Phase 26: Final Polish and Documentation

**Goal**: Clean up code, add comments, update CLAUDE.md

### Tasks:
1. Add code comments to all major functions explaining logic
2. Update CLAUDE.md with inventory system architecture overview
3. Create debug command reference doc (if not exists)
4. Remove any debug-only code or commands
5. Final playthrough test

**Acceptance**: Code is readable, documented, ready for future development
