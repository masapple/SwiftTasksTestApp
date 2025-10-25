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
        GridItem(.adaptive(minimum: 100))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.pokemonList) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemonId: pokemon.id)) {
                            VStack {
                                AsyncImage(url: pokemon.sprites.frontDefault) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    case .failure:
                                        Image(systemName: "questionmark.square.dashed")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                Text(pokemon.name.capitalized)
                                    .font(.caption)
                                    .lineLimit(1)
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
