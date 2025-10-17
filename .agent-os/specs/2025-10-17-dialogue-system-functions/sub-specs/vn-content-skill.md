# VN Content Creation Skill Specification

This is the skill specification for the spec detailed in @.agent-os/specs/2025-10-17-dialogue-system-functions/spec.md

## Skill Overview

Create a Claude Code skill that provides an interactive, guided workflow for adding new VN dialogue content to the game. The skill should handle all four major dialogue content types and streamline the creation process from concept to implementation.

## Skill Command

**Command**: `/vn-content`

**Location**: `.claude/skills/vn-content.md`

## Content Types Supported

1. **Companion Dialogue** - Post-recruitment conversation hubs for Canopy, Hola, and Yorna
2. **Quest Dialogue** - Quest acceptance, progress check-ins, and completion sequences
3. **NPC Dialogue** - Merchants, information givers, story NPCs with branching conversations
4. **VN Intro Sequences** - Environmental storytelling with camera panning, portraits, and videos

## Skill Workflow

### Step 1: Content Type Selection

Present user with options:
- Companion dialogue (add to existing companion)
- Quest dialogue (for new or existing quest)
- NPC dialogue (create new NPC or add to existing)
- VN intro sequence (environmental storytelling)

### Step 2: Context Gathering

Based on content type, gather specific information:

**For Companion Dialogue:**
- Which companion (Canopy/Hola/Yorna)
- Dialogue purpose (general chat, quest-related, affinity milestone)
- Starting node name
- Required affinity level (if gated content)
- Items involved (if any)
- Quest integration (if any)

**For Quest Dialogue:**
- Quest ID and name
- Quest giver (companion or NPC)
- Number of objectives
- Quest rewards (items, gold, XP, affinity)
- Quest acceptance requirements (level, items, previous quests)

**For NPC Dialogue:**
- NPC name and role (merchant, informant, quest giver)
- Location in game world
- Dialogue purpose (trading, information, quest)
- Inventory of items (if merchant)
- One-time or repeatable dialogue

**For VN Intro:**
- Scene/location name
- Trigger type (enter room, interact with object, story trigger)
- Character(s) involved
- Camera panning behavior
- Portrait/video requirements
- "Seen" persistence (one-time or repeatable)

### Step 3: Generate Yarn Template

Create appropriate Yarn file template with:
- Proper node structure
- Example dialogue function usage (`has_item`, `get_affinity`, `quest_progress`, etc.)
- Conditional logic patterns
- Choice branching
- Variable setting
- Jump statements to Exit

**Template Examples:**

**Companion Template:**
```yarn
title: [CompanionName]Chat
---
<<if get_affinity("[CompanionName]") >= 8>>
    [Companion]: [High affinity greeting]
    -> [Deep conversation option]
        [Companion]: [Personal revelation]
        <<jump Exit>>
<<elseif get_affinity("[CompanionName]") >= 5>>
    [Companion]: [Medium affinity greeting]
<<else>>
    [Companion]: [Low affinity greeting]
<<endif>>

    -> [General chat option]
        <<jump GeneralChat>>
    -> [Quest-related option] <<if quest_is_active("[quest_id]")>>
        <<jump QuestChat>>
    -> Nevermind
        <<jump Exit>>
===
```

**Quest Template:**
```yarn
title: QuestAcceptance
---
[Quest Giver]: [Quest introduction]
    -> Accept quest <<if quest_can_accept("[quest_id]")>>
        <<quest_accept("[quest_id]")>>
        [Quest Giver]: [Acceptance response]
        <<jump Exit>>
    -> Not now
        <<jump Exit>>
===

title: QuestCheckIn
---
<<if quest_is_active("[quest_id]")>>
    <<if objective_complete("[quest_id]", 0)>>
        [Quest Giver]: You've completed the objective!
        -> Turn in quest
            <<quest_complete("[quest_id]")>>
            <<give_item("[reward_item]")>>
            [Quest Giver]: Here's your reward!
            <<jump Exit>>
    <<else>>
        [Quest Giver]: Progress: <<quest_progress("[quest_id]", 0)>>/[required]
    <<endif>>
<<endif>>
===
```

**Merchant Template:**
```yarn
title: MerchantGreeting
---
[Merchant]: Welcome! What can I get you?
    -> Buy [item1] ([price] gold) <<if has_item("gold", [price])>>
        <<remove_item("gold", [price])>>
        <<give_item("[item1]")>>
        [Merchant]: Pleasure doing business!
        <<jump MerchantGreeting>>
    -> Buy [item2] ([price] gold) <<if has_item("gold", [price])>>
        <<remove_item("gold", [price])>>
        <<give_item("[item2]")>>
        [Merchant]: Excellent choice!
        <<jump MerchantGreeting>>
    -> Sell items <<if inventory_count("[sellable_item]") > 0>>
        <<jump SellMenu>>
    -> Leave
        <<jump Exit>>
===
```

### Step 4: Asset Requirements

Guide user through required assets:

**For Companion Dialogue:**
- Existing companion sprites already in place
- Optional: New VN video (`.webm` in `/datafiles/videos/`)
- Music: Companion theme (already implemented)

**For NPCs:**
- Portrait sprite (single frame, ~200x300px recommended)
- Sprite naming: `spr_[npc_name]_portrait`
- Optional: VN video alternative
- Optional: Custom music track

**For VN Intros:**
- Character portrait sprite
- Optional: Video file for animated portrait
- Background image (if scene-specific)

