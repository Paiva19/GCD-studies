//
//  MoviePosterViewModel.swift
//  Grand Central Dispatch Test App
//
//  Created by Mobile2you on 25/04/22.
//

import Foundation
import Combine

enum ThreadType: String {
    case noThread = "no async thread"
    case mainThread = "main thread"
    case backgroundThread = "background thread"
}

enum Poster: String {
    case madagascar
    case shrek
}

class MoviePosterViewModel {
    
    var currentPoster: Poster = .madagascar

    func getOtherPoster() -> Poster {
        switch currentPoster {
            case .shrek:
                return .madagascar
            case .madagascar:
                return .shrek
        }
    }
    
    var threadType: ThreadType = .mainThread
    func switchThreadType() -> String {
        switch threadType {
        case .mainThread:
            threadType = .backgroundThread
        case .backgroundThread:
            threadType = .noThread
        case .noThread:
            threadType = .mainThread
        }
        return threadType.rawValue
    }
}
