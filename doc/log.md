# Registro de cambios

## 2024-05-24
* Initial project setup using Flutter.
* Added `GameProvider` for state management.
* Implemented `Carta`, `Jugador`, `Partida`, `Usuario` models.
* Created `GameLogic` for deck generation and shuffling.
* Added Neo-Brutalist `AppTheme`.
* Implemented `HomeScreen`, `GameListScreen`, and `GameScreen` skeletons.
* Implemented `CartaWidget` with support for 'Clasico' and 'Moderno' (simplified) themes.
* Added basic drag-and-drop mechanics in `GameScreen`.
* Created initial `Carta2.svg` asset.
* Added system dependencies (`cmake`, `clang`, `ninja`, `pkg-config`, `gtk3`) to `.idx/dev.nix` to support Linux builds.
* Fixed compilation error: Added missing `cartasDescartadas` getter and state to `GameProvider`.