### Step 5: Integration Code

Generate appropriate integration code:

**For Companion Dialogue:**
```gml
// Add to [companion object]/Step_0.gml
// In the interaction check section (after recruitment check)

if (_dist_to_player < 48 && keyboard_check_pressed(vk_space) && is_recruited) {
    start_vn_dialogue(id, "[companion_name]_[dialogue_type].yarn", "Start");
}
```

**For NPCs:**
```gml
// Create new object: obj_[npc_name]
// Inherit from: obj_interactable_parent (or create standalone)

// Create Event:
portrait_sprite = spr_[npc_name]_portrait;
vn_video_path = ""; // Or "videos/[npc_name].webm"
npc_name = "[Display Name]";
theme_song = noone; // Or snd_[theme] if custom

// Step Event:
var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

if (_dist_to_player < 48 && keyboard_check_pressed(vk_space)) {
    start_vn_dialogue(id, "[npc_name].yarn", "Start");
}

// Draw Event (if showing interaction prompt):
if (point_distance(x, y, obj_player.x, obj_player.y) < 48) {
    draw_text(x, y - 32, "Press SPACE to talk");
}
```

**For VN Intros:**
```gml
// In triggering object or room creation code:

if (!global.[scene_name]_seen) {
    // Create VN intro trigger
    var _intro_data = {
        character_name: "[Character Name]",
        portrait_sprite: spr_[character]_portrait,
        video_path: "", // Or "videos/[scene].webm"
        yarn_file: "[scene_name]_intro.yarn",
        starting_node: "Start",
        camera_target_x: [x_position],
        camera_target_y: [y_position]
    };

    start_vn_intro(_intro_data);
    global.[scene_name]_seen = true;
}
```

### Step 6: File Creation and Placement

Create files and provide placement instructions:

**Yarn File:**
- Location: `/datafiles/[filename].yarn`
- Naming convention:
  - Companion: `[companion_name]_[purpose].yarn` (e.g., `canopy_affinity_8.yarn`)
  - Quest: `quest_[quest_id].yarn`
  - NPC: `[npc_name].yarn`
  - Intro: `[scene_name]_intro.yarn`

**Object File:**
- For NPCs: Create in GameMaker IDE as `obj_[npc_name]`
- For intros: May use existing trigger objects

**Sprite Assets:**
- Location: Import into GameMaker sprite editor
- Naming: `spr_[name]_portrait` or `spr_[name]_vn`

**Video Assets:**
- Location: `/datafiles/videos/[filename].webm`
- Format: WebM with VP8/VP9 codec
- Resolution: 400x600 recommended (portrait orientation)

### Step 7: Testing Checklist

Provide testing checklist:

- [ ] Yarn file loads without errors (check GameMaker output)
- [ ] Dialogue triggers properly in-game
- [ ] Portrait/video displays correctly
- [ ] All conditional branches work (test both passing and failing conditions)
- [ ] Function calls work (inventory checks, affinity checks, quest progress)
- [ ] Item give/remove operations execute correctly
- [ ] Exit paths work (dialogue closes properly)
- [ ] Music transitions work (starts companion theme, restores on close)
- [ ] Interaction prompt appears at correct distance
- [ ] Repeated conversations work as expected

## Skill Behavior

### Interactive Prompts
- Use clear numbered prompts for content type selection
- Provide examples and context for each choice
- Validate inputs and provide helpful error messages

### Template Customization
- Replace all `[placeholder]` text with user-provided values
- Include commented sections explaining advanced patterns
- Provide working default values that can be refined

### Code Generation
- Generate complete, runnable code snippets
- Include line number references to existing code when modifying
- Provide file paths for all created assets

### Documentation Links
- Reference relevant CLAUDE.md sections
- Link to documentation files (e.g., QUEST_SYSTEM.md, COMPANION_SYSTEM_TECHNICAL.md)
- Provide Yarn syntax examples from existing dialogue files

## Error Handling

The skill should handle common issues:
- Invalid companion names (only Canopy, Hola, Yorna supported)
- Non-existent quest IDs
- Missing required assets (provide creation guidance)
- Syntax errors in user-provided dialogue text
- Invalid function names (suggest correct alternatives)

## Example Skill Invocation

```
User: /vn-content
Skill: I'll help you create new VN dialogue content. What type of content do you want to create?

1. Companion dialogue (add conversation to existing companion)
2. Quest dialogue (quest acceptance/completion/check-ins)
3. NPC dialogue (merchants, info givers, quest givers)
4. VN intro sequence (environmental storytelling scene)

User: 2
Skill: Great! Let's create quest dialogue. I'll need some information:

1. Quest ID (lowercase with underscores, e.g., "defeat_bandits"): [waits for input]
2. Quest name (display name): [waits for input]
3. Quest giver (Canopy/Hola/Yorna/new NPC name): [waits for input]
...
```

## Implementation Notes

- The skill file should be created at `.claude/skills/vn-content.md`
- Use the Agent tool for complex template generation
- Leverage existing helper functions from `scr_vn_helpers.gml`
- Reference dialogue function documentation from technical-spec.md
- Validate all generated code against GameMaker GML syntax

## Success Criteria

The skill is successful when:
1. User can invoke `/vn-content` and receive clear, interactive prompts
2. Generated Yarn templates are syntactically correct and use proper function calls
3. Integration code is copy-paste ready and works without modification
4. Asset requirements are clearly documented with naming conventions
5. User can complete the workflow without referencing external documentation
