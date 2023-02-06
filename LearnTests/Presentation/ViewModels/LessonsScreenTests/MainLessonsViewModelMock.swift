//
//  MainLessonsViewModelMock.swift
//  LearnTests
//
//  Created by Mahmoud Abdelshafi on 04/02/2023.
//

import XCTest
import Combine
@testable import Learn

final class MainLessonsViewModelMock: XCTestCase {

    func testGetLessons_Successfully() {
        //given
        let fetchLessonsUseCaseMock = FetchLessonsUseCaseMock()
        fetchLessonsUseCaseMock.expectation = self.expectation(description: "Getting Lessons success")
        let viewModel = DefaultMainLessonsViewModel(fetchLessonsUseCase: fetchLessonsUseCaseMock)
        
        //When
        viewModel.viewAppeared()
        
        //Then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(viewModel.lessonsData)
    }
    
    
    func testGetLessons_Faild() {
        //given
        let fetchLessonsUseCaseMock = FetchLessonsUseCaseMock()
        fetchLessonsUseCaseMock.expectation = self.expectation(description: "Getting Lessons success")
        fetchLessonsUseCaseMock.error = .faildFetchingLessons
        let viewModel = DefaultMainLessonsViewModel(fetchLessonsUseCase: fetchLessonsUseCaseMock)
        
        //When
        viewModel.viewAppeared()
        
        //Then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(viewModel.lessonsData.isEmpty)
        XCTAssertEqual(fetchLessonsUseCaseMock.error, FetchLessonsUseCaseTestingError.faildFetchingLessons)
    }
    
    enum FetchLessonsUseCaseTestingError: Error {
        case faildFetchingLessons
    }
    
   final class FetchLessonsUseCaseMock: FetchLessonsUseCase {

       var expectation: XCTestExpectation?
       var error: FetchLessonsUseCaseTestingError?
       let lesson1 = Lesson(id: 1, name: "Lesson1", description: "Lesson one enjoy learning", thumbnail: "👍🏻", videoURL: "https://")
       let lesson2 = Lesson(id: 2, name: "Lesson2", description: "Lesson two enjoy learning", thumbnail: "👍🏻", videoURL: "https://")
       var lessons = [Lesson]()
       
       func execute() -> AnyPublisher<[Lesson], ProviderError> {
           let pass = PassthroughSubject<[Learn.Lesson], ProviderError>()
           if error != nil {
               pass.send(completion: .failure(ProviderError.underlying(error!)))
           } else {
               lessons = [lesson1 , lesson2, lesson1]
               pass.send(lessons)
           }
           expectation?.fulfill()
           return pass.eraseToAnyPublisher()
       }
    }

}
