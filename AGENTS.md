# Repository Guidelines

## Project Structure & Module Organization
Shadow Work anchors on `Shadow Work.yyp`; editing resources through the GameMaker IDE keeps GUIDs consistent. Runtime object logic lives in `objects/` event scripts (`Create_0`, `Step_0`, `Draw_0`). Shared helpers belong in `scripts/` grouped by system (`scripts/player`, `scripts/inventory`, `scripts/grid`). Rooms and puzzle flows sit in `rooms/`, while UI overlays and HUD pieces reside in `roomui/`. Binary assets live in `sprites/`, `tilesets/`, `sounds/`, and `fonts/`; narrative and config payloads stay in `datafiles/` and `yarn/`. Use `docs/` for design notes and keep `Shadow Work.resource_order` IDE-managed.

## Build, Test & Development Commands
GameMaker drives execution: press `F5` for a playtest build and `F6` for the debugger. Run Build → Clean before exports to purge stale caches. `git status` and `git diff --name-status` help confirm intentional asset changes; run them before committing. Export builds via File → Export with the target platform selected.

## Coding Style & Naming Conventions
Follow the Ruby-inspired GML style already in place. Functions, variables, and enums use snake_case names; enum types stay PascalCase. Prefix temporary locals with `_`, and mirror resource prefixes (`obj_`, `spr_`, `snd_`, `tls_`). Favor compact scripts over sprawling event blocks, and only add inline comments when control flow is non-obvious.

## Testing Guidelines
There is no automated harness, so validate changes by running affected rooms through the IDE. Exercise combat loops, grid puzzles, and inventory flows after every mechanic tweak. Use `show_debug_message()` sparingly, and gate temporary instrumentation behind `global.debug_mode` so it can be disabled quickly.

## Commit & Pull Request Guidelines
Keep commits short and imperative (e.g., `Add plate armor`) and group related code, asset, and data changes together. PRs should describe gameplay impact, note impacted rooms or objects, and flag follow-up art or audio needs. Include repro steps for bug fixes and attach screenshots or GIFs whenever UI or VFX shift.

## Asset & Configuration Tips
Place supplemental UI on `roomui/` layers to protect draw order. Balance texture and audio groups to avoid runtime spikes. Before merging, open the project in GameMaker to ensure folders and `Shadow Work.resource_order` stay in sync—manual edits to `.yy` files are brittle.
