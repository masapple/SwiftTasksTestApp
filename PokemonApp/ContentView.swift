//
//  ContentView.swift
//  StarWarsApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI
import PokemonAPI
import Observation

struct ContentView: View {
    @State private var viewModel = PokemonListViewModel()
    // Note: Define PokemonListViewModel in a separate file using the Observation framework,
    // conforming to the 'Observable' protocol (value type), replacing ObservableObject.

    var body: some View {
        NavigationView {
            List(viewModel.pokemonList, id: \.id) { pokemon in
                NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                    HStack(alignment: .center, spacing: 12) {
                        AsyncImage(url: pokemon.sprites.frontDefault) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            case .failure:
                                Image(systemName: "questionmark.square.dashed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(pokemon.name.capitalized)
                                .font(.headline)
                            HStack(spacing: 6) {
                                ForEach(pokemon.types, id: \.self) { type in
                                    TypeBadgeView(typeName: type)
                                }
                            }
                            HStack(spacing: 6) {
                                ForEach(pokemon.stats, id: \.name) { stat in
                                    StatBadgeView(statName: stat.name, value: stat.value)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Pokémon List")
            .onAppear {
                Task {
                    await viewModel.loadPokemonList()
                }
            }
        }
    }
}

struct PokemonSummary: Identifiable {
    let id: Int
    let name: String
    let types: [String]
    let stats: [Stat]
    let height: Int
    let weight: Int
    let abilities: [String]
    let moves: [String]
    let sprites: Sprites

    struct Stat {
        let name: String
        let value: Int
    }

    struct Sprites {
        let frontDefault: URL?
        let backDefault: URL?
        let frontShiny: URL?
        let backShiny: URL?
        let otherImages: [URL] // To support more images if needed

        init(frontDefault: URL?, backDefault: URL?, frontShiny: URL?, backShiny: URL?, otherImages: [URL]) {
            self.frontDefault = frontDefault
            self.backDefault = backDefault
            self.frontShiny = frontShiny
            self.backShiny = backShiny
            self.otherImages = otherImages
        }

        init(from spriteModel: PKMPokemonSprites) {
            // PKMPokemonSprites has optional String properties, create an array of URLs for carousel
            frontDefault = spriteModel.frontDefault != nil ? URL(string: spriteModel.frontDefault!) : nil
            backDefault = spriteModel.backDefault != nil ? URL(string: spriteModel.backDefault!) : nil
            frontShiny = spriteModel.frontShiny != nil ? URL(string: spriteModel.frontShiny!) : nil
            backShiny = spriteModel.backShiny != nil ? URL(string: spriteModel.backShiny!) : nil

            var others: [URL] = []
            if let officialArtwork = spriteModel.other?.officialArtwork?.frontDefault,
               let url = URL(string: officialArtwork) {
                others.append(url)
            }
            if let dreamWorld = spriteModel.other?.dreamWorld?.frontDefault,
               let url = URL(string: dreamWorld) {
                others.append(url)
            }
            otherImages = others
        }
    }

    init(from pokemon: PKMPokemon) {
        self.id = pokemon.id ?? 0
        self.name = pokemon.name ?? ""
        self.types = pokemon.types?.map { $0.type?.name ?? "" } ?? []
        self.stats = pokemon.stats?.map { Stat(name: $0.stat?.name ?? "", value: $0.baseStat ?? 0) } ?? []
        self.height = pokemon.height ?? 0
        self.weight = pokemon.weight ?? 0
        self.abilities = pokemon.abilities?.map { $0.ability?.name ?? "" } ?? []
        self.moves = Array((pokemon.moves?.prefix(5) ?? []).map { $0.move?.name ?? "" })
        self.sprites = pokemon.sprites != nil ? Sprites(from: pokemon.sprites!) : Sprites(frontDefault: nil, backDefault: nil, frontShiny: nil, backShiny: nil, otherImages: [])
    }
}

// MARK: - Views

struct TypeBadgeView: View {
    let typeName: String

    var body: some View {
        Text(typeName.capitalized)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color(for: typeName))
            .foregroundColor(.white)
            .cornerRadius(10)
    }

    private func color(for type: String) -> Color {
        switch type.lowercased() {
        case "normal": return Color.gray
        case "fire": return Color.red
        case "water": return Color.blue
        case "electric": return Color.yellow
        case "grass": return Color.green
        case "ice": return Color.cyan
        case "fighting": return Color.orange
        case "poison": return Color.purple
        case "ground": return Color.brown
        case "flying": return Color.indigo
        case "psychic": return Color.pink
        case "bug": return Color.green.opacity(0.7)
        case "rock": return Color.gray.opacity(0.7)
        case "ghost": return Color.purple.opacity(0.7)
        case "dragon": return Color(red: 0.4, green: 0, blue: 0.8)
        case "dark": return Color.black
        case "steel": return Color.gray.opacity(0.5)
        case "fairy": return Color.pink.opacity(0.7)
        default: return Color.secondary
        }
    }
}

struct StatBadgeView: View {
    let statName: String
    let value: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(statName.prefix(3).uppercased())
                .font(.caption2)
                .bold()
            Text("\(value)")
                .font(.caption2)
        }
        .padding(4)
        .background(Color.secondary.opacity(0.15))
        .cornerRadius(6)
    }
}

struct PokemonDetailView: View {
    let pokemon: PokemonSummary

    private var spriteURLs: [URL] {
        var urls: [URL] = []
        if let front = pokemon.sprites.frontDefault { urls.append(front) }
        if let back = pokemon.sprites.backDefault { urls.append(back) }
        if let frontShiny = pokemon.sprites.frontShiny { urls.append(frontShiny) }
        if let backShiny = pokemon.sprites.backShiny { urls.append(backShiny) }
        urls.append(contentsOf: pokemon.sprites.otherImages)
        return Array(Set(urls)) // unique urls only
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TabView {
                    ForEach(spriteURLs, id: \.self) { url in
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .frame(height: 320)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))

                VStack(alignment: .leading, spacing: 12) {
                    Text(pokemon.name.capitalized)
                        .font(.largeTitle)
                        .bold()

                    HStack(spacing: 10) {
                        ForEach(pokemon.types, id: \.self) { type in
                            TypeBadgeView(typeName: type)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Abilities")
                            .font(.headline)
                        Text(pokemon.abilities.map { $0.capitalized }.joined(separator: ", "))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stats")
                            .font(.headline)
                        ForEach(pokemon.stats, id: \.name) { stat in
                            HStack {
                                Text(stat.name.capitalized)
                                    .frame(width: 100, alignment: .leading)
                                ProgressView(value: Float(stat.value), total: 255)
                                    .tint(color(for: stat.name))
                                Text("\(stat.value)")
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }
                    }

                    HStack(spacing: 24) {
                        VStack {
                            Text("Height")
                                .font(.subheadline)
                                .bold()
                            Text("\(Float(pokemon.height) / 10, specifier: "%.1f") m")
                        }
                        VStack {
                            Text("Weight")
                                .font(.subheadline)
                                .bold()
                            Text("\(Float(pokemon.weight) / 10, specifier: "%.1f") kg")
                        }
                    }
                    .padding(.vertical)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Moves Sample")
                            .font(.headline)
                        ForEach(pokemon.moves, id: \.self) { move in
                            Text("• \(move.capitalized)")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(pokemon.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func color(for stat: String) -> Color {
        switch stat.lowercased() {
        case "hp": return .red
        case "attack": return .orange
        case "defense": return .yellow
        case "special-attack": return .purple
        case "special-defense": return .blue
        case "speed": return .green
        default: return .gray
        }
    }
}

#Preview {
    ContentView()
}
