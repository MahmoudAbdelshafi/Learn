//
//  LessonsRepository.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation
import Combine

protocol LessonsRepository {
    func getAllLessons() -> AnyPublisher<[Lesson], ProviderError>
    func downloadLessonVideo(videoURL: String)
    func isVideoExist(destinationPath: String) -> Bool
    func localFilePath(for url: URL) -> URL?
    func cancelDownLoad()
    var downloadStreamProgress: PassthroughSubject<DownloadProgressData,Never> { get set }
}
