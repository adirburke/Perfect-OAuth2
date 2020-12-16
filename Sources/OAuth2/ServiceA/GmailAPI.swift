// This is Generated Code


import Foundation
import AsyncHTTPClient
import NIO
import Core
import NIOFoundationCompat
import NIOHTTP1
import CodableWrappers


public struct GoogleCloudDataResponse: GoogleCloudModel {
    public var data: Data?
}

public struct PlaceHolderObject : GoogleCloudModel {}



public enum GoogleCloudGmailScope : GoogleCloudAPIScope {
   public var value : String {
      switch self {
      case .GmailSettingsSharing: return "https://www.googleapis.com/auth/gmail.settings.sharing"
      case .GmailSend: return "https://www.googleapis.com/auth/gmail.send"
      case .GmailMetadata: return "https://www.googleapis.com/auth/gmail.metadata"
      case .FullAccess: return "https://mail.google.com/"
      case .GmailInsert: return "https://www.googleapis.com/auth/gmail.insert"
      case .GmailModify: return "https://www.googleapis.com/auth/gmail.modify"
      case .GmailLabels: return "https://www.googleapis.com/auth/gmail.labels"
      case .GmailCompose: return "https://www.googleapis.com/auth/gmail.compose"
      case .GmailSettingsBasic: return "https://www.googleapis.com/auth/gmail.settings.basic"
      case .GmailReadonly: return "https://www.googleapis.com/auth/gmail.readonly"
      }
   }

   case GmailSettingsSharing // Manage your sensitive mail settings, including who can manage your mail
   case GmailSend // Send email on your behalf
   case GmailMetadata // View your email message metadata such as labels and headers, but not the email body
   case FullAccess // Read, compose, send, and permanently delete all your email from Gmail
   case GmailInsert // Insert mail into your mailbox
   case GmailModify // View and modify but not delete your email
   case GmailLabels // Manage mailbox labels
   case GmailCompose // Manage drafts and send emails
   case GmailSettingsBasic // Manage your basic mail settings
   case GmailReadonly // View your email messages and settings
}


public struct GoogleCloudGmailConfiguration : GoogleCloudAPIConfiguration {
   public var scope : [GoogleCloudAPIScope]
   public var serviceAccount: String
   public var project: String?
   public var subscription: String?

   public init(scope: [GoogleCloudGmailScope], serviceAccount : String, project: String?, subscription: String?) {
      self.scope = scope
      self.serviceAccount = serviceAccount
      self.project = project
      self.subscription = subscription
   }
}


public final class GoogleCloudGmailRequest : GoogleCloudAPIRequest {
   public var refreshableToken: OAuthRefreshable
   public var project: String
   public var httpClient: HTTPClient
   public var responseDecoder: JSONDecoder = JSONDecoder()
   public var currentToken: OAuthAccessToken?
   public var tokenCreatedTime: Date?
   private let eventLoop : EventLoop

   init(httpClient: HTTPClient, eventLoop: EventLoop, oauth: OAuthRefreshable, project: String) {
      self.refreshableToken = oauth
      self.project = project
      self.httpClient = httpClient
      self.eventLoop = eventLoop
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      self.responseDecoder.dateDecodingStrategy = .formatted(dateFormatter)
   }
   public func send<GCM: GoogleCloudModel>(method: HTTPMethod, headers: HTTPHeaders = [:], path: String, query: String = "", body: HTTPClient.Body = .data(Data())) -> EventLoopFuture<GCM> {
      return withToken { token in
         return self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken).flatMap { response in
            do {
               if GCM.self is GoogleCloudDataResponse.Type {
                  let model = GoogleCloudDataResponse(data: response) as! GCM
                  return self.eventLoop.makeSucceededFuture(model)
               } else {
                  let model = try self.responseDecoder.decode(GCM.self, from: response)
                  return self.eventLoop.makeSucceededFuture(model)
               }
            } catch {
               return self.eventLoop.makeFailedFuture(error)
            }
         }
      }
   }

   private func _send(method: HTTPMethod, headers: HTTPHeaders, path: String, query: String, body: HTTPClient.Body, accessToken: String) -> EventLoopFuture<Data> {
      var _headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)",
                        "Content-Type": "application/json"]
      headers.forEach { _headers.replaceOrAdd(name: $0.name, value: $0.value) }
      do {
         let request = try HTTPClient.Request(url: "\(path)?\(query)", method: method, headers: _headers, body: body)

         return httpClient.execute(request: request, eventLoop: .delegate(on: self.eventLoop)).flatMap { response in
            // If we get a 204 for example in the delete api call just return an empty body to decode.
            // https://cloud.google.com/s/results/?q=If+successful%2C+this+method+returns+an+empty+response+body.&p=%2Fstorage%2Fdocs%2F
            if response.status == .noContent {
               return self.eventLoop.makeSucceededFuture("{}".data(using: .utf8)!)
            }
            guard var byteBuffer = response.body else {
               fatalError("Response body from Google is missing! This should never happen.")
            }
            let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!
//            print(String(data: responseData, encoding: .utf8))
               guard (200...299).contains(response.status.code) else {
                print(String(data: responseData, encoding: .utf8))
               let error: Error
               if let jsonError = try? self.responseDecoder.decode(GoogleCloudAPIErrorMain.self, from: responseData) {
                  error = jsonError
               } else {
                  let body = response.body?.getString(at: response.body?.readerIndex ?? 0, length: response.body?.readableBytes ?? 0) ?? ""
                  error = GoogleCloudAPIErrorMain(error: GoogleCloudAPIErrorBody(errors: [], code: Int(response.status.code), message: body))
               }
               return self.eventLoop.makeFailedFuture(error)
            }
            return self.eventLoop.makeSucceededFuture(responseData)
         }
      } catch {
         return self.eventLoop.makeFailedFuture(error)
      }
   }
}
public final class GoogleCloudGmailUsersAPI : GmailUsersAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Gets the current user's Gmail profile.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func getProfile(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailProfile> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/profile", query: queryParams)
   }
   /// Stop receiving push notifications for the given user mailbox.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func stop(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .POST, path: "\(endpoint)\(userId)/stop", query: queryParams)
   }
   /// Set up or update a push notification watch on the given user mailbox.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func watch(userId : String, body : GoogleCloudGmailWatchRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailWatchResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/watch", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
}

