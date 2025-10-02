# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-01-inventory-system/spec.md

## Technical Requirements

### UI Rendering Architecture

- **Single sprite-based frame system**: Use `spr_box_frame` for main background, individual panel sprites (`spr_character_panel`, `spr_paper_doll`, `spr_companions_panel`, `spr_inventory_slot`) for UI elements
- **Manual positioning with offset constants**: Define anchor points for each panel, draw all content relative to anchors using code-based positioning
- **Draw GUI event**: All rendering in `obj_inventory_controller` Draw_64 event at fixed screen position (40, 40)
- **Layered rendering order**: Frame → Panels → Slots → Items → Selection cursor → Text overlays

### Data Structures

#### Player Inventory Array
```gml
inventory = []; // Array of item instances, max 16 slots
// Each item instance: { definition: item_def, count: number, durability: number }
```

#### Dual Loadout System
```gml
melee_loadout = {
    right_hand: undefined,  // One-handed or two-handed weapon
    left_hand: undefined    // Shield, torch, or blocked if two-handed
};

ranged_loadout = {
    weapon: undefined,      // Bow or crossbow (always two-handed)
    left_hand: undefined    // Always blocked for ranged
};

active_loadout = "melee"; // "melee" or "ranged"
```

#### Equipment Slots
```gml
equipped = {
    head: undefined,
    torso: undefined,
    legs: undefined
    // Weapons managed separately in loadouts
};
```

#### Arrow Resource
```gml
arrow_count = 0; // Integer 0-25, not an inventory item
```

### Navigation System

#### Selection State
```gml
selected_slot = 0;           // Current selected inventory slot (0-15)
grid_columns = 4;
grid_rows = 4;
```

#### Keyboard Input Handling (Step Event)
- Arrow keys: Update `selected_slot` based on direction (with wrapping or boundary stops)
- E key: Call `equip_selected_item()`
- D key: Call `drop_selected_item()`
- Q key: Call `swap_active_loadout()`
- I/Esc: Toggle `is_open` flag

### Item Scaling System

#### Context-Based Scale Function
```gml
function get_item_scale(_item_def, _context) {
    switch (_context) {
        case "inventory_grid":
            return (_item_def.large_sprite ?? false) ? 1 : 2;
        case "loadout_slot":
            return 2;
        case "paperdoll_armor":
            return 4;
        default:
            return 1;
    }
}
```

#### Item Database Extension
Add `large_sprite` boolean property to item definitions:
- Greatsword: `large_sprite: true`
- Greataxe: `large_sprite: true`
- Longbow: `large_sprite: true`
- Crossbow: `large_sprite: true`

### Equip Logic

#### Smart Auto-Equip Function
```gml
function equip_selected_item() {
    var _item = inventory[selected_slot];
    var _def = _item.definition;

    // Route to correct slot based on item type
    if (_def.type == ItemType.weapon) {
        if (_def.is_ranged) {
            equip_to_ranged_loadout(_item);
        } else {
            equip_to_melee_loadout(_item);
        }
    } else if (_def.equip_slot in [EquipSlot.helmet, EquipSlot.armor, EquipSlot.boots]) {
        equip_to_armor_slot(_item);
    }
}
```

#### Two-Handed Weapon Handling
```gml
function equip_to_melee_loadout(_item) {
    var _def = _item.definition;

    if (_def.handedness == WeaponHandedness.two_handed) {
        // Force-clear both hands
        if (melee_loadout.right_hand != undefined) {
            inventory_add_item(melee_loadout.right_hand.definition, melee_loadout.right_hand.count);
        }
        if (melee_loadout.left_hand != undefined) {
            inventory_add_item(melee_loadout.left_hand.definition, melee_loadout.left_hand.count);
        }
        melee_loadout.right_hand = _item;
        melee_loadout.left_hand = undefined; // Blocked
    } else {
        // One-handed: equip to right hand by default
        if (melee_loadout.right_hand != undefined) {
            inventory_add_item(melee_loadout.right_hand.definition, melee_loadout.right_hand.count);
        }
        melee_loadout.right_hand = _item;
    }

    // Remove from inventory
    array_delete(inventory, selected_slot, 1);
}
```

### Loadout Switching

#### In-Game Swap (Q Key)
```gml
function swap_active_loadout() {
    if (active_loadout == "melee") {
        active_loadout = "ranged";
        // Update player sprite to show bow
        update_player_weapon_sprite();
    } else {
        active_loadout = "melee";
        // Update player sprite to show melee weapon
        update_player_weapon_sprite();
    }
}
```

