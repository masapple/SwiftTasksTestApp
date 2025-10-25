//
//  PokemonCollectionView.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI

struct PokemonCollectionView: View {
    @State private var viewModel = PokemonCollectionViewModel()

    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: PokemonImageThumbnail.maxThumbnailSize))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.pokemonList) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemonId: pokemon.id)) {
                            VStack {
                                PokemonThumbnailView(imageURL: pokemon.sprites.preferredImage)
//                                Text(pokemon.name.capitalized)
//                                    .font(.caption)
//                                    .lineLimit(1)
                            }
                        }
                        .onAppear {
                            if pokemon.id == viewModel.pokemonList.last?.id {
                                Task {
                                    await viewModel.loadMorePokemon()
                                }
                            }
                        }
                    }

                    if viewModel.isLoadingMore {
                        ProgressView()
                            .gridCellColumns(columns.count)
                    }
                }
                .padding()
            }
            .navigationTitle("Collection")
            .onAppear {
                if viewModel.pokemonList.isEmpty {
                    Task {
                        await viewModel.loadPokemonList()
                    }
                }
            }
        }
    }
}

#Preview {
    PokemonCollectionView()
}