public protocol GmailUsersAPIProtocol  {
   /// Gets the current user's Gmail profile.
   func getProfile(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailProfile>
   /// Stop receiving push notifications for the given user mailbox.
   func stop(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Set up or update a push notification watch on the given user mailbox.
   func watch(userId : String, body : GoogleCloudGmailWatchRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailWatchResponse>
}
extension GmailUsersAPIProtocol   {
      public func getProfile(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailProfile> {
      getProfile(userId: userId,  queryParameters: queryParameters)
   }

      public func stop(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      stop(userId: userId,  queryParameters: queryParameters)
   }

      public func watch(userId : String, body : GoogleCloudGmailWatchRequest, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailWatchResponse> {
      watch(userId: userId, body: body, queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailDraftsAPI : GmailDraftsAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Creates a new draft with the DRAFT label.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func create(userId : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDraft> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/drafts", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Immediately and permanently deletes the specified draft. Does not simply trash it.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the draft to delete.

   public func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/drafts/\(id)", query: queryParams)
   }
   /// Gets the specified draft.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the draft to retrieve.

   public func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDraft> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/drafts/\(id)", query: queryParams)
   }
   /// Lists the drafts in the user's mailbox.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListDraftsResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/drafts", query: queryParams)
   }
   /// Sends the specified, existing draft to the recipients in the To, Cc, and Bcc headers.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func send(userId : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/drafts/send", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Replaces a draft's content.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the draft to update.

   public func update(userId : String, id : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDraft> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PUT, path: "\(endpoint)\(userId)/drafts/\(id)", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
}

public protocol GmailDraftsAPIProtocol  {
   /// Creates a new draft with the DRAFT label.
   func create(userId : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDraft>
   /// Immediately and permanently deletes the specified draft. Does not simply trash it.
   func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets the specified draft.
   func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDraft>
   /// Lists the drafts in the user's mailbox.
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListDraftsResponse>
   /// Sends the specified, existing draft to the recipients in the To, Cc, and Bcc headers.
   func send(userId : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage>
   /// Replaces a draft's content.
   func update(userId : String, id : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDraft>
}
extension GmailDraftsAPIProtocol   {
      public func create(userId : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailDraft> {
      create(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func delete(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func get(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailDraft> {
      get(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListDraftsResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

      public func send(userId : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessage> {
      send(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func update(userId : String, id : String, body : GoogleCloudGmailDraft, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailDraft> {
      update(userId: userId,id: id, body: body, queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailHistoryAPI : GmailHistoryAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Lists the history of all changes to the given mailbox. History results are returned in chronological order (increasing historyId).
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListHistoryResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/history", query: queryParams)
   }
}

public protocol GmailHistoryAPIProtocol  {
   /// Lists the history of all changes to the given mailbox. History results are returned in chronological order (increasing historyId).
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListHistoryResponse>
}
extension GmailHistoryAPIProtocol   {
      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListHistoryResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailLabelsAPI : GmailLabelsAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Creates a new label.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func create(userId : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLabel> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/labels", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Immediately and permanently deletes the specified label and removes it from any messages and threads that it is applied to.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the label to delete.

   public func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/labels/\(id)", query: queryParams)
   }
   /// Gets the specified label.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the label to retrieve.

   public func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLabel> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/labels/\(id)", query: queryParams)
   }
   /// Lists all labels in the user's mailbox.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListLabelsResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/labels", query: queryParams)
   }
   /// Updates the specified label. This method supports patch semantics.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the label to update.

   public func patch(userId : String, id : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLabel> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PATCH, path: "\(endpoint)\(userId)/labels/\(id)", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Updates the specified label.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the label to update.

   public func update(userId : String, id : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLabel> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PUT, path: "\(endpoint)\(userId)/labels/\(id)", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
}

public protocol GmailLabelsAPIProtocol  {
   /// Creates a new label.
   func create(userId : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLabel>
   /// Immediately and permanently deletes the specified label and removes it from any messages and threads that it is applied to.
   func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets the specified label.
   func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLabel>
   /// Lists all labels in the user's mailbox.
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListLabelsResponse>
   /// Updates the specified label. This method supports patch semantics.
   func patch(userId : String, id : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLabel>
   /// Updates the specified label.
   func update(userId : String, id : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLabel>
}
extension GmailLabelsAPIProtocol   {
      public func create(userId : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailLabel> {
      create(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func delete(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func get(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailLabel> {
      get(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListLabelsResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

      public func patch(userId : String, id : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailLabel> {
      patch(userId: userId,id: id, body: body, queryParameters: queryParameters)
   }

      public func update(userId : String, id : String, body : GoogleCloudGmailLabel, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailLabel> {
      update(userId: userId,id: id, body: body, queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailMessagesAPI : GmailMessagesAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Deletes many messages by message ID. Provides no guarantees that messages were not already deleted or even existed at all.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

    public func batchDelete(userId : String, body : GoogleCloudGmailBatchDeleteMessagesRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        do {
            let data = try JSONEncoder().encode(body)
            return request.send(method: .POST, path: "\(endpoint)\(userId)/messages/batchDelete", query: queryParams, body: .data(data))
        } catch {
            return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
        }
    }
   /// Modifies the labels on the specified messages.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func batchModify(userId : String, body : GoogleCloudGmailBatchModifyMessagesRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/messages/batchModify", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Immediately and permanently deletes the specified message. This operation cannot be undone. Prefer messages.trash instead.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the message to delete.

   public func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/messages/\(id)", query: queryParams)
   }
   /// Gets the specified message.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the message to retrieve.

   public func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/messages/\(id)", query: queryParams)
   }
   /// Imports a message into only this user's mailbox, with standard email delivery scanning and classification similar to receiving via SMTP. Does not send a message.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func `import`(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/messages/import", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Directly inserts a message into only this user's mailbox similar to IMAP APPEND, bypassing most scanning and classification. Does not send a message.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func insert(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/messages", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Lists the messages in the user's mailbox.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListMessagesResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
        queryParams = queryParameters.queryParameters.stringByEncodingURL
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/messages", query: queryParams)
   }
   /// Modifies the labels on the specified message.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the message to modify.

   public func modify(userId : String, id : String, body : GoogleCloudGmailModifyMessageRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/messages/\(id)/modify", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Sends the specified message to the recipients in the To, Cc, and Bcc headers.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func send(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/messages/send", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Moves the specified message to the trash.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the message to Trash.

   public func trash(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .POST, path: "\(endpoint)\(userId)/messages/\(id)/trash", query: queryParams)
   }
   /// Removes the specified message from the trash.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the message to remove from Trash.

   public func untrash(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .POST, path: "\(endpoint)\(userId)/messages/\(id)/untrash", query: queryParams)
   }
}

public protocol GmailMessagesAPIProtocol  {
   /// Deletes many messages by message ID. Provides no guarantees that messages were not already deleted or even existed at all.
   func batchDelete(userId : String, body : GoogleCloudGmailBatchDeleteMessagesRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Modifies the labels on the specified messages.
   func batchModify(userId : String, body : GoogleCloudGmailBatchModifyMessagesRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Immediately and permanently deletes the specified message. This operation cannot be undone. Prefer messages.trash instead.
   func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets the specified message.
   func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage>
   /// Imports a message into only this user's mailbox, with standard email delivery scanning and classification similar to receiving via SMTP. Does not send a message.
   func `import`(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage>
   /// Directly inserts a message into only this user's mailbox similar to IMAP APPEND, bypassing most scanning and classification. Does not send a message.
   func insert(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage>
   /// Lists the messages in the user's mailbox.
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListMessagesResponse>
   /// Modifies the labels on the specified message.
   func modify(userId : String, id : String, body : GoogleCloudGmailModifyMessageRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage>
   /// Sends the specified message to the recipients in the To, Cc, and Bcc headers.
   func send(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage>
   /// Moves the specified message to the trash.
   func trash(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage>
   /// Removes the specified message from the trash.
   func untrash(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessage>
}
extension GmailMessagesAPIProtocol   {
      public func batchDelete(userId : String, body : GoogleCloudGmailBatchDeleteMessagesRequest, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      batchDelete(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func batchModify(userId : String, body : GoogleCloudGmailBatchModifyMessagesRequest, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      batchModify(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func delete(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func get(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessage> {
      get(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func `import`(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessage> {
      `import`(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func insert(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessage> {
      insert(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListMessagesResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

      public func modify(userId : String, id : String, body : GoogleCloudGmailModifyMessageRequest, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessage> {
      modify(userId: userId,id: id, body: body, queryParameters: queryParameters)
   }

      public func send(userId : String, body : GoogleCloudGmailMessage, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessage> {
      send(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func trash(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessage> {
      trash(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func untrash(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessage> {
      untrash(userId: userId,id: id,  queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailSettingsAPI : GmailSettingsAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Gets the auto-forwarding setting for the specified account.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func getAutoForwarding(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailAutoForwarding> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/autoForwarding", query: queryParams)
   }
   /// Gets IMAP settings.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func getImap(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailImapSettings> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/imap", query: queryParams)
   }
   /// Gets language settings.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func getLanguage(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLanguageSettings> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/language", query: queryParams)
   }
   /// Gets POP settings.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func getPop(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailPopSettings> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/pop", query: queryParams)
   }
   /// Gets vacation responder settings.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func getVacation(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailVacationSettings> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/vacation", query: queryParams)
   }
   /// Updates the auto-forwarding setting for the specified account. A verified forwarding address must be specified when auto-forwarding is enabled.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func updateAutoForwarding(userId : String, body : GoogleCloudGmailAutoForwarding, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailAutoForwarding> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PUT, path: "\(endpoint)\(userId)/settings/autoForwarding", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Updates IMAP settings.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func updateImap(userId : String, body : GoogleCloudGmailImapSettings, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailImapSettings> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PUT, path: "\(endpoint)\(userId)/settings/imap", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Updates language settings.  If successful, the return object contains the displayLanguage that was saved for the user, which may differ from the value passed into the request. This is because the requested displayLanguage may not be directly supported by Gmail but have a close variant that is, and so the variant may be chosen and saved instead.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func updateLanguage(userId : String, body : GoogleCloudGmailLanguageSettings, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLanguageSettings> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PUT, path: "\(endpoint)\(userId)/settings/language", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Updates POP settings.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func updatePop(userId : String, body : GoogleCloudGmailPopSettings, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailPopSettings> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PUT, path: "\(endpoint)\(userId)/settings/pop", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Updates vacation responder settings.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func updateVacation(userId : String, body : GoogleCloudGmailVacationSettings, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailVacationSettings> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PUT, path: "\(endpoint)\(userId)/settings/vacation", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
}

public protocol GmailSettingsAPIProtocol  {
   /// Gets the auto-forwarding setting for the specified account.
   func getAutoForwarding(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailAutoForwarding>
   /// Gets IMAP settings.
   func getImap(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailImapSettings>
   /// Gets language settings.
   func getLanguage(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLanguageSettings>
   /// Gets POP settings.
   func getPop(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailPopSettings>
   /// Gets vacation responder settings.
   func getVacation(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailVacationSettings>
   /// Updates the auto-forwarding setting for the specified account. A verified forwarding address must be specified when auto-forwarding is enabled.  This method is only available to service account clients that have been delegated domain-wide authority.
   func updateAutoForwarding(userId : String, body : GoogleCloudGmailAutoForwarding, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailAutoForwarding>
   /// Updates IMAP settings.
   func updateImap(userId : String, body : GoogleCloudGmailImapSettings, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailImapSettings>
   /// Updates language settings.  If successful, the return object contains the displayLanguage that was saved for the user, which may differ from the value passed into the request. This is because the requested displayLanguage may not be directly supported by Gmail but have a close variant that is, and so the variant may be chosen and saved instead.
   func updateLanguage(userId : String, body : GoogleCloudGmailLanguageSettings, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailLanguageSettings>
   /// Updates POP settings.
   func updatePop(userId : String, body : GoogleCloudGmailPopSettings, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailPopSettings>
   /// Updates vacation responder settings.
   func updateVacation(userId : String, body : GoogleCloudGmailVacationSettings, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailVacationSettings>
}
extension GmailSettingsAPIProtocol   {
      public func getAutoForwarding(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailAutoForwarding> {
      getAutoForwarding(userId: userId,  queryParameters: queryParameters)
   }

      public func getImap(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailImapSettings> {
      getImap(userId: userId,  queryParameters: queryParameters)
   }

      public func getLanguage(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailLanguageSettings> {
      getLanguage(userId: userId,  queryParameters: queryParameters)
   }

      public func getPop(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailPopSettings> {
      getPop(userId: userId,  queryParameters: queryParameters)
   }

      public func getVacation(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailVacationSettings> {
      getVacation(userId: userId,  queryParameters: queryParameters)
   }

      public func updateAutoForwarding(userId : String, body : GoogleCloudGmailAutoForwarding, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailAutoForwarding> {
      updateAutoForwarding(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func updateImap(userId : String, body : GoogleCloudGmailImapSettings, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailImapSettings> {
      updateImap(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func updateLanguage(userId : String, body : GoogleCloudGmailLanguageSettings, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailLanguageSettings> {
      updateLanguage(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func updatePop(userId : String, body : GoogleCloudGmailPopSettings, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailPopSettings> {
      updatePop(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func updateVacation(userId : String, body : GoogleCloudGmailVacationSettings, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailVacationSettings> {
      updateVacation(userId: userId, body: body, queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailThreadsAPI : GmailThreadsAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Immediately and permanently deletes the specified thread. This operation cannot be undone. Prefer threads.trash instead.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: ID of the Thread to delete.

   public func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/threads/\(id)", query: queryParams)
   }
   /// Gets the specified thread.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the thread to retrieve.

   public func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailThread> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/threads/\(id)", query: queryParams)
   }
   /// Lists the threads in the user's mailbox.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListThreadsResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/threads", query: queryParams)
   }
   /// Modifies the labels applied to the thread. This applies to all messages in the thread.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the thread to modify.

   public func modify(userId : String, id : String, body : GoogleCloudGmailModifyThreadRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailThread> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/threads/\(id)/modify", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Moves the specified thread to the trash.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the thread to Trash.

   public func trash(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailThread> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .POST, path: "\(endpoint)\(userId)/threads/\(id)/trash", query: queryParams)
   }
   /// Removes the specified thread from the trash.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter id: The ID of the thread to remove from Trash.

   public func untrash(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailThread> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .POST, path: "\(endpoint)\(userId)/threads/\(id)/untrash", query: queryParams)
   }
}

public protocol GmailThreadsAPIProtocol  {
   /// Immediately and permanently deletes the specified thread. This operation cannot be undone. Prefer threads.trash instead.
   func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets the specified thread.
   func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailThread>
   /// Lists the threads in the user's mailbox.
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListThreadsResponse>
   /// Modifies the labels applied to the thread. This applies to all messages in the thread.
   func modify(userId : String, id : String, body : GoogleCloudGmailModifyThreadRequest, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailThread>
   /// Moves the specified thread to the trash.
   func trash(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailThread>
   /// Removes the specified thread from the trash.
   func untrash(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailThread>
}
extension GmailThreadsAPIProtocol   {
      public func delete(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func get(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailThread> {
      get(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListThreadsResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

      public func modify(userId : String, id : String, body : GoogleCloudGmailModifyThreadRequest, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailThread> {
      modify(userId: userId,id: id, body: body, queryParameters: queryParameters)
   }

      public func trash(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailThread> {
      trash(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func untrash(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailThread> {
      untrash(userId: userId,id: id,  queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailAttachmentsAPI : GmailAttachmentsAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Gets the specified message attachment.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter messageId: The ID of the message containing the attachment.
/// - Parameter id: The ID of the attachment.

   public func get(userId : String, messageId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessagePartBody> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/messages/\(messageId)/attachments/\(id)", query: queryParams)
   }
}

public protocol GmailAttachmentsAPIProtocol  {
   /// Gets the specified message attachment.
   func get(userId : String, messageId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailMessagePartBody>
}
extension GmailAttachmentsAPIProtocol   {
      public func get(userId : String, messageId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailMessagePartBody> {
      get(userId: userId,messageId: messageId,id: id,  queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailDelegatesAPI : GmailDelegatesAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Adds a delegate with its verification status set directly to accepted, without sending any verification email. The delegate user must be a member of the same G Suite organization as the delegator user.  Gmail imposes limitations on the number of delegates and delegators each user in a G Suite organization can have. These limits depend on your organization, but in general each user can have up to 25 delegates and up to 10 delegators.  Note that a delegate user must be referred to by their primary email address, and not an email alias.  Also note that when a new delegate is created, there may be up to a one minute delay before the new delegate is available for use.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func create(userId : String, body : GoogleCloudGmailDelegate, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDelegate> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/settings/delegates", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Removes the specified delegate (which can be of any verification status), and revokes any verification that may have been required for using it.  Note that a delegate user must be referred to by their primary email address, and not an email alias.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter delegateEmail: The email address of the user to be removed as a delegate.

   public func delete(userId : String, delegateEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/settings/delegates/\(delegateEmail)", query: queryParams)
   }
   /// Gets the specified delegate.  Note that a delegate user must be referred to by their primary email address, and not an email alias.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter delegateEmail: The email address of the user whose delegate relationship is to be retrieved.

   public func get(userId : String, delegateEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDelegate> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/delegates/\(delegateEmail)", query: queryParams)
   }
   /// Lists the delegates for the specified account.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListDelegatesResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/delegates", query: queryParams)
   }
}

public protocol GmailDelegatesAPIProtocol  {
   /// Adds a delegate with its verification status set directly to accepted, without sending any verification email. The delegate user must be a member of the same G Suite organization as the delegator user.  Gmail imposes limitations on the number of delegates and delegators each user in a G Suite organization can have. These limits depend on your organization, but in general each user can have up to 25 delegates and up to 10 delegators.  Note that a delegate user must be referred to by their primary email address, and not an email alias.  Also note that when a new delegate is created, there may be up to a one minute delay before the new delegate is available for use.  This method is only available to service account clients that have been delegated domain-wide authority.
   func create(userId : String, body : GoogleCloudGmailDelegate, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDelegate>
   /// Removes the specified delegate (which can be of any verification status), and revokes any verification that may have been required for using it.  Note that a delegate user must be referred to by their primary email address, and not an email alias.  This method is only available to service account clients that have been delegated domain-wide authority.
   func delete(userId : String, delegateEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets the specified delegate.  Note that a delegate user must be referred to by their primary email address, and not an email alias.  This method is only available to service account clients that have been delegated domain-wide authority.
   func get(userId : String, delegateEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailDelegate>
   /// Lists the delegates for the specified account.  This method is only available to service account clients that have been delegated domain-wide authority.
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListDelegatesResponse>
}
extension GmailDelegatesAPIProtocol   {
      public func create(userId : String, body : GoogleCloudGmailDelegate, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailDelegate> {
      create(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func delete(userId : String, delegateEmail : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,delegateEmail: delegateEmail,  queryParameters: queryParameters)
   }

      public func get(userId : String, delegateEmail : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailDelegate> {
      get(userId: userId,delegateEmail: delegateEmail,  queryParameters: queryParameters)
   }

      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListDelegatesResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailFiltersAPI : GmailFiltersAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Creates a filter.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func create(userId : String, body : GoogleCloudGmailFilter, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailFilter> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/settings/filters", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Deletes a filter.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter id: The ID of the filter to be deleted.

   public func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/settings/filters/\(id)", query: queryParams)
   }
   /// Gets a filter.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter id: The ID of the filter to be fetched.

   public func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailFilter> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/filters/\(id)", query: queryParams)
   }
   /// Lists the message filters of a Gmail user.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListFiltersResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/filters", query: queryParams)
   }
}

public protocol GmailFiltersAPIProtocol  {
   /// Creates a filter.
   func create(userId : String, body : GoogleCloudGmailFilter, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailFilter>
   /// Deletes a filter.
   func delete(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets a filter.
   func get(userId : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailFilter>
   /// Lists the message filters of a Gmail user.
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListFiltersResponse>
}
extension GmailFiltersAPIProtocol   {
      public func create(userId : String, body : GoogleCloudGmailFilter, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailFilter> {
      create(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func delete(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func get(userId : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailFilter> {
      get(userId: userId,id: id,  queryParameters: queryParameters)
   }

      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListFiltersResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailForwardingAddressesAPI : GmailForwardingAddressesAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Creates a forwarding address. If ownership verification is required, a message will be sent to the recipient and the resource's verification status will be set to pending; otherwise, the resource will be created with verification status set to accepted.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func create(userId : String, body : GoogleCloudGmailForwardingAddress, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailForwardingAddress> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/settings/forwardingAddresses", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Deletes the specified forwarding address and revokes any verification that may have been required.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter forwardingEmail: The forwarding address to be deleted.

   public func delete(userId : String, forwardingEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/settings/forwardingAddresses/\(forwardingEmail)", query: queryParams)
   }
   /// Gets the specified forwarding address.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter forwardingEmail: The forwarding address to be retrieved.

   public func get(userId : String, forwardingEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailForwardingAddress> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/forwardingAddresses/\(forwardingEmail)", query: queryParams)
   }
   /// Lists the forwarding addresses for the specified account.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListForwardingAddressesResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/forwardingAddresses", query: queryParams)
   }
}

public protocol GmailForwardingAddressesAPIProtocol  {
   /// Creates a forwarding address. If ownership verification is required, a message will be sent to the recipient and the resource's verification status will be set to pending; otherwise, the resource will be created with verification status set to accepted.  This method is only available to service account clients that have been delegated domain-wide authority.
   func create(userId : String, body : GoogleCloudGmailForwardingAddress, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailForwardingAddress>
   /// Deletes the specified forwarding address and revokes any verification that may have been required.  This method is only available to service account clients that have been delegated domain-wide authority.
   func delete(userId : String, forwardingEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets the specified forwarding address.
   func get(userId : String, forwardingEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailForwardingAddress>
   /// Lists the forwarding addresses for the specified account.
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListForwardingAddressesResponse>
}
extension GmailForwardingAddressesAPIProtocol   {
      public func create(userId : String, body : GoogleCloudGmailForwardingAddress, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailForwardingAddress> {
      create(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func delete(userId : String, forwardingEmail : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,forwardingEmail: forwardingEmail,  queryParameters: queryParameters)
   }

      public func get(userId : String, forwardingEmail : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailForwardingAddress> {
      get(userId: userId,forwardingEmail: forwardingEmail,  queryParameters: queryParameters)
   }

      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListForwardingAddressesResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailSendAsAPI : GmailSendAsAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Creates a custom "from" send-as alias. If an SMTP MSA is specified, Gmail will attempt to connect to the SMTP service to validate the configuration before creating the alias. If ownership verification is required for the alias, a message will be sent to the email address and the resource's verification status will be set to pending; otherwise, the resource will be created with verification status set to accepted. If a signature is provided, Gmail will sanitize the HTML before saving it with the alias.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func create(userId : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSendAs> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/settings/sendAs", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Deletes the specified send-as alias. Revokes any verification that may have been required for using it.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The send-as alias to be deleted.

   public func delete(userId : String, sendAsEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)", query: queryParams)
   }
   /// Gets the specified send-as alias. Fails with an HTTP 404 error if the specified address is not a member of the collection.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The send-as alias to be retrieved.

   public func get(userId : String, sendAsEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSendAs> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)", query: queryParams)
   }
   /// Lists the send-as aliases for the specified account. The result includes the primary send-as address associated with the account as well as any custom "from" aliases.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.

   public func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListSendAsResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/sendAs", query: queryParams)
   }
   /// Updates a send-as alias. If a signature is provided, Gmail will sanitize the HTML before saving it with the alias.  Addresses other than the primary address for the account can only be updated by service account clients that have been delegated domain-wide authority. This method supports patch semantics.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The send-as alias to be updated.

   public func patch(userId : String, sendAsEmail : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSendAs> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PATCH, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Updates a send-as alias. If a signature is provided, Gmail will sanitize the HTML before saving it with the alias.  Addresses other than the primary address for the account can only be updated by service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The send-as alias to be updated.

   public func update(userId : String, sendAsEmail : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSendAs> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .PUT, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Sends a verification email to the specified send-as alias address. The verification status must be pending.  This method is only available to service account clients that have been delegated domain-wide authority.
   /// - Parameter userId: User's email address. The special value "me" can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The send-as alias to be verified.

   public func verify(userId : String, sendAsEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .POST, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)/verify", query: queryParams)
   }
}

public protocol GmailSendAsAPIProtocol  {
   /// Creates a custom "from" send-as alias. If an SMTP MSA is specified, Gmail will attempt to connect to the SMTP service to validate the configuration before creating the alias. If ownership verification is required for the alias, a message will be sent to the email address and the resource's verification status will be set to pending; otherwise, the resource will be created with verification status set to accepted. If a signature is provided, Gmail will sanitize the HTML before saving it with the alias.  This method is only available to service account clients that have been delegated domain-wide authority.
   func create(userId : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSendAs>
   /// Deletes the specified send-as alias. Revokes any verification that may have been required for using it.  This method is only available to service account clients that have been delegated domain-wide authority.
   func delete(userId : String, sendAsEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets the specified send-as alias. Fails with an HTTP 404 error if the specified address is not a member of the collection.
   func get(userId : String, sendAsEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSendAs>
   /// Lists the send-as aliases for the specified account. The result includes the primary send-as address associated with the account as well as any custom "from" aliases.
   func list(userId : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListSendAsResponse>
   /// Updates a send-as alias. If a signature is provided, Gmail will sanitize the HTML before saving it with the alias.  Addresses other than the primary address for the account can only be updated by service account clients that have been delegated domain-wide authority. This method supports patch semantics.
   func patch(userId : String, sendAsEmail : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSendAs>
   /// Updates a send-as alias. If a signature is provided, Gmail will sanitize the HTML before saving it with the alias.  Addresses other than the primary address for the account can only be updated by service account clients that have been delegated domain-wide authority.
   func update(userId : String, sendAsEmail : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSendAs>
   /// Sends a verification email to the specified send-as alias address. The verification status must be pending.  This method is only available to service account clients that have been delegated domain-wide authority.
   func verify(userId : String, sendAsEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
}
extension GmailSendAsAPIProtocol   {
      public func create(userId : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailSendAs> {
      create(userId: userId, body: body, queryParameters: queryParameters)
   }

      public func delete(userId : String, sendAsEmail : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,sendAsEmail: sendAsEmail,  queryParameters: queryParameters)
   }

      public func get(userId : String, sendAsEmail : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailSendAs> {
      get(userId: userId,sendAsEmail: sendAsEmail,  queryParameters: queryParameters)
   }

      public func list(userId : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListSendAsResponse> {
      list(userId: userId,  queryParameters: queryParameters)
   }

      public func patch(userId : String, sendAsEmail : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailSendAs> {
      patch(userId: userId,sendAsEmail: sendAsEmail, body: body, queryParameters: queryParameters)
   }

      public func update(userId : String, sendAsEmail : String, body : GoogleCloudGmailSendAs, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailSendAs> {
      update(userId: userId,sendAsEmail: sendAsEmail, body: body, queryParameters: queryParameters)
   }

      public func verify(userId : String, sendAsEmail : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      verify(userId: userId,sendAsEmail: sendAsEmail,  queryParameters: queryParameters)
   }

}
public final class GoogleCloudGmailSmimeInfoAPI : GmailSmimeInfoAPIProtocol {
   let endpoint = "https://www.googleapis.com/gmail/v1/users/"
   let request : GoogleCloudGmailRequest

   init(request: GoogleCloudGmailRequest) {
      self.request = request
   }

   /// Deletes the specified S/MIME config for the specified send-as alias.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The email address that appears in the "From:" header for mail sent using this alias.
/// - Parameter id: The immutable ID for the SmimeInfo.

   public func delete(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .DELETE, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)/smimeInfo/\(id)", query: queryParams)
   }
   /// Gets the specified S/MIME config for the specified send-as alias.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The email address that appears in the "From:" header for mail sent using this alias.
/// - Parameter id: The immutable ID for the SmimeInfo.

   public func get(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSmimeInfo> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)/smimeInfo/\(id)", query: queryParams)
   }
   /// Insert (upload) the given S/MIME config for the specified send-as alias. Note that pkcs12 format is required for the key.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The email address that appears in the "From:" header for mail sent using this alias.

   public func insert(userId : String, sendAsEmail : String, body : GoogleCloudGmailSmimeInfo, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSmimeInfo> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      do {
         let data = try JSONEncoder().encode(body)
         return request.send(method: .POST, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)/smimeInfo", query: queryParams, body: .data(data))
      } catch {
         return request.httpClient.eventLoopGroup.next().makeFailedFuture(error)
   }
   }
   /// Lists S/MIME configs for the specified send-as alias.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The email address that appears in the "From:" header for mail sent using this alias.

   public func list(userId : String, sendAsEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListSmimeInfoResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .GET, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)/smimeInfo", query: queryParams)
   }
   /// Sets the default S/MIME config for the specified send-as alias.
   /// - Parameter userId: The user's email address. The special value me can be used to indicate the authenticated user.
/// - Parameter sendAsEmail: The email address that appears in the "From:" header for mail sent using this alias.
/// - Parameter id: The immutable ID for the SmimeInfo.

   public func setDefault(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      var queryParams = ""
      if let queryParameters = queryParameters {
         queryParams = queryParameters.queryParameters
      }
      return request.send(method: .POST, path: "\(endpoint)\(userId)/settings/sendAs/\(sendAsEmail)/smimeInfo/\(id)/setDefault", query: queryParams)
   }
}

public protocol GmailSmimeInfoAPIProtocol  {
   /// Deletes the specified S/MIME config for the specified send-as alias.
   func delete(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
   /// Gets the specified S/MIME config for the specified send-as alias.
   func get(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSmimeInfo>
   /// Insert (upload) the given S/MIME config for the specified send-as alias. Note that pkcs12 format is required for the key.
   func insert(userId : String, sendAsEmail : String, body : GoogleCloudGmailSmimeInfo, queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailSmimeInfo>
   /// Lists S/MIME configs for the specified send-as alias.
   func list(userId : String, sendAsEmail : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailListSmimeInfoResponse>
   /// Sets the default S/MIME config for the specified send-as alias.
   func setDefault(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]?) -> EventLoopFuture<GoogleCloudGmailEmptyResponse>
}
extension GmailSmimeInfoAPIProtocol   {
      public func delete(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      delete(userId: userId,sendAsEmail: sendAsEmail,id: id,  queryParameters: queryParameters)
   }

      public func get(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailSmimeInfo> {
      get(userId: userId,sendAsEmail: sendAsEmail,id: id,  queryParameters: queryParameters)
   }

      public func insert(userId : String, sendAsEmail : String, body : GoogleCloudGmailSmimeInfo, queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailSmimeInfo> {
      insert(userId: userId,sendAsEmail: sendAsEmail, body: body, queryParameters: queryParameters)
   }

      public func list(userId : String, sendAsEmail : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailListSmimeInfoResponse> {
      list(userId: userId,sendAsEmail: sendAsEmail,  queryParameters: queryParameters)
   }

      public func setDefault(userId : String, sendAsEmail : String, id : String,  queryParameters: [String: String]? = nil) -> EventLoopFuture<GoogleCloudGmailEmptyResponse> {
      setDefault(userId: userId,sendAsEmail: sendAsEmail,id: id,  queryParameters: queryParameters)
   }

}
public struct GoogleCloudGmailEmptyResponse : GoogleCloudModel {}
public struct GoogleCloudGmailAutoForwarding : GoogleCloudModel {
   /*The state that a message should be left in after it has been forwarded. */
   public var disposition: String?
   /*Email address to which all incoming messages are forwarded. This email address must be a verified member of the forwarding addresses. */
   public var emailAddress: String?
   /*Whether all incoming mail is automatically forwarded to another address. */
   public var enabled: Bool?
   public init(disposition:String?, emailAddress:String?, enabled:Bool?) {
      self.disposition = disposition
      self.emailAddress = emailAddress
      self.enabled = enabled
   }
}
public struct GoogleCloudGmailBatchDeleteMessagesRequest : GoogleCloudModel {
   /*The IDs of the messages to delete. */
   public var ids: [String]?
   public init(ids:[String]?) {
      self.ids = ids
   }
}
public struct GoogleCloudGmailBatchModifyMessagesRequest : GoogleCloudModel {
   /*A list of label IDs to add to messages. */
   public var addLabelIds: [String]?
   /*The IDs of the messages to modify. There is a limit of 1000 ids per request. */
   public var ids: [String]?
   /*A list of label IDs to remove from messages. */
   public var removeLabelIds: [String]?
   public init(addLabelIds:[String]?, ids:[String]?, removeLabelIds:[String]?) {
      self.addLabelIds = addLabelIds
      self.ids = ids
      self.removeLabelIds = removeLabelIds
   }
}
public struct GoogleCloudGmailDelegate : GoogleCloudModel {
   /*The email address of the delegate. */
   public var delegateEmail: String?
   /*Indicates whether this address has been verified and can act as a delegate for the account. Read-only. */
   public var verificationStatus: String?
   public init(delegateEmail:String?, verificationStatus:String?) {
      self.delegateEmail = delegateEmail
      self.verificationStatus = verificationStatus
   }
}
public struct GoogleCloudGmailDraft : GoogleCloudModel {
   /*The immutable ID of the draft. */
   public var id: String?
   /*The message content of the draft. */
   public var message: GoogleCloudGmailMessage?
   public init(id:String?, message:GoogleCloudGmailMessage?) {
      self.id = id
      self.message = message
   }
}
public struct GoogleCloudGmailFilter : GoogleCloudModel {
   /*Action that the filter performs. */
   public var action: GoogleCloudGmailFilterAction?
   /*Matching criteria for the filter. */
   public var criteria: GoogleCloudGmailFilterCriteria?
   /*The server assigned ID of the filter. */
   public var id: String?
   public init(action:GoogleCloudGmailFilterAction?, criteria:GoogleCloudGmailFilterCriteria?, id:String?) {
      self.action = action
      self.criteria = criteria
      self.id = id
   }
}
public struct GoogleCloudGmailFilterAction : GoogleCloudModel {
   /*List of labels to add to the message. */
   public var addLabelIds: [String]?
   /*Email address that the message should be forwarded to. */
   public var forward: String?
   /*List of labels to remove from the message. */
   public var removeLabelIds: [String]?
   public init(addLabelIds:[String]?, forward:String?, removeLabelIds:[String]?) {
      self.addLabelIds = addLabelIds
      self.forward = forward
      self.removeLabelIds = removeLabelIds
   }
}
public struct GoogleCloudGmailFilterCriteria : GoogleCloudModel {
   /*Whether the response should exclude chats. */
   public var excludeChats: Bool?
   /*The sender's display name or email address. */
   public var from: String?
   /*Whether the message has any attachment. */
   public var hasAttachment: Bool?
   /*Only return messages not matching the specified query. Supports the same query format as the Gmail search box. For example, "from:someuser@example.com rfc822msgid: is:unread". */
   public var negatedQuery: String?
   /*Only return messages matching the specified query. Supports the same query format as the Gmail search box. For example, "from:someuser@example.com rfc822msgid: is:unread". */
   public var query: String?
   /*The size of the entire RFC822 message in bytes, including all headers and attachments. */
   @CodingUsesMutable<Coder> public var size: Int?
   /*How the message size in bytes should be in relation to the size field. */
   public var sizeComparison: String?
   /*Case-insensitive phrase found in the message's subject. Trailing and leading whitespace are be trimmed and adjacent spaces are collapsed. */
   public var subject: String?
   /*The recipient's display name or email address. Includes recipients in the "to", "cc", and "bcc" header fields. You can use simply the local part of the email address. For example, "example" and "example@" both match "example@gmail.com". This field is case-insensitive. */
   public var to: String?
   public init(excludeChats:Bool?, from:String?, hasAttachment:Bool?, negatedQuery:String?, query:String?, size:Int?, sizeComparison:String?, subject:String?, to:String?) {
      self.excludeChats = excludeChats
      self.from = from
      self.hasAttachment = hasAttachment
      self.negatedQuery = negatedQuery
      self.query = query
      self.size = size
      self.sizeComparison = sizeComparison
      self.subject = subject
      self.to = to
   }
}
public struct GoogleCloudGmailForwardingAddress : GoogleCloudModel {
   /*An email address to which messages can be forwarded. */
   public var forwardingEmail: String?
   /*Indicates whether this address has been verified and is usable for forwarding. Read-only. */
   public var verificationStatus: String?
   public init(forwardingEmail:String?, verificationStatus:String?) {
      self.forwardingEmail = forwardingEmail
      self.verificationStatus = verificationStatus
   }
}
public struct GoogleCloudGmailHistory : GoogleCloudModel {
   /*The mailbox sequence ID. */
   @CodingUsesMutable<Coder> public var id: UInt?
   /*Labels added to messages in this history record. */
   public var labelsAdded: [GoogleCloudGmailHistoryLabelAdded]?
   /*Labels removed from messages in this history record. */
   public var labelsRemoved: [GoogleCloudGmailHistoryLabelRemoved]?
   /*List of messages changed in this history record. The fields for specific change types, such as messagesAdded may duplicate messages in this field. We recommend using the specific change-type fields instead of this. */
   public var messages: [GoogleCloudGmailMessage]?
   /*Messages added to the mailbox in this history record. */
   public var messagesAdded: [GoogleCloudGmailHistoryMessageAdded]?
   /*Messages deleted (not Trashed) from the mailbox in this history record. */
   public var messagesDeleted: [GoogleCloudGmailHistoryMessageDeleted]?
   public init(id:UInt?, labelsAdded:[GoogleCloudGmailHistoryLabelAdded]?, labelsRemoved:[GoogleCloudGmailHistoryLabelRemoved]?, messages:[GoogleCloudGmailMessage]?, messagesAdded:[GoogleCloudGmailHistoryMessageAdded]?, messagesDeleted:[GoogleCloudGmailHistoryMessageDeleted]?) {
      self.id = id
      self.labelsAdded = labelsAdded
      self.labelsRemoved = labelsRemoved
      self.messages = messages
      self.messagesAdded = messagesAdded
      self.messagesDeleted = messagesDeleted
   }
}
public struct GoogleCloudGmailHistoryLabelAdded : GoogleCloudModel {
   /*Label IDs added to the message. */
   public var labelIds: [String]?
   public var message: GoogleCloudGmailMessage?
   public init(labelIds:[String]?, message:GoogleCloudGmailMessage?) {
      self.labelIds = labelIds
      self.message = message
   }
}
public struct GoogleCloudGmailHistoryLabelRemoved : GoogleCloudModel {
   /*Label IDs removed from the message. */
   public var labelIds: [String]?
   public var message: GoogleCloudGmailMessage?
   public init(labelIds:[String]?, message:GoogleCloudGmailMessage?) {
      self.labelIds = labelIds
      self.message = message
   }
}
public struct GoogleCloudGmailHistoryMessageAdded : GoogleCloudModel {
   public var message: GoogleCloudGmailMessage?
   public init(message:GoogleCloudGmailMessage?) {
      self.message = message
   }
}
public struct GoogleCloudGmailHistoryMessageDeleted : GoogleCloudModel {
   public var message: GoogleCloudGmailMessage?
   public init(message:GoogleCloudGmailMessage?) {
      self.message = message
   }
}
public struct GoogleCloudGmailImapSettings : GoogleCloudModel {
   /*If this value is true, Gmail will immediately expunge a message when it is marked as deleted in IMAP. Otherwise, Gmail will wait for an update from the client before expunging messages marked as deleted. */
   public var autoExpunge: Bool?
   /*Whether IMAP is enabled for the account. */
   public var enabled: Bool?
   /*The action that will be executed on a message when it is marked as deleted and expunged from the last visible IMAP folder. */
   public var expungeBehavior: String?
   /*An optional limit on the number of messages that an IMAP folder may contain. Legal values are 0, 1000, 2000, 5000 or 10000. A value of zero is interpreted to mean that there is no limit. */
   @CodingUsesMutable<Coder> public var maxFolderSize: Int?
   public init(autoExpunge:Bool?, enabled:Bool?, expungeBehavior:String?, maxFolderSize:Int?) {
      self.autoExpunge = autoExpunge
      self.enabled = enabled
      self.expungeBehavior = expungeBehavior
      self.maxFolderSize = maxFolderSize
   }
}
public struct GoogleCloudGmailLabel : GoogleCloudModel {
   /*The color to assign to the label. Color is only available for labels that have their type set to user. */
   public var color: GoogleCloudGmailLabelColor?
   /*The immutable ID of the label. */
   public var id: String?
   /*The visibility of the label in the label list in the Gmail web interface. */
   public var labelListVisibility: String?
   /*The visibility of the label in the message list in the Gmail web interface. */
   public var messageListVisibility: String?
   /*The total number of messages with the label. */
   @CodingUsesMutable<Coder> public var messagesTotal: Int?
   /*The number of unread messages with the label. */
   @CodingUsesMutable<Coder> public var messagesUnread: Int?
   /*The display name of the label. */
   public var name: String?
   /*The total number of threads with the label. */
   @CodingUsesMutable<Coder> public var threadsTotal: Int?
   /*The number of unread threads with the label. */
   @CodingUsesMutable<Coder> public var threadsUnread: Int?
   /*The owner type for the label. User labels are created by the user and can be modified and deleted by the user and can be applied to any message or thread. System labels are internally created and cannot be added, modified, or deleted. System labels may be able to be applied to or removed from messages and threads under some circumstances but this is not guaranteed. For example, users can apply and remove the INBOX and UNREAD labels from messages and threads, but cannot apply or remove the DRAFTS or SENT labels from messages or threads. */
   public var type: String?
   public init(color:GoogleCloudGmailLabelColor?, id:String?, labelListVisibility:String?, messageListVisibility:String?, messagesTotal:Int?, messagesUnread:Int?, name:String?, threadsTotal:Int?, threadsUnread:Int?, type:String?) {
      self.color = color
      self.id = id
      self.labelListVisibility = labelListVisibility
      self.messageListVisibility = messageListVisibility
      self.messagesTotal = messagesTotal
      self.messagesUnread = messagesUnread
      self.name = name
      self.threadsTotal = threadsTotal
      self.threadsUnread = threadsUnread
      self.type = type
   }
}
public struct GoogleCloudGmailLabelColor : GoogleCloudModel {
   /*The background color represented as hex string #RRGGBB (ex #000000). This field is required in order to set the color of a label. Only the following predefined set of color values are allowed:
#000000, #434343, #666666, #999999, #cccccc, #efefef, #f3f3f3, #ffffff, #fb4c2f, #ffad47, #fad165, #16a766, #43d692, #4a86e8, #a479e2, #f691b3, #f6c5be, #ffe6c7, #fef1d1, #b9e4d0, #c6f3de, #c9daf8, #e4d7f5, #fcdee8, #efa093, #ffd6a2, #fce8b3, #89d3b2, #a0eac9, #a4c2f4, #d0bcf1, #fbc8d9, #e66550, #ffbc6b, #fcda83, #44b984, #68dfa9, #6d9eeb, #b694e8, #f7a7c0, #cc3a21, #eaa041, #f2c960, #149e60, #3dc789, #3c78d8, #8e63ce, #e07798, #ac2b16, #cf8933, #d5ae49, #0b804b, #2a9c68, #285bac, #653e9b, #b65775, #822111, #a46a21, #aa8831, #076239, #1a764d, #1c4587, #41236d, #83334c #464646, #e7e7e7, #0d3472, #b6cff5, #0d3b44, #98d7e4, #3d188e, #e3d7ff, #711a36, #fbd3e0, #8a1c0a, #f2b2a8, #7a2e0b, #ffc8af, #7a4706, #ffdeb5, #594c05, #fbe983, #684e07, #fdedc1, #0b4f30, #b3efd3, #04502e, #a2dcc1, #c2c2c2, #4986e7, #2da2bb, #b99aff, #994a64, #f691b2, #ff7537, #ffad46, #662e37, #ebdbde, #cca6ac, #094228, #42d692, #16a765 */
   public var backgroundColor: String?
   /*The text color of the label, represented as hex string. This field is required in order to set the color of a label. Only the following predefined set of color values are allowed:
#000000, #434343, #666666, #999999, #cccccc, #efefef, #f3f3f3, #ffffff, #fb4c2f, #ffad47, #fad165, #16a766, #43d692, #4a86e8, #a479e2, #f691b3, #f6c5be, #ffe6c7, #fef1d1, #b9e4d0, #c6f3de, #c9daf8, #e4d7f5, #fcdee8, #efa093, #ffd6a2, #fce8b3, #89d3b2, #a0eac9, #a4c2f4, #d0bcf1, #fbc8d9, #e66550, #ffbc6b, #fcda83, #44b984, #68dfa9, #6d9eeb, #b694e8, #f7a7c0, #cc3a21, #eaa041, #f2c960, #149e60, #3dc789, #3c78d8, #8e63ce, #e07798, #ac2b16, #cf8933, #d5ae49, #0b804b, #2a9c68, #285bac, #653e9b, #b65775, #822111, #a46a21, #aa8831, #076239, #1a764d, #1c4587, #41236d, #83334c #464646, #e7e7e7, #0d3472, #b6cff5, #0d3b44, #98d7e4, #3d188e, #e3d7ff, #711a36, #fbd3e0, #8a1c0a, #f2b2a8, #7a2e0b, #ffc8af, #7a4706, #ffdeb5, #594c05, #fbe983, #684e07, #fdedc1, #0b4f30, #b3efd3, #04502e, #a2dcc1, #c2c2c2, #4986e7, #2da2bb, #b99aff, #994a64, #f691b2, #ff7537, #ffad46, #662e37, #ebdbde, #cca6ac, #094228, #42d692, #16a765 */
   public var textColor: String?
   public init(backgroundColor:String?, textColor:String?) {
      self.backgroundColor = backgroundColor
      self.textColor = textColor
   }
}
public struct GoogleCloudGmailLanguageSettings : GoogleCloudModel {
   /*The language to display Gmail in, formatted as an RFC 3066 Language Tag (for example en-GB, fr or ja for British English, French, or Japanese respectively).

The set of languages supported by Gmail evolves over time, so please refer to the "Language" dropdown in the Gmail settings  for all available options, as described in the language settings help article. A table of sample values is also provided in the Managing Language Settings guide

Not all Gmail clients can display the same set of languages. In the case that a user's display language is not available for use on a particular client, said client automatically chooses to display in the closest supported variant (or a reasonable default). */
   public var displayLanguage: String?
   public init(displayLanguage:String?) {
      self.displayLanguage = displayLanguage
   }
}
public struct GoogleCloudGmailListDelegatesResponse : GoogleCloudModel {
   /*List of the user's delegates (with any verification status). */
   public var delegates: [GoogleCloudGmailDelegate]?
   public init(delegates:[GoogleCloudGmailDelegate]?) {
      self.delegates = delegates
   }
}
public struct GoogleCloudGmailListDraftsResponse : GoogleCloudModel {
   /*List of drafts. Note that the Message property in each Draft resource only contains an id and a threadId. The messages.get method can fetch additional message details. */
   public var drafts: [GoogleCloudGmailDraft]?
   /*Token to retrieve the next page of results in the list. */
   public var nextPageToken: String?
   /*Estimated total number of results. */
   @CodingUsesMutable<Coder> public var resultSizeEstimate: UInt?
   public init(drafts:[GoogleCloudGmailDraft]?, nextPageToken:String?, resultSizeEstimate:UInt?) {
      self.drafts = drafts
      self.nextPageToken = nextPageToken
      self.resultSizeEstimate = resultSizeEstimate
   }
}
public struct GoogleCloudGmailListFiltersResponse : GoogleCloudModel {
   /*List of a user's filters. */
   public var filter: [GoogleCloudGmailFilter]?
   public init(filter:[GoogleCloudGmailFilter]?) {
      self.filter = filter
   }
}
public struct GoogleCloudGmailListForwardingAddressesResponse : GoogleCloudModel {
   /*List of addresses that may be used for forwarding. */
   public var forwardingAddresses: [GoogleCloudGmailForwardingAddress]?
   public init(forwardingAddresses:[GoogleCloudGmailForwardingAddress]?) {
      self.forwardingAddresses = forwardingAddresses
   }
}
public struct GoogleCloudGmailListHistoryResponse : GoogleCloudModel {
   /*List of history records. Any messages contained in the response will typically only have id and threadId fields populated. */
   public var history: [GoogleCloudGmailHistory]?
   /*The ID of the mailbox's current history record. */
   @CodingUsesMutable<Coder> public var historyId: UInt?
   /*Page token to retrieve the next page of results in the list. */
   public var nextPageToken: String?
   public init(history:[GoogleCloudGmailHistory]?, historyId:UInt?, nextPageToken:String?) {
      self.history = history
      self.historyId = historyId
      self.nextPageToken = nextPageToken
   }
}
public struct GoogleCloudGmailListLabelsResponse : GoogleCloudModel {
   /*List of labels. Note that each label resource only contains an id, name, messageListVisibility, labelListVisibility, and type. The labels.get method can fetch additional label details. */
   public var labels: [GoogleCloudGmailLabel]?
   public init(labels:[GoogleCloudGmailLabel]?) {
      self.labels = labels
   }
}
public struct GoogleCloudGmailListMessagesResponse : GoogleCloudModel {
   /*List of messages. Note that each message resource contains only an id and a threadId. Additional message details can be fetched using the messages.get method. */
   public var messages: [GoogleCloudGmailMessage]?
   /*Token to retrieve the next page of results in the list. */
   public var nextPageToken: String?
   /*Estimated total number of results. */
   @CodingUsesMutable<Coder> public var resultSizeEstimate: UInt?
   public init(messages:[GoogleCloudGmailMessage]?, nextPageToken:String?, resultSizeEstimate:UInt?) {
      self.messages = messages
      self.nextPageToken = nextPageToken
      self.resultSizeEstimate = resultSizeEstimate
   }
}
public struct GoogleCloudGmailListSendAsResponse : GoogleCloudModel {
   /*List of send-as aliases. */
   public var sendAs: [GoogleCloudGmailSendAs]?
   public init(sendAs:[GoogleCloudGmailSendAs]?) {
      self.sendAs = sendAs
   }
}
public struct GoogleCloudGmailListSmimeInfoResponse : GoogleCloudModel {
   /*List of SmimeInfo. */
   public var smimeInfo: [GoogleCloudGmailSmimeInfo]?
   public init(smimeInfo:[GoogleCloudGmailSmimeInfo]?) {
      self.smimeInfo = smimeInfo
   }
}
public struct GoogleCloudGmailListThreadsResponse : GoogleCloudModel {
   /*Page token to retrieve the next page of results in the list. */
   public var nextPageToken: String?
   /*Estimated total number of results. */
   @CodingUsesMutable<Coder> public var resultSizeEstimate: UInt?
   /*List of threads. Note that each thread resource does not contain a list of messages. The list of messages for a given thread can be fetched using the threads.get method. */
   public var threads: [GoogleCloudGmailThread]?
   public init(nextPageToken:String?, resultSizeEstimate:UInt?, threads:[GoogleCloudGmailThread]?) {
      self.nextPageToken = nextPageToken
      self.resultSizeEstimate = resultSizeEstimate
      self.threads = threads
   }
}
public struct GoogleCloudGmailMessage : GoogleCloudModel {
   /*The ID of the last history record that modified this message. */
   @CodingUsesMutable<Coder> public var historyId: UInt?
   /*The immutable ID of the message. */
   public var id: String?
   /*The internal message creation timestamp (epoch ms), which determines ordering in the inbox. For normal SMTP-received email, this represents the time the message was originally accepted by Google, which is more reliable than the Date header. However, for API-migrated mail, it can be configured by client to be based on the Date header. */
   @CodingUsesMutable<Coder> public var internalDate: Int?
   /*List of IDs of labels applied to this message. */
   public var labelIds: [String]?
   /*The parsed email structure in the message parts. */
   public var payload: GoogleCloudGmailMessagePart?
   /*The entire email message in an RFC 2822 formatted and base64url encoded string. Returned in messages.get and drafts.get responses when the format=RAW parameter is supplied. */
   @CodingUsesMutable<Coder> public var raw: Data?
   /*Estimated size in bytes of the message. */
   @CodingUsesMutable<Coder> public var sizeEstimate: Int?
   /*A short part of the message text. */
   public var snippet: String?
   /*The ID of the thread the message belongs to. To add a message or draft to a thread, the following criteria must be met:
- The requested threadId must be specified on the Message or Draft.Message you supply with your request.
- The References and In-Reply-To headers must be set in compliance with the RFC 2822 standard.
- The Subject headers must match. */
   public var threadId: String?
   public init(historyId:UInt?, id:String?, internalDate:Int?, labelIds:[String]?, payload:GoogleCloudGmailMessagePart?, raw:Data?, sizeEstimate:Int?, snippet:String?, threadId:String?) {
      self.historyId = historyId
      self.id = id
      self.internalDate = internalDate
      self.labelIds = labelIds
      self.payload = payload
      self.raw = raw
      self.sizeEstimate = sizeEstimate
      self.snippet = snippet
      self.threadId = threadId
   }
}
public struct GoogleCloudGmailMessagePart : GoogleCloudModel {
   /*The message part body for this part, which may be empty for container MIME message parts. */
   public var body: GoogleCloudGmailMessagePartBody?
   /*The filename of the attachment. Only present if this message part represents an attachment. */
   public var filename: String?
   /*List of headers on this message part. For the top-level message part, representing the entire message payload, it will contain the standard RFC 2822 email headers such as To, From, and Subject. */
   public var headers: [GoogleCloudGmailMessagePartHeader]?
   /*The MIME type of the message part. */
   public var mimeType: String?
   /*The immutable ID of the message part. */
   public var partId: String?
   /*The child MIME message parts of this part. This only applies to container MIME message parts, for example multipart/ *. For non- container MIME message part types, such as text/plain, this field is empty. For more information, see RFC 1521. */
   public var parts: [GoogleCloudGmailMessagePart]?
   public init(body:GoogleCloudGmailMessagePartBody?, filename:String?, headers:[GoogleCloudGmailMessagePartHeader]?, mimeType:String?, partId:String?, parts:[GoogleCloudGmailMessagePart]?) {
      self.body = body
      self.filename = filename
      self.headers = headers
      self.mimeType = mimeType
      self.partId = partId
      self.parts = parts
   }
}
public struct GoogleCloudGmailMessagePartBody : GoogleCloudModel {
   /*When present, contains the ID of an external attachment that can be retrieved in a separate messages.attachments.get request. When not present, the entire content of the message part body is contained in the data field. */
   public var attachmentId: String?
   /*The body data of a MIME message part as a base64url encoded string. May be empty for MIME container types that have no message body or when the body data is sent as a separate attachment. An attachment ID is present if the body data is contained in a separate attachment. */
   @CodingUsesMutable<Coder> public var data: String?
   /*Number of bytes for the message part data (encoding notwithstanding). */
   @CodingUsesMutable<Coder> public var size: Int?
   public init(attachmentId:String?, data:String?, size:Int?) {
      self.attachmentId = attachmentId
      self.data = data
      self.size = size
   }
}
public struct GoogleCloudGmailMessagePartHeader : GoogleCloudModel {
   /*The name of the header before the : separator. For example, To. */
   public var name: String?
   /*The value of the header after the : separator. For example, someuser@example.com. */
   public var value: String?
   public init(name:String?, value:String?) {
      self.name = name
      self.value = value
   }
}
public struct GoogleCloudGmailModifyMessageRequest : GoogleCloudModel {
   /*A list of IDs of labels to add to this message. */
   public var addLabelIds: [String]?
   /*A list IDs of labels to remove from this message. */
   public var removeLabelIds: [String]?
   public init(addLabelIds:[String]?, removeLabelIds:[String]?) {
      self.addLabelIds = addLabelIds
      self.removeLabelIds = removeLabelIds
   }
}
public struct GoogleCloudGmailModifyThreadRequest : GoogleCloudModel {
   /*A list of IDs of labels to add to this thread. */
   public var addLabelIds: [String]?
   /*A list of IDs of labels to remove from this thread. */
   public var removeLabelIds: [String]?
   public init(addLabelIds:[String]?, removeLabelIds:[String]?) {
      self.addLabelIds = addLabelIds
      self.removeLabelIds = removeLabelIds
   }
}
public struct GoogleCloudGmailPopSettings : GoogleCloudModel {
   /*The range of messages which are accessible via POP. */
   public var accessWindow: String?
   /*The action that will be executed on a message after it has been fetched via POP. */
   public var disposition: String?
   public init(accessWindow:String?, disposition:String?) {
      self.accessWindow = accessWindow
      self.disposition = disposition
   }
}
public struct GoogleCloudGmailProfile : GoogleCloudModel {
   /*The user's email address. */
   public var emailAddress: String?
   /*The ID of the mailbox's current history record. */
   @CodingUsesMutable<Coder> public var historyId: UInt?
   /*The total number of messages in the mailbox. */
   @CodingUsesMutable<Coder> public var messagesTotal: Int?
   /*The total number of threads in the mailbox. */
   @CodingUsesMutable<Coder> public var threadsTotal: Int?
   public init(emailAddress:String?, historyId:UInt?, messagesTotal:Int?, threadsTotal:Int?) {
      self.emailAddress = emailAddress
      self.historyId = historyId
      self.messagesTotal = messagesTotal
      self.threadsTotal = threadsTotal
   }
}
public struct GoogleCloudGmailSendAs : GoogleCloudModel {
   /*A name that appears in the "From:" header for mail sent using this alias. For custom "from" addresses, when this is empty, Gmail will populate the "From:" header with the name that is used for the primary address associated with the account. If the admin has disabled the ability for users to update their name format, requests to update this field for the primary login will silently fail. */
   public var displayName: String?
   /*Whether this address is selected as the default "From:" address in situations such as composing a new message or sending a vacation auto-reply. Every Gmail account has exactly one default send-as address, so the only legal value that clients may write to this field is true. Changing this from false to true for an address will result in this field becoming false for the other previous default address. */
   public var isDefault: Bool?
   /*Whether this address is the primary address used to login to the account. Every Gmail account has exactly one primary address, and it cannot be deleted from the collection of send-as aliases. This field is read-only. */
   public var isPrimary: Bool?
   /*An optional email address that is included in a "Reply-To:" header for mail sent using this alias. If this is empty, Gmail will not generate a "Reply-To:" header. */
   public var replyToAddress: String?
   /*The email address that appears in the "From:" header for mail sent using this alias. This is read-only for all operations except create. */
   public var sendAsEmail: String?
   /*An optional HTML signature that is included in messages composed with this alias in the Gmail web UI. */
   public var signature: String?
   /*An optional SMTP service that will be used as an outbound relay for mail sent using this alias. If this is empty, outbound mail will be sent directly from Gmail's servers to the destination SMTP service. This setting only applies to custom "from" aliases. */
   public var smtpMsa: GoogleCloudGmailSmtpMsa?
   /*Whether Gmail should  treat this address as an alias for the user's primary email address. This setting only applies to custom "from" aliases. */
   public var treatAsAlias: Bool?
   /*Indicates whether this address has been verified for use as a send-as alias. Read-only. This setting only applies to custom "from" aliases. */
   public var verificationStatus: String?
   public init(displayName:String?, isDefault:Bool?, isPrimary:Bool?, replyToAddress:String?, sendAsEmail:String?, signature:String?, smtpMsa:GoogleCloudGmailSmtpMsa?, treatAsAlias:Bool?, verificationStatus:String?) {
      self.displayName = displayName
      self.isDefault = isDefault
      self.isPrimary = isPrimary
      self.replyToAddress = replyToAddress
      self.sendAsEmail = sendAsEmail
      self.signature = signature
      self.smtpMsa = smtpMsa
      self.treatAsAlias = treatAsAlias
      self.verificationStatus = verificationStatus
   }
}
public struct GoogleCloudGmailSmimeInfo : GoogleCloudModel {
   /*Encrypted key password, when key is encrypted. */
   public var encryptedKeyPassword: String?
   /*When the certificate expires (in milliseconds since epoch). */
   @CodingUsesMutable<Coder> public var expiration: Int?
   /*The immutable ID for the SmimeInfo. */
   public var id: String?
   /*Whether this SmimeInfo is the default one for this user's send-as address. */
   public var isDefault: Bool?
   /*The S/MIME certificate issuer's common name. */
   public var issuerCn: String?
   /*PEM formatted X509 concatenated certificate string (standard base64 encoding). Format used for returning key, which includes public key as well as certificate chain (not private key). */
   public var pem: String?
   /*PKCS#12 format containing a single private/public key pair and certificate chain. This format is only accepted from client for creating a new SmimeInfo and is never returned, because the private key is not intended to be exported. PKCS#12 may be encrypted, in which case encryptedKeyPassword should be set appropriately. */
   @CodingUsesMutable<Coder> public var pkcs12: Data?
   public init(encryptedKeyPassword:String?, expiration:Int?, id:String?, isDefault:Bool?, issuerCn:String?, pem:String?, pkcs12:Data?) {
      self.encryptedKeyPassword = encryptedKeyPassword
      self.expiration = expiration
      self.id = id
      self.isDefault = isDefault
      self.issuerCn = issuerCn
      self.pem = pem
      self.pkcs12 = pkcs12
   }
}
public struct GoogleCloudGmailSmtpMsa : GoogleCloudModel {
   /*The hostname of the SMTP service. Required. */
   public var host: String?
   /*The password that will be used for authentication with the SMTP service. This is a write-only field that can be specified in requests to create or update SendAs settings; it is never populated in responses. */
   public var password: String?
   /*The port of the SMTP service. Required. */
   @CodingUsesMutable<Coder> public var port: Int?
   /*The protocol that will be used to secure communication with the SMTP service. Required. */
   public var securityMode: String?
   /*The username that will be used for authentication with the SMTP service. This is a write-only field that can be specified in requests to create or update SendAs settings; it is never populated in responses. */
   public var username: String?
   public init(host:String?, password:String?, port:Int?, securityMode:String?, username:String?) {
      self.host = host
      self.password = password
      self.port = port
      self.securityMode = securityMode
      self.username = username
   }
}
public struct GoogleCloudGmailThread : GoogleCloudModel {
   /*The ID of the last history record that modified this thread. */
   @CodingUsesMutable<Coder> public var historyId: UInt?
   /*The unique ID of the thread. */
   public var id: String?
   /*The list of messages in the thread. */
   public var messages: [GoogleCloudGmailMessage]?
   /*A short part of the message text. */
   public var snippet: String?
   public init(historyId:UInt?, id:String?, messages:[GoogleCloudGmailMessage]?, snippet:String?) {
      self.historyId = historyId
      self.id = id
      self.messages = messages
      self.snippet = snippet
   }
}
public struct GoogleCloudGmailVacationSettings : GoogleCloudModel {
   /*Flag that controls whether Gmail automatically replies to messages. */
   public var enableAutoReply: Bool?
   /*An optional end time for sending auto-replies (epoch ms). When this is specified, Gmail will automatically reply only to messages that it receives before the end time. If both startTime and endTime are specified, startTime must precede endTime. */
   @CodingUsesMutable<Coder> public var endTime: Int?
   /*Response body in HTML format. Gmail will sanitize the HTML before storing it. */
   public var responseBodyHtml: String?
   /*Response body in plain text format. */
   public var responseBodyPlainText: String?
   /*Optional text to prepend to the subject line in vacation responses. In order to enable auto-replies, either the response subject or the response body must be nonempty. */
   public var responseSubject: String?
   /*Flag that determines whether responses are sent to recipients who are not in the user's list of contacts. */
   public var restrictToContacts: Bool?
   /*Flag that determines whether responses are sent to recipients who are outside of the user's domain. This feature is only available for G Suite users. */
   public var restrictToDomain: Bool?
   /*An optional start time for sending auto-replies (epoch ms). When this is specified, Gmail will automatically reply only to messages that it receives after the start time. If both startTime and endTime are specified, startTime must precede endTime. */
   @CodingUsesMutable<Coder> public var startTime: Int?
   public init(enableAutoReply:Bool?, endTime:Int?, responseBodyHtml:String?, responseBodyPlainText:String?, responseSubject:String?, restrictToContacts:Bool?, restrictToDomain:Bool?, startTime:Int?) {
      self.enableAutoReply = enableAutoReply
      self.endTime = endTime
      self.responseBodyHtml = responseBodyHtml
      self.responseBodyPlainText = responseBodyPlainText
      self.responseSubject = responseSubject
      self.restrictToContacts = restrictToContacts
      self.restrictToDomain = restrictToDomain
      self.startTime = startTime
   }
}
public struct GoogleCloudGmailWatchRequest : GoogleCloudModel {
   /*Filtering behavior of labelIds list specified. */
   public var labelFilterAction: String?
   /*List of label_ids to restrict notifications about. By default, if unspecified, all changes are pushed out. If specified then dictates which labels are required for a push notification to be generated. */
   public var labelIds: [String]?
   /*A fully qualified Google Cloud Pub/Sub API topic name to publish the events to. This topic name **must** already exist in Cloud Pub/Sub and you **must** have already granted gmail "publish" permission on it. For example, "projects/my-project-identifier/topics/my-topic-name" (using the Cloud Pub/Sub "v1" topic naming format).

Note that the "my-project-identifier" portion must exactly match your Google developer project id (the one executing this watch request). */
   public var topicName: String?
   public init(labelFilterAction:String?, labelIds:[String]?, topicName:String?) {
      self.labelFilterAction = labelFilterAction
      self.labelIds = labelIds
      self.topicName = topicName
   }
}
public struct GoogleCloudGmailWatchResponse : GoogleCloudModel {
   /*When Gmail will stop sending notifications for mailbox updates (epoch millis). Call watch again before this time to renew the watch. */
   @CodingUsesMutable<Coder> public var expiration: Int?
   /*The ID of the mailbox's current history record. */
   @CodingUsesMutable<Coder> public var historyId: UInt?
   public init(expiration:Int?, historyId:UInt?) {
      self.expiration = expiration
      self.historyId = historyId
   }
}
public final class GoogleCloudGmailClient {
   public var users : GmailUsersAPIProtocol
   public var drafts : GmailDraftsAPIProtocol
   public var history : GmailHistoryAPIProtocol
   public var labels : GmailLabelsAPIProtocol
   public var messages : GmailMessagesAPIProtocol
   public var attachments : GmailAttachmentsAPIProtocol
   public var settings : GmailSettingsAPIProtocol
   public var delegates : GmailDelegatesAPIProtocol
   public var filters : GmailFiltersAPIProtocol
   public var forwardingAddresses : GmailForwardingAddressesAPIProtocol
   public var sendAs : GmailSendAsAPIProtocol
   public var smimeInfo : GmailSmimeInfoAPIProtocol
   public var threads : GmailThreadsAPIProtocol


   public init(credentials: GoogleCloudCredentialsConfiguration, gmailConfig: GoogleCloudGmailConfiguration, httpClient: HTTPClient, eventLoop: EventLoop) throws {
      let refreshableToken = OAuthCredentialLoader.getRefreshableToken(credentials: credentials, withConfig: gmailConfig, andClient: httpClient, eventLoop: eventLoop)
      guard let projectId = ProcessInfo.processInfo.environment["PROJECT_ID"] ??
               (refreshableToken as? OAuthServiceAccount)?.credentials.projectId ??
               gmailConfig.project ?? credentials.project else {
         throw GoogleCloudInternalError.projectIdMissing
      }

      let request = GoogleCloudGmailRequest(httpClient: httpClient, eventLoop: eventLoop, oauth: refreshableToken, project: projectId)


      users = GoogleCloudGmailUsersAPI(request: request)
      drafts = GoogleCloudGmailDraftsAPI(request: request)
      history = GoogleCloudGmailHistoryAPI(request: request)
      labels = GoogleCloudGmailLabelsAPI(request: request)
      messages = GoogleCloudGmailMessagesAPI(request: request)
      attachments = GoogleCloudGmailAttachmentsAPI(request: request)
      settings = GoogleCloudGmailSettingsAPI(request: request)
      delegates = GoogleCloudGmailDelegatesAPI(request: request)
      filters = GoogleCloudGmailFiltersAPI(request: request)
      forwardingAddresses = GoogleCloudGmailForwardingAddressesAPI(request: request)
      sendAs = GoogleCloudGmailSendAsAPI(request: request)
      smimeInfo = GoogleCloudGmailSmimeInfoAPI(request: request)
      threads = GoogleCloudGmailThreadsAPI(request: request)
   }
}

public enum GoogleCloudInternalError: GoogleCloudError {
   case projectIdMissing
   case unknownError(String)

   var localizedDescription: String {
      switch self {
      case .projectIdMissing:
         return "Missing project id for Gmail API. Did you forget to set your project id?"
      case .unknownError(let reason):
         return "An unknown error occured: \(reason)"
      }
   }
}