#### Visual Feedback
- Draw `[ACTIVE]` text indicator next to active loadout panel
- Highlight active loadout slots with brighter border or glow effect
- Dim inactive loadout slots slightly

### Rendering Specifications

#### Inventory Grid (4x4)
```gml
var _slot_size = 64;
var _slot_padding = 32;
var _grid_start_x = frame_x + 480;
var _grid_start_y = frame_y + 80;

for (var i = 0; i < 16; i++) {
    var _col = i % 4;
    var _row = floor(i / 4);
    var _slot_x = _grid_start_x + (_col * (_slot_size + _slot_padding));
    var _slot_y = _grid_start_y + (_row * (_slot_size + _slot_padding));

    // Draw slot background
    draw_sprite_ext(spr_inventory_slot, 0, _slot_x, _slot_y, 2, 2, 0, c_white, 1);

    // Draw item if exists
    if (i < array_length(inventory) && inventory[i] != undefined) {
        var _item = inventory[i];
        var _scale = get_item_scale(_item.definition, "inventory_grid");
        draw_sprite_ext(spr_items, _item.definition.world_sprite_frame,
                       _slot_x + 32, _slot_y + 32, _scale, _scale, 0, c_white, 1);
    }

    // Draw selection cursor
    if (i == selected_slot) {
        draw_sprite_ext(spr_selection_cursor, 0, _slot_x, _slot_y, 2, 2, 0, c_yellow, 1);
    }
}
```

#### Paper Doll Armor
```gml
// Helmet position (relative to paper doll sprite)
if (equipped.head != undefined) {
    draw_sprite_ext(spr_items, equipped.head.definition.world_sprite_frame,
                   paperdoll_x + 60, paperdoll_y + 30, 4, 4, 0, c_white, 1);
}

// Torso armor
if (equipped.torso != undefined) {
    draw_sprite_ext(spr_items, equipped.torso.definition.world_sprite_frame,
                   paperdoll_x + 60, paperdoll_y + 90, 4, 4, 0, c_white, 1);
}

// Leg armor
if (equipped.legs != undefined) {
    draw_sprite_ext(spr_items, equipped.legs.definition.world_sprite_frame,
                   paperdoll_x + 60, paperdoll_y + 150, 4, 4, 0, c_white, 1);
}
```

#### Loadout Slots
```gml
// Melee loadout (character panel)
var _melee_active = (active_loadout == "melee");
if (_melee_active) draw_text(char_panel_x + 10, char_panel_y + 80, "[ACTIVE]");

// Right hand
if (melee_loadout.right_hand != undefined) {
    draw_sprite_ext(spr_items, melee_loadout.right_hand.definition.world_sprite_frame,
                   char_panel_x + 90, char_panel_y + 100, 2, 2, 0, c_white, 1);
}

// Left hand (grayed if two-handed weapon equipped)
if (melee_loadout.left_hand != undefined) {
    draw_sprite_ext(spr_items, melee_loadout.left_hand.definition.world_sprite_frame,
                   char_panel_x + 40, char_panel_y + 100, 2, 2, 0, c_white, 1);
} else if (melee_loadout.right_hand != undefined &&
           melee_loadout.right_hand.definition.handedness == WeaponHandedness.two_handed) {
    // Draw blocked indicator or gray box
    draw_sprite_ext(spr_inventory_slot, 0, char_panel_x + 40, char_panel_y + 100,
                   2, 2, 0, c_gray, 0.5);
}

// Ranged loadout
var _ranged_active = (active_loadout == "ranged");
if (_ranged_active) draw_text(char_panel_x + 10, char_panel_y + 160, "[ACTIVE]");

if (ranged_loadout.weapon != undefined) {
    draw_sprite_ext(spr_items, ranged_loadout.weapon.definition.world_sprite_frame,
                   char_panel_x + 90, char_panel_y + 180, 2, 2, 0, c_white, 1);
}

// Arrow counter
draw_text(char_panel_x + 10, char_panel_y + 220, "Arrows: " + string(arrow_count) + "/25");
```

### Performance Considerations

- **Single draw event**: All rendering in Draw_64, no multiple draw passes
- **Cached sprite positions**: Calculate panel anchors once when opening inventory
- **Conditional rendering**: Only draw items that exist (skip undefined slots)
- **No dynamic memory allocation**: Fixed 16-slot array, no array resizing during draw

## External Dependencies

None - all functionality uses existing GameMaker built-in functions and current project sprites.
