//
//  Networking.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation
import Alamofire
import Network
import Combine

typealias Callback<T> = (Result<T, Error>) -> Void

private typealias RetryBlock = () -> Void

protocol Networking {
    func get(_ endpoint: String,  params: [String: Any?]) -> CallbackPublisher<Data>
    func get<Response: Decodable>(_ endpoint: String,  params: [String: Any?], responseType: Response.Type) -> CallbackPublisher<Response>
    func get<Response: Decodable>(_ endpoint: String,  params: [String: Any?], headers: HTTPHeaders?, responseType: Response.Type) -> CallbackPublisher<Response>
    func post<Body: Encodable>(_ endpoint: String, body: Body) -> SuccessPublisher
    func post<Request: Encodable, Response: Decodable>(_ endpoint: String, body: Request, responseType: Response.Type) -> CallbackPublisher<Response>
    func put<Body: Encodable>(_ endpoint: String, body: Body) -> SuccessPublisher
    func invalidate()
}

class NetworkingImpl: Networking {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue.global(qos: .background)
    private var isConnected = true
    
    private var accessTokenInvalidator: () -> Void {
        { }
    }
    
    init() {
        self.monitor.start(queue: self.monitorQueue)
        self.monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
    }
    
    static let baseURL = environment.baseUrl
    
