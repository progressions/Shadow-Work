# Armor Defense & Block System Implementation Plan

This document outlines the plan for implementing damage reduction through armor and shields in Shadow Work (GameMaker version), based on the proven mechanics from the JavaScript version.

## Current State

**Defense System Exists But Isn't Integrated:**
- `get_total_defense()` function calculates total armor defense (scr_combat_system.gml:78)
- `get_block_chance()` retrieves shield block percentage (scr_combat_system.gml:94)
- Armor items have defense stat values in item database
- **Neither function is called during damage calculation**

**Current Damage Flow:**
1. Enemy/Player deals base damage
2. Trait modifiers apply (fire_damage_modifier, etc.)
3. Status effect modifiers apply (empowered/weakened)
4. Full damage applied to HP - **defense never consulted**

---

## Goals

- Preserve the fantasy of heavy armor feeling meaningful
- Prevent complete immunity where high DR blocks all damage
- Add readable spikes via critical hits that threaten through armor
- Keep implementation straightforward and data-driven for tuning
- Maintain balance across enemy types (mooks, featured, bosses)

---

## Multi-Layered Defense System

### 1. Damage Reduction (DR) - Flat Armor Value
Armor provides flat damage reduction subtracted from incoming damage.

**Formula:**
```gml
var _defense = get_total_defense();
var _mitigated_damage = max(_base_damage - _defense, 0);
var _final_damage = max(_mitigated_damage, _chip_damage);
```

### 2. Chip Damage Floor
Guarantees minimum damage even when armor is high to prevent AFK tanking.

**Chip Values by Enemy Class:**
- **Mook** (Burglar, Greenwood Bandit): `chip = 1`
- **Featured** (Orc, Fire Imp, Sandsnake): `chip = 2`
- **Boss**: `chip = 0` (handled via crits/AP instead)

### 3. Critical Hits (DR Penetration + Bonus)
Enemies can roll critical hits that ignore a percentage of player DR and add bonus damage.

**Default Crit Stats (Enemy Parent):**
```gml
crit_chance = 0.06;        // 6% chance
crit_dr_ignore = 0.5;      // Ignore 50% of player DR
crit_bonus_damage = 1;     // +1 flat damage bonus
```

**Per-Enemy Overrides:**
- **Mooks** (Burglar, Greenwood Bandit): 6% / 50% ignore / +1 bonus
- **Featured** (Orc, Fire Imp): 10% / 60% ignore / +2 bonus
- **Boss**: 12% / 70% ignore / +3 bonus

### 4. Block Chance (Shields)
Shields provide a chance to block incoming attacks, reducing damage by 75%.

**Block Calculation:**
```gml
var _block_chance = get_block_chance();
var _blocked = random(1) < _block_chance;
if (_blocked) {
    _final_damage = _base_damage * 0.25; // 75% reduction
}
```

**Shield Block Values:**
- Small Shield: 20-30% block chance
- Iron Shield: 40-50% block chance
- Greatshield: 60-70% block chance

### 5. Player Critical Hits
Give player counter-play with DR penetration and damage multiplier.

**Player Crit Stats:**
```gml
crit_chance = 0.08;          // 8% base chance
crit_damage_mult = 1.5;      // 1.5x damage multiplier
crit_dr_ignore = 0.5;        // Ignore 50% enemy DR (future)
```

**Companion Aura Bonuses (Future):**
- Certain companions can grant +3-6% crit chance aura
- Example: Sharp-eyed archer companion provides +5% crit

---

## Implementation Plan

### **Phase 1: Basic DR System** ⭐ Start Here

**Files to Modify:**
1. `objects/obj_player/Collision_obj_enemy_parent.gml:10`
2. `objects/obj_enemy_parent/Alarm_2.gml:16-19`

**Changes:**
- Call `get_total_defense()` before applying damage
- Subtract defense from base damage
- Apply chip damage floor based on enemy type
- Add floating text for damage mitigation feedback

**Pseudocode:**
```gml
// Player taking damage
var _defense = get_total_defense();
var _mitigated = max(_base_damage - _defense, 0);
var _chip = (other.enemy_class == "featured") ? 2 : 1;
var _final_damage = max(_mitigated, _chip);
hp -= _final_damage;
```

