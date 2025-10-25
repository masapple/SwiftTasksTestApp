//
//  ContentView.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PokemonListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }

            PokemonCollectionView()
                .tabItem {
                    Label("Collection", systemImage: "square.grid.2x2")
                }
        }
    }
}

#Preview {
    ContentView()
}
