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
    private lazy var urlSession = URLSession(configuration: .default,
                                             delegate: self,
                                             delegateQueue: nil)
    private let downloadManager: DownloadManager
    
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
        isFileExist(destinationPath: destinationPath)
    }
    
    func getAllLessons() -> AnyPublisher<[Lesson], ProviderError> {
        provider.request(
            with: LessonsTarget.getAllLessons,
            scheduler: DispatchQueue.main,
            class: LessonsDTO.self
        )
        .map{ $0.toLessonDomain()}
        .eraseToAnyPublisher()
    }
    
    func downloadLessonVideo(videoURL: String) {
        download(with: videoURL)
    }
    
    func localFilePath(for url: URL) -> URL? {
        getLocalFilePath(for: url)
    }
    
    func cancelDownLoad() {
        downloadTask?.cancel()
    }
}

//MARK: - Download Manager -

extension DefaultLessonsRepository: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        debugPrint("Task has been resumed")
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        debugPrint("Downloaded")
        downloadStreamProgress.send(completion: .finished)
        guard let sourceUrl = downloadTask.originalRequest?.url else {
            return
        }
        guard let destinationURL = localFilePath(for: sourceUrl) else { return }
        debugPrint(destinationURL)
        do {
            let _ = try
            FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
            try FileManager.default.moveItem(at: location, to: destinationURL)
            debugPrint(destinationURL)
            debugPrint(location)
        } catch {
            debugPrint ("file error: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        let download = DownloadProgressData(session: session,
                                            downloadTask: downloadTask,
                                            bytesWritten: bytesWritten,
                                            totalBytesWritten: totalBytesWritten,
                                            totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        if downloadTask == self.downloadTask {
            DispatchQueue.main.async { [weak self] in
                self?.downloadStreamProgress.send(download)
            }
        }
    }
    
    private func download(with url: String) {
        guard let url = URL(string: url) else { return }
        let destinationURL = localFilePath(for: url)
        if isFileExist(destinationPath: destinationURL!.path) {
            debugPrint("video is available")
        } else {
            downloadTask = urlSession.downloadTask(with: url)
            downloadTask?.resume()
        }
    }
    
    private func isFileExist(destinationPath: String) -> Bool {
        return FileManager.default.fileExists(atPath: destinationPath)
    }
    
    private func getLocalFilePath(for url: URL) -> URL? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
}