    func get(_ endpoint: String, params: [String : Any?]) -> CallbackPublisher<Data> {
        checkConnectivity()
            .flatMap { _ -> CallbackPublisher<Data> in
                AF.request(NetworkingImpl.baseURL + endpoint,
                                  parameters: params.filter { $0.value != nil }.mapValues { $0! } as Parameters,
                                  encoding: URLEncoding(destination: .queryString),
                                  headers: nil)
                    .publishData()
                    .compactMap(\.data)
                    .mapError { NetworkingError.serverError($0.localizedDescription) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func get<Response>(_ endpoint: String,
                       params: [String : Any?],
                       headers: HTTPHeaders?,
                       responseType: Response.Type
    ) -> CallbackPublisher<Response> where Response : Decodable {
        checkConnectivity()
            .flatMap { [self] _ -> CallbackPublisher<Response> in
                if let providedHeaders = headers {
                    return AF.request(NetworkingImpl.baseURL + endpoint,
                                      parameters: params.filter { $0.value != nil }.mapValues { $0! } as Parameters,
                                      encoding: URLEncoding(destination: .queryString),
                                      headers: providedHeaders
                    ).publishData()
                    .decodeResponseOrError(responseType: responseType,
                                           jsonDecoder: jsonDecoder,
                                           accessTokenInvalidator: accessTokenInvalidator
                    ).eraseToAnyPublisher()
                } else {
                    return prepareCommonHeaders()
                        .flatMap { headers in
                            self.get(endpoint, params: params, headers: headers, responseType: responseType)
                        }.eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
    
    func get<Response>(_ endpoint: String,
                       params: [String : Any?],
                       responseType: Response.Type
    ) -> CallbackPublisher<Response> where Response : Decodable {
        get(endpoint, params: params, headers: nil, responseType: responseType)
    }
    
    func post<Body: Encodable>(_ endpoint: String, body: Body) -> SuccessPublisher {
        prepareCommonHeaders()
            .flatMap { [self] headers -> SuccessPublisher in
                AF.request(NetworkingImpl.baseURL + endpoint,
                           method: .post,
                           parameters: body,
                           encoder: JSONParameterEncoder(encoder: jsonEncoder),
                           headers: headers
                ).publishData()
                .validateResponseOrError(jsonDecoder: jsonDecoder,
                                         accessTokenInvalidator: accessTokenInvalidator)
            }.eraseToAnyPublisher()
    }
    
    func post<Request, Response>(_ endpoint: String,
                                 body: Request,
                                 responseType: Response.Type
    ) -> CallbackPublisher<Response> where Request : Encodable, Response : Decodable {
        prepareCommonHeaders()
            .flatMap { [self] headers -> CallbackPublisher<Response> in
                AF.request(NetworkingImpl.baseURL + endpoint,
                           method: .post,
                           parameters: body,
                           encoder: JSONParameterEncoder(encoder: jsonEncoder),
                           headers: headers
                ).publishData()
                .decodeResponseOrError(responseType: responseType,
                                       jsonDecoder: jsonDecoder,
                                       accessTokenInvalidator: accessTokenInvalidator
                ).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    func put<Body>(_ endpoint: String,
                   body: Body
    ) -> SuccessPublisher where Body : Encodable {
        prepareCommonHeaders()
            .flatMap { [self] headers -> SuccessPublisher in
                AF.request(NetworkingImpl.baseURL + endpoint,
                           method: .put,
                           parameters: body,
                           encoder: JSONParameterEncoder(encoder: jsonEncoder),
                           headers: headers
                ).publishData()
                .validateResponseOrError(jsonDecoder: jsonDecoder,
                                         accessTokenInvalidator: accessTokenInvalidator
                ).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    func invalidate() {
        
    }
    
    private func checkConnectivity<T>(callback: @escaping Callback<T>) -> Bool {
        if !isConnected {
            callback(.failure(NetworkingError.networkUnavailable))
        }
        return isConnected
    }
    
    private func checkConnectivity() -> AnyPublisher<Bool, Error> {
        if !isConnected {
            return Fail(outputType: Bool.self, failure: NetworkingError.networkUnavailable)
                .eraseToAnyPublisher()
        }
        return callbackJust(true)
    }
    
    private func prepareCommonHeaders() -> AnyPublisher<HTTPHeaders, Error> {
        checkConnectivity()
            .flatMap { [self] _ -> AnyPublisher<HTTPHeaders, Error> in
                    return callbackJust(commonHeaders())
            }.eraseToAnyPublisher()
    }
    
    private func commonHeaders() -> HTTPHeaders {
        HTTPHeaders([/*"Authorization": "Bearer \(accessToken)",
                     "X-Request-Time-ISO": DateUtil.format(localIso: Date())*/
        ])
    }
    
    /**
     Extracts the necessary data and decodes the response error.
     */
    private func getResponseOrError<Response>(_ response: AFDataResponse<Any>,
                                              responseType: Response.Type,
                                              callback: @escaping Callback<Response>,
                                              retry: RetryBlock?,
                                              responseDecoder: (Data) throws -> Response) {
        if let error = response.error {
            callback(.failure(error))
            return
        }
        guard let statusCode = response.response?.statusCode,
              let data = response.data else {
            callback(.failure(NetworkingError.unknown))
            return
        }
        do {
            if (200..<300).contains(statusCode) {
                callback(.success(try responseDecoder(data)))
            } else if statusCode == 401, // Unauthorized, need to refresh token
                      let retry = retry {
//                accessToken = nil // invalidate the token
                retry()
            } else {
                callback(.failure(NetworkingError.serverError(try jsonDecoder.decode(ErrorResponse.self, from: data).error.message)))
            }
        } catch {
            callback(.failure(error))
        }
    }
    
    /**
     Just validates the presence of a response or decodes an error.
     */
    private func validateResponseOrError(_ response: AFDataResponse<Any>,
                                         callback: @escaping Callback<Bool>,
                                         retry: RetryBlock?) {
        getResponseOrError(response,
                           responseType: Bool.self,
                           callback: callback,
                           retry: retry) { data in
            true
        }
    }
    
    private func decodeResponseOrError<Response: Decodable>(_ response: AFDataResponse<Any>,
                                                            responseType: Response.Type,
                                                            callback: @escaping Callback<Response>,
                                                            retry: RetryBlock?) {
        getResponseOrError(response,
                           responseType: responseType,
                           callback: callback,
                           retry: retry) { data in
            try jsonDecoder.decode(responseType, from: data)
        }
    }
}

enum NetworkingError: LocalizedError, CustomStringConvertible, Hashable {
    case networkUnavailable,
         unauthorized,
         serverError(String),
         unknown
    
    var description: String {
        let desc: String
        switch self {
        case .networkUnavailable:
            desc = "Network connection unavailable!"
        case .unauthorized:
            desc = "Unauthorized!"
        case .serverError(let message):
            desc = message
        case .unknown:
            desc = "Unknown networking error!"
        }
        let format = NSLocalizedString("%@", comment: "Error description")
        return String.localizedStringWithFormat(format, desc)
    }
}

struct ErrorResponse: Decodable {
    let error: ErrorMessage
    
    enum CodingKeys: CodingKey {
        case error
    }
}

struct ErrorMessage: Decodable {
    let message: String
    
    enum CodingKeys: CodingKey {
        case message
    }
}

private extension DataResponsePublisher where Value == Data {
    func getResponseOrError<Response>(responseType: Response.Type,
                                      responseDecoder: @escaping (Data) throws -> Response,
                                      jsonDecoder: JSONDecoder,
                                      accessTokenInvalidator: @escaping () -> Void
    ) -> CallbackPublisher<Response> {
       tryMap { response in
            guard let statusCode = response.response?.statusCode,
                  let data = response.data
            else {
                throw NetworkingError.unknown
            }
            if (200..<300).contains(statusCode) {
                return try responseDecoder(data)
            } else if statusCode == 401 {
                accessTokenInvalidator()
                throw NetworkingError.unauthorized
            } else {
                throw NetworkingError.serverError(try jsonDecoder.decode(ErrorResponse.self, from: data).error.message)
            }
       }.retry(times: 1, if: { ($0 as? NetworkingError) == .unauthorized })
        .eraseToAnyPublisher()
    }
    
    func validateResponseOrError(jsonDecoder: JSONDecoder,
                                 accessTokenInvalidator: @escaping () -> Void
    ) -> SuccessPublisher {
        getResponseOrError(responseType: Void.self,
                           responseDecoder: { _ in () },
                           jsonDecoder: jsonDecoder,
                           accessTokenInvalidator: accessTokenInvalidator)
    }
    
    func decodeResponseOrError<Response: Decodable>(responseType: Response.Type,
                                                    jsonDecoder: JSONDecoder,
                                                    accessTokenInvalidator: @escaping () -> Void
    ) -> CallbackPublisher<Response> {
        getResponseOrError(responseType: responseType,
                           responseDecoder: { try jsonDecoder.decode(responseType, from: $0) },
                           jsonDecoder: jsonDecoder,
                           accessTokenInvalidator: accessTokenInvalidator)
    }
}
