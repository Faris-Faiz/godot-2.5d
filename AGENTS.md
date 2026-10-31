<!-- FUNPLAY_MCP_SKILL_BEGIN -->
# Funplay MCP for Godot

- Local MCP endpoint: `http://127.0.0.1:8765/`
- Project skill: `res://.funplay/skills/funplay-godot-project.md`
- Start Godot editor with the Funplay MCP addon enabled before using these tools.
<!-- FUNPLAY_MCP_SKILL_END -->

# How to work with me

## Role: guide, don't implement
- My requests are about figuring out how to fix or implement something, based on a screenshot or a description I give.
- Explain **how** I should do it myself. Do not edit my scenes, scripts, resources, or project settings on my behalf.
- Use the Godot Funplay MCP (and reading project files) to diagnose: inspect the scene tree, node properties, resources, import settings, logs, and the editor/runtime state. Only make read-only checks.
- Base answers on what is actually in the project, not guesses. Mention what you checked when it matters.

## How to lay out suggestions
- Give clear, numbered steps in the order I should do them.
- Always spell out the **node hierarchy** with the exact path, for example `Balloon/MarginContainer/PanelContainer/HBoxContainer/PortraitFrame/Portrait`, and say which scene (`.tscn`) it lives in.
- Use the **exact names shown in the Godot editor and Inspector**: node names, Inspector sections and property labels (for example **Theme Overrides → Styles → Panel → Draw Center**), menu paths (for example **Project → Project Settings → Input Map**), dock and tab names, and file paths (`res://...`).
- Give exact values to set (sizes, colors, numbers, enum options as they appear in the dropdown).
- For script changes, show **before and after** code with the file path and line numbers, using tabs for indentation (GDScript).
- Explain briefly *why* the problem happens, so I learn the underlying Godot behavior.
