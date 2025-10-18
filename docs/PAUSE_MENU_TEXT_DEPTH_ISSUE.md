# Pause Menu Text Depth Issue - Investigation Log

## Problem Description
The pause menu button is obscuring/covering the text that should be displayed on top of it. The text appears to be rendering behind the button sprite instead of in front.

## Known Facts

### The Bad Commit
- **Commit:** `622cf45e69c7e2fe98faa1cb1315472e74bf26f3`
- **Date:** Mon Sep 29 15:25:34 2025 -0400
- **Message:** "Implement comprehensive audio configuration system with music manager"
- **Identified via:** `git bisect`

### What This Commit Changed
1. Made `obj_pause_controller` and `obj_inventory` persistent
2. Changed layer depths in `Room1.yy`:
   - Removed `Assets_1` layer (depth -200)
   - Removed `Instances_1` layer (depth 0)
   - Changed `Instances` layer: depth 100 → depth 0
   - Changed `Tiles_Col`: depth 200 → depth 100
   - Changed `Tiles_Forest`: depth 300 → depth 200
   - Changed `Tiles_Water`: depth 400 → depth 300
   - Changed `Tiles_Water_Background`: depth 500 → depth 400
   - Changed `Tiles_Path`: depth 600 → depth 500
   - Changed `Tiles_Background`: depth 700 → depth 600
   - Changed `Background`: depth 800 → depth 700
3. Added music controller objects and song triggers
4. Added `obj_ui_hud/Draw_0.gml`

### Subsequent Changes
- **Commit `3525e85`** (Oct 18 2025): "Starting over on pause"
  - Deleted `obj_pause_controller` entirely
  - Removed pause controller from Room1
- **Commit `6ecc772`** (Oct 18 2025): "Debug button"
  - Added `PauseLayer` to `RoomUI.yy` with working button structure
- **Commit `13f53dd`** (Oct 17 2025): "Remove debug logs and update UI assets"
  - Removed the complete PauseLayer with all buttons (Resume/Settings/Quit)
- **Current state:** `UILayer_1` exists in RoomUI with a button and text

## What We've Investigated (DO NOT REPEAT)

### ✗ RoomUI Layer Ordering (Attempted 2025-10-18)
- **Hypothesis:** Button rendering after text in FlexPanel children
- **Action Taken:** Reordered children in `FlexPanel_1` to put button first, added `stretchHeight/stretchWidth` properties
- **File Changed:** `roomui/RoomUI/RoomUI.yy`
- **Result:** Unknown/Not working (user indicated this wasn't the issue)

### ✗ obj_pause_controller.update_pause() Reference
- **Issue Found:** `obj_button/Mouse_7.gml` had broken reference to deleted `obj_pause_controller.update_pause()`
- **Action Taken:** Removed the broken function call (line 4)
- **File Changed:** `objects/obj_button/Mouse_7.gml`
- **Result:** Fixed broken reference but didn't solve text depth issue

### ✗ Persistence Flag
- **Hypothesis:** Making controllers persistent caused the issue
- **Analysis:** Making objects persistent wouldn't affect rendering depth/layering
- **Result:** Not the root cause

## Current System State

### Button Code (`obj_button/Mouse_7.gml`)
```gml
switch(button_id) {
	case ButtonType.resume:
		global.game_paused = false;
		break;
	case ButtonType.settings:
		break;
	case ButtonType.quit:
		game_end();
		break;
}
```

### RoomUI Structure (Current)
- `UILayer_1` contains:
  - `FlexPanel` → `FlexPanel_1` → Button + Text Panel
  - Button: `inst_7E343F6E` (obj_button)
  - Text: `text_7ABEC4B0` ("Lorem Ipsum") inside `FlexPanel_2`
  - Background: `graphic_10CEA9D4` (spr_box_frame)

### Important Notes
- **UI Layers are global for all rooms** - changes to Room1 depths could affect UI rendering
- The pause system currently works via `global.game_paused` flag only
- No `obj_pause_controller` exists anymore (deleted in commit 3525e85)

## What Still Needs Investigation

### 1. Room Layer Depth Impact on UI
- Since commit 622cf45 changed all room layer depths (shifted everything down by 100)
- UI Layers are global - need to understand how room depths interact with UI layer rendering
- **Key Question:** Do UI layers have implicit depths relative to room layers?

### 2. Font/Text Rendering Settings
- Check if `fnt_hud` font has changed (used by text in pause menu)
- Look at SDF settings, texture groups, depth settings
- Commit 622cf45 didn't directly change fonts, but check commits around that time

### 3. Draw Event Depth
- Check if there's a Draw event on obj_button that's overriding depth
- Look for `depth` assignments in button or UI controller code
- Check `obj_ui_hud/Draw_0.gml` (added in bad commit)

### 4. Sprite/Frame Depth Settings
- Check `spr_button` sprite settings for depth/layer info
- Check if button sprite has multiple layers that could obscure text

### 5. GameMaker UI System Configuration
- Check if there's a UI depth or layer priority setting in GameMaker project settings
- Look for RoomUI configuration that might have been affected

## Files to Examine

Priority order:
1. `objects/obj_ui_hud/Draw_0.gml` (added in bad commit)
2. Button draw events: `objects/obj_button/Draw_*.gml`
3. Font settings: `fonts/fnt_hud/` and `fonts/fnt_ui/`
4. Sprite depth: `sprites/spr_button/spr_button.yy`
5. Project settings related to UI rendering
6. Any controller that manages RoomUI visibility/depth

## Testing Approach

When testing a fix:
1. Load the game in GameMaker
2. Press ESC or trigger pause menu
3. Check if text "Resume"/"Settings"/"Quit" appears ON TOP of button backgrounds
4. Text should be clearly readable, not obscured

## References
- Commit history around the issue: `622cf45`, `3525e85`, `6ecc772`, `13f53dd`
- Key files: `roomui/RoomUI/RoomUI.yy`, `objects/obj_button/Mouse_7.gml`
- Documentation: `/docs/CLAUDE.md` mentions UI Layers are global
