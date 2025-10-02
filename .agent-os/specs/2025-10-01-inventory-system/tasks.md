# Spec Tasks

## Tasks

- [ ] 1. Foundation - Grid Navigation and Item Display
  - [ ] 1.1 Add `selected_slot` variable and navigation logic (WASD + arrow keys) in Step event
  - [ ] 1.2 Implement cursor wrapping at grid boundaries (0-15)
  - [ ] 1.3 Draw selection cursor sprite at selected slot position
  - [ ] 1.4 Display items from inventory array in grid at 2x scale
  - [ ] 1.5 Create `get_item_scale()` function with context-based scaling logic
  - [ ] 1.6 Add `large_sprite: true` to greatsword, greataxe, bow, crossbow in item database
  - [ ] 1.7 Update grid rendering to use `get_item_scale()` for each item
  - [ ] 1.8 Verify cursor navigation and item scaling work correctly

- [ ] 2. Equipment System - Armor and Paper Doll
  - [ ] 2.1 Create `equip_selected_item()` function with item type detection
  - [ ] 2.2 Implement armor equipping to `equipped.head/torso/legs` slots
  - [ ] 2.3 Render equipped armor on paper doll at 4x scale
  - [ ] 2.4 Implement swap logic (old armor returns to inventory)
  - [ ] 2.5 Add stack count display for items with `count > 1`
  - [ ] 2.6 Verify armor equips correctly and renders on paper doll

- [ ] 3. Dual Loadout System - Data Structure and Display
  - [ ] 3.1 Initialize `melee_loadout` and `ranged_loadout` structs in player Create event
  - [ ] 3.2 Add `active_loadout = "melee"` variable
  - [ ] 3.3 Render melee loadout slots (right_hand, left_hand) at 2x scale
  - [ ] 3.4 Render ranged loadout weapon slot at 2x scale
  - [ ] 3.5 Draw `[ACTIVE]` indicator next to active loadout
  - [ ] 3.6 Add visual distinction (brightness/alpha) between active/inactive loadouts
  - [ ] 3.7 Verify loadout slots render correctly with test data

- [ ] 4. Weapon Equipping - Melee One-Handed
  - [ ] 4.1 Implement one-handed melee weapon detection in `equip_selected_item()`
  - [ ] 4.2 Move weapon from inventory to `melee_loadout.right_hand`
  - [ ] 4.3 Return old weapon to inventory if slot occupied
  - [ ] 4.4 Update character panel to show newly equipped weapon
  - [ ] 4.5 Verify one-handed weapons equip and swap correctly

- [ ] 5. Weapon Equipping - Two-Handed Force-Clear
  - [ ] 5.1 Detect two-handed weapon (`handedness == WeaponHandedness.two_handed`)
  - [ ] 5.2 Return both right_hand and left_hand items to inventory
  - [ ] 5.3 Equip two-handed weapon to right_hand, set left_hand = undefined
  - [ ] 5.4 Render blocked/grayed indicator for left hand when two-hander equipped
  - [ ] 5.5 Verify two-handed equip clears both hands and shows blocked state

- [ ] 6. Weapon Equipping - Shields and Ranged
  - [ ] 6.1 Implement shield equipping to `melee_loadout.left_hand`
  - [ ] 6.2 Add check to refuse shield equip if two-handed weapon active
  - [ ] 6.3 Implement ranged weapon detection (`is_ranged: true`)
  - [ ] 6.4 Move ranged weapons to `ranged_loadout.weapon`
  - [ ] 6.5 Return old ranged weapon to inventory if exists
  - [ ] 6.6 Verify shields and ranged weapons equip to correct slots

- [ ] 7. Loadout Switching - Q Key Implementation
  - [ ] 7.1 Detect Q key in inventory screen Step event
  - [ ] 7.2 Toggle `active_loadout` between "melee" and "ranged"
  - [ ] 7.3 Update `[ACTIVE]` indicator rendering
  - [ ] 7.4 Detect Q key in player Step event (when inventory closed)
  - [ ] 7.5 Create `swap_active_loadout()` function
  - [ ] 7.6 Update `wielded_sprite` based on active loadout weapon
  - [ ] 7.7 Verify Q swaps loadouts in both inventory and in-game

- [ ] 8. Arrow System and Item Management
  - [ ] 8.1 Add `arrow_count = 0` variable to player Create event
  - [ ] 8.2 Render "Arrows: X/25" text below ranged loadout
  - [ ] 8.3 Add arrow item definition with `is_ammo: true` flag
  - [ ] 8.4 Implement arrow pickup logic (increment counter, max 25, don't add to inventory)
  - [ ] 8.5 Create `drop_selected_item()` function for D key
  - [ ] 8.6 Spawn dropped item in world at player position
  - [ ] 8.7 Verify arrows increment counter and items drop correctly

- [ ] 9. Companion and Stats Panels (Placeholders)
  - [ ] 9.1 Render 3 companion slot sprites vertically on right panel
  - [ ] 9.2 Add placeholder text labels for companion slots
  - [ ] 9.3 Render HP bar at top of character panel
  - [ ] 9.4 Render XP bar below HP bar
  - [ ] 9.5 Draw level, tags, and traits as placeholder text
  - [ ] 9.6 Verify all placeholder elements render correctly

- [ ] 10. Inventory Management and Polish
  - [ ] 10.1 Implement inventory full check before equipping (prevent swap if no room)
  - [ ] 10.2 Add "Inventory full!" message when equip refused
  - [ ] 10.3 Implement I/Esc key to close inventory and resume game
  - [ ] 10.4 Create animated selection cursor sprite with pulse/glow effect
  - [ ] 10.5 Add visual polish to active loadout border/highlight
  - [ ] 10.6 Verify inventory opens/closes smoothly and state persists

- [ ] 11. Testing and Edge Cases
  - [ ] 11.1 Test equipping two-handed weapon with both hands full
  - [ ] 11.2 Test equipping shield with two-handed weapon active (verify refusal)
  - [ ] 11.3 Test rapid Q-key presses and cursor navigation spam
  - [ ] 11.4 Test equipping unknown item types (graceful failure)
  - [ ] 11.5 Test dropping items and picking them back up
  - [ ] 11.6 Fill inventory to 16/16 and test all operations
  - [ ] 11.7 Performance test with full inventory (verify 60fps)
  - [ ] 11.8 Verify all edge cases handled without crashes

- [ ] 12. Documentation and Final Polish
  - [ ] 12.1 Add code comments to all major functions
  - [ ] 12.2 Update CLAUDE.md with inventory system architecture
  - [ ] 12.3 Create or update debug command reference
  - [ ] 12.4 Remove debug-only code
  - [ ] 12.5 Final integration playthrough test
  - [ ] 12.6 Verify all deliverables from spec.md are complete
