//
//  PokemonDetailView.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemonId: Int
    @State private var viewModel = PokemonDetailViewModel()

    private var spriteURLs: [URL] {
        guard let pokemon = viewModel.pokemon else { return [] }
        var urls: [URL] = []
        if let front = pokemon.sprites.frontDefault { urls.append(front) }
        if let back = pokemon.sprites.backDefault { urls.append(back) }
        if let frontShiny = pokemon.sprites.frontShiny { urls.append(frontShiny) }
        if let backShiny = pokemon.sprites.backShiny { urls.append(backShiny) }
        urls.append(contentsOf: pokemon.sprites.otherImages)
        return urls // unique urls only
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let pokemon = viewModel.pokemon {
                detailContent(for: pokemon)
            } else {
                Text("Failed to load Pokemon")
            }
        }
        .onAppear {
            Task {
                await viewModel.loadPokemonDetail(id: pokemonId)
            }
        }
    }

    @ViewBuilder
    private func detailContent(for pokemon: PokemonSummary) -> some View {
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
