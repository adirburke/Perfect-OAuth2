//
//  ServiceAccount.swift
//  OAuth2
//
//  Created by Adir Burke on 2/12/20.
//

import Foundation
import Core
import NIO
import AsyncHTTPClient

public struct ServiceAccountClient  {
    public let eventLoop : EventLoopGroup
    public let client : GoogleCloudGmailClient
    
    public init(projectId: String, credentialsFile: String, eventLoop: EventLoopGroup, httpClient : HTTPClient, emailAccount: String) throws {
        let cred = try GoogleCloudCredentialsConfiguration(projectId: projectId, credentialsFile: credentialsFile)
        let config = GoogleCloudGmailConfiguration(scope: [.FullAccess], serviceAccount: "AdirServer", project: projectId, subscription: emailAccount)
        self.client = try GoogleCloudGmailClient(credentials: cred, gmailConfig: config, httpClient: httpClient, eventLoop: eventLoop.next())
        self.eventLoop = eventLoop
    }
    
}


