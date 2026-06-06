//
//  MockURLProtocol.swift
//  GhibliSwiftUIAppTests
//

import Foundation
@testable import GhibliSwiftUIApp

typealias MockURLResponseHandler = (URLRequest) throws -> (HTTPURLResponse, Data)

final class MockURLProtocol: URLProtocol {

    private static let lock = NSLock()
    nonisolated(unsafe) private static var requestHandler: MockURLResponseHandler?

    static func setHandler(_ handler: MockURLResponseHandler?) {
        lock.lock()
        defer { lock.unlock() }
        requestHandler = handler
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lock.lock()
        let handler = Self.requestHandler
        Self.lock.unlock()

        guard let handler else {
            client?.urlProtocol(
                self,
                didFailWithError: URLError(.unsupportedURL)
            )
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

extension URLSession {

    static var mock: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

enum MockURLSessionSupport {

    static func withService<T>(
        handler: @escaping MockURLResponseHandler,
        operation: (DefaultGhibliService) async throws -> T
    ) async throws -> T {
        MockURLProtocol.setHandler(handler)
        defer { MockURLProtocol.setHandler(nil) }

        let service = DefaultGhibliService(session: .mock)
        return try await operation(service)
    }
}
