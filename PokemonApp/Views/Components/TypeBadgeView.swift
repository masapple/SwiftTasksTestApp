//
//  TypeBadgeView.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI

struct TypeBadgeView: View {
    let typeName: String

    var body: some View {
        Text(typeName.capitalized)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color(for: typeName))
            .foregroundColor(.white)
            .cornerRadius(10)
    }

    private func color(for type: String) -> Color {
        switch type.lowercased() {
        case "normal": return Color.gray
        case "fire": return Color.red
        case "water": return Color.blue
        case "electric": return Color.yellow
        case "grass": return Color.green
        case "ice": return Color.cyan
        case "fighting": return Color.orange
        case "poison": return Color.purple
        case "ground": return Color.brown
        case "flying": return Color.indigo
        case "psychic": return Color.pink
        case "bug": return Color.green.opacity(0.7)
        case "rock": return Color.gray.opacity(0.7)
        case "ghost": return Color.purple.opacity(0.7)
        case "dragon": return Color(red: 0.4, green: 0, blue: 0.8)
        case "dark": return Color.black
        case "steel": return Color.gray.opacity(0.5)
        case "fairy": return Color.pink.opacity(0.7)
        default: return Color.secondary
        }
    }
}
