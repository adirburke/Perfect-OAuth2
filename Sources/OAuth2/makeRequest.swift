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


import AsyncHTTPClient
import NIOHTTP1

extension OAuth2 {
    
    static let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    
    static public func makeRequestNIO(
        _ method: NIOHTTP1.HTTPMethod,
        _ url: String,
        body: String = "",
        encoding: String = "JSON",
        bearerToken: String = "", complete: (([String:Any]) -> ())? = nil
    )  {
        
        //        defer {
        //            try? httpClient.syncShutdown()
        //        }
        //
        do {
            
            var request = try HTTPClient.Request(url: url, method: method)
            request.headers.add(name: "Accept", value: "application/json")
            request.headers.add(name: "Cache-Control", value: "no-cache")
            if !bearerToken.isEmpty {
                request.headers.add(name: "Authorization", value: "Bearer \(bearerToken)")
            }
            
            switch method {
            case .POST:
                if encoding == "form" {
                    request.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
                } else
                {
                    request.headers.add(name: "Content-Type", value: "application/json")
                }
            default:
                break
            }
            
            request.body = .string(body)
            
            httpClient.execute(request: request).whenComplete { result in
                var data = [String:Any]()
                //                print(result)
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let response):
                    if response.status == .ok {
                        // handle response
                        //                        print(response.body)
                        let responseBody = response.body
                        let content = responseBody?.getString(at: 0, length: responseBody?.capacity ?? 0)
                        
                        print(content)
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
                    } else {
                        // handle remote error
                    }
                }
                
                //                try? httpClient.syncShutdown()
            }
            //            (url: url, method: method, headers: .init([
            //            "Accept", "application/json",
            //            "Cache-Control", "no-cache",
            //            "Authorization", "Bearer \(bearerToken)"
            //
            //            ]), body: body)
            
            
            
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
        
    
        
        OAuth2.makeRequestNIO(method.convert(), url, body: body, encoding: encoding, bearerToken: bearerToken) {
            
        }
//        let curlObject = CURL(url: url)
//        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Accept: application/json")
//        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Cache-Control: no-cache")
//        curlObject.setOption(CURLOPT_USERAGENT, s: "PerfectAPI2.0")
//
//        if !bearerToken.isEmpty {
//            curlObject.setOption(CURLOPT_HTTPHEADER, s: "Authorization: Bearer \(bearerToken)")
//        }
//
//        switch method {
//        case .post :
//            let byteArray = [UInt8](body.utf8)
//            curlObject.setOption(CURLOPT_POST, int: 1)
//            curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
//            curlObject.setOption(CURLOPT_COPYPOSTFIELDS, v: UnsafeMutablePointer(mutating: byteArray))
//
//            if encoding == "form" {
//                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/x-www-form-urlencoded")
//            } else {
//                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/json")
//            }
//
//        default: //.get :
//            curlObject.setOption(CURLOPT_HTTPGET, int: 1)
//        }
//
//
//        var header = [UInt8]()
//        var bodyIn = [UInt8]()
//
//        var code = 0
//        var data = [String: Any]()
//        var raw = [String: Any]()
//
//        var perf = curlObject.perform()
//        defer { curlObject.close() }
//
//        while perf.0 {
//            if let h = perf.2 {
//                header.append(contentsOf: h)
//            }
//            if let b = perf.3 {
//                bodyIn.append(contentsOf: b)
//            }
//            perf = curlObject.perform()
//        }
//        if let h = perf.2 {
//            header.append(contentsOf: h)
//        }
//        if let b = perf.3 {
//            bodyIn.append(contentsOf: b)
//        }
//        let _ = perf.1
//
//        // Parsing now:
//
//        // assember the header from a binary byte array to a string
//        //		let headerStr = String(bytes: header, encoding: String.Encoding.utf8)
//
//        // parse the header
//        //		let http = HTTPHeaderParser(header:headerStr!)
//
//        // assamble the body from a binary byte array to a string
//        let content = String(bytes:bodyIn, encoding:String.Encoding.utf8)
//
//        // prepare the failsafe content.
//        //		raw = ["status": http.status, "header": headerStr!, "body": content!]
//
//        // parse the body data into a json convertible
//        do {
//            if (content?.count)! > 0 {
//                if (content?.starts(with: "["))! {
//                    let arr = try content?.jsonDecode() as! [Any]
//                    data["response"] = arr
//                } else {
//                    data = try content?.jsonDecode() as! [String : Any]
//                }
//            }
//            return data
//            //			return (http.code, data, raw, http)
//        } catch {
//            return [:]
//            //			return (http.code, [:], raw, http)
//        }
    }
}


extension PerfectHTTP.HTTPMethod {
    func convert() -> NIOHTTP1.HTTPMethod {
        return NIOHTTP1.HTTPMethod(rawValue: self.description)
    }
}
