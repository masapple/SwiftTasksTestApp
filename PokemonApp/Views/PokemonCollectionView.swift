//
//  PokemonCollectionView.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI

struct PokemonCollectionView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Collection View")
                    .font(.title)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Collection")
        }
    }
}

#Preview {
    PokemonCollectionView()
}
