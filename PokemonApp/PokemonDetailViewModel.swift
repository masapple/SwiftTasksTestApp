//
//  PokemonDetailViewModel.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import Foundation
import PokemonAPI
import Observation

@Observable
class PokemonDetailViewModel {
    var pokemon: PokemonSummary?
    var isLoading = false
    private let pokemonAPI = PokemonAPI()

    func loadPokemonDetail(id: Int) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let detail = try? await pokemonAPI.pokemonService.fetchPokemon(id) {
                pokemon = PokemonSummary(from: detail)
            }
        }
    }
}