---

### **Phase 2: Block Chance (Shields)**

**Files to Modify:**
1. Same files as Phase 1 (before DR calculation)

**Changes:**
- Roll block chance before damage calculation
- If blocked, reduce damage by 75%
- Show "BLOCKED!" floating text
- Play shield block sound effect

**Pseudocode:**
```gml
var _block_chance = get_block_chance();
if (random(1) < _block_chance) {
    _base_damage *= 0.25; // 75% reduction
    // Show "BLOCKED!" text
    // Play snd_shield_block
}
```

---

### **Phase 3: Enemy Critical Hits**

**Files to Modify:**
1. `objects/obj_enemy_parent/Create_0.gml` - Add crit stats
2. `objects/obj_orc/Create_0.gml` - Override with featured values
3. `objects/obj_fire_imp/Create_0.gml` - Override with featured values
4. `objects/obj_enemy_parent/Alarm_2.gml` - Add crit roll

**Changes:**
- Add crit properties to enemy parent
- Override crit values per enemy type (mook/featured/boss)
- Roll crit chance before damage calculation
- Reduce effective DR by crit_dr_ignore percentage
- Add crit_bonus_damage to final damage
- Show "CRIT! X" floating text in different color

**Pseudocode:**
```gml
var _is_crit = random(1) < crit_chance;
var _effective_defense = _is_crit ? (_defense * (1 - crit_dr_ignore)) : _defense;
var _bonus = _is_crit ? crit_bonus_damage : 0;
var _mitigated = max(_base_damage - _effective_defense + _bonus, _chip);

if (_is_crit) {
    // Spawn floating text: "CRIT! " + string(_mitigated)
    // Play pierce SFX
}
```

---

### **Phase 4: Player Critical Hits**

**Files to Modify:**
1. `objects/obj_player/Create_0.gml` - Add player crit stats
2. `scripts/player_attacking/player_attacking.gml` or attack damage calculation
3. `objects/obj_attack/Create_0.gml` - Store crit flag

**Changes:**
- Add crit_chance and crit_damage_mult to player
- Roll crit when player attacks
- Multiply damage by crit_damage_mult on crit
- Show "CRIT! X" floating text in bright color
- Play critical hit sound effect

**Pseudocode:**
```gml
// In player attack code
var _is_crit = random(1) < crit_chance;
var _damage = _is_crit ? (_base_damage * crit_damage_mult) : _base_damage;
obj_attack.damage = _damage;
obj_attack.is_crit = _is_crit;
```

---

## Balance Tuning

### Armor Defense Values (From Item Database)

**Current Values to Check/Adjust:**
- **Leather Armor Set**: ~6-9 total DR
  - Helmet: 2 defense
  - Torso: 3 defense
  - Legs: 2 defense
- **Chain Armor Set**: ~15-21 total DR
  - Coif: 5 defense
  - Armor: 8 defense
  - Leggings: 5 defense
- **Plate Armor Set**: ~30-45 total DR
  - Helmet: 10 defense
  - Armor: 20 defense
  - Sabatons: 10 defense

### Enemy Damage Values (Current)

**Mooks:**
- Burglar: 1 damage → chip through everything (always 1 damage minimum)
- Greenwood Bandit: 2 damage → partially mitigated by leather/chain

**Featured:**
- Orc: 3 damage → mitigated by leather/chain, chip 2 through plate
- Fire Imp: varies (needs review for magic damage type)
- Sandsnake: needs review

**Expected Outcomes:**
- **No Armor**: Take full damage
- **Leather Armor**: Reduce mook damage by 60-70%, featured by 30-50%
- **Chain Armor**: Reduce mook damage by 80-90%, featured by 50-70%
- **Plate Armor**: Reduce mook to chip (1-2), featured by 70-85%
- **Crits**: Bypass mitigation ~6-12% of hits, creating damage spikes

---

## Visual & Audio Feedback

