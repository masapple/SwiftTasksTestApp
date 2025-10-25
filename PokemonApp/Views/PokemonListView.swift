//
//  PokemonListView.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI

struct PokemonListView: View {
    @State private var viewModel = PokemonListViewModel()

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

#Preview {
    PokemonListView()
}
