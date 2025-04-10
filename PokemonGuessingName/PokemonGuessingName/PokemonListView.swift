import SwiftUI

struct PokemonListView: View {
    @StateObject var fetcher = PokemonFetcher()

    var filteredList: [PokemonEntry] {
        if fetcher.searchText.isEmpty {
            return fetcher.pokemonList
        } else {
            return fetcher.pokemonList.filter { $0.name.contains(fetcher.searchText.lowercased()) }
        }
    }

    var body: some View {
            List(filteredList) { pokemon in
                NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                    HStack {
                        AsyncImage(url: URL(string: pokemon.imageUrl)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 90, height: 90)
                        
                        Text(pokemon.name.capitalized)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Pokémon List")
            .searchable(text: $fetcher.searchText)
            .onAppear {
                fetcher.fetchPokemon()
            }
        
    }

}
struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView()
    }
}

