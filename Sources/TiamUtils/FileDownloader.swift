import Foundation

/// A simple URLSession wrapper that downloads files directly to disk
public final class FileDownloader {
    public enum StateChange {
        case waitForConnectivity
        case progress(Double)
        case finish(Result<URL, Error>)
    }

    public typealias UpdateHandler = (StateChange) -> Void

    fileprivate class Delegate: NSObject {
        fileprivate weak var weakFileDownloader: FileDownloader?
    }

    private var ongoingDownloads = [URLRequest: [UpdateHandler]]()
    private let delegate = Delegate()
    private let urlSession: URLSession

    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        self.urlSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        self.delegate.weakFileDownloader = self
    }

    deinit {
        urlSession.invalidateAndCancel()
    }

    /// Starts a new download task if necessary, or reuse an ongoing task if one for the same urlRequest already exists
    /// - Parameters:
    ///   - urlRequest: Http URL to the file to download
    ///   - handler: Handler called regularly as a download progresses, then called once when it ends
    /// - Note: The downloaded file resides inside the cache directory.
    public func startDownloadingFile(at urlRequest: URLRequest, updateHandler handler: @escaping UpdateHandler) {
        guard let scheme = urlRequest.url?.scheme, scheme == "http" || scheme == "https" else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.ongoingDownloads[urlRequest] != nil {
                self.ongoingDownloads[urlRequest]?.append(handler)
            } else {
                self.ongoingDownloads[urlRequest] = [handler]
                self.urlSession.downloadTask(with: urlRequest).resume()
            }
        }
    }

    private func downloadTask(_ downloadTask: URLSessionDownloadTask, did change: StateChange) {
        DispatchQueue.main.async { [weak self] in
            guard let urlRequest = downloadTask.originalRequest else {
                return assertionFailure("Missing url request in download task: \(downloadTask)")
            }
            guard let self = self, let handlers = self.ongoingDownloads[urlRequest] else {
                return print("Request already removed")
            }

            if case .finish = change {
                self.ongoingDownloads.removeValue(forKey: urlRequest)
            }

            for handler in handlers {
                handler(change)
            }
        }
    }
}


extension FileDownloader.Delegate: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error ?? task.error ?? (task.response as? HTTPURLResponse)?.serverError,
              let downloadTask = task as? URLSessionDownloadTask else {
            return
        }
        weakFileDownloader?.downloadTask(downloadTask, did: .finish(.failure(error)))
    }

    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        guard let downloadTask = task as? URLSessionDownloadTask else { return }
        weakFileDownloader?.downloadTask(downloadTask, did: .waitForConnectivity)
    }
}

extension FileDownloader.Delegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard (downloadTask.response as? HTTPURLResponse)?.serverError == nil else {
            return
        }

        let destinationURL = URL.cacheDirectory.appendingPathComponent(UUID().uuidString, isDirectory: false)
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            weakFileDownloader?.downloadTask(downloadTask, did: .finish(.success(destinationURL)))
        } catch {
            weakFileDownloader?.downloadTask(downloadTask, did: .finish(.failure(error)))
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let calculatedProgress = (Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)).clamped(to: 0...1)
        weakFileDownloader?.downloadTask(downloadTask, did: .progress(calculatedProgress))
    }
}
