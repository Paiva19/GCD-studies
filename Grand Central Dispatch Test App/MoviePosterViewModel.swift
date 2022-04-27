//
//  MoviePosterViewModel.swift
//  Grand Central Dispatch Test App
//
//  Created by Mobile2you on 25/04/22.
//

import Foundation
import Combine

enum QueueType: String {
    case noQueue = "no queue"
    case main = "main thread queue"
    case background = "background thread queue"
    case serialQueue = "serial queue"
    case concurrentQueue = "concurrent queue"
    case concurrentQueueBarrier = "concurrent queue with barrier"
    case concurrentQueueSemaphore = "concurrent queue with semaphore"
    case dispatchGroup = "dispatch group"
    case dispatchGroupWithArray = "dispatch group with array"
}

enum Poster: String {
    case madagascar
    case shrek
    case nemo
}

class MoviePosterViewModel {
    
    // Shared resource that represents the current poster
    var currentPoster: Poster = .madagascar

    var soma = 0
    
    // Get a poster that is different from the one we have
    func getOtherPoster() -> Poster {
        switch currentPoster {
            case .shrek:
                return .madagascar
            case .madagascar:
                return .nemo
            case .nemo:
                return .shrek
        }
    }
    
    
///     Selecting which type of thread we want to queue our task on
///     For demonstration purposes
///     In a real world application, this would not exist
    var queueType: QueueType = .noQueue
    func switchQueueType() -> String {
        switch queueType {
        case .noQueue:
            queueType = .main
        case .main:
            queueType = .background
        case .background:
            queueType = .serialQueue
        case .serialQueue:
            queueType = .concurrentQueue
        case .concurrentQueue:
            queueType = .concurrentQueueBarrier
        case .concurrentQueueBarrier:
            queueType = .concurrentQueueSemaphore
        case .concurrentQueueSemaphore:
            queueType = .dispatchGroup
        case .dispatchGroup:
            queueType = .dispatchGroupWithArray
        case .dispatchGroupWithArray:
            queueType = .noQueue
        }
        return queueType.rawValue
    }
}
