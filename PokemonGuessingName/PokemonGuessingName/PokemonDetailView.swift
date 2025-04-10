import SwiftUI

struct PokemonDetailView: View {
    let pokemon: PokemonEntry

    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: pokemon.imageUrl)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } placeholder: {
                ProgressView()
            }

            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()
        }
        .padding()
        .navigationTitle(pokemon.name.capitalized)
    }
}


