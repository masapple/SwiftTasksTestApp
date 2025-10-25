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
            List {
                ForEach(viewModel.pokemonList) { pokemon in
                    if let pokemonId = pokemon.pokemonId {
                        NavigationLink(destination: PokemonDetailView(pokemonId: pokemonId)) {
                            Text(pokemon.name.capitalized)
                        }
                        .onAppear {
                            if pokemon.id == viewModel.pokemonList.last?.id {
                                Task {
                                    await viewModel.loadMorePokemon()
                                }
                            }
                        }
                    } else {
                        Text(pokemon.name.capitalized)
                    }
                }

                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
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
