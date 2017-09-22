// ImageDownloader.swift
//
// Copyright (c) 2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Alamofire
import Foundation

#if os(iOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

/// The `RequestReceipt` is an object vended by the `ImageDownloader` when starting a download request. It can be used 
/// to cancel active requests running on the `ImageDownloader` session. As a general rule, image download requests 
/// should be cancelled using the `RequestReceipt` instead of calling `cancel` directly on the `request` itself. The 
/// `ImageDownloader` is optimized to handle duplicate request scenarios as well as pending versus active downloads.
open class RequestReceipt {
    /// The download request created by the `ImageDownloader`.
    open let request: Request

    /// The unique identifier for the image filters and completion handlers when duplicate requests are made.
    open let receiptID: String

    init(request: Request, receiptID: String) {
        self.request = request
        self.receiptID = receiptID
    }
}

/// The `ImageDownloader` class is responsible for downloading images in parallel on a prioritized queue. Incoming
/// downloads are added to the front or back of the queue depending on the download prioritization. Each downloaded 
/// image is cached in the underlying `NSURLCache` as well as the in-memory image cache that supports image filters. 
/// By default, any download request with a cached image equivalent in the image cache will automatically be served the
/// cached image representation. Additional advanced features include supporting multiple image filters and completion 
/// handlers for a single request.
open class ImageDownloader {
    /// The completion handler closure used when an image download completes.
    public typealias CompletionHandler = (Response<Image, NSError>) -> Void

    /**
        Defines the order prioritization of incoming download requests being inserted into the queue.

        - FIFO: All incoming downloads are added to the back of the queue.
        - LIFO: All incoming downloads are added to the front of the queue.
    */
    public enum DownloadPrioritization {
        case fifo, lifo
    }

    class ResponseHandler {
        let identifier: String
        let request: Request
        var operations: [(id: String, filter: ImageFilter?, completion: CompletionHandler?)]

        init(request: Request, id: String, filter: ImageFilter?, completion: CompletionHandler?) {
            self.request = request
            self.identifier = ImageDownloader.identifierForURLRequest(request.request!)
            self.operations = [(id: id, filter: filter, completion: completion)]
        }
    }

    // MARK: - Properties

    /// The image cache used to store all downloaded images in.
    open let imageCache: ImageRequestCache?

    /// The credential used for authenticating each download request.
    open fileprivate(set) var credential: URLCredential?

    let sessionManager: Alamofire.Manager
    let downloadPrioritization: DownloadPrioritization
    let maximumActiveDownloads: Int

    var activeRequestCount = 0
    var queuedRequests: [Request] = []
    var responseHandlers: [String: ResponseHandler] = [:]

    fileprivate let synchronizationQueue: DispatchQueue = {
        let name = String(format: "com.alamofire.imagedownloader.synchronizationqueue-%08%08", arc4random(), arc4random())
        return DispatchQueue(label: name, attributes: [])
    }()

    fileprivate let responseQueue: DispatchQueue = {
        let name = String(format: "com.alamofire.imagedownloader.responsequeue-%08%08", arc4random(), arc4random())
        return DispatchQueue(label: name, attributes: DispatchQueue.Attributes.concurrent)
    }()

    // MARK: - Initialization

    /// The default instance of `ImageDownloader` initialized with default values.
    open static let defaultInstance = ImageDownloader()

    /**
        Creates a default `NSURLSessionConfiguration` with common usage parameter values.
    
        - returns: The default `NSURLSessionConfiguration` instance.
    */
    open class func defaultURLSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default

        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.httpShouldSetCookies = true
        configuration.httpShouldUsePipelining = false

        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForRequest = 60

        configuration.urlCache = ImageDownloader.defaultURLCache()

