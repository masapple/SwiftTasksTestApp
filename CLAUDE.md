# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PokemonApp is a SwiftUI iOS application that displays a list of Pokémon fetched from the PokéAPI. The app demonstrates modern Swift concurrency patterns with async/await and uses the Observation framework for reactive state management.

**Note:** Despite the directory name `SwiftTasksTestApp` and file references to `StarWarsApp`, this is a Pokemon-themed application. The project appears to have been migrated from a Star Wars app to a Pokemon app.

## Build and Run Commands

### Building the Project
```bash
# Build the project
xcodebuild -project PokemonApp.xcodeproj -scheme PokemonApp -configuration Debug build

# Build for release
xcodebuild -project PokemonApp.xcodeproj -scheme PokemonApp -configuration Release build

# Clean build folder
xcodebuild -project PokemonApp.xcodeproj -scheme PokemonApp clean
```

### Running in Simulator
```bash
# Open in Xcode (recommended for development)
open PokemonApp.xcodeproj
```

### Package Management
The project uses Swift Package Manager (SPM) with the following dependency:
- **PokemonAPI** (v7.0.3): https://github.com/kinkofer/PokemonAPI

To resolve packages:
```bash
xcodebuild -resolvePackageDependencies -project PokemonApp.xcodeproj
```

## Architecture

### State Management
- Uses Swift's **Observation framework** (not ObservableObject/Combine)
- ViewModels conform to `@Observable` protocol as reference types (classes)
- Views use `@State` for property wrapper instead of `@StateObject` or `@ObservedObject`

### Key Components

**PokemonListViewModel** (`PokemonApp/PokemonListViewModel.swift`)
- Manages fetching and storing Pokemon data
- Uses async/await for network operations
- Extracts Pokemon IDs from API URLs and fetches detailed information for each Pokemon
- Sorts Pokemon by ID before displaying

**ContentView** (`PokemonApp/ContentView.swift`)
- Main list view displaying Pokemon with images, types, and stats
- Contains all view components including:
  - `PokemonSummary`: Model object that transforms `PKMPokemon` API responses into view-friendly data
  - `TypeBadgeView`: Displays Pokemon type badges with color-coded backgrounds
  - `StatBadgeView`: Shows individual stat values in compact format
  - `PokemonDetailView`: Detail screen with image carousel, stats, abilities, and moves

### Data Flow
1. `ContentView` creates a `@State` property for `PokemonListViewModel`
2. On view appear, triggers async `loadPokemonList()` in a `Task`
3. ViewModel fetches Pokemon list from API, then fetches individual details
4. `PokemonSummary` transforms API models (`PKMPokemon`) into display models
5. View automatically updates when `pokemonList` changes (Observation framework)

### Swift Concurrency
- All API calls use async/await
- Network operations happen in `Task` blocks
- No completion handlers or Combine publishers

## Project Configuration

- **iOS Deployment Target:** iOS 26.0
- **Swift Version:** 5.0
- **Development Team ID:** 9Q846N5J34
- **Bundle Identifier:** com.miyagawa.local.asynctest.PokemonApp
- **Swift Concurrency Settings:**
  - `SWIFT_APPROACHABLE_CONCURRENCY = YES`
  - `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`

## Known Issues & Notes

1. **Naming Inconsistency:** The app entry point is still named `StarWarsAppApp.swift` but should likely be renamed to match the Pokemon theme
2. **No Tests:** The project currently has no test target
3. **Error Handling:** Network errors are caught and printed to console but not displayed to users
4. **Sprite Loading:** The app loads multiple sprite images (front, back, shiny variants) which may impact performance with many Pokemon
