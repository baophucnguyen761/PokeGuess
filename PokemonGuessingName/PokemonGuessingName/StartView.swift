import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background1") // Background image
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    Image("PokeGuesslogo" )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 370)
                        .background(Color.clear)
                    
                    // Start game button
                    NavigationLink(destination: ContentView()) {
                        Text("Start Game")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 220, height: 55)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding()
                    
                    // Pokemon lists button
                    NavigationLink(destination: PokemonListView()) {
                        Text("Pokemon Lists")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 220, height: 55)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding()
                    
                    // Favorite Pokemon Lists button
                    NavigationLink(destination: PokemonListView()) {
                        Text("Favorite")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 220, height: 55)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Preview
struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
