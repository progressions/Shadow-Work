# Interaction Manager Testing Checklist

## Test Environment Setup
- [ ] Launch game in GameMaker (F5)
- [ ] Load a room with both companions and chests (or create test room)
- [ ] Enable debug mode if needed (F6)

## Test 1: Companion + Chest Priority (Companion should win)
**Setup:** Position player equidistant from a companion and a chest

**Expected Behavior:**
- [ ] Companion's interaction prompt shows ("[Space] Recruit" or "[Space] Talk")
- [ ] Chest prompt does NOT show
- [ ] Pressing SPACE interacts with companion only
- [ ] No double-interaction occurs

**How to verify:**
1. Stand equal distance from companion and chest (use Debug overlay to check distances if available)
2. Observe which prompt appears
3. Press SPACE and confirm only companion interaction triggers

---

## Test 2: Multiple Chests (Nearest wins)
**Setup:** Position player between 2-3 chests at different distances

**Expected Behavior:**
- [ ] Only nearest chest shows prompt ("[Space] Open")
- [ ] Prompt switches to different chest when player moves closer to it
- [ ] Pressing SPACE opens only the nearest chest
- [ ] No orphaned prompts remain after moving

**How to verify:**
1. Stand closer to Chest A than Chest B
2. Confirm Chest A shows prompt
3. Move closer to Chest B
4. Confirm prompt switches to Chest B
5. Open nearest chest, confirm only it opens

---

## Test 3: Distance as Tiebreaker
**Setup:** Position companion and chest with same base priority at different distances

**Expected Behavior:**
- [ ] When companion is closer → companion prompt shows
- [ ] When chest is closer → chest prompt shows
- [ ] Priority formula works: `score = base_priority + (max_distance - distance)`
- [ ] Smooth switching between objects as player moves

**How to verify:**
1. Find scenario where companion (priority 100) is far, chest (priority 50) is close
2. Chest should win due to distance bonus
3. Walk toward companion
4. Companion should win when close enough

---

## Test 4: Edge Cases
**Setup:** Various challenging scenarios

**Test 4a: Fast Movement**
- [ ] Sprint/dash past multiple interactive objects
- [ ] Prompts update correctly without lag
- [ ] No crashes or stuck prompts

**Test 4b: Same Distance Objects**
- [ ] Position two chests at exactly same distance
- [ ] One prompt shows (consistent selection)
- [ ] No flickering between prompts

**Test 4c: Interaction Radius Boundary**
- [ ] Walk slowly toward interactive object
- [ ] Prompt appears exactly at interaction_radius distance
- [ ] Prompt disappears when leaving radius

**Test 4d: Multiple Object Types**
- [ ] Test with companion + chest + any other interactive objects
- [ ] Correct priority order maintained
- [ ] No conflicts between different object types

---

## Test 5: Input Conflicts
**Setup:** Scenarios that could cause double-interactions

**Expected Behavior:**
- [ ] Pressing SPACE once triggers only ONE interaction
- [ ] No duplicate dialogue windows
- [ ] No multiple chest openings
- [ ] Only `global.active_interactive` responds to input

**How to verify:**
1. Stand in range of multiple objects
2. Press SPACE once
3. Confirm only one interaction occurs
4. Check debug log for duplicate interaction messages

---

## Test 6: Backward Compatibility
**Setup:** Load existing save file from before interaction manager

**Expected Behavior:**
- [ ] Game loads without errors
- [ ] All interactive objects still work
- [ ] Companions can still be recruited/talked to
- [ ] Chests can still be opened
- [ ] No missing variables or undefined errors

**How to verify:**
1. Load old save file
2. Test interacting with companions
3. Test opening chests
4. Check console for errors

---

## Test 7: Performance Check
**Setup:** Room with many interactive objects (10+ chests, 2-3 companions)

**Expected Behavior:**
- [ ] No frame drops when walking through room
- [ ] Prompt switching is smooth
- [ ] obj_interaction_manager Step event runs efficiently
- [ ] No lag when calculating priorities

**How to verify:**
1. Create/find room with many interactive objects
2. Monitor FPS (show_debug_overlay in GameMaker)
3. Walk around room, observe frame rate
4. Confirm smooth performance

---

## Test 8: Final Validation
**All Interactive Object Types:**
- [ ] obj_companion_parent → Works correctly
- [ ] obj_openable (chests) → Works correctly
- [ ] obj_openable (barrels) → Works correctly
- [ ] obj_openable (crates) → Works correctly
- [ ] Any other interactive objects → Document and test

**Integration Points:**
- [ ] VN dialogue system triggers correctly from companions
- [ ] Loot spawning works when opening containers
- [ ] Interaction prompts follow parent instances correctly
- [ ] Prompt text updates dynamically (Recruit → Talk)

---

## Known Issues / Edge Cases to Document
Use this section to note any unexpected behavior:

```
Issue:
Expected:
Actual:
Steps to reproduce:
```

---

## Sign-off Checklist
- [ ] All priority scenarios work as designed
- [ ] No double-interactions occur
- [ ] Performance is acceptable
- [ ] Backward compatibility confirmed
- [ ] All interactive object types validated
- [ ] Edge cases handled gracefully
- [ ] Ready for production use

---

## Debug Tips

**Check active interactive:**
Add to obj_interaction_manager Step event temporarily:
```gml
if (global.active_interactive != noone) {
    show_debug_message("Active: " + object_get_name(global.active_interactive.object_index));
}
```

**Visualize interaction radius:**
Add to interactive objects' Draw event temporarily:
```gml
draw_circle(x, y, interaction_radius, true);
draw_text(x, y - 40, string(interaction_priority));
```

**Monitor priority scores:**
Add to obj_interaction_manager after score calculation:
```gml
show_debug_message(object_get_name(_obj.object_index) +
    " - Priority: " + string(_obj.interaction_priority) +
    " - Distance: " + string(_distance) +
    " - Score: " + string(_score));
```
