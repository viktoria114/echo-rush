# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6.2
- **Language**: GDScript
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

## Input & Platform

<!-- Written by /setup-engine. Read by /ux-design, /ux-review, /test-setup, /team-ui, and /dev-story -->
<!-- to scope interaction specs, test helpers, and implementation to the correct input methods. -->

- **Target Platforms**: PC (Windows, Linux)
- **Input Methods**: Keyboard/Mouse
- **Primary Input**: Keyboard/Mouse
- **Gamepad Support**: Partial
- **Touch Support**: None
- **Platform Notes**: WASD movement, Z or left click for attack. Fixed resolution via config.SCREEN_WIDTH / config.SCREEN_HEIGHT. All UI must be navigable with mouse.

## Naming Conventions

- **Classes**: PascalCase (e.g., `PlayerController`)
- **Variables/Functions**: snake_case (e.g., `move_speed`, `take_damage()`)
- **Signals/Events**: snake_case past tense (e.g., `health_changed`, `wave_completed`)
- **Files**: snake_case matching class (e.g., `player_controller.gd`)
- **Scenes/Prefabs**: PascalCase matching root node (e.g., `PlayerController.tscn`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`)

## Performance Budgets

- **Target Framerate**: 60fps
- **Frame Budget**: 16.6ms
- **Draw Calls**: ~200 (2D game, Godot CanvasItem batching)
- **Memory Ceiling**: 512MB

## Testing

- **Framework**: GUT (Godot Unit Test) — https://github.com/bitwes/Gut
- **Minimum Coverage**: Core systems (WaveManager, KeywordSystem, EchoAPI parsing)
- **Required Tests**: Keyword regex parsing, wave progression logic, stat calculations from config.gd

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- C# — project is GDScript only
- Hardcoded numeric stats — all values via config.gd
- Direct node references — use signals only for inter-node communication

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here -->
- GUT (Godot Unit Test) — unit testing framework

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /architecture-decision to create one]

## Engine Specialists

<!-- Written by /setup-engine when engine is configured. -->
<!-- Read by /code-review, /architecture-decision, /architecture-review, and team skills -->
<!-- to know which specialist to spawn for engine-specific validation. -->

- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist (all .gd files)
- **Shader Specialist**: godot-shader-specialist (.gdshader files, VisualShader resources)
- **UI Specialist**: godot-specialist (no dedicated UI specialist — primary covers all UI)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for architecture decisions, ADR validation, and cross-cutting code review. Invoke GDScript specialist for code quality, signal architecture, static typing enforcement, and GDScript idioms. Invoke shader specialist for material design and shader code. Invoke GDExtension specialist only when native extensions are involved.

### File Extension Routing

<!-- Skills use this table to select the right specialist per file type. -->

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.gd files) | godot-gdscript-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |
