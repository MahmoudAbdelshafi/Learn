//
//  AppConfiguration.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 31/01/2023.
//

import Foundation

final class AppConfiguration {
    
    lazy var apiBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
            fatalError("ApiBaseURL must not be empty in plist")
        }
        return apiBaseURL
    }()
    
}
