//
//  FetchLessonsUseCaseTests.swift
//  LearnTests
//
//  Created by Mahmoud Abdelshafi on 04/02/2023.
//

import XCTest
import Combine
@testable import Learn

final class FetchLessonsUseCaseTests: XCTestCase {
    
    static let lessons: [Lesson] = {
        let lesson1 = Lesson(id: 1, name: "Lesson1", description: "Lesson one enjoy learning", thumbnail: "👍🏻", videoURL: "https://")
        let lesson2 = Lesson(id: 2, name: "Lesson2", description: "Lesson two enjoy learning", thumbnail: "👍🏻", videoURL: "https://")
        return [ lesson1, lesson2 ]
    }()
    
    private var cancellableBag: Set<AnyCancellable> = []
    private let repoMock = DefaultLessonsRepositoryMock()
    private var useCase: FetchLessonsUseCase?
    
    func testFetchLessonsUseCase_whenFaildFetchesLessons() throws {
        // given
        let expectation = self.expectation(description: "Fetch Lessons UseCase Faild")
        expectation.expectedFulfillmentCount = 2
        repoMock.lessons = nil
        repoMock.shouldSuccess = false
        useCase = DefaultFetchLessonsUseCase(lessonsRepository: repoMock)
        
        // when
        useCase!.execute().sink { _ in
            expectation.fulfill()
        } receiveValue: { lessons in
            
        }.store(in: &cancellableBag)
        
        // then
        var lessons = [Lesson]()
        repoMock.getAllLessons().sink { _ in
            expectation.fulfill()
        } receiveValue: { response in
            lessons = response
            
        }.store(in: &cancellableBag)
        
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(lessons.isEmpty)
        XCTAssertNotNil(repoMock.error)
    }
    
    func testFetchLessonsUseCase_whenSuccessfullyFetchesLessons() throws {
        // given
        let expectation = self.expectation(description: "Fetch Lessons UseCase Successfully")
        expectation.expectedFulfillmentCount = 2
        repoMock.shouldSuccess = true
        repoMock.lessons = FetchLessonsUseCaseTests.lessons
        useCase = DefaultFetchLessonsUseCase(lessonsRepository: repoMock)
        // when
        useCase!.execute().sink { _ in
            
        } receiveValue: { lessons in
            expectation.fulfill()
        }.store(in: &cancellableBag)
        
        
        // then
        var lessons = [Lesson]()
        
        repoMock.getAllLessons().sink { _ in
            
        } receiveValue: { response in
            XCTAssertFalse(response.isEmpty)
            lessons = response
            expectation.fulfill()
        }.store(in: &cancellableBag)
        
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(!lessons.isEmpty)
        XCTAssertTrue(lessons.contains(where: { $0.description == "Lesson two enjoy learning" }))
    }
    
    
    class DefaultLessonsRepositoryMock: BaseRepoMock, LessonsRepository {
        var lessons : [Learn.Lesson]? = []
        var videoDestinationPath: String!
        var localFilePath: URL!
        var error: ProviderError? = ProviderError.invalidServerResponse
        
        var downloadStreamProgress = PassthroughSubject<Learn.DownloadProgressData, Never>()
        
        func getAllLessons() -> AnyPublisher<[Learn.Lesson], Learn.ProviderError> {
            let pass = CurrentValueSubject<[Learn.Lesson], ProviderError>([])
            if shouldSuccess {
                error = nil
                pass.send(lessons!)
            } else {
                pass.send(completion: .failure(ProviderError.invalidServerResponse))
                
            }
            return pass.eraseToAnyPublisher()
        }
        
        func downloadLessonVideo(videoURL: String) {
            
        }
        
        func isVideoExist(destinationPath: String) -> Bool {
            return destinationPath == videoDestinationPath
        }
        
        func localFilePath(for url: URL) -> URL? {
            return self.localFilePath
        }
        
        func cancelDownLoad(url: String) {
            
        }
        
        func checkVideoStatus(videoURl: String) {
            
        }
        
        
    }
    
    
}
