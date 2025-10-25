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
            pokemonList = results.compactMap { entry in
                guard let name = entry.name, let url = entry.url else { return nil }
                return SimplePokemon(id: url, name: name, url: url)
            }
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
            let newPokemon = results.compactMap { entry -> SimplePokemon? in
                guard let name = entry.name, let url = entry.url else { return nil }
                return SimplePokemon(id: url, name: name, url: url)
            }
            pokemonList.append(contentsOf: newPokemon)
        } catch {
            print("Failed to load more pokemons", error)
        }
    }
}

