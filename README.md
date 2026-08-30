# Pokémon Red and Blue [![Build Status][ci-badge]][ci]

A faithful, save-compatible expansion of Pokémon Red, built directly in the
original Gen I engine.

## What this is

This repository is a fan-made fork of
[pret/pokered](https://github.com/pret/pokered), a source-code disassembly of
Pokémon Red and Blue. It reconstructs the Game Boy games as editable
[RGBDS](https://rgbds.gbdev.io/) assembly: maps, dialogue, encounters, battle
logic, graphics, audio, and saved data all live in this repository and assemble
into playable ROMs.

The fork extends the reconstructed Game Boy engine directly at source level.
Pokémon Red is the primary design target; the Blue and Blue debug builds
exercise the shared engine and catch regressions.

The result aims to feel like a surprisingly expansive version of the cartridge
you remember.

## What changes in the game

### Mysteries and discoveries

Kanto now rewards curiosity with new optional encounters, hidden scenes,
restored unused ideas, and answers to a few old playground rumours. Familiar
places can reveal something unexpected when revisited with the right Pokémon,
item, or piece of knowledge.

### A world that reacts

Characters remember what happened, notice particular lead Pokémon, recognise
old partners, and respond to the player's progress. Small moments connect
people, places, fossils, legends, and later discoveries with a light touch.

### A fuller adventure

All 151 Pokémon can be obtained through solo play on one cartridge. Wild areas
have stronger identities and occasional rare finds, while Gym Leaders, rivals,
the Elite Four, and other important opponents use fuller, purpose-built teams
and movesets. Additional challenges enrich the middle and end of the original
journey.

### Red+ conveniences

A restrained quality-of-life layer adds faster movement, reusable TMs,
contextual HM use, move remembering and forgetting, automatic PC-box rollover,
clearer battle feedback, fast text, improved weak moves, and selected Gen I bug
fixes. These changes remove friction while preserving the game's limitations,
rhythm, and personality.

This overview keeps discoveries broad and spoiler-light. Readers who want every
addition can consult the [complete feature catalogue](FEATURES.md).

## Design philosophy

The original story, maps, progression, presentation, and strange compact charm
remain the foundation. New content should look, sound, and behave like something
that might always have been hidden inside the cartridge.

Subtle clues should make secrets discoverable. Familiar characters should
remain recognisable even when their battles become more interesting.
Conveniences should reduce needless repetition while retaining the oddities
that make Gen I memorable.

## Save compatibility

The project is designed for round-trip compatibility with an unmodified
Pokémon Red save. It preserves the original save layout, Pokémon structures,
and established identifiers, reusing reserved space for new persistent state.

Added maps temporarily suspend saving to keep stock-save transfers safe. Return
to an original location before moving a save back to a stock cartridge or ROM,
and always keep a backup of the `.sav` file when transferring between builds.

Every full build runs an automated save-ABI check. It can also be invoked
directly:

```bash
make check-save-compat
```

## Building

Install the required tools, including RGBDS 1.0.3, by following
[INSTALL.md](INSTALL.md). Then clone this fork and build it:

```bash
git clone https://github.com/wiigg/pokered.git
cd pokered
make
```

`make` builds `pokered.gbc`, `pokeblue.gbc`, and `pokeblue_debug.gbc`, and
checks the protected save layout. To build only the primary Red ROM:

```bash
make red
```

Compiled ROMs remain local build outputs under the repository's ignore rules.

## Repository guide

- `scripts/` contains map events, NPC behaviour, battles, and scene logic.
- `text/` contains map dialogue and story text.
- `data/` contains tables for Pokémon, moves, trainers, encounters, maps, and
  other game content.
- `engine/` contains shared battle, overworld, menu, item, and Pokémon systems.
- `gfx/` contains the source graphics assembled into the ROM.
- `ram/` defines the original Game Boy memory and saved-data layout.
- The root assembly files compose those pieces into the final ROM banks.

## Upstream

This project is made possible by the reverse-engineering work in
[pret/pokered](https://github.com/pret/pokered) and by the
[RGBDS](https://rgbds.gbdev.io/) Game Boy development toolchain.

[ci]: https://github.com/wiigg/pokered/actions
[ci-badge]: https://github.com/wiigg/pokered/actions/workflows/main.yml/badge.svg
