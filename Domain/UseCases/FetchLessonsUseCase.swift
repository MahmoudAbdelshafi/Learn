//
//  FetchLessonsUseCase.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation
import Combine

protocol FetchLessonsUseCase {
    func execute() -> AnyPublisher<[Lesson], ProviderError>
}

final class DefaultFetchLessonsUseCase: FetchLessonsUseCase {

    //MARK: - Properties

    private let lessonsRepository: LessonsRepository

    //MARK: - Init

    init(lessonsRepository: LessonsRepository) {
        self.lessonsRepository = lessonsRepository
    }

    //MARK: - Methods

    func execute() -> AnyPublisher<[Lesson], ProviderError> {
        lessonsRepository.getAllLessons()
    }
    
}
