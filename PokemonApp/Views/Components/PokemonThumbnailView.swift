//
//  PokemonThumbnailView.swift
//  PokemonApp
//
//  Created by Masataka Miyagawa on 2025/10/25.
//

import SwiftUI

struct PokemonImageThumbnail: Identifiable {
    let imageURL: URL?
    static let maxThumbnailSize: CGFloat = 50

    var id: String {
        imageURL?.absoluteString ?? ""
    }

    func makeThumbnail(displayScale: CGFloat) async -> UIImage? {
        guard let imageURL = imageURL else { return nil }

        // URLから画像データをダウンロード
        guard let (data, _) = try? await URLSession.shared.data(from: imageURL),
              let image = UIImage(data: data) else {
            return nil
        }

        // 画像のリサイズ
        return await resizeImage(
            for: image,
            with: image.size,
            maxThumbnailSize: Self.maxThumbnailSize,
            displayScale: displayScale
        )
    }
    
    @concurrent
    private func resizeImage(for image: UIImage, with originalSize: CGSize, maxThumbnailSize: CGFloat, displayScale: CGFloat) async -> UIImage? {
        // サムネイルサイズを計算して生成
        let maxDimension = max(originalSize.width, originalSize.height)
        let shrinkFactor = maxThumbnailSize / maxDimension
        let newSize = CGSize(
            width: originalSize.width * shrinkFactor * displayScale,
            height: originalSize.height * shrinkFactor * displayScale
        )
        return image.preparingThumbnail(of: newSize)
    }
}

struct PokemonThumbnailView: View {
    @Environment(\.displayScale) private var displayScale: CGFloat
    let imageURL: URL?
    @State private var loadedThumbnail: Image?
    @State private var loadingFailed = false

    var body: some View {
        content
            .task(id: displayScale) {
                let thumbnail = PokemonImageThumbnail(imageURL: imageURL)
                guard let uiImage = await thumbnail.makeThumbnail(displayScale: displayScale) else {
                    loadedThumbnail = nil
                    loadingFailed = true
                    return
                }
                loadedThumbnail = Image(uiImage: uiImage)
                loadingFailed = false
            }
    }

    @MainActor
    @ViewBuilder
    var content: some View {
        if let loadedThumbnail {
            loadedThumbnail
                .resizable()
                .scaledToFit()
                .frame(width: PokemonImageThumbnail.maxThumbnailSize, height: PokemonImageThumbnail.maxThumbnailSize)
        } else if loadingFailed {
            Image(systemName: "questionmark.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(width: PokemonImageThumbnail.maxThumbnailSize, height: PokemonImageThumbnail.maxThumbnailSize)
                .foregroundColor(.gray)
        } else {
            ProgressView()
                .frame(width: PokemonImageThumbnail.maxThumbnailSize, height: PokemonImageThumbnail.maxThumbnailSize)
        }
    }
}

#Preview {
    PokemonThumbnailView(imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"))
}
