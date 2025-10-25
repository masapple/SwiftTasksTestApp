# PokemonApp

PokéAPIからポケモンのデータを取得して一覧表示するiOSアプリです。

## 機能

- ポケモン一覧の表示（名前、タイプ、ステータス）
- ポケモン詳細画面（画像カルーセル、能力値、技など）
- 非同期データ取得（Swift Concurrency）

## 技術スタック

- **Swift 5.0**
- **SwiftUI**
- **iOS 26.0+**
- **Swift Concurrency** (async/await)
- **Observation Framework** (状態管理)
- **PokemonAPI** (v7.0.3) - Swift Package Manager

## アーキテクチャ

### 主要コンポーネント

- **ContentView**: ポケモン一覧画面
- **PokemonListViewModel**: データ取得と状態管理
- **PokemonDetailView**: ポケモン詳細画面

### 状態管理

Observationフレームワークを使用:
- ViewModelは `@Observable` プロトコルに準拠
- Viewでは `@State` でViewModelを保持

## ビルドと実行

### ビルド

```bash
xcodebuild -project PokemonApp.xcodeproj -scheme PokemonApp -configuration Debug build
```

### Xcodeで開く

```bash
open PokemonApp.xcodeproj
```

### パッケージ解決

```bash
xcodebuild -resolvePackageDependencies -project PokemonApp.xcodeproj
```

## プロジェクト構成

```
PokemonApp/
├── StarWarsAppApp.swift    # アプリエントリーポイント
├── ContentView.swift        # メインビュー
├── PokemonListViewModel.swift # ViewModel
└── Assets.xcassets/         # アセット
```

## API

[PokéAPI](https://pokeapi.co/) を使用してポケモンデータを取得しています。

## ライセンス

このプロジェクトは個人学習用です。
