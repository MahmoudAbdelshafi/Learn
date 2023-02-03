//
//  DownloadLessonVideoUseCase.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation
import Combine

protocol DownloadLessonVideoUseCase {
    func execute(videoURL: String)
    func isVideoExist(destinationPath: String) -> Bool
    func localFilePath(for url: URL) -> URL?
    func getDownloadProgress() -> AnyPublisher<DownloadProgressData, Never>
    func cancelDownLoad()
}

final class DefaultDownloadLessonVideoUseCase: DownloadLessonVideoUseCase {

    var downloadStreamProgress = PassthroughSubject<DownloadProgressData, Never>()
    
    //MARK: - Properties -
    
    private let lessonsRepository: LessonsRepository
    
    //MARK: - Init -
    
    init(lessonsRepository: LessonsRepository) {
        self.lessonsRepository = lessonsRepository
    }
    
    //MARK: - Methods
    
    func execute(videoURL: String) {
        lessonsRepository.downloadLessonVideo(videoURL: videoURL)
    }
    
    func cancelDownLoad() {
        lessonsRepository.cancelDownLoad()
    }
    
    func getDownloadProgress() -> AnyPublisher<DownloadProgressData, Never> {
        return lessonsRepository.downloadStreamProgress.eraseToAnyPublisher()
    }
    
    func isVideoExist(destinationPath: String) -> Bool {
        lessonsRepository.isVideoExist(destinationPath: destinationPath)
    }
    
    func localFilePath(for url: URL) -> URL? {
        lessonsRepository.localFilePath(for: url)
    }
}
