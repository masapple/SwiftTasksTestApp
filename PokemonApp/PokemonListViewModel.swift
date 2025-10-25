import Foundation
import PokemonAPI
import Observation

struct SimplePokemon: Identifiable {
    let id: String
    let name: String
    let url: String

    var pokemonId: Int? {
        let parts = url.split(separator: "/")
        if let last = parts.last, let id = Int(last) {
            return id
        } else if parts.count >= 2, let id = Int(parts[parts.count - 2]) {
            return id
        }
        return nil
    }
}

@Observable
class PokemonListViewModel {
    var pokemonList: [SimplePokemon] = []
    private let pokemonAPI = PokemonAPI()

    func loadPokemonList() async {
        do {
            let list = try await pokemonAPI.pokemonService.fetchPokemonList()
            guard let results = list.results else { return }

            pokemonList = results.compactMap { entry in
                guard let name = entry.name, let url = entry.url else { return nil }
                return SimplePokemon(id: url, name: name, url: url)
            }
        } catch {
            print("Failed to load pokemons", error)
        }
    }
}

