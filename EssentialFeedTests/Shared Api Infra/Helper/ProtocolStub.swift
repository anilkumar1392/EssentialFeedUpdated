//
//  ProtocolStub.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 21/06/22.
//

import Foundation

class URLProtocolStub: URLProtocol {
    // var receivedUrls = [URL]()
    // private static var stubs = [URL: Stub]()
    private static var stubs: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        // stubs[url] = Stub(data: data, response: response, error: error)
        stubs = Stub(data: data, response: response, error: error)
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stubs = nil
        requestObserver = nil
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        // guard let url = request.url else { return false }
        // return URLProtocolStub.stubs[url] != nil
        
        requestObserver?(request)
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        /*
        guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
            return
        } */
        
        if let data = URLProtocolStub.stubs?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stubs?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stubs?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
    }
}
