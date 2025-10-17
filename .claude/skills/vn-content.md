# VN Content Creation Skill

Create new visual novel dialogue content for Shadow Work with guided templates and integration code.

## Overview

This skill helps you create companion dialogues, quest conversations, NPC interactions, and environmental VN sequences with proper Yarn syntax and Chatterbox function usage.

## Workflow

I'll guide you through creating VN dialogue content step by step. First, let me know what type of content you want to create:

**Content Types:**
1. **Companion Dialogue** - Post-recruitment conversation hub for Canopy/Hola/Yorna
2. **Quest Dialogue** - Quest acceptance, progress check-ins, and completion
3. **NPC Dialogue** - Merchants, info givers, or story NPCs with branching conversations
4. **VN Intro Sequence** - Environmental storytelling with camera panning and portraits

**Available Functions:**
- **Inventory**: `has_item(item_id, quantity)`, `give_item(item_id, quantity)`, `remove_item(item_id, quantity)`, `inventory_count(item_id)`
- **Affinity**: `get_affinity(companion_name)` returns 0-10
- **Quest Progress**: `objective_complete(quest_id, index)`, `quest_progress(quest_id, index)`
- **Quest Management**: `quest_accept(quest_id)`, `quest_is_active(quest_id)`, `quest_is_complete(quest_id)`, `quest_can_accept(quest_id)`

## What to Ask

**Tell me:**
1. Which content type you want to create (1-4)
2. Any specific details about the dialogue (purpose, context, requirements)

I'll then generate:
- Complete Yarn file with proper templates
- GML integration code (if needed)
- Asset requirements
- Testing checklist

## Examples

**Example 1: Companion Affinity Dialogue**
```
User: Create companion dialogue for Canopy with affinity-gated content
Claude: [Generates complete Yarn file with 5 affinity tiers, uses get_affinity(), includes training/backstory/romance options]
```

**Example 2: Merchant with Inventory**
```
User: Create a merchant NPC that sells arrows and health potions
Claude: [Generates Yarn with buy/sell menus using has_item(), give_item(), remove_item(), plus NPC object code]
```

**Example 3: Quest with Progress Tracking**
```
User: Create quest dialogue for a "defeat 5 bandits" quest
Claude: [Generates Yarn with acceptance, progress checks using quest_progress(), turn-in logic]
```

## Ready?

What type of VN content would you like to create?
