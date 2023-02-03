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
    private let downloadManager: DownloadManager
    fileprivate let cache: LessonsResponseStorage?
    fileprivate var cancellableBag = Set<AnyCancellable>()
    
    var downloadTask: URLSessionDownloadTask?
    var downloadStreamProgress = PassthroughSubject<DownloadProgressData, Never>()
    let pass = PassthroughSubject<[Lesson], Never>()
    
    init(provider: Hover,
         downloadManager: DownloadManager? = nil,
         cache: LessonsResponseStorage? = nil) {
        self.provider = provider
        self.downloadManager = downloadManager ?? DownloadManager.shared
        self.cache = cache
    }
    
}

//MARK: - LessonsRepository - 

extension DefaultLessonsRepository: LessonsRepository {
    
    func isVideoExist(destinationPath: String) -> Bool {
        downloadManager.isFileExist(destinationPath: destinationPath)
    }
    
    func getAllLessons() -> AnyPublisher<[Lesson], ProviderError> {
        
        let pass = PassthroughSubject<[Lesson], ProviderError>()
        
        self.cache?.getCached().sink(receiveCompletion: { _ in
        }, receiveValue: { lessonsDTO in
            pass.send(lessonsDTO.toLessonDomain())
            if lessonsDTO.lessons?.count ?? 0 <= 0 {
                self.provider.request(
                    with: LessonsTarget.getAllLessons,
                    scheduler: DispatchQueue.main,
                    class: LessonsDTO.self
                ).sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        pass.send(completion: .finished)
                    case .failure(let failure):
                        pass.send(completion: .failure(failure))
                    }
                }, receiveValue: { [weak self] lessonDTO in
                    self?.cache?.cacheLessonsResponse(response: lessonDTO)
                    pass.send(lessonDTO.toLessonDomain())
                    
                }).store(in: &self.cancellableBag)
            }
        }).store(in: &cancellableBag)
        
        return pass.eraseToAnyPublisher()
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
    
    private func getCachedLessons() {
        let pass = PassthroughSubject<LessonsDTO, CoreDataStorageError>()
        self.cache?.getCached().sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                pass.send(completion: .finished)
            case .failure(let failure):
                pass.send(completion: .failure(failure))
            }
        }, receiveValue: { lessonsDTO in
            pass.send(lessonsDTO)
        }).store(in: &cancellableBag)
    }
    
}
