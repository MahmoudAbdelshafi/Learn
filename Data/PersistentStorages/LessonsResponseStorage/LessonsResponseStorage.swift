//
//  LessonsResponseStorage.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 03/02/2023.
//

import Foundation
import Combine

protocol LessonsResponseStorage {
    func getCachedLessons() -> AnyPublisher<LessonsDTO, ProviderError>
    func cacheLessonsResponse(response: LessonsDTO) 
}
