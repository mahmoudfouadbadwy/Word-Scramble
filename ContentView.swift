//
//  ContentView.swift
//  Word Scramble
//
//  Created by Mahmoud Fouad on 6/11/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var allWords = [String]()
    @State private var usedWords = [String]()
    @State private var originalWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    var body: some View {
        
        NavigationView {
            VStack {
            
                Text("Make words out of")
                    .font(.title)
                    .padding(.top, 20)
                
                Text(originalWord)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(.top, 5)
                
                TextField("Enter your word here ", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle("Word Scramble")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: refreshGame) {
                Text("New Game")
            })
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else {
            return
        }
        
        guard isNotUsed() else {
            showError(with: "Word used already", message: "Be more original")
            return
        }
        
        
        guard isPossible(word: answer) else {
            showError(with: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else  {
            showError(with: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    private func startGame() {
        if let wordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            
            if let words =  try? String(contentsOf: wordsURL) {
                allWords = words.components(separatedBy: "\n")
                originalWord = allWords.randomElement() ?? "mahmoudf"
            }
        } else {
            fatalError("Cant find the file ...")
        }
    }
    
    private func isNotUsed() -> Bool {
        !usedWords.contains(newWord)
    }
    
    private func isPossible(word: String) -> Bool {
        var tempWord = originalWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    private func showError(with title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError.toggle()
    }
    
    private func refreshGame() {
        usedWords.removeAll()
        originalWord = allWords.randomElement() ?? "mahmoudf"
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