### Floating Text Types
- **Full Mitigation**: Show reduced number in gray (e.g., "1" when 3 damage reduced to chip)
- **Blocked**: "BLOCKED!" in blue/cyan when shield blocks
- **Critical Hit (Enemy)**: "CRIT! X" in red/orange
- **Critical Hit (Player)**: "CRIT! X" in yellow/bright
- **Pierce/AP** (Future): "PIERCE! X" in distinct color

### Sound Effects Needed
- `snd_shield_block` - Shield blocking attack (metallic clang)
- `snd_crit_hit` - Critical hit landed (heavier impact)
- `snd_armor_deflect` - High DR mitigation (armor clank)

### Visual Effects (Optional)
- Brief sprite flash on crit
- Shield shimmer on block
- Camera shake on boss pierce (future)

---

## Testing Checklist

### Phase 1 Testing (DR + Chip)
- [ ] Equip no armor → take full damage from all enemies
- [ ] Equip leather set → verify ~6-9 damage reduction
- [ ] Equip chain set → verify ~15-21 damage reduction
- [ ] Equip plate set → verify ~30-45 damage reduction
- [ ] Verify chip damage (1-2) always applies even with high DR
- [ ] Check debug display shows correct defense value

### Phase 2 Testing (Block)
- [ ] Equip shield → verify block chance triggers
- [ ] Verify blocked attacks reduce damage by 75%
- [ ] Verify "BLOCKED!" text appears
- [ ] Test block + DR interaction (block applies first)

### Phase 3 Testing (Enemy Crits)
- [ ] Mooks crit ~6% of the time
- [ ] Featured enemies crit ~10% of the time
- [ ] Crits show "CRIT!" floating text
- [ ] Crits deal noticeably more damage through armor
- [ ] Verify crit sound plays

### Phase 4 Testing (Player Crits)
- [ ] Player crits ~8% of attacks
- [ ] Crits deal 1.5x damage
- [ ] Player crit text distinct from enemy crits
- [ ] Crit sound plays on player hits

---

## Optional Future Enhancements

### Armor Penetration (AP) Special Attacks
- Tag specific enemy attacks with `ap: 2-3` (ignores flat DR)
- Featured enemies: One wind-up attack with AP
- Bosses: Special ability with true damage component

### Soft DR Cap (Guardrail)
- Cap effective mitigation at ~75% vs attacker's base
- Only enable if needed after playtesting

### Companion Crit Auras
- Certain companions grant +5% crit chance while present
- Example: Sharp-eyed ranger, weak point specialist

### Enemy Armor/DR
- Elite enemies could have defense values
- Player crits would ignore 50% of enemy DR

---

## Implementation Order Summary

1. **✅ Phase 1 (Basic DR)** - Immediate impact, easiest to implement
2. **✅ Phase 2 (Block Chance)** - Already coded, just needs integration
3. **⏳ Phase 3 (Enemy Crits)** - Adds danger spikes, prevents tanking
4. **⏳ Phase 4 (Player Crits)** - Rewards player skill, parity with enemies

**Start with Phase 1**, test thoroughly, then incrementally add Phases 2-4 based on playtesting feedback.

---

## Reference Files

**Functions to Use:**
- `scripts/scr_combat_system/scr_combat_system.gml:78` - `get_total_defense()`
- `scripts/scr_combat_system/scr_combat_system.gml:94` - `get_block_chance()`

**Damage Calculation Locations:**
- `objects/obj_player/Collision_obj_enemy_parent.gml:10` - Player hit by enemy collision
- `objects/obj_enemy_parent/Alarm_2.gml:16-19` - Player hit by enemy attack
- `objects/obj_enemy_parent/Collision_obj_attack.gml:15` - Enemy hit by player

**Item Database:**
- `scripts/scr_item_database/scr_item_database.gml` - Armor defense values

**Enemy Definitions:**
- `objects/obj_enemy_parent/Create_0.gml` - Base enemy stats
- `objects/obj_orc/Create_0.gml` - Orc stats
- `objects/obj_burglar/Create_0.gml` - Burglar stats
- `objects/obj_greenwood_bandit/Create_0.gml` - Greenwood Bandit stats
