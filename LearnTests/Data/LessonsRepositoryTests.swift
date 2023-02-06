//
//  LessonsRepositoryTests.swift
//  LearnTests
//
//  Created by Mahmoud Abdelshafi on 06/02/2023.
//

import XCTest
import Combine
@testable import Learn

final class LessonsRepositoryTests: XCTestCase {
    
    private var cancellableBag: Set<AnyCancellable> = []
    private var repo: LessonsRepository!
    private var useCase: DefaultFetchLessonsUseCaseMock!

    override func setUpWithError() throws {
        repo = DefaultLessonsRepository(provider: Hover())
        useCase = DefaultFetchLessonsUseCaseMock(lessonsRepository: repo)
    }

    override func tearDownWithError() throws {
        repo = nil
        useCase = nil
    }

    func testExecuteLessonsUseCase_whenFaildLessonsExecution() {
        // given
        let expectation = self.expectation(description: "execute UseCase Faild")
        expectation.expectedFulfillmentCount = 2
        useCase.success = false
        var lessons = [Lesson]()
        // when
        useCase!.execute().sink { _ in
            expectation.fulfill()
        } receiveValue: { response in
            lessons = response
        }.store(in: &cancellableBag)
        
        // then
   
        repo.getAllLessons().sink { _ in
            expectation.fulfill()
        } receiveValue: { response in
            
            
        }.store(in: &cancellableBag)
        
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(lessons.isEmpty)
        XCTAssertTrue(useCase.lessons.isEmpty)
        XCTAssertNotNil(useCase.error)
    }
    
    func testExecuteLessonsUseCase_whenSuccessLessonsExecution()  {
        // given
        let expectation = self.expectation(description: "execute UseCase success")
        expectation.expectedFulfillmentCount = 2
        useCase.success = true
        var lessons = [Lesson]()
        // when
        useCase!.execute().sink { _ in
            
        } receiveValue: { response in
            expectation.fulfill()
            lessons = response
        }.store(in: &cancellableBag)
        
        // then
   
        repo.getAllLessons().sink { _ in
           
        } receiveValue: { response in
            expectation.fulfill()
        }.store(in: &cancellableBag)
        
        wait(for: [expectation], timeout: 5)
        XCTAssertFalse(lessons.isEmpty)
        XCTAssertFalse(useCase.lessons.isEmpty)
        XCTAssertTrue(lessons.contains(where: { $0.description == "Lesson two enjoy learning" }))
        XCTAssertNil(useCase.error)
    }
    
    class DefaultFetchLessonsUseCaseMock: FetchLessonsUseCase {
        
        private let lessonsRepository: LessonsRepository
        var success: Bool!
        var lessons: [Lesson] = []
        var error: ProviderError?
        
        init(lessonsRepository: LessonsRepository) {
            self.lessonsRepository = lessonsRepository
        }
        
        func execute() -> AnyPublisher<[Learn.Lesson], Learn.ProviderError> {
            let pass = CurrentValueSubject<[Learn.Lesson], ProviderError>([])
            if success {
                self.lessons = FetchLessonsUseCaseTests.lessons
                pass.send(FetchLessonsUseCaseTests.lessons)
            } else {
                error = ProviderError.invalidServerResponse
                pass.send(completion: .failure(ProviderError.invalidServerResponse))
            }
            return pass.eraseToAnyPublisher()
        }
        
    }
    

}
