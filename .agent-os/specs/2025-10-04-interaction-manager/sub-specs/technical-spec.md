# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-04-interaction-manager/spec.md

## Technical Requirements

### Interaction Manager (obj_interaction_manager)

- **Singleton pattern**: Only one instance exists, created in obj_game_controller if needed
- **High execution priority**: depth = -9999 or persistent flag to ensure it runs before interactive objects
- **Step event logic**:
  1. Find player instance (obj_player)
  2. Query all instances of obj_interactable_parent within player interaction radius
  3. Calculate priority score for each: `score = base_priority + (max_distance - distance)`
  4. Store highest-scoring object in `global.active_interactive`
  5. All other objects check this global before showing prompts

### Interactive Object Parent (obj_interactable_parent)

- **New parent object** that all interactive objects inherit from
- **Required properties**:
  - `interaction_radius` (number, default: 32)
  - `interaction_priority` (number, companions=100, quest_markers=90, chests=50, doors=40)
  - `interaction_key` (string, default: "Space")
  - `interaction_action` (string, e.g., "Open", "Recruit", "Talk")
- **Required methods**:
  - `can_interact()` - returns boolean (e.g., !is_opened for chests, !is_recruited for companions)
  - `on_interact()` - handles the interaction logic

### Refactoring Existing Objects

**obj_chest, obj_barrel, obj_crate:**
- Change parent from obj_openable to obj_interactable_parent
- Call event_inherited() in Create
- Set `interaction_priority = 50`
- Set `interaction_action = "Open"`
- Implement `can_interact()` to return `!is_opened`
- Move opening logic to `on_interact()`
- Remove direct SPACE key checks

**obj_companion_parent:**
- Change parent to obj_interactable_parent (or add it to inheritance chain)
- Set `interaction_priority = 100`
- Set `interaction_action = "Recruit"` or "Talk" based on state
- Implement `can_interact()` and `on_interact()`

### Interaction Prompt Management

- Modify `show_interaction_prompt()` in scr_ui_functions.gml to:
  1. Check if `id == global.active_interactive`
  2. Only create/show prompt if true
  3. Destroy prompt if false

### Input Handling

- Option A: Manager calls `global.active_interactive.on_interact()` when SPACE pressed
- Option B: Objects check `if keyboard_check_pressed(vk_space) && id == global.active_interactive`

**Recommendation:** Option A for cleaner separation, but Option B requires less refactoring

## Performance Considerations

- Use `instance_place_list()` or `collision_circle_list()` for efficient object queries
- Cache the active interactive between frames (only recalculate when player moves)
- Limit query radius to reasonable interaction distance (e.g., 64 pixels)

## Implementation Order

1. Create obj_interactable_parent with base properties/methods
2. Create obj_interaction_manager with selection logic
3. Refactor obj_chest to inherit from obj_interactable_parent
4. Test with chest interaction only
5. Refactor obj_companion_parent
6. Test with companion + chest scenarios
7. Add remaining interactive types as needed
