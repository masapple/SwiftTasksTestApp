//
//  PokemonSummary.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import Foundation
import PokemonAPI

struct PokemonSummary: Identifiable {
    let id: Int
    let name: String
    let types: [String]
    let stats: [Stat]
    let height: Int
    let weight: Int
    let abilities: [String]
    let moves: [String]
    let sprites: Sprites

    struct Stat {
        let name: String
        let value: Int
    }

    struct Sprites {
        let frontDefault: URL?
        let backDefault: URL?
        let frontShiny: URL?
        let backShiny: URL?
        let otherImages: [URL] // To support more images if needed

        /// otherImagesがあればその最初の要素を返し、なければfrontDefaultを返す
        var preferredImage: URL? {
            otherImages.first ?? frontDefault
        }

        init(frontDefault: URL?, backDefault: URL?, frontShiny: URL?, backShiny: URL?, otherImages: [URL]) {
            self.frontDefault = frontDefault
            self.backDefault = backDefault
            self.frontShiny = frontShiny
            self.backShiny = backShiny
            self.otherImages = otherImages
        }

        init(from spriteModel: PKMPokemonSprites) {
            // PKMPokemonSprites has optional String properties, create an array of URLs for carousel
            frontDefault = spriteModel.frontDefault != nil ? URL(string: spriteModel.frontDefault!) : nil
            backDefault = spriteModel.backDefault != nil ? URL(string: spriteModel.backDefault!) : nil
            frontShiny = spriteModel.frontShiny != nil ? URL(string: spriteModel.frontShiny!) : nil
            backShiny = spriteModel.backShiny != nil ? URL(string: spriteModel.backShiny!) : nil

            var others: [URL] = []
            if let officialArtwork = spriteModel.other?.officialArtwork?.frontDefault,
               let url = URL(string: officialArtwork) {
                others.append(url)
            }
            if let dreamWorld = spriteModel.other?.dreamWorld?.frontDefault,
               let url = URL(string: dreamWorld) {
                others.append(url)
            }
            otherImages = others
        }
    }

    init(from pokemon: PKMPokemon) {
        self.id = pokemon.id ?? 0
        self.name = pokemon.name ?? ""
        self.types = pokemon.types?.map { $0.type?.name ?? "" } ?? []
        self.stats = pokemon.stats?.map { Stat(name: $0.stat?.name ?? "", value: $0.baseStat ?? 0) } ?? []
        self.height = pokemon.height ?? 0
        self.weight = pokemon.weight ?? 0
        self.abilities = pokemon.abilities?.map { $0.ability?.name ?? "" } ?? []
        self.moves = Array((pokemon.moves?.prefix(5) ?? []).map { $0.move?.name ?? "" })
        self.sprites = pokemon.sprites != nil ? Sprites(from: pokemon.sprites!) : Sprites(frontDefault: nil, backDefault: nil, frontShiny: nil, backShiny: nil, otherImages: [])
    }
}
