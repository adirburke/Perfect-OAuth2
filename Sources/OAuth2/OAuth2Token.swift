//
//  OAuth2Token.swift
//  Based on Turnstile's oAuth2
//
//  Created by Edward Jiang on 8/13/16.
//
//	Modified by Jonathan Guthrie 18 Jan 2017
//	Intended to work more independantly of Turnstile


import Foundation

/**
Represents an OAuth 2 Token
*/


public class OAuth2Token : Codable {
	public let accessToken: String
	public let refreshToken: String?
	public let expiration: Date?
	public let tokenType: String?
	public let instanceURL: String?
	public let idURL: String?
	public let scope: [String]?
    public let webToken: [String: String]?

    
    enum CodingKeys : String, CodingKey {
        case accessToken = "access_token"
      case refreshToken = "refresh_token"
      case expiration = "expires_in"
      case tokenType  = "token_type"
      case instanceURL = "instance_url"
      case idURL = "id"
      case scope = "scope"
      case webToken = "id_token"
        
    }
    
    
    
	public init(accessToken: String, tokenType: String, instanceURL: String? = nil, idURL: String? = nil, expiresIn: Int? = nil, refreshToken: String? = nil, scope: [String]? = nil, webToken: [String: String]? = nil) {
		self.accessToken = accessToken
		self.tokenType = tokenType
		self.refreshToken = refreshToken

        self.expiration = expiresIn == nil ? nil : Date().addingTimeInterval(TimeInterval(expiresIn!))
		self.scope = scope
        self.webToken = webToken
		self.instanceURL = instanceURL
		self.idURL = idURL
	}
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try values.decode(String.self, forKey: .accessToken)
        self.tokenType = try? values.decode(String.self, forKey: .tokenType)
        self.refreshToken = try? values.decode(String.self, forKey: .refreshToken)
        let expiresIn = try? values.decode(Int.self, forKey: .expiration)
        self.expiration = Date().addingTimeInterval(TimeInterval(expiresIn ?? 3660))
        self.scope = try? values.decode(String.self, forKey: .scope).components(separatedBy: " ")
        let json = try? values.decode(String.self, forKey: .webToken)
        self.webToken = OAuth2Token.decodeWebToken(string: json)
        self.instanceURL = try? values.decode(String.self, forKey: .instanceURL)
        self.idURL = try? values.decode(String.self, forKey: .idURL)
        
    }

    
	public convenience init?(json: [String: Any]) {
		guard let accessToken = json["access_token"] as? String else {
			return nil
		}
		var tokenType = "Bearer"
		if let tt = json["token_type"] {
			tokenType = tt as! String
		}
		let instanceURL: String? = json["instance_url"] as? String
		let idURL: String? = json["id"] as? String

		let expiresIn = json["expires_in"] as? Int
		let refreshToken: String? = json["refresh_token"] as? String
		let scope = (json["scope"] as? String)?.components(separatedBy: " ")
        let webToken = OAuth2Token.decodeWebToken(json: json)
		self.init(accessToken: accessToken, tokenType: tokenType, instanceURL: instanceURL, idURL: idURL, expiresIn: expiresIn, refreshToken: refreshToken, scope: scope, webToken: webToken)
	}
    
    public init(previousToken : OAuth2Token, refreshToken : String) {
        self.accessToken = previousToken.accessToken
        self.tokenType = previousToken.tokenType
        self.refreshToken = refreshToken
        self.expiration = previousToken.expiration
        self.scope = previousToken.scope
        self.webToken = previousToken.webToken
        self.instanceURL = previousToken.instanceURL
        self.idURL = previousToken.idURL
    }
    
    private static func decodeWebToken(string: String?) -> [String: String]? {
        var webToken: [String: Any]?
        var returnToken : [String:String]?

        /// Decode Google Json web token
        if let id = string {
            let arr = id.components(separatedBy: ".")
            var content = arr[1] as String
            if content.count % 4 != 0 {
                let padlen = 4 - content.count % 4
                content += String(repeating: "=", count: padlen)
            }

            if let data = Data(base64Encoded: content, options: []),
                let str = String(data: data, encoding: String.Encoding.utf8) {
                do {
                    webToken = try str.jsonDecode() as? [String : Any]
                    for (f,v) in webToken! {
                        returnToken?[f] = String(describing: v)
                    }
                } catch {
                }
            }
        }
        

        return returnToken
    }

	private static func decodeWebToken(json: [String: Any]) -> [String: String]? {
		var webToken: [String: Any]?
        var returnToken : [String:String]?

		/// Decode Google Json web token
		if let id = json["id_token"] as? String {
			let arr = id.components(separatedBy: ".")

			var content = arr[1] as String
			if content.count % 4 != 0 {
				let padlen = 4 - content.count % 4
				content += String(repeating: "=", count: padlen)
			}

			if let data = Data(base64Encoded: content, options: []),
				let str = String(data: data, encoding: String.Encoding.utf8) {
				do {
					webToken = try str.jsonDecode() as? [String : Any]
                    for (f,v) in webToken! {
                        returnToken?[f] = String(describing: v)
                    }
				} catch {
				}
			}
		}

		return returnToken
	}
    

    
    
}

extension OAuth2Token {

}
