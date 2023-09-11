//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Akhmed on 21.08.23.
//

import SwiftUI

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var userScore = 0
    @State private var questionCount = 0
    
    @State private var rotationAngle: Double = 0.0
    @State private var rotationAngles: [Double] = [0.0, 0.0, 0.0]
    
    @State private var isCorrectAnswerSelected = false
    @State private var isIncorrectAnswerSelected = false

    
    
    
    var rotationBindings: [Binding<Double>] {
        (0..<3).map { i in
            .constant(rotationAngles[i])
        }
    }



    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 400)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .customStyle()
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(country: countries[number], rotationAngle: rotationAngles[number])
                                .opacity((isCorrectAnswerSelected || isIncorrectAnswerSelected) && number != correctAnswer ? 0.25 : 1.0)
                                .scaleEffect(isIncorrectAnswerSelected && number != correctAnswer ? 0.8 : 1.0)
                                .rotation3DEffect(.degrees(isIncorrectAnswerSelected && number != correctAnswer ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(userScore) out of 10")
                    .foregroundColor(.white)
                    .font(.title.bold())
                
                Spacer()
                
                Button(action: restartGame) {
                    Image(systemName: "gobackward")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            if questionCount < 10 {
                Button("Continue", action: askQuestion)
            } else {
                Button("Restart", action: restartGame)
            }
        }
//    message: {
//            Text("Your final score is \(userScore) out of 8")
//        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "✅"
            userScore += 1
            isCorrectAnswerSelected = true
        } else {
            let correctFlag = countries[number]
            scoreTitle = "Wrong! \nIt's the flag of \(correctFlag)"
            isIncorrectAnswerSelected = true
        }
        
        questionCount += 1
        
        withAnimation(.interpolatingSpring(stiffness: 5, damping: 1)) {
            rotationAngles[number] += 360
        }
        
        if questionCount < 8 {
            showingScore = true
        } else {
            showingScore = true
        }
        
        // Reset the flags to their initial state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                isCorrectAnswerSelected = false
                isIncorrectAnswerSelected = false
                rotationAngles = [0.0, 0.0, 0.0]
                if questionCount < 10 {
                    askQuestion()
                } else {
                    restartGame()
                }
            }
        }
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        showingScore = false
    }
    
    func restartGame() {
        questionCount = 0
        userScore = 0
        askQuestion()
    }
}



struct FlagImage: View {
    var country: String
    var rotationAngle: Double

    var body: some View {
        Image(country)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 5)
            .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
    }
}




struct CustomStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.bold())
            .foregroundColor(.blue)
            .shadow(radius: 5)
    }
}

extension View {
    func customStyle() -> some View {
        self.modifier(CustomStyleModifier())
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
