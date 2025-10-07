# Spec Tasks

> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Foundation - Grid Navigation and Item Display
  - [x] 1.1 Add `selected_slot` variable and navigation logic (WASD + arrow keys) in Step event
  - [x] 1.2 Implement cursor wrapping at grid boundaries (0-15)
  - [x] 1.3 Draw selection cursor sprite at selected slot position
  - [x] 1.4 Display items from inventory array in grid at 2x scale
  - [x] 1.5 Create `get_item_scale()` function with context-based scaling logic
  - [x] 1.6 Add `large_sprite: true` to greatsword, greataxe, bow, crossbow in item database
  - [x] 1.7 Update grid rendering to use `get_item_scale()` for each item
  - [x] 1.8 Verify cursor navigation and item scaling work correctly

- [x] 2. Keystroke Action Stubs
  - [x] 2.1 Add Space key detection to show debug message with selected slot position (row, col)
  - [x] 2.2 Add E key stub for equip action (debug message)
  - [x] 2.3 Add P key stub for drop action (debug message)
  - [x] 2.4 Add U key stub for use/consume action (debug message)
  - [x] 2.5 Add Esc key to close inventory
  - [x] 2.6 Verify all key stubs show correct slot indices
  - [x] 2.7 Update Space key stub to note upcoming context-sensitive behavior (equip/use)

- [x] 3. Equipment System - Armor and Paper Doll
  - [x] 3.1 Create `equip_selected_item()` function with item type detection
  - [x] 3.2 Implement armor equipping to `equipped.head/torso/legs` slots
  - [x] 3.3 Render equipped armor on paper doll at 4x scale
  - [x] 3.4 Implement swap logic (old armor returns to inventory)
  - [x] 3.5 Add stack count display for items with `count > 1`
  - [x] 3.6 Verify armor equips correctly and renders on paper doll

- [x] 4. Dual Loadout System - Data Structure and Display
  - [x] 4.1 Initialize `melee_loadout` and `ranged_loadout` structs in player Create event
  - [x] 4.2 Add `active_loadout = "melee"` variable
  - [x] 4.3 Render melee loadout slots (right_hand, left_hand) at 2x scale
  - [x] 4.4 Render ranged loadout weapon slot at 2x scale
  - [x] 4.5 Draw `[ACTIVE]` indicator next to active loadout
  - [x] 4.6 Add visual distinction (brightness/alpha) between active/inactive loadouts
  - [x] 4.7 Verify loadout slots render correctly with test data

- [x] 5. Weapon Equipping - Melee One-Handed
  - [x] 5.1 Implement one-handed melee weapon detection in `equip_selected_item()`
  - [x] 5.2 Move weapon from inventory to `melee_loadout.right_hand`
  - [x] 5.3 Return old weapon to inventory if slot occupied
  - [x] 5.4 Update character panel to show newly equipped weapon
  - [x] 5.5 Verify one-handed weapons equip and swap correctly

- [x] 6. Weapon Equipping - Two-Handed Force-Clear
  - [x] 6.1 Detect two-handed weapon (`handedness == WeaponHandedness.two_handed`)
  - [x] 6.2 Return both right_hand and left_hand items to inventory
  - [x] 6.3 Equip two-handed weapon to right_hand, set left_hand = undefined
  - [x] 6.4 Render blocked/grayed indicator for left hand when two-hander equipped
  - [x] 6.5 Verify two-handed equip clears both hands and shows blocked state

- [x] 7. Weapon Equipping - Shields and Ranged
  - [x] 7.1 Implement shield equipping to `melee_loadout.left_hand`
  - [x] 7.2 Add check to refuse shield equip if two-handed weapon active
  - [x] 7.3 Implement ranged weapon detection (`is_ranged: true`)
  - [x] 7.4 Move ranged weapons to `ranged_loadout.weapon`
  - [x] 7.5 Return old ranged weapon to inventory if exists
  - [x] 7.6 Verify shields and ranged weapons equip to correct slots

- [x] 8. Loadout Switching - Q Key Implementation
  - [x] 8.1 Detect Q key in inventory screen Step event
  - [x] 8.2 Toggle `active_loadout` between "melee" and "ranged"
  - [x] 8.3 Update `[ACTIVE]` indicator rendering
  - [x] 8.4 Detect Q key in player Step event (when inventory closed)
  - [x] 8.5 Create `swap_active_loadout()` function
  - [x] 8.6 Update `wielded_sprite` based on active loadout weapon
  - [x] 8.7 Verify Q swaps loadouts in both inventory and in-game

- [x] 9. Arrow System and Item Management
  - [x] 9.1 Add `arrow_count = 0` variable to player Create event
  - [x] 9.2 Render "Arrows: X/25" text below ranged loadout
  - [x] 9.3 Add arrow item definition with `is_ammo: true` flag
  - [x] 9.4 Implement arrow pickup logic (increment counter, max 25, don't add to inventory)
  - [x] 9.5 Create `drop_selected_item()` function for P key
  - [x] 9.6 Spawn dropped item in world at player position
  - [x] 9.7 Verify arrows increment counter and items drop correctly

- [x] 10. Companion and Stats Panels (Placeholders)
  - [x] 10.1 Render 3 companion slot sprites vertically on right panel
  - [x] 10.2 Add placeholder text labels for companion slots
  - [x] 10.3 Render HP bar at top of character panel
  - [x] 10.4 Render XP bar below HP bar
  - [x] 10.5 Draw level, tags, and traits as placeholder text
  - [x] 10.6 Verify all placeholder elements render correctly

- [x] 11. Inventory Management and Polish
  - [x] 11.1 Implement inventory full check before equipping (prevent swap if no room)
  - [x] 11.2 Add "Inventory full!" message when equip refused
  - [x] 11.3 Implement I/Esc key to close inventory and resume game
  - [x] 11.4 Create animated selection cursor sprite with pulse/glow effect
  - [x] 11.5 Add visual polish to active loadout border/highlight
  - [x] 11.6 Verify inventory opens/closes smoothly and state persists
  - [x] 11.7 Ensure save/load persistence for picked-up and dropped items (tracked via spawn IDs)

- [x] 12. Testing and Edge Cases
  - [x] 12.1 Test equipping two-handed weapon with both hands full
  - [x] 12.2 Test equipping shield with two-handed weapon active (verify refusal)
  - [x] 12.3 Test rapid Q-key presses and cursor navigation spam
  - [x] 12.4 Test equipping unknown item types (graceful failure)
  - [x] 12.5 Test dropping items and picking them back up
  - [x] 12.6 Fill inventory to 16/16 and test all operations
  - [x] 12.7 Performance test with full inventory (verify 60fps)
  - [x] 12.8 Verify all edge cases handled without crashes

- [x] 13. Documentation and Final Polish
  - [x] 13.1 Add code comments to all major functions
  - [x] 13.2 Update CLAUDE.md with inventory system architecture
  - [x] 13.3 Create or update debug command reference
  - [x] 13.4 Remove debug-only code
  - [x] 13.5 Final integration playthrough test
  - [x] 13.6 Verify all deliverables from spec.md are complete
  - [x] 13.7 Integrate navigation/action/error SFX per Audio Feedback section

- [x] 14. Context-Sensitive Space Key Action
  - [x] 14.1 Detect whether the selected item would equip (E) or use (U)
  - [x] 14.2 Route Space key to call the corresponding equip/use function
  - [x] 14.3 Ensure Space-triggered actions mirror all feedback/validation (messages, inventory updates)
