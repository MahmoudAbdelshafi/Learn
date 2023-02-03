//
//  LessonsResponseStorage.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 03/02/2023.
//

import Foundation
import Combine

protocol LessonsResponseStorage {
    func getCached() -> AnyPublisher<LessonsDTO, CoreDataStorageError>
    func cacheLessonsResponse(response: LessonsDTO) 
}
