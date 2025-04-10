import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var pokemonName = "" // Correct Pokemon name
    @State private var imageUrl = "" // Pokemon image URL
    @State private var guessedLetters: [Character] = [] // Letters clicked by user
    @State private var incorrectGuesses = 0 // Incorrect guesses count
    @State private var maxAttempts = 6 // Maximum wrong guesses allowed
    @State private var gameOver = false // Game over flag
    @State private var score = 0 // Keeps track of the score
    @State private var hint = "" // Hint message
    @State private var showAlert = false // Controls alert pop-up
    @State private var alertMessage = "" // Alert message
    @State private var showPokemonInfo = false
    @State private var hintRevealedLetters: [Character] = [] // Track letters revealed by hints

    // Keyboard rows
    let rows: [[Character]] = [
        ["A", "B", "C", "D", "E", "F", "G"],
        ["H", "I", "J", "K", "L", "M", "N"],
        ["O", "P", "Q", "R", "S", "T", "U"],
        ["V", "W", "X", "Y", "Z"]
    ]

    // Shows the hidden word with "_" for unguessed letters
    var hiddenWord: String {
        return pokemonName.map { guessedLetters.contains($0.lowercased()) || hintRevealedLetters.contains($0.lowercased()) ? String($0) : "_" }.joined(separator: " ")
    }

    var body: some View {
        ZStack {
            Image("background1") // Background image
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Text("Who's That Pokémon?") // Game title
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Pokémon image with tap gesture to show info sheet
                if let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .contentShape(Rectangle()) // makes whole image tappable
                            .onTapGesture {
                                showPokemonInfo = true
                            }
                    } placeholder: {
                        ProgressView()
                    }
                    .padding()
                }


                Text(hiddenWord)
                    .font(.largeTitle)
                    .padding()

                // Incorrect guesses label
                Text("Incorrect guesses: \(incorrectGuesses)/\(maxAttempts)")
                    .font(.title2)
                    .foregroundColor(incorrectGuesses < maxAttempts ? .blue : .red)
                    .padding()

                // Hint display
                if !hint.isEmpty {
                    Text("Hint: \(hint)")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                
                // Score display
                Text("Score: \(score)")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()

                // On-screen keyboard
                VStack(spacing: 10) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { letter in
                                Button(action: {
                                    guessLetter(letter)
                                }) {
                                    Text(String(letter))
                                        .font(.title2)
                                        .frame(width: 40, height: 40) // Adjust button size
                                        .foregroundColor(.black)
                                }
                                .disabled(guessedLetters.contains(Character(letter.lowercased())) || hintRevealedLetters.contains(Character(letter.lowercased())))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            startNewGame()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(gameOver && incorrectGuesses < maxAttempts ? "Congratulations!" : "Game Over!"),
                message: Text(alertMessage),
                primaryButton: .cancel(Text("Exit"), action: {
                    dismiss()
                }),
                secondaryButton: .default(Text("Play Again"), action: {
                    startNewGame()
                })
            )
        }
        // Pokémon Info Sheet (when image tapped)
        .sheet(isPresented: $showPokemonInfo) {
            VStack(spacing: 20) {
                Text(pokemonName)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                } placeholder: {
                    ProgressView()
                }

                Text("This Pokémon appears in Gen 1.")
                    .font(.headline)

                Button("Close") {
                    showPokemonInfo = false
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }

    }

    // MARK: - Game Logic

    func startNewGame() {
        incorrectGuesses = 0
        guessedLetters = []
        hintRevealedLetters = []
        gameOver = false
        hint = ""
        showAlert = false
        fetchPokemon()
    }


    func fetchPokemon() {
        let randomId = Int.random(in: 1...151) // Gen 1 Pokémon
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(randomId)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(Pokemon.self, from: data)
                    DispatchQueue.main.async {
                        pokemonName = decodedData.name.capitalized
                        imageUrl = decodedData.sprites.front_default ?? ""
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("Network error: \(error)")
            }
        }.resume()
    }

    func guessLetter(_ letter: Character) {
        guard !gameOver else { return }

        let lowerLetter = Character(letter.lowercased())

        // Add letter to guessed list
        if !guessedLetters.contains(lowerLetter) {
            guessedLetters.append(lowerLetter)
        }

        if !pokemonName.lowercased().contains(lowerLetter) {
            incorrectGuesses += 1
        }

        checkHint()
        checkGameOver()
    }




    func checkGameOver() {
        let lowercasePokemonName = pokemonName.lowercased()
        
        // Check if all letters of the Pokémon name are guessed
        let allLettersGuessed = lowercasePokemonName.allSatisfy {
            guessedLetters.contains($0) || hintRevealedLetters.contains($0) || $0 == " " || $0 == "-"
        }

        if allLettersGuessed {
            gameOver = true
            guessedLetters = Array(lowercasePokemonName)
            score += 1 // More correct guesses = higher score
            alertMessage = "Congratulations! You got it! The Pokémon was \(pokemonName).\nScore: \(score). Want to play again?"
            showAlert = true
        }

        if incorrectGuesses >= maxAttempts {
            gameOver = true
            guessedLetters = Array(lowercasePokemonName) //Auto-fill all letters!
            score -= 1
            alertMessage = "Nice try! The Pokémon was \(pokemonName).\nScore: \(score). Want to play again?"
            showAlert = true
        }
    }


    
    func checkHint() {
        // Show hint after specific number of incorrect attempts
        if incorrectGuesses == 3 || incorrectGuesses == 4 || incorrectGuesses == 5 {
            revealRandomLetter()
        }
    }

    func revealRandomLetter() {
        let lowercasePokemonName = pokemonName.lowercased()
        let hiddenLetters = lowercasePokemonName.filter { !guessedLetters.contains($0) && !hintRevealedLetters.contains($0) }

        if let randomLetter = hiddenLetters.randomElement() {
            hintRevealedLetters.append(randomLetter) // Store as hint-revealed letter
            hint = "Revealed letter: \(randomLetter.uppercased())"
        }
    }
}


struct Pokemon: Codable {
    let name: String
    let sprites: Sprites
}

struct Sprites: Codable {
    let front_default: String?
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
