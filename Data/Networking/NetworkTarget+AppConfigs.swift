//
//  NetworkTarget+AppConfigs.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation

extension NetworkTarget {
    
    var baseURL: URL {
        guard let url = URL(string: AppConfiguration().apiBaseURL) else { fatalError("Base URL is not valid") }
        return url
    }
    
}
