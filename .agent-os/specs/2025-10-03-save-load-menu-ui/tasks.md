# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-03-save-load-menu-ui/spec.md

> Created: 2025-10-03
> Status: Ready for Implementation

## Tasks

- [ ] 1. Save file metadata extraction system
  - [ ] 1.1 Create `get_save_slot_metadata()` function to read save file JSON without loading full game state
  - [ ] 1.2 Create `save_slot_exists()` helper function to check if save file exists for a given slot
  - [ ] 1.3 Create `format_timestamp()` function to convert GameMaker timestamp to human-readable "X minutes/hours/days ago" format
  - [ ] 1.4 Create `format_playtime()` function to convert seconds to HH:MM:SS format (placeholder for future playtime tracking)
  - [ ] 1.5 Add metadata extraction functions to `scripts/scr_save_system/scr_save_system.gml` (or create new script file)
  - [ ] 1.6 Test metadata extraction with existing save files and verify JSON parsing works correctly

- [ ] 2. Create SaveLoadLayer RoomUI structure
  - [ ] 2.1 Create `spr_ui_icon_saveload` sprite (48x48px) for pause menu button
  - [ ] 2.2 Create `spr_save_slot_icon` sprite (32x32px) for save slot entries
  - [ ] 2.3 Add new `SaveLoadLayer` (GMRUILayer) to `rooms/RoomUI/RoomUI.yy` with `visible: false` by default
  - [ ] 2.4 Create `SaveLoadContainer` flexbox panel with horizontal layout and center justify
  - [ ] 2.5 Create `SaveSlotListPanel` (width: 400px, vertical layout) with header showing "Save / Load" title and mode indicator
  - [ ] 2.6 Create `SaveSlotScrollPanel` with vertical layout for scrollable slot list
  - [ ] 2.7 Add `SaveSlot_0` (AutoSave) panel with SlotGraphic, SlotInfoPanel (title, location, timestamp), and obj_button instance (button_id: 100)
  - [ ] 2.8 Add `SaveSlot_1` through `SaveSlot_8` panels with SlotGraphic, SlotInfoPanel (slot number, location, level, playtime, timestamp), and obj_button instances (button_id: 101-108)
  - [ ] 2.9 Create `PreviewPanel` (width: 350px, vertical layout) with header "Save Details"
  - [ ] 2.10 Add preview content elements: CharacterNameText, LevelText, LocationText, PlaytimeText, TimestampText, HPText, XPText
  - [ ] 2.11 Add `BackButtonPanel` with obj_button instance (button_id: 200) to return to pause menu
  - [ ] 2.12 Verify SaveLoadLayer renders correctly and is positioned above PauseLayer in layer order

- [ ] 3. Create obj_save_load_controller
  - [ ] 3.1 Create new object `obj_save_load_controller`
  - [ ] 3.2 Add Create event: initialize UI state variables (is_active, current_mode, selected_slot, num_slots, confirmation_pending, confirmation_slot)
  - [ ] 3.3 Add Create event: initialize navigation variables (navigation_cooldown, navigation_delay)
  - [ ] 3.4 Add Create event: initialize save_slots_data array (size 9: index 0=autosave, 1-8=manual slots)
  - [ ] 3.5 Create `open_save_load_menu(mode)` function to show SaveLoadLayer, hide PauseLayer, scan save slots, and update UI
  - [ ] 3.6 Create `close_save_load_menu()` function to hide SaveLoadLayer and show PauseLayer
  - [ ] 3.7 Create `scan_all_save_slots()` function to populate save_slots_data array with metadata from all save files
  - [ ] 3.8 Create `execute_slot_action()` function to handle save/load based on current_mode and selected_slot
  - [ ] 3.9 Create `perform_save(slot)` function to call save_game(), show feedback, and refresh UI
  - [ ] 3.10 Create `perform_load(slot)` function to call load_game() and handle transition
  - [ ] 3.11 Create `show_overwrite_confirmation(slot)` function to set confirmation state and display confirmation message
  - [ ] 3.12 Create `handle_confirmation_input()` function to process Enter (confirm) and Escape (cancel) during confirmation
  - [ ] 3.13 Add obj_save_load_controller instance to RoomUI room (persistent controller)
  - [ ] 3.14 Verify controller initializes correctly and can be activated/deactivated

- [ ] 4. Implement UI navigation and display updates
  - [ ] 4.1 Create `handle_navigation_input()` function to process WASD/arrow key input for slot selection
  - [ ] 4.2 Create `select_previous_slot()` function to move selection up with wrapping
  - [ ] 4.3 Create `select_next_slot()` function to move selection down with wrapping
  - [ ] 4.4 Create `switch_mode(new_mode)` function to toggle between "save" and "load" modes
  - [ ] 4.5 Create `update_ui_display()` function to refresh all SaveLoadLayer text elements with current slot data
  - [ ] 4.6 Implement visual highlight for selected save slot (update selected obj_button or panel styling)
  - [ ] 4.7 Implement preview panel update when selected_slot changes (show detailed metadata for selected slot)
  - [ ] 4.8 Add Step event: call handle_navigation_input() when is_active is true
  - [ ] 4.9 Add Step event: call handle_confirmation_input() when confirmation_pending is true
  - [ ] 4.10 Add Enter key handling to execute_slot_action() when not in confirmation state
  - [ ] 4.11 Add Escape key handling to close_save_load_menu() when not in confirmation state
  - [ ] 4.12 Test keyboard navigation through all slots, mode switching, and slot selection
  - [ ] 4.13 Test mouse interaction with obj_button instances for slot selection and actions

- [ ] 5. Pause menu integration and final polish
  - [ ] 5.1 Add "Save/Load" button to PausePanel in RoomUI.yy between "Settings" and "Quit" buttons
  - [ ] 5.2 Create SaveLoadButton FlexPanel structure: icon graphic (GMRSpriteGraphic: spr_ui_icon_saveload), text (GMRTextItem: "Save/Load"), button instance (obj_button, button_id: 3)
  - [ ] 5.3 Modify obj_pause_controller to handle button_id 3 and call obj_save_load_controller.open_save_load_menu("save")
  - [ ] 5.4 Test opening save/load menu from pause menu and returning to pause menu with Back button
  - [ ] 5.5 Test save operation: select empty slot, save game, verify slot displays updated metadata
  - [ ] 5.6 Test save operation: select occupied slot, verify overwrite confirmation appears, confirm overwrite, verify save succeeds
  - [ ] 5.7 Test save operation: verify autosave slot (slot 0) cannot be manually saved to when in save mode
  - [ ] 5.8 Test load operation: select occupied slot, verify game loads correctly and returns to gameplay
  - [ ] 5.9 Test load operation: select empty slot, verify no action occurs or appropriate feedback is shown
  - [ ] 5.10 Add sound effects for navigation (snd_ui_navigate), selection (snd_ui_select), save success (snd_save_success), load success (snd_load_success)
  - [ ] 5.11 Test edge cases: wrapping slot selection, switching modes, canceling confirmation, navigating during cooldown
  - [ ] 5.12 Verify all text elements display correctly (no overflow, proper formatting, "Empty" for empty slots)
  - [ ] 5.13 Verify SaveLoadLayer visibility toggles correctly when opening/closing menu
  - [ ] 5.14 Verify all tests pass and save/load menu functionality works correctly in all scenarios