        return configuration
    }

    /**
        Creates a default `NSURLCache` with common usage parameter values.

        - returns: The default `NSURLCache` instance.
    */
    open class func defaultURLCache() -> URLCache {
        return URLCache(
            memoryCapacity: 20 * 1024 * 1024, // 20 MB
            diskCapacity: 150 * 1024 * 1024,  // 150 MB
            diskPath: "com.alamofire.imagedownloader"
        )
    }

    /**
        Initializes the `ImageDownloader` instance with the given configuration, download prioritization, maximum active 
        download count and image cache.

        - parameter configuration:          The `NSURLSessionConfiguration` to use to create the underlying Alamofire 
                                            `Manager` instance.
        - parameter downloadPrioritization: The download prioritization of the download queue. `.FIFO` by default.
        - parameter maximumActiveDownloads: The maximum number of active downloads allowed at any given time.
        - parameter imageCache:             The image cache used to store all downloaded images in.

        - returns: The new `ImageDownloader` instance.
    */
    public init(
        configuration: URLSessionConfiguration = ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: DownloadPrioritization = .fifo,
        maximumActiveDownloads: Int = 4,
        imageCache: ImageRequestCache? = AutoPurgingImageCache())
    {
        self.sessionManager = Alamofire.Manager(configuration: configuration)
        self.sessionManager.startRequestsImmediately = false

        self.downloadPrioritization = downloadPrioritization
        self.maximumActiveDownloads = maximumActiveDownloads
        self.imageCache = imageCache
    }

    /**
        Initializes the `ImageDownloader` instance with the given sesion manager, download prioritization, maximum
        active download count and image cache.

        - parameter sessionManager:         The Alamofire `Manager` instance to handle all download requests.
        - parameter downloadPrioritization: The download prioritization of the download queue. `.FIFO` by default.
        - parameter maximumActiveDownloads: The maximum number of active downloads allowed at any given time.
        - parameter imageCache:             The image cache used to store all downloaded images in.

        - returns: The new `ImageDownloader` instance.
    */
    public init(
        sessionManager: Manager,
        downloadPrioritization: DownloadPrioritization = .fifo,
        maximumActiveDownloads: Int = 4,
        imageCache: ImageRequestCache? = AutoPurgingImageCache())
    {
        self.sessionManager = sessionManager
        self.sessionManager.startRequestsImmediately = false

        self.downloadPrioritization = downloadPrioritization
        self.maximumActiveDownloads = maximumActiveDownloads
        self.imageCache = imageCache
    }

    // MARK: - Authentication

    /**
        Associates an HTTP Basic Auth credential with all future download requests.

        - parameter user:        The user.
        - parameter password:    The password.
        - parameter persistence: The URL credential persistence. `.ForSession` by default.
    */
    open func addAuthentication(
        user: String,
        password: String,
        persistence: URLCredential.Persistence = .forSession)
    {
        let credential = URLCredential(user: user, password: password, persistence: persistence)
        addAuthentication(usingCredential: credential)
    }

    /**
        Associates the specified credential with all future download requests.

        - parameter credential: The credential.
    */
    open func addAuthentication(usingCredential credential: URLCredential) {
        synchronizationQueue.sync {
            self.credential = credential
        }
    }

    // MARK: - Download

    /**
        Creates a download request using the internal Alamofire `Manager` instance for the specified URL request.
    
        If the same download request is already in the queue or currently being downloaded, the completion handler is
        appended to the already existing request. Once the request completes, all completion handlers attached to the
        request are executed in the order they were added.

        - parameter URLRequest: The URL request.
        - parameter completion: The closure called when the download request is complete.

        - returns: The request receipt for the download request if available. `nil` if the image is stored in the image
                   cache and the URL request cache policy allows the cache to be used.
    */
    open func downloadImage(
        URLRequest: URLRequestConvertible,
        completion: CompletionHandler?)
        -> RequestReceipt?
    {
        return downloadImage(URLRequest: URLRequest, filter: nil, completion: completion)
    }

    /**
        Creates a download request using the internal Alamofire `Manager` instance for the specified URL request.

        If the same download request is already in the queue or currently being downloaded, the filter and completion 
        handler are appended to the already existing request. Once the request completes, all filters and completion 
        handlers attached to the request are executed in the order they were added. Additionally, any filters attached
        to the request with the same identifiers are only executed once. The resulting image is then passed into each
        completion handler paired with the filter.

        You should not attempt to directly cancel the `request` inside the request receipt since other callers may be
        relying on the completion of that request. Instead, you should call `cancelRequestForRequestReceipt` with the
        returned request receipt to allow the `ImageDownloader` to optimize the cancellation on behalf of all active
        callers.

        - parameter URLRequest: The URL request.
        - parameter filter      The image filter to apply to the image after the download is complete.
        - parameter completion: The closure called when the download request is complete.

        - returns: The request receipt for the download request if available. `nil` if the image is stored in the image
                   cache and the URL request cache policy allows the cache to be used.
    */
    open func downloadImage(
        URLRequest: URLRequestConvertible,
        filter: ImageFilter?,
        completion: CompletionHandler?)
        -> RequestReceipt?
    {
        var request: Request!
        let receiptID = UUID().uuidString

        synchronizationQueue.sync {
            // 1) Append the filter and completion handler to a pre-existing request if it already exists
            let identifier = ImageDownloader.identifierForURLRequest(URLRequest)

            if let responseHandler = self.responseHandlers[identifier] {
                responseHandler.operations.append(id: receiptID, filter: filter, completion: completion)
                request = responseHandler.request
                return
            }

            // 2) Attempt to load the image from the image cache if the cache policy allows it
            switch URLRequest.URLRequest.cachePolicy {
            case .useProtocolCachePolicy, .returnCacheDataElseLoad, .returnCacheDataDontLoad:
                if let image = self.imageCache?.imageForRequest(
                    URLRequest.URLRequest,
                    withAdditionalIdentifier: filter?.identifier)
                {
                    DispatchQueue.main.async {
                        let response = Response<Image, NSError>(
                            request: URLRequest.URLRequest,
                            response: nil,
                            data: nil,
                            result: .success(image)
                        )

                        completion?(response)
                    }

                    return
                }
            default:
                break
            }

            // 3) Create the request and set up authentication, validation and response serialization
            request = self.sessionManager.request(URLRequest)

            if let credential = self.credential {
                request.authenticate(usingCredential: credential)
            }

            request.validate()
            request.response(
                queue: self.responseQueue,
                responseSerializer: Request.imageResponseSerializer(),
                completionHandler: { [weak self] response in
                    guard let strongSelf = self, let request = response.request else { return }

                    let responseHandler = strongSelf.safelyRemoveResponseHandlerWithIdentifier(identifier)

                    switch response.result {
                    case .success(let image):
                        var filteredImages: [String: Image] = [:]

                        for (_, filter, completion) in responseHandler.operations {
                            var filteredImage: Image

                            if let filter = filter {
                                if let alreadyFilteredImage = filteredImages[filter.identifier] {
                                    filteredImage = alreadyFilteredImage
                                } else {
                                    filteredImage = filter.filter(image)
                                    filteredImages[filter.identifier] = filteredImage
                                }
                            } else {
                                filteredImage = image
                            }

                            strongSelf.imageCache?.addImage(
                                filteredImage,
                                forRequest: request,
                                withAdditionalIdentifier: filter?.identifier
                            )

                            DispatchQueue.main.async {
                                let response = Response<Image, NSError>(
                                    request: response.request,
                                    response: response.response,
                                    data: response.data,
                                    result: .success(filteredImage)
                                )

                                completion?(response)
                            }
                        }
                    case .failure:
                        for (_, _, completion) in responseHandler.operations {
                            DispatchQueue.main.async { completion?(response) }
                        }
                    }

                    strongSelf.safelyDecrementActiveRequestCount()
                    strongSelf.safelyStartNextRequestIfNecessary()
                }
            )

            // 4) Store the response handler for use when the request completes
            let responseHandler = ResponseHandler(
                request: request,
                id: receiptID,
                filter: filter,
                completion: completion
            )

            self.responseHandlers[identifier] = responseHandler

            // 5) Either start the request or enqueue it depending on the current active request count
            if self.isActiveRequestCountBelowMaximumLimit() {
                self.startRequest(request)
            } else {
                self.enqueueRequest(request)
            }
        }

        if let request = request {
            return RequestReceipt(request: request, receiptID: receiptID)
        }

        return nil
    }

    /**
        Cancels the request in the receipt by removing the response handler and cancelling the request if necessary.

        If the request is pending in the queue, it will be cancelled if no other response handlers are registered with
        the request. If the request is currently executing or is already completed, the response handler is removed and
        will not be called.

        - parameter requestReceipt: The request receipt to cancel.
    */
    open func cancelRequestForRequestReceipt(_ requestReceipt: RequestReceipt) {
        synchronizationQueue.sync {
            let identifier = ImageDownloader.identifierForURLRequest(requestReceipt.request.request!)
            guard let responseHandler = self.responseHandlers[identifier] else { return }

            if let index = responseHandler.operations.index(where: { $0.id == requestReceipt.receiptID }) {
                let operation = responseHandler.operations.remove(at: index)

                let response: Response<Image, NSError> = {
                    let URLRequest = requestReceipt.request.request!
                    let error: NSError = {
                        let failureReason = "ImageDownloader cancelled URL request: \(URLRequest.URLString)"
                        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
                        return NSError(domain: Alamofire.Error.Domain, code: NSURLErrorCancelled, userInfo: userInfo)
                    }()

                    return Response(request: URLRequest, response: nil, data: nil, result: .failure(error))
                }()

                DispatchQueue.main.async { operation.completion?(response) }
            }

            if responseHandler.operations.isEmpty && requestReceipt.request.task.state == .suspended {
                requestReceipt.request.cancel()
            }
        }
    }

    // MARK: - Internal - Thread-Safe Request Methods

    func safelyRemoveResponseHandlerWithIdentifier(_ identifier: String) -> ResponseHandler {
        var responseHandler: ResponseHandler!

        synchronizationQueue.sync {
            responseHandler = self.responseHandlers.removeValue(forKey: identifier)
        }

        return responseHandler
    }

    func safelyStartNextRequestIfNecessary() {
        synchronizationQueue.sync {
            guard self.isActiveRequestCountBelowMaximumLimit() else { return }

            while (!self.queuedRequests.isEmpty) {
                if let request = self.dequeueRequest(), request.task.state == .suspended {
                    self.startRequest(request)
                    break
                }
            }
        }
    }

    func safelyDecrementActiveRequestCount() {
        self.synchronizationQueue.sync {
            if self.activeRequestCount > 0 {
                self.activeRequestCount -= 1
            }
        }
    }

    // MARK: - Internal - Non Thread-Safe Request Methods

    func startRequest(_ request: Request) {
        request.resume()
        activeRequestCount += 1
    }

    func enqueueRequest(_ request: Request) {
        switch downloadPrioritization {
        case .fifo:
            queuedRequests.append(request)
        case .lifo:
            queuedRequests.insert(request, at: 0)
        }
    }

    func dequeueRequest() -> Request? {
        var request: Request?

        if !queuedRequests.isEmpty {
            request = queuedRequests.removeFirst()
        }

        return request
    }

    func isActiveRequestCountBelowMaximumLimit() -> Bool {
        return activeRequestCount < maximumActiveDownloads
    }

    static func identifierForURLRequest(_ URLRequest: URLRequestConvertible) -> String {
        return URLRequest.URLRequest.URLString
    }
}
