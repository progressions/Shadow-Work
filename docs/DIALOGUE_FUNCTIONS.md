# Dialogue Functions for Chatterbox

Complete reference for custom Chatterbox functions that enable Yarn dialogue to interact with game systems.

## Overview

These functions are registered with Chatterbox in `obj_game_controller/Create_0.gml` and can be called directly from Yarn dialogue files. They provide safe, validated access to inventory, companion affinity, and quest progress systems.

## Inventory Functions

### has_item(item_id, [quantity])

Check if player has items in inventory.

**Parameters:**
- `item_id` (string) - Item ID from `global.item_database` (e.g., "arrows", "gold", "small_health_potion")
- `quantity` (number, optional) - Minimum quantity required (default: 1)

**Returns:** `true` if player has >= quantity, `false` otherwise

**Usage:**
```yarn
<<if has_item("arrows", 10)>>
    You have enough arrows!
<<endif>>

// Check for single item
<<if has_item("rusty_dagger")>>
    -> Sell your rusty dagger
<<endif>>

// Guard dialogue option with item check
-> Buy health potion (25 gold) <<if has_item("gold", 25)>>
    <<jump BuyPotion>>
```

**Error Handling:**
- Returns `false` if player doesn't exist
- Returns `false` if item_id is invalid
- Returns `true` if quantity <= 0 (edge case)

---

### inventory_count(item_id)

Get exact count of items in inventory.

**Parameters:**
- `item_id` (string) - Item ID to count

**Returns:** Total count across all inventory stacks (number)

**Usage:**
```yarn
You have <<inventory_count("arrows")>> arrows.

<<if inventory_count("gold") >= 100>>
    You're quite wealthy!
<<endif>>

Merchant: You have <<inventory_count("wolf_pelt")>> wolf pelts. I'll buy them for 20 gold each!
```

**Error Handling:**
- Returns `0` if player doesn't exist
- Returns `0` if item_id is invalid

---

### give_item(item_id, [quantity])

Add items to player inventory.

**Parameters:**
- `item_id` (string) - Item ID to give
- `quantity` (number, optional) - Amount to give (default: 1)

**Returns:** `true` if successful, `false` if failed (invalid ID or full inventory)

**Usage:**
```yarn
-> Accept quest reward
    <<give_item("small_health_potion", 3)>>
    <<give_item("gold", 100)>>
    Quest Giver: Here's your reward!

// Check if item was successfully given
<<if give_item("short_sword")>>
    Merchant: Here's your sword!
<<else>>
    Merchant: Your inventory is full!
<<endif>>
```

**Error Handling:**
- Returns `false` if player doesn't exist
- Returns `false` if item_id is invalid (logs debug message)
- Returns `false` if inventory is full
- Returns `false` if quantity <= 0

---

### remove_item(item_id, [quantity])

Remove items from player inventory.

**Parameters:**
- `item_id` (string) - Item ID to remove
- `quantity` (number, optional) - Amount to remove (default: 1)

**Returns:** `true` if successful, `false` if insufficient items

**Usage:**
```yarn
-> Buy arrows (5 gold)
    <<if remove_item("gold", 5)>>
        <<give_item("arrows", 10)>>
        Merchant: Here you go!
    <<else>>
        Merchant: You don't have enough gold.
    <<endif>>

// Remove items for crafting
<<if remove_item("wolf_pelt", 3)>>
    <<give_item("leather_armor")>>
    Crafted leather armor!
<<endif>>
```

