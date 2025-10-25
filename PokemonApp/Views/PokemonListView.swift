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
            List(viewModel.pokemonList) { pokemon in
                if let pokemonId = pokemon.pokemonId {
                    NavigationLink(destination: PokemonDetailView(pokemonId: pokemonId)) {
                        Text(pokemon.name.capitalized)
                    }
                } else {
                    Text(pokemon.name.capitalized)
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
