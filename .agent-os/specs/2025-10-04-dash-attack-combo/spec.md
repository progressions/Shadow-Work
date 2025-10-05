# Spec Requirements Document

> Spec: Dash Attack Combo
> Created: 2025-10-04

## Overview

Implement a dash attack combo system that rewards players for attacking immediately after dashing by providing a significant damage boost with a minor defensive tradeoff. This mechanic adds a high-risk, high-reward combat option that encourages aggressive, mobile playstyles.

## User Stories

### Aggressive Combat Maneuver

As a player, I want to execute a powerful dash attack combo, so that I can deal extra damage to enemies while maintaining offensive momentum.

**Workflow**: Player initiates a dash in a direction (existing dash mechanic), then immediately presses attack while still moving in the dash direction. The attack executes with boosted damage (+50%) but the player temporarily suffers reduced damage reduction (-25%) during the attack. A sound effect plays to confirm the successful combo execution.

### Tactical Risk vs Reward

As a player, I want to decide when to use dash attacks, so that I can balance the increased damage output against the increased vulnerability.

**Workflow**: Player assesses combat situation and decides whether the damage boost is worth the defensive penalty. If fighting tough enemies, player must time the dash attack carefully to maximize damage while minimizing exposure to counterattacks.

## Spec Scope

1. **Dash Attack Window** - Implement a brief timing window (approximately 0.3-0.5 seconds) after dash completion where attacking triggers the combo
2. **Directional Consistency** - Only trigger dash attack if player attacks in the same direction as the dash (changing direction cancels the combo opportunity)
3. **Damage Boost** - Apply +50% damage modifier to attacks executed during the dash attack window
4. **Defense Penalty** - Apply -25% damage reduction modifier during dash attack execution
5. **Audio Feedback** - Trigger special sound effect when dash attack combo is successfully executed

## Out of Scope

- Visual effects (beyond existing attack animations) - player will create sound effect, visual effects are optional/future consideration
- Additional cooldown system - existing dash cooldown is sufficient
- Combo chains beyond single dash-attack sequence
- Tutorial or UI indicators for the dash attack mechanic

## Expected Deliverable

1. Player can dash and immediately attack to trigger a combo with visible damage increase on enemies
2. Dash attack only triggers when attacking in the same dash direction; changing direction before attacking prevents the combo
3. Player takes increased damage from enemy hits during dash attack execution (testable by intentionally getting hit during combo)
