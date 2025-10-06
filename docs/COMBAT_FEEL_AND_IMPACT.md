# Combat Feel and Impact - Design Ideas

This document outlines ideas for making Shadow Work's combat feel fast, punchy, and impactful, with a focus on visual/audio feedback, responsive controls, and meaningful companion interactions.

## Core Philosophy

Combat should feel:
- **Fast** - Responsive controls, quick attacks, fluid movement
- **Punchy** - Strong visual and audio feedback on every action
- **Impactful** - Player actions and companion triggers create visible, powerful effects

---

## Juice & Feel (The "Punchy" Part)

### Visual Feedback

- **Freeze frames** on hit (2-4 frames) - especially on crits or killing blows
- **Screen shake** intensity based on weapon (dagger = subtle, two-handed sword = big shake)
- **Hit sparks/particles** that spray in the direction of the attack
- **Enemy flash white** on hit, **red flash** on crit
- **Slow-mo moments** when triggers activate (0.5 second bullet-time)

### Audio Feedback

- **Layered hit sounds** - weapon swish + impact + enemy grunt
- **Different impact sounds** for armor vs flesh vs killing blow
- **Companion callouts** on trigger activation ("Now!" / "Strike!")

---

## Attack Feel (The "Fast" Part)

### Animation & Responsiveness

- **Animation canceling** - let players dash or dodge-cancel out of attack recovery frames
- **Attack buffering** - queue next attack during current swing (feels responsive)
- **Directional attacks** - holding a direction during attack changes the swing arc/range
- **Dash attacks** - attacking during dash = different attack with more range/damage

### Weapon Differentiation

- **Daggers**: 3-hit combo chain, each hit faster than the last
- **Swords**: Balanced speed, can change direction mid-combo
- **Two-handed**: Slower but has **super armor** during swing (can't be interrupted)
- **Versatile**: Hold J for charged heavy attack, tap for quick strikes

---

## Companion Trigger Systems (The "Impactful" Part)

### Active Trigger Ideas

- **Trigger chains** - Yorna trigger → brief window where Cowsill's trigger costs no cooldown
- **Conditional triggers** - Canopy's heal trigger is **instant** if player HP < 30%
- **AOE triggers** - Hola's magic creates a damage zone that stays for 3 seconds
- **Buff triggers** - Urn gives 5 seconds of attack speed + movement speed burst

### Trigger Activation Methods

- **Combo finishers** - land 5 hits → companion trigger auto-activates
- **Critical moments** - companion triggers when player drops to 25% HP
- **Enemy thresholds** - trigger when you break an enemy's guard/armor

### Visual Distinction

- **Aura rings** around player showing active buffs (color-coded per companion)
- **Trigger flash** - companion portrait glows/pulses when trigger activates
- **On-screen notifications** - "YORNA: BATTLE CRY!" with brief icon

---

## Enemy Reactions (Makes Hits Feel Good)

- **Knockback** on heavy hits (enemies slide back 8-16 pixels)
- **Stagger states** - enemies briefly stop attacking, show stagger animation
- **Guard break** - armored enemies have a guard bar, break it for 2x damage window
- **Death reactions** - enemies ragdoll/spin/explode based on what killed them
- **Overkill** - if killing blow does 3x remaining HP, enemy disintegrates

---

## Momentum & Flow

- **Attack speed stacking** - consecutive hits increase attack speed (caps at 150%)
- **Kill streaks** - every kill extends a damage buff by 2 seconds
- **Perfect dodges** - dodge just before hit = 1 second of slow-mo + guaranteed crit
- **Parry system** - attack at exact moment enemy attacks = stun them
- **Aura multiplication** - having 2+ companions with damage auras = extra bonus (1.2x + 1.2x = 1.5x instead of 1.4x)

---

## Combat Clarity

- **Danger zones** - enemies telegraph big attacks with red flash/circle
- **Attack arcs** - show your weapon's hitbox as a subtle white arc
- **Hit confirmation** - distinct sound + number popup on every successful hit
- **Damage numbers** - color-coded (white = normal, yellow = crit, red = super effective)

---

## Quick Wins (Highest Impact/Effort Ratio)

These features offer the most noticeable improvement for the least implementation effort:

1. **Add 3-frame freeze on kills** (feels SO good)
2. **Screen shake on every hit** (toggleable in options)
3. **Attack buffering** so J presses never feel dropped
4. **Knockback on heavy weapons**
5. **Flash enemies white on hit**

---

## Combat Evolution Ideas

### Combo Systems

- **Player-companion combos** - Yorna's aggression creates openings for backstab damage
- **Environmental combos** - Twil's fire with oil slicks, Tin creating ice patches on water
- **Weapon stance switching** mid-combat (aggressive/defensive toggles that change attack pattern)

### Companion Depth

- **Companion banter during combat** - reactive callouts when they synergize or when rivals work together
- **Affinity-gated combat abilities** - companions unlock new moves/auras at specific affinity thresholds
- **Jealousy/romance tension** - companions comment when pursuing multiple high-affinity relationships

### Enemy AI & Party Dynamics

- **Enemies calling for reinforcements** when they witness deaths (using AI memory system)
- **Elite enemies that target specific companions** they're weak against
- **Enemy morale breaks** - some flee, some go berserk (already supported by AI memory system)

### Meta-Systems

- **New Game+** with affinity carryover but harder enemies
- **Alternate boss strategies** based on which 12 quests you completed
