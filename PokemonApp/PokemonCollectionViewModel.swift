//
//  PokemonCollectionViewModel.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import Foundation
import PokemonAPI
import Observation

@Observable
class PokemonCollectionViewModel {
    var pokemonList: [PokemonSummary] = []
    var isLoadingMore = false
    private var currentPage: PKMPagedObject<PKMPokemon>?
    private let pokemonAPI = PokemonAPI()

    var hasMorePages: Bool {
        guard let currentPage, let currentPageMaxCount = currentPage.count else { return false }
        return pokemonList.count < currentPageMaxCount
    }

    func loadPokemonList() async {
        do {
            let paginationState = PaginationState<PKMPokemon>.initial(pageLimit: 20)
            let pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(paginationState: paginationState)

            currentPage = pagedObject

            guard let results = pagedObject.results else { return }
            var summaries: [PokemonSummary] = []

            for entry in results {
                if let urlString = entry.url, let id = extractID(from: urlString) {
                    if let detail = try? await pokemonAPI.pokemonService.fetchPokemon(id) {
                        let summary = PokemonSummary(from: detail)
                        summaries.append(summary)
                    }
                }
            }

            pokemonList = summaries.sorted { $0.id < $1.id }
        } catch {
            print("Failed to load pokemons", error)
        }
    }

    func loadMorePokemon() async {
        guard let currentPage = currentPage, hasMorePages, !isLoadingMore else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let paginationState = PaginationState<PKMPokemon>.continuing(currentPage, .next)
            let pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(paginationState: paginationState)

            self.currentPage = pagedObject

            guard let results = pagedObject.results else { return }
            var summaries: [PokemonSummary] = []

            for entry in results {
                if let urlString = entry.url, let id = extractID(from: urlString) {
                    if let detail = try? await pokemonAPI.pokemonService.fetchPokemon(id) {
                        let summary = PokemonSummary(from: detail)
                        summaries.append(summary)
                    }
                }
            }

            pokemonList.append(contentsOf: summaries.sorted { $0.id < $1.id })
        } catch {
            print("Failed to load more pokemons", error)
        }
    }

    private func extractID(from urlString: String) -> Int? {
        let parts = urlString.split(separator: "/")
        if let last = parts.last, let id = Int(last) {
            return id
        } else if parts.count >= 2, let id = Int(parts[parts.count - 2]) {
            return id
        }
        return nil
    }
}
