//
//  makeRequest.swift
//  Perfect-Authentication
//
//  Created by Jonathan Guthrie on 2017-01-18.
//	Branched from CouchDB Version


//import PerfectLib
//import PerfectHTTP

import Foundation


import AsyncHTTPClient
import NIOHTTP1
import NIO
import NIOFoundationCompat

extension OAuth2 {
    
    static let httpClient = HTTPClient(eventLoopGroupProvider: .createNew, configuration: .init(tlsConfiguration: nil, redirectConfiguration: nil, timeout: .init(), proxy: nil, ignoreUncleanSSLShutdown: true, decompression: .disabled))
//    static let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    
    static public func makeRequestNIO(_ method: NIOHTTP1.HTTPMethod,
                                      _ url: String,
                                      body: String = "",
                                      encoding: String = "JSON",
                                      bearerToken: String = "") throws -> EventLoopFuture<HTTPClient.Response> {
        
        var request = try HTTPClient.Request(url: url, method: method)
        request.headers.add(name: "user-agent", value: "adir-test-app")
        if !bearerToken.isEmpty {
            request.headers.add(name: "Authorization", value: "Bearer \(bearerToken)")
        }
        request.body = .string(body)
        
        switch method {
        case .POST:
            if encoding == "form" {
                request.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
            } else
            {
                request.headers.add(name: "Content-Type", value: "application/json")
            }
            request.headers.add(name: "Content-length", value: "\(request.body?.length ?? 0)")
        default:
            break
        }
        //            request.body = nil
        request.body = .string(body)
        
        return self.httpClient.execute(request: request)
        
    }
    
    static public func makeRequestNIO(
        _ method: NIOHTTP1.HTTPMethod,
        _ url: String,
        body: String = "",
        encoding: String = "JSON",
        bearerToken: String = "", complete: (([String:Any]) -> ())? = nil
    )  {
        do {
            var request = try HTTPClient.Request(url: url, method: method)
            request.headers.add(name: "user-agent", value: "adir-test-app")
            if !bearerToken.isEmpty {
                request.headers.add(name: "Authorization", value: "Bearer \(bearerToken)")
            }
            request.body = .string(body)
            
            switch method {
            case .POST:
                if encoding == "form" {
                    request.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
                } else {
                    request.headers.add(name: "Content-Type", value: "application/json")
                }
                request.headers.add(name: "Content-length", value: "\(request.body?.length ?? 0)")
            default:
                break
            }
//            request.body = nil
            request.body = .string(body)

            httpClient.execute(request: request).whenComplete { result in
                var data = [String:Any]()
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let response):
                    print(response.status)
           
                    if response.status == .ok {
   
                        #warning("Clean up the conversion or abstract away")
                        let bytes = response.body.flatMap { $0.getBytes(at: 0, length: $0.readableBytes )}
//                        let dataResponse = Data(bytes: bytes!)
//                        let decoder = JSONDecoder()
//                        print(String(data: dataResponse, encoding: .utf8))
//                        let test = try? decoder.decode(OAuth2Token.self, from: response.body!)
                        
                        let string = String(decoding: bytes!, as: UTF8.self)
                        let content = string
                        
                        
                        
                        do {
                            #warning("Clean up the conversion or abstract away")
                            if content.count > 0 {
                                if (content.starts(with: "[")) {
                                    let arr = try content.jsonDecode() as! [Any]
                                    data["response"] = arr
                                } else {
                                    data = try content.jsonDecode() as! [String : Any]
                                }
                            }
                            
                            
                            complete?(data)
                         
                        } catch {
                            complete?([:])
                  
                        }
                    } else {
                           complete?([:])
                        // handle remote error
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        
    }
    
    
    private static let waitTime = 5
    private static let semaphoreValue = 0
    private static var timeOut : DispatchTime{
        return DispatchTime.now() + .seconds(waitTime)
    }
    
    /// The function that triggers the specific interaction with a remote server
    /// Parameters:
    /// - method: The HTTP Method enum, i.e. .get, .post
    /// - route: The route required
    /// - body: The JSON formatted sring to sent to the server
    /// Response:
    /// (HTTPResponseStatus, "data" - [String:Any], "raw response" - [String:Any], HTTPHeaderParser)
    public func makeRequest(
        _ method: HTTPMethod,
        _ url: String,
        body: String = "",
        encoding: String = "JSON",
        bearerToken: String = ""
        //		) -> (Int, [String:Any], [String:Any], HTTPHeaderParser) {
    ) -> ([String:Any]) {
        
    
        var returnValue = [String:Any]()
        let semaphore = DispatchSemaphore(value: OAuth2.semaphoreValue)
        let newMethod  = method
        print(newMethod.rawValue)
        OAuth2.makeRequestNIO(newMethod, url, body: body, encoding: encoding, bearerToken: bearerToken) { result in
            returnValue = result
            print(result)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: OAuth2.timeOut)
        return returnValue
        
    }
}
