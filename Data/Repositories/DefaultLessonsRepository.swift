//
//  DefaultLessonsRepository.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation
import Combine

final class DefaultLessonsRepository: NSObject {
    
    private let provider: Hover
    private let downloadManager: VideosDownloadManager
    fileprivate let cache: LessonsResponseStorage?
    fileprivate var cancellableBag = Set<AnyCancellable>()
    
    var downloadTask: URLSessionDownloadTask?
    var downloadStreamProgress = PassthroughSubject<DownloadProgressData, Never>()
    let pass = PassthroughSubject<[Lesson], Never>()
    
    init(provider: Hover,
         downloadManager: VideosDownloadManager? = nil,
         cache: LessonsResponseStorage? = nil) {
        self.provider = provider
        self.downloadManager = downloadManager ?? VideosDownloadManager.shared
        self.cache = cache
    }
    
}

//MARK: - LessonsRepository - 

extension DefaultLessonsRepository: LessonsRepository {
    
    func isVideoExist(destinationPath: String) -> Bool {
        downloadManager.isFileExist(destinationPath: destinationPath)
    }
    
    func getAllLessons() -> AnyPublisher<[Lesson], ProviderError> {
        guard let cache = cache else { return loadServerLessons().eraseToAnyPublisher() }
        return cache.getCachedLessons()
            .map { $0.toLessonDomain() }
            .flatMap({ (response: [Lesson]?) -> AnyPublisher<[ Lesson ], ProviderError>  in
                
                if let response = response, response.count > 0 {
                    debugPrint("get from cache")
                    return Just( response.map{ $0 } )
                        .setFailureType(to: ProviderError.self)
                        .eraseToAnyPublisher()
                    
                } else {
                    debugPrint("get from server")
                    return self.loadServerLessons().eraseToAnyPublisher()
                }
            }).eraseToAnyPublisher()
    }
    
    func downloadLessonVideo(videoURL: String) {
        downloadManager.download(with: videoURL)
        bindOnCurrentVideoStreamProgress(videoURL: videoURL)
    }
    
    func localFilePath(for url: URL) -> URL? {
        downloadManager.getLocalFilePath(for: url)
    }
    
    func cancelDownLoad(url: String) {
        downloadManager.cancel(url: url)
    }
    
    func checkVideoStatus(videoURl: String) {
        if downloadManager.isVideoDownloading(videoURL: videoURl) {
            bindOnCurrentVideoStreamProgress(videoURL: videoURl)
        }
    }
    
    private func bindOnCurrentVideoStreamProgress(videoURL: String) {
        guard let url = URL(string: videoURL) else { return }
        downloadManager.downloadingVideos[url]?.progressStreem.sink(receiveValue: { [weak self] in
            self?.downloadStreamProgress.send($0)
        }).store(in: &cancellableBag)
    }
    
    private func loadServerLessons() -> AnyPublisher<[Lesson], ProviderError> {
        return self.provider.request(
            with: LessonsTarget.getAllLessons,
            scheduler: DispatchQueue.main,
            class: LessonsDTO.self
        ).map { [weak self] lesson in
            self?.cache?.cacheLessonsResponse(response: lesson)
            return lesson.toLessonDomain()
        }.eraseToAnyPublisher()
    }
}
