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
    fileprivate var cancellableBag = Set<AnyCancellable>()
    
    var downloadTask: URLSessionDownloadTask?
    var downloadStreamProgress = PassthroughSubject<DownloadProgressData, Never>()
    let pass = PassthroughSubject<[Lesson], Never>()
    
    init(provider: Hover, downloadManager: DownloadManager? = nil) {
        self.provider = provider
        self.downloadManager = downloadManager ?? DownloadManager.shared
    }
    
}

//MARK: - LessonsRepository - 

extension DefaultLessonsRepository: LessonsRepository {
    
    func isVideoExist(destinationPath: String) -> Bool {
        downloadManager.isFileExist(destinationPath: destinationPath)
    }
    
    func getAllLessons() -> AnyPublisher<[Lesson], ProviderError> {
        provider.request(
            with: LessonsTarget.getAllLessons,
            scheduler: DispatchQueue.main,
            class: LessonsDTO.self
        )
        .map{ $0.toLessonDomain() }
        .eraseToAnyPublisher()
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
    
}
