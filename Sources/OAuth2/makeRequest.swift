//
//  makeRequest.swift
//  Perfect-Authentication
//
//  Created by Jonathan Guthrie on 2017-01-18.
//	Branched from CouchDB Version


import PerfectLib
import PerfectCURL
import cURL
import PerfectHTTP

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
    
    public func makeRequestAsync(
        _ method: PerfectHTTP.HTTPMethod,
        _ url: String,
        body: String = "",
        encoding: String = "JSON",
        bearerToken: String = "", complete: (([String:Any]) -> ())? = nil
        //        ) -> (Int, [String:Any], [String:Any], HTTPHeaderParser) {
    ) {
        
        let curlObject = CURL(url: url)
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Accept: application/json")
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Cache-Control: no-cache")
        curlObject.setOption(CURLOPT_USERAGENT, s: "PerfectAPI2.0")
        
        if !bearerToken.isEmpty {
            curlObject.setOption(CURLOPT_HTTPHEADER, s: "Authorization: Bearer \(bearerToken)")
        }
        
        switch method {
        case .post :
            let byteArray = [UInt8](body.utf8)
            curlObject.setOption(CURLOPT_POST, int: 1)
            curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
            curlObject.setOption(CURLOPT_COPYPOSTFIELDS, v: UnsafeMutablePointer(mutating: byteArray))
            
            if encoding == "form" {
                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/x-www-form-urlencoded")
            } else {
                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/json")
            }
            
        default: //.get :
            curlObject.setOption(CURLOPT_HTTPGET, int: 1)
        }
        
        curlObject.perform { (code, header, bodyIn) in
            var data = [String:Any]()
            // Parsing now:
            
            // assember the header from a binary byte array to a string
            //        let headerStr = String(bytes: header, encoding: String.Encoding.utf8)
            
            // parse the header
            //        let http = HTTPHeaderParser(header:headerStr!)
            
            // assamble the body from a binary byte array to a string
            let content = String(bytes:bodyIn, encoding:String.Encoding.utf8)
            
            // prepare the failsafe content.
            //        raw = ["status": http.status, "header": headerStr!, "body": content!]
            
            // parse the body data into a json convertible
            do {
                if (content?.count)! > 0 {
                    if (content?.starts(with: "["))! {
                        let arr = try content?.jsonDecode() as! [Any]
                        data["response"] = arr
                    } else {
                        data = try content?.jsonDecode() as! [String : Any]
                    }
                }
                complete?(data)
                //            return (http.code, data, raw, http)
            } catch {
                complete?([:])
                //            return (http.code, [:], raw, http)
            }
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
        _ method: PerfectHTTP.HTTPMethod,
        _ url: String,
        body: String = "",
        encoding: String = "JSON",
        bearerToken: String = ""
        //		) -> (Int, [String:Any], [String:Any], HTTPHeaderParser) {
    ) -> ([String:Any]) {
        
    
        var returnValue = [String:Any]()
        let semaphore = DispatchSemaphore(value: OAuth2.semaphoreValue)
        let newMethod  = method.convert()
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


extension PerfectHTTP.HTTPMethod {
    func convert() -> NIOHTTP1.HTTPMethod {
        print(self.description)
        
        
        switch self {
    
        case .options:
            return .OPTIONS
        case .get:
            return .GET
        case .head:
            return .HEAD
        case .post:
            return .POST
        case .patch:
            return .PATCH
        case .put:
            return .PUT
        case .delete:
            return .DELETE
        case .trace:
            return .TRACE
        case .connect:
            return .CONNECT
        case .custom(let s):
            return NIOHTTP1.HTTPMethod(rawValue: s)
        @unknown default:
            return NIOHTTP1.HTTPMethod(rawValue: self.description)
        }
        
    }
}