**Error Handling:**
- Returns `false` if player doesn't exist
- Returns `false` if player doesn't have enough items
- Returns `true` if quantity <= 0 (edge case)
- Respects quest item protection (won't remove quest items)

---

## Affinity Functions

### get_affinity(companion_name)

Get companion's affinity level.

**Parameters:**
- `companion_name` (string) - Companion name: "Canopy", "Hola", or "Yorna" (case-insensitive)

**Returns:** Affinity level (0-10 scale), or `0` if not recruited/found

**Usage:**
```yarn
<<if get_affinity("Canopy") >= 8>>
    Canopy: You've become very special to me.
    -> Discuss deeper feelings
        <<jump RomanceConversation>>
<<elseif get_affinity("Canopy") >= 5>>
    Canopy: I'm glad we're getting to know each other.
<<endif>>

// Store affinity in variable
<<set $canopy_affinity = get_affinity("Canopy")>>
Canopy: Our bond is at level <<$canopy_affinity>>.

// Check multiple companions
<<if get_affinity("Hola") >= 5 and get_affinity("Yorna") >= 5>>
    Both Hola and Yorna trust you deeply!
<<endif>>
```

**Affinity Tiers (Recommended):**
- **0-2.9**: Not recruited or very low trust
- **3.0-4.9**: Base tier - Basic companion abilities unlocked
- **5.0-7.9**: Mid tier - Backstory and deeper conversations
- **8.0-9.9**: Advanced tier - Romance options and personal quests
- **10.0**: Ultimate tier - Deepest secrets and maximum power

**Error Handling:**
- Returns `0` if companion_name is invalid
- Returns `0` if companion not found
- Returns `0` if companion not recruited
- Case-insensitive: "Canopy", "canopy", "CANOPY" all work

---

## Quest Progress Functions

### objective_complete(quest_id, objective_index)

Check if a quest objective is complete.

**Parameters:**
- `quest_id` (string) - Quest ID from `global.quest_database`
- `objective_index` (number) - Objective index (0-based)

**Returns:** `true` if objective complete, `false` otherwise

**Usage:**
```yarn
<<if quest_is_active("defeat_bandits")>>
    <<if objective_complete("defeat_bandits", 0)>>
        Quest Giver: You've defeated all the bandits!
        -> Turn in quest
            <<quest_complete("defeat_bandits")>>
    <<else>>
        Quest Giver: Keep hunting those bandits!
    <<endif>>
<<endif>>

// Check multiple objectives
<<if objective_complete("main_quest", 0) and objective_complete("main_quest", 1)>>
    All objectives complete! Return to quest giver.
<<endif>>
```

**Error Handling:**
- Returns `false` if quest not active
- Returns `false` if quest_id is invalid
- Returns `false` if objective_index is out of bounds
- Returns `false` if objective_index is negative

---

### quest_progress(quest_id, objective_index)

Get current progress count for a quest objective.

**Parameters:**
- `quest_id` (string) - Quest ID from `global.quest_database`
- `objective_index` (number) - Objective index (0-based)

**Returns:** Current progress count (number), or `0` if invalid

**Usage:**
```yarn
Quest Giver: You've defeated <<quest_progress("defeat_bandits", 0)>> out of 5 bandits.

// Show progress bar
<<set $progress = quest_progress("collect_herbs", 0)>>
Progress: [<<$progress>>/10 herbs collected]

// Conditional dialogue based on progress
<<if quest_progress("escort_mission", 0) >= 3>>
    NPC: You're more than halfway there!
<<elseif quest_progress("escort_mission", 0) >= 1>>
    NPC: Good start!
<<else>>
    NPC: The journey begins.
<<endif>>

// Display all objectives for multi-objective quest
Quest Progress:
- Kill Orcs: <<quest_progress("main_quest", 0)>>/5 <<if objective_complete("main_quest", 0)>>[✓]<<endif>>
- Collect Herbs: <<quest_progress("main_quest", 1)>>/3 <<if objective_complete("main_quest", 1)>>[✓]<<endif>>
- Return to Town: <<quest_progress("main_quest", 2)>>/1 <<if objective_complete("main_quest", 2)>>[✓]<<endif>>
```

**Error Handling:**
- Returns `0` if quest not active
- Returns `0` if quest_id is invalid
- Returns `0` if objective_index is out of bounds
- Returns `0` if objective_index is negative

---

## Existing Quest Functions

These functions already exist in the quest system:

### quest_accept(quest_id)
Accept a quest and add it to active quests.

### quest_is_active(quest_id)
Returns `true` if quest is currently active.

### quest_is_complete(quest_id)
Returns `true` if quest has been completed.

### quest_can_accept(quest_id)
Returns `true` if quest can be accepted (prerequisites met, not already active/complete).

**Usage:**
```yarn
<<if quest_can_accept("rescue_mission")>>
    -> Accept Rescue Mission quest
        <<quest_accept("rescue_mission")>>
        Quest accepted!
<<endif>>

<<if quest_is_active("defeat_bandits")>>
    -> Check quest progress
        <<jump QuestCheckIn>>
<<endif>>
```

---

## Complete Examples

### Merchant NPC with Full Shop

```yarn
title: MerchantStart
---
Merchant: Welcome! What can I do for you?
Merchant: You have <<inventory_count("gold")>> gold.

    -> Browse wares
        <<jump BrowseShop>>
    -> Sell items
        <<jump SellMenu>>
    -> Leave
        <<jump Exit>>
===

title: BrowseShop
---
    -> Arrows (10 for 5 gold) <<if has_item("gold", 5)>>
        <<if remove_item("gold", 5)>>
            <<if give_item("arrows", 10)>>
                Merchant: Here you go! You now have <<inventory_count("arrows")>> arrows.
            <<else>>
                Merchant: Inventory full!
                <<give_item("gold", 5)>>
            <<endif>>
        <<endif>>
        <<jump BrowseShop>>
    -> Back
        <<jump MerchantStart>>
===
```

### Companion with Affinity Gates

```yarn
title: CanopyTalk
---
<<set $affinity = get_affinity("Canopy")>>

<<if $affinity >= 8>>
    Canopy: I'm so glad you're here.
<<elseif $affinity >= 5>>
    Canopy: Good to see you!
<<else>>
    Canopy: Hello.
<<endif>>

    -> Tell me about your past <<if get_affinity("Canopy") >= 5>>
        <<jump Backstory>>
    -> What's your deepest secret? <<if get_affinity("Canopy") >= 10>>
        <<jump DeepSecret>>
    -> Just checking in
        <<jump Exit>>
===
```

### Quest with Progress Tracking

```yarn
title: QuestGiver
---
<<if quest_is_complete("defeat_bandits")>>
    Quest Giver: Thanks for dealing with those bandits!
<<elseif quest_is_active("defeat_bandits")>>
    <<if objective_complete("defeat_bandits", 0)>>
        Quest Giver: All bandits defeated! Well done!
        -> Turn in quest
            <<quest_complete("defeat_bandits")>>
            <<give_item("gold", 100)>>
            Quest complete! +100 gold
    <<else>>
        Quest Giver: Progress: <<quest_progress("defeat_bandits", 0)>>/5 bandits defeated.
        Quest Giver: Keep it up!
    <<endif>>
<<elseif quest_can_accept("defeat_bandits")>>
    -> Accept quest: Defeat 5 Bandits
        <<quest_accept("defeat_bandits")>>
        Quest accepted!
<<endif>>
===
```

---

## Integration Notes

**File Locations:**
- Function registration: `obj_game_controller/Create_0.gml` (lines 206-284)
- Inventory system: `scr_inventory_system.gml`
- Companion system: `scr_companion_system.gml`
- Quest system: `scr_quest_system.gml`

**Item IDs:**
All valid item IDs are defined in `global.item_database` (see `scr_item_database.gml`). Common items include:
- Weapons: `rusty_dagger`, `short_sword`, `long_sword`, `wooden_bow`, `longbow`
- Armor: `leather_helmet`, `leather_armor`, `chain_coif`, `plate_helmet`
- Consumables: `small_health_potion`, `medium_health_potion`, `large_health_potion`
- Ammo: `arrows`
- Currency: `gold`
- Quest items: `mysterious_letter`, `ancient_artifact`, `wolf_pelt`

**Quest IDs:**
Check `global.quest_database` in `scr_quest_system.gml` for all available quests.

**Companion Names:**
- "Canopy" (or "canopy", "CANOPY" - case insensitive)
- "Hola" (or "hola", "HOLA")
- "Yorna" (or "yorna", "YORNA")

---

## Creating New Content

Use the `/vn-content` skill to generate dialogue templates with these functions automatically integrated. The skill guides you through creating:
- Companion dialogue hubs
- Quest acceptance/progress/completion dialogues
- Merchant NPCs with shops
- Environmental VN sequences

See: `.claude/skills/vn-content.md`

---

## Testing

Test dialogue files created in `/datafiles/`:
- `test_inventory_functions.yarn` - All inventory functions
- `test_affinity_functions.yarn` - Affinity queries and tiers
- `test_quest_progress_functions.yarn` - Quest progress tracking
- `example_merchant.yarn` - Full merchant shop
- `example_affinity.yarn` - Companion with affinity gates
- `example_quest.yarn` - Quest with progress tracking

Test NPCs in objects:
- `obj_test_inventory_merchant`
- `obj_test_affinity_sage`
- `obj_test_quest_master`
