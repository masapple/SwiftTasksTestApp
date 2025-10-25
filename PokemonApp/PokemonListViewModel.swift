import Foundation
import PokemonAPI
import Observation

@Observable
class PokemonListViewModel {
    var pokemonList: [PokemonSummary] = []
    private let pokemonAPI = PokemonAPI()

    func loadPokemonList() async {
        do {
            let list = try await pokemonAPI.pokemonService.fetchPokemonList()
            guard let results = list.results else { return }
            var summaries: [PokemonSummary] = []
            for entry in results {
                if let urlString = entry.url, let id = PokemonListViewModel.extractID(from: urlString) {
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

    private static func extractID(from urlString: String) -> Int? {
        let parts = urlString.split(separator: "/")
        if let last = parts.last, let id = Int(last) {
            return id
        } else if parts.count >= 2, let id = Int(parts[parts.count - 2]) {
            return id
        }
        return nil
    }
}

