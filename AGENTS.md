# Repository Guidelines

## Project Structure & Module Organization
Shadow Work is maintained as a GameMaker Studio 2 project anchored by `Shadow Work.yyp`. Gameplay logic lives in `objects/` event scripts (Create_0, Step_0, Draw_0). Shared GML utilities, enums, and inventory helpers belong in `scripts/`—group new modules by system (player, inventory, grid). Room layouts and puzzle flows reside in `rooms/`, with interface overlays in `roomui/`. Art and audio assets live in `sprites/`, `tilesets/`, `sounds/`, and `fonts/`; structured payloads go in `datafiles/`. When adding resources, let the IDE update `Shadow Work.resource_order` so ordering and folder tags stay consistent.

## Build, Test & Development Commands
GameMaker IDE drives the toolchain. Use `F5` to run the game, `F6` to launch the debugger, and Build → Clean before exporting to clear stale caches. Export builds through File → Export with the target platform selected. For asset diffs, `git status` and `git diff --name-status` help confirm that binary resources were touched intentionally.

## Coding Style & Naming Conventions
Follow the existing Ruby-inspired GML conventions: functions and variables in snake_case, enums in PascalCase, enum members snake_case, and local temporaries prefixed with an underscore (e.g., `_item_def`). Keep object names descriptive (e.g., `obj_player_dash`) and mirror sprite prefixes (`spr_`), tile sets (`tls_`), sounds (`snd_`). Prefer small, focused scripts over long event blocks; add inline comments only where control flow is non-obvious.

## Testing Guidelines
There is no automated test harness—validate changes by running target rooms from the IDE. Exercise new combat behaviors, grid puzzles, and inventory flows after each change. Use the debugger (`F6`) and `show_debug_message()` for instrumentation, and keep temporary debug toggles behind a `global.debug_mode` check so they can be disabled quickly.

## Commit & Pull Request Guidelines
Match the current history: short, imperative commits (e.g., "Add plate armor"). Group related asset and code edits together and avoid bundling multiple features. Pull requests should outline gameplay impact, mention affected rooms or objects, and note any follow-up asset work. Include repro or validation steps and screenshots or GIFs when UI or VFX change.

## Asset & Configuration Tips
Place new UI layers in `roomui/` rather than the base room to preserve draw order. Keep texture groups and audio groups balanced to avoid runtime spikes. Before merging, open the project in GameMaker to ensure resource GUIDs and folders sync correctly—manual merges in `.yy` files are brittle.
