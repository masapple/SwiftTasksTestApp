//
//  StatBadgeView.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI

struct StatBadgeView: View {
    let statName: String
    let value: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(statName.prefix(3).uppercased())
                .font(.caption2)
                .bold()
            Text("\(value)")
                .font(.caption2)
        }
        .padding(4)
        .background(Color.secondary.opacity(0.15))
        .cornerRadius(6)
    }
}
