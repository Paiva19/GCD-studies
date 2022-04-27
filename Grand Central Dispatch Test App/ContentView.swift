//
//  ContentView.swift
//  Grand Central Dispatch Test App
//
//  Created by Mobile2you on 25/04/22.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    // MARK: - Variables
    let viewModel: MoviePosterViewModel = MoviePosterViewModel()
    
    // MARK: - Layout Variables
    @State var posterImage: UIImage = UIImage(named: "madagascar")!
    @State var posterTitle: String = "madagascar"
    @State var queueTypeButtonLabel = "Will run on: \(QueueType.noQueue.rawValue)"
    
    private func didTapCounterButton() {
        queueTypeButtonLabel = "Will run on: \(viewModel.switchQueueType())"
    }
    
    // MARK: - Poster methods
    //    Fixes the poster showed to be the Shrek poster
    private func fixPoster() {
        switch viewModel.queueType {
        case .noQueue:
            changePosterWithoutQueue()
        case .main:
            changePosterUsingMain()
        case .background:
            changePosterUsingBackground()
        case .serialQueue:
            useSerialQueue()
        case .concurrentQueue:
            useConcurrentQueue()
        case .concurrentQueueBarrier:
            useConcurrentQueueWithBarrier()
        case .concurrentQueueSemaphore:
            useConcurrentQueueWithSemaphore()
        case .dispatchGroup:
            useDispatchGroup()
        case .dispatchGroupWithArray:
            useDispatchGroupWithArray()
        }
    }
    
    private func changePoster(newPoster: Poster, delay: UInt32 = 3) {
        // We write to a shared resource
        viewModel.currentPoster = newPoster
        
        posterTitle = viewModel.currentPoster.rawValue
        
        // Simulate that this block takes a while to execute...
        // Might be some calculation that takes a while, an API request...
        sleep(delay)
        
        // We read that shared resource to update our poster
        if let image = UIImage(named: viewModel.currentPoster.rawValue) {
            posterImage = image
        }
    }
    
    // MARK: - Parallelism
    // Serial Queue
    private let dispatchQueue = DispatchQueue(label: "DQueue")
    
    // Concurrent Queue
    private let concurrentQueue = DispatchQueue(label: "CQueue", attributes: .concurrent)
    
    // Dispatch Group
    private let group = DispatchGroup()

    // MARK: - With different types of queue
    // No queueing task. Using main thread
    private func changePosterWithoutQueue() {
        print("Iniciando Tarefa: \(Thread.current)")
        changePoster(newPoster: viewModel.getOtherPoster())
        print("Finalizando Tarefa: \(Thread.current)")
    }
    
    // Queueing task on main thread
    private func changePosterUsingMain() {
        print("Adicionando tarefa na fila da thread principal")
        DispatchQueue.main.async {
            print("Iniciando tarefa: \(Thread.current)")
            changePoster(newPoster: viewModel.getOtherPoster())
            print("Finalizando tarefa: \(Thread.current)")
        }
    }
    
    // Queueing task on a random background thread
    private func changePosterUsingBackground() {
        print("Adicionando tarefa síncrona na fila da thread no plano de fundo")
        dispatchQueue.async {
            print("Iniciando Tarefa: \(Thread.current)")
            changePoster(newPoster: viewModel.getOtherPoster())
            print("Finalizando Tarefa: \(Thread.current)")
        }
    }

    
    // MARK: - Serial vs Concurrent queues
    private func useSerialQueue() {
        print("Adicionando tarefa 1 na fila da thread no plano de fundo")
        dispatchQueue.async {
            print("Iniciando Tarefa 1: \(Thread.current)")
            changePoster(newPoster: .madagascar, delay: 10)
            print("Finalizando Tarefa 1: \(Thread.current)")
        }
        
        print("Adicionando tarefa 2 na fila da thread no plano de fundo")
        dispatchQueue.async {
            print("Iniciando tarefa 2: \(Thread.current)")
            changePoster(newPoster: .nemo, delay: 5)
            print("Finalizando Tarefa 2: \(Thread.current)")
        }
    }
    
    private func useConcurrentQueue() {
        print("Adicionando Tarefa: Paralela 1")
        concurrentQueue.async {
            print("Iniciando Tarefa 1: \(Thread.current)")
            changePoster(newPoster: .shrek, delay: 10)
            print("Finalizando Tarefa 1:  \(Thread.current)")
        }
        
        print("Adicionando Tarefa: Paralela 2")
        concurrentQueue.async {
            print("Iniciando Tarefa 2: \(Thread.current)")
            changePoster(newPoster: .nemo, delay: 15)
            print("Finalizando Tarefa 2:  \(Thread.current)")
        }
    }
    
    // MARK: - Race condition handling
    private func useConcurrentQueueWithBarrier() {
        print("Adicionando Tarefa: Paralela 1")
        concurrentQueue.async(flags: .barrier) {
            print("Iniciando Tarefa 1: \(Thread.current)")
            changePoster(newPoster: .shrek, delay: 10)
            print("Finalizando Tarefa 1: \(Thread.current)")
        }
        
        print("Adicionando Tarefa: Paralela 2")
        concurrentQueue.async {
            print("Iniciando Tarefa 2: \(Thread.current)")
            changePoster(newPoster: .nemo, delay: 5)
            print("Finalizando Tarefa 2: \(Thread.current)")
        }
    }
    
    private let semaphore = DispatchSemaphore(value: 2)
    
    private func useConcurrentQueueWithSemaphore() {
        print("Adicionando Tarefa: Paralela 1")
        concurrentQueue.async() {
            print("Iniciando Tarefa 1: \(Thread.current)")
            
            // Indicates we want to use the shared resource
            semaphore.wait()
            print("Tarefa 1 Usando o recurso")
            
            changePoster(newPoster: .madagascar, delay: 10)
            
            // Indicates we are done using the shared semaphore
            print("Finalizando Tarefa 1: \(Thread.current)")
            semaphore.signal()
        }
        
        print("Adicionando Tarefa: Paralela 2")
        concurrentQueue.async {
            print("Iniciando Tarefa 2: \(Thread.current)")
            
            viewModel.soma = 5
            
            // Indicates we want to use the shared resource
            semaphore.wait()
            print("Tarefa 2 Usando o recurso")
            
            changePoster(newPoster: .nemo, delay: 5)
            
            // Indicates we are done using the shared resource
            print("Finalizando Tarefa 2: \(Thread.current)")
            semaphore.signal()
        }
    }
    
    // MARK: - Dispatch Group
    private func useDispatchGroup() {
        // We need the task to enter the DispatchGroup
        print("Adicionando Tarefa 1")
        group.enter()
        
        concurrentQueue.async {
            // We perform the task
            semaphore.wait()
            print("Iniciando Tarefa 1: \(Thread.current)")
            changePoster(newPoster: .madagascar, delay: 10)
            
            // After we are done, we need the task to leave the group
            print("Finalizando Tarefa 1:  \(Thread.current)")
            semaphore.signal()
            group.leave()
        }
        
        // We need the task to enter the DispatchGroup
        print("Adicionando Tarefa 2")
        group.enter()
        
        concurrentQueue.async {
            // We perform the task
            semaphore.wait()
            print("Iniciando Tarefa 2: \(Thread.current)")
            changePoster(newPoster: .nemo, delay: 5)
            
            // After we are done, we need the task to leave the group
            print("Finalizando Tarefa 2: \(Thread.current)")
            semaphore.signal()
            group.leave()
        }
        
        group.notify(queue: dispatchQueue) {
            // After all tasks are done, we end up here! :)
            print("Finalizando DispatchGroup: \(Thread.current)")
        }
    }
    
    private func useDispatchGroupWithArray() {
        let posters: [Poster] = [.madagascar, .nemo, .shrek]
        
        for (index, poster) in posters.enumerated() {
            // We need the task to enter the DispatchGroup
            print("Adicionando tarefa \(index)")
            group.enter()
            
            concurrentQueue.async {
                // We perform the task
                semaphore.wait()
                print("Iniciando tarefa \(index): \(Thread.current)")
                changePoster(newPoster: poster, delay: UInt32(index))
                
                // After we are done, we need the task to leave the group
                print("Finalizando tarefa \(index): \(Thread.current)")
                semaphore.signal()
                group.leave()
            }
        }
        
        group.notify(queue: dispatchQueue) {
            // After all tasks are done, we end up here! :)
            print("Finalizando DispatchGroup")
        }
    }
    
    // MARK: - Layout
    var body: some View {
        
        VStack {
            
            Button(queueTypeButtonLabel, action: {
                didTapCounterButton()
            })
                .padding(.top, 32)
                .font(.system(size: 12, weight: .bold, design: .default))
            
            Text(posterTitle)
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

// MARK: - Live preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
