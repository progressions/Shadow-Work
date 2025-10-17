# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-17-dialogue-system-functions/spec.md

## Technical Requirements

### Inventory Functions

**has_item(item_id, [quantity])**
- Check if player inventory contains item with optional quantity check
- Parameters: `item_id` (string), `quantity` (number, default: 1)
- Returns: boolean
- Implementation: Call existing `inventory_has_item()` or `inventory_count_item() >= quantity`
- Location: Register in `obj_game_controller/Create_0.gml`

**give_item(item_id, [quantity])**
- Add items to player inventory
- Parameters: `item_id` (string), `quantity` (number, default: 1)
- Returns: boolean (success/failure)
- Implementation: Call existing `inventory_add_item()`
- Location: Register in `obj_game_controller/Create_0.gml`

**remove_item(item_id, [quantity])**
- Remove items from player inventory
- Parameters: `item_id` (string), `quantity` (number, default: 1)
- Returns: boolean (success/failure if insufficient quantity)
- Implementation: Call existing `inventory_remove_item()`
- Location: Register in `obj_game_controller/Create_0.gml`

**inventory_count(item_id)**
- Get exact count of item in inventory
- Parameters: `item_id` (string)
- Returns: number
- Implementation: Call existing `inventory_count_item()`
- Location: Register in `obj_game_controller/Create_0.gml`

### Affinity Functions

**get_affinity(companion_name)**
- Retrieve current affinity level for named companion
- Parameters: `companion_name` (string) - "Canopy", "Hola", or "Yorna"
- Returns: number (0-10 scale)
- Implementation:
  - Use `get_companion_by_name()` helper to find companion instance
  - Return `companion.affinity` or 0 if not found/not recruited
- Location: Register in `obj_game_controller/Create_0.gml`

### Quest Progress Functions

**objective_complete(quest_id, objective_index)**
- Check if specific quest objective is complete
- Parameters: `quest_id` (string), `objective_index` (number, 0-based)
- Returns: boolean
- Implementation:
  - Access `global.quests[$ quest_id]`
  - Check if `objectives[objective_index].current_count >= required_count`
  - Return false if quest/objective doesn't exist
- Location: Add to `scr_quest_system.gml`, register in `obj_game_controller/Create_0.gml`

**quest_progress(quest_id, objective_index)**
- Get current progress count for specific objective
- Parameters: `quest_id` (string), `objective_index` (number, 0-based)
- Returns: number (current count, 0 if not found)
- Implementation:
  - Access `global.quests[$ quest_id]`
  - Return `objectives[objective_index].current_count`
  - Return 0 if quest/objective doesn't exist
- Location: Add to `scr_quest_system.gml`, register in `obj_game_controller/Create_0.gml`

## Registration Pattern

All functions must be registered in `obj_game_controller/Create_0.gml` after Chatterbox initialization using `ChatterboxAddFunction()`:

```gml
// Inventory functions
ChatterboxAddFunction("has_item", function(_item_id, _quantity = 1) {
    return inventory_count_item(_item_id) >= _quantity;
});

ChatterboxAddFunction("give_item", function(_item_id, _quantity = 1) {
    return inventory_add_item(_item_id, _quantity);
});

ChatterboxAddFunction("remove_item", function(_item_id, _quantity = 1) {
    return inventory_remove_item(_item_id, _quantity);
});

ChatterboxAddFunction("inventory_count", inventory_count_item);

// Affinity function
ChatterboxAddFunction("get_affinity", function(_companion_name) {
    var _comp = get_companion_by_name(_companion_name);
    if (_comp != noone && _comp.is_recruited) return _comp.affinity;
    return 0;
});

// Quest progress functions
ChatterboxAddFunction("objective_complete", quest_objective_complete);
ChatterboxAddFunction("quest_progress", quest_objective_progress);
```

## Yarn Usage Examples

### Inventory Example
```yarn
title: Blacksmith
---
Blacksmith: What can I do for you?
    -> Buy healing potion (50 gold) <<if has_item("gold", 50)>>
        <<remove_item("gold", 50)>>
        <<give_item("healing_potion")>>
        Blacksmith: Here you go!
    -> Sell iron ore <<if has_item("iron_ore")>>
        You have <<inventory_count("iron_ore")>> iron ore.
        <<jump SellMenu>>
===
```

### Affinity Example
```yarn
title: CanopyTalk
---
<<if get_affinity("Canopy") >= 8>>
    Canopy: I feel like we've become really close.
    -> Tell me about your past
        <<jump DeepBackstory>>
<<elseif get_affinity("Canopy") >= 5>>
    Canopy: Good to see you again!
<<else>>
    Canopy: Hello.
<<endif>>
===
```

### Quest Progress Example
```yarn
title: QuestGiverCheckIn
---
<<if quest_is_active("defeat_bandits")>>
    <<if objective_complete("defeat_bandits", 0)>>
        Quest Giver: You've defeated all the bandits! Well done!
        -> Claim reward
            <<quest_complete("defeat_bandits")>>
    <<else>>
        Quest Giver: You've defeated <<quest_progress("defeat_bandits", 0)>> out of 5 bandits.
        Quest Giver: Keep going!
    <<endif>>
<<endif>>
===
```

## Error Handling

- All functions should fail gracefully (return 0/false) if:
  - Item ID doesn't exist in database
  - Companion name is invalid
  - Quest ID or objective index is invalid
  - Player instance doesn't exist (shouldn't happen but defensive coding)

## Integration Points

- **Existing Systems**: Uses existing inventory, companion, and quest systems
- **No Database Changes**: All functions query existing game state
- **No New Dependencies**: Uses only existing Chatterbox integration
- **Location**: `obj_game_controller/Create_0.gml` lines 192-216 (existing Chatterbox setup area)
