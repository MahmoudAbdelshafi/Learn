//
//  LessonsTarget.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation

enum LessonsTarget {
    
    case getAllLessons
}

extension LessonsTarget: NetworkTarget {
    
    var path: String {
        switch self {
        case .getAllLessons:
            return "lessons"
        }
    }
    
    var methodType: MethodType {
        
        switch self {
        case .getAllLessons:
            return .get
        }
    }

    var workType: WorkType {
        switch self {
        case .getAllLessons:
            return .requestPlain
            
        }
    }
    
    var providerType: AuthProviderType {
        switch self {
        case .getAllLessons:
            return .none
        }
    }
    
    var contentType: ContentType? {
        switch self {
        case .getAllLessons:
            return .applicationJson
        }
    }
    
    var headers: [String : String]? {
        [:]
    }
    
    
}
