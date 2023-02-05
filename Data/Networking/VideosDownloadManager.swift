//
//  VideosDownloadManager.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 03/02/2023.
//

import Foundation
import Combine

final class VideosDownloadManager: NSObject {
    
    private lazy var urlSession = URLSession(configuration: .default,
                                             delegate: self,
                                             delegateQueue: nil)
    
    var downloadingVideos: [ URL : DownloadVideoModel ] = [:]
    let pass = PassthroughSubject<[Lesson], Never>()
    
    static let shared = VideosDownloadManager()
    
    private override init() {}
    
    func localFilePath(for url: URL) -> URL? {
        getLocalFilePath(for: url)
    }
    
}

//MARK: - URLSessionDownloadDelegate -

extension VideosDownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64,
                    expectedTotalBytes: Int64) {
        debugPrint("Task has been resumed")
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        debugPrint("Downloaded")
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
        guard let url = downloadTask.response?.url else { return }
       removeDownloadFromCache(url: url)
      
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
        DispatchQueue.main.async { [weak self] in
            guard let url = downloadTask.response?.url else { return }
            self?.downloadingVideos[url]?.progressStreem.send(download)
        }
    }
    
    func download(with url: String) {
        guard let url = URL(string: url) else { return }
        let destinationURL = localFilePath(for: url)
        if isFileExist(destinationPath: destinationURL!.path) {
            debugPrint("video is available")
        } else {
            if !downloadingVideos.contains(where: { $0.key.absoluteURL == url}) {
                let downloadTask = urlSession.downloadTask(with: url)
                downloadTask.resume()
                let downloadModel = DownloadVideoModel(sessionTask: downloadTask)
                self.downloadingVideos.updateValue(downloadModel, forKey: url)
            }
        }
    }
    
    func cancel(url: String) {
        guard let url = URL(string: url) else { return }
        downloadingVideos[url]?.sessionTask?.cancel()
        removeDownloadFromCache(url: url)
    }
    
    func isFileExist(destinationPath: String) -> Bool {
        return FileManager.default.fileExists(atPath: destinationPath)
    }
    
    func getLocalFilePath(for url: URL) -> URL? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                           in: .userDomainMask).first else { return nil }
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    func isVideoDownloading(videoURL: String) -> Bool {
        guard let url = URL(string: videoURL) else { return false }
        return downloadingVideos[url] != nil
    }
    
    private func removeDownloadFromCache(url: URL) {
        self.downloadingVideos[url]?.progressStreem.send(completion: .finished)
        self.downloadingVideos.removeValue(forKey: url)
    }
}

struct DownloadVideoModel {
    var isDownloading: Bool = false
    var progress: Float = 0.0
    var progressStreem = PassthroughSubject<DownloadProgressData, Never>()
    var sessionTask: URLSessionDownloadTask?
}
