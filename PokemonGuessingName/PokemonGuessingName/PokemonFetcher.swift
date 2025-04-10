import Foundation
import Combine

struct PokemonEntry: Identifiable, Decodable {
    let id: Int
    let name: String
    
    var imageUrl: String {
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
    }
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let urlString = try container.decode(String.self, forKey: .url)
        if let idString = urlString.split(separator: "/").last,
           let parsedId = Int(idString) {
            id = parsedId
        } else {
            id = 0
        }
    }
}

class PokemonFetcher: ObservableObject {
    @Published var pokemonList: [PokemonEntry] = []
    @Published var searchText: String = ""

    func fetchPokemon() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(PokemonAPIResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.pokemonList = decoded.results.shuffled()
                    }
                }
            }
        }.resume()
    }
}

struct PokemonAPIResponse: Decodable {
    let results: [PokemonEntry]
}
