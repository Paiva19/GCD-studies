//
//  ContentView.swift
//  Grand Central Dispatch Test App
//
//  Created by Mobile2you on 25/04/22.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    let viewModel: MoviePosterViewModel = MoviePosterViewModel()
    
    @State var posterImage: UIImage = UIImage(named: "madagascar")!
    @State var counterButtonLabel = "Will run on: "
    
    private func didTapCounterButton() {
        counterButtonLabel = "Will run on: \(viewModel.switchThreadType())"
    }
    
    //    Fixes the poster showed to be the Shrek poster
        func fixPoster() {
            switch viewModel.threadType {
            case .noThread:
                fixPosterWithoutThread()
            case .mainThread:
                fixPosterUsingMain()
            case .backgroundThread:
                fixPosterUsingBackground()
            }
        }
        
    
    private let dispatchQueue = DispatchQueue(label: "DQueue")
        
    
    private func fixPosterWithoutThread() {
        changePoster(newPoster: viewModel.getOtherPoster())
    }
        private func fixPosterUsingMain() {
            DispatchQueue.main.async {
                changePoster(newPoster: viewModel.getOtherPoster())
            }
        }
        
        private func fixPosterUsingBackground() {
            dispatchQueue.async {
                changePoster(newPoster: viewModel.getOtherPoster(), delay: 10)
            }
            
            dispatchQueue.async {
                changePoster(newPoster: viewModel.getOtherPoster())
            }
        }
    
    private func changePoster(newPoster: Poster, delay: UInt32 = 3) {
        viewModel.currentPoster = newPoster
        sleep(delay)
        if let image = UIImage(named: viewModel.currentPoster.rawValue) {
            posterImage = image
        }
    }
    
    var body: some View {
        
        VStack {
            
            Button(counterButtonLabel, action: {
                didTapCounterButton()
            })
                .padding(.top, 32)
            
            Text("Shrek")
                .padding()
            
            Image(uiImage: posterImage)
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fill)
            
            Button("Corrigir Pôster", action: {
                fixPoster()
            })
                .padding(.bottom, 32)
        }
        .padding()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
