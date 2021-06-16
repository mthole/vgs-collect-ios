//
//  VGSCollectRequestLogger.swift
//  VGSCollectSDK
//

import Foundation

/// Utilities to log network requests.
internal class VGSCollectRequestLogger {

	/// no:doc
	internal var loggerPrefix = VGSCollectLogger.loggerPrefix

	/// Log sending request.
	/// - Parameters:
	///   - request: `URLRequest` object, request to send.
	///   - payload: `VGSRequestPayloadBody` object, request payload.
	internal func logRequest(_ request: URLRequest, payload: JsonData?) {

		if !VGSCollectLogger.shared.configuration.isNetworkDebugEnabled {return}

		print("⬆️ Send \(loggerPrefix) request url: \(stringFromURL(request.url))")
		if let headers = request.allHTTPHeaderFields {
			print("⬆️ Send \(loggerPrefix) request headers:")
			print(normalizeRequestHeadersForLogs(headers))
		}
		if let payloadValue = payload {
			print("⬆️ Send \(loggerPrefix) request payload:")
			print(stringifyRawRequestPayloadForLogs(payloadValue))
		}
		print("------------------------------------")
	}

	/// Log failed request.
	/// - Parameters:
	///   - response: `URLResponse?` object.
	///   - data: `Data?` object of failed request.
	///   - error: `Error?` object, request error.
	///   - code: `Int` object, status code.
	internal func logErrorResponse(_ response: URLResponse?, data: Data?, error: Error?, code: Int) {

		if !VGSCollectLogger.shared.configuration.isNetworkDebugEnabled {return}

		if let url = response?.url {
			print("❗Failed ⬇️ \(loggerPrefix) request url: \(stringFromURL(url))")
		}
		print("❗Failed ⬇️ \(loggerPrefix) response status code: \(code)")
		if let httpResponse = response as? HTTPURLResponse {
			print("❗Failed ⬇️ \(loggerPrefix) response headers:")
			print(normalizeHeadersForLogs(httpResponse.allHeaderFields))
		}
		if let errorData = data {
			if let bodyErrorText = String(data: errorData, encoding: String.Encoding.utf8) {
				print("❗Failed ⬇️ \(loggerPrefix) response extra info:")
				if bodyErrorText.count > maxTextCountToPrintLimit {
					print("\(loggerPrefix) response size is too big to print. Use debugger if needed.")
				} else {
					print("\(bodyErrorText)")
				}
			}
		}

		// Track error.
		let errorMessage = (error as NSError?)?.localizedDescription ?? ""

		print("❗Failed ⬇️ \(loggerPrefix) response error message: \(errorMessage)")
		print("------------------------------------")
	}

	/// Log success request.
	/// - Parameters:
	///   - response: `URLResponse?` object.
	///   - data: `Data?` object of success request.
	///   - code: `Int` object, status code.
	internal func logSuccessResponse(_ response: URLResponse?, data: Data?, code: Int) {

		if !VGSCollectLogger.shared.configuration.isNetworkDebugEnabled {return}

		print("✅ Success ⬇️ \(loggerPrefix) request url: \(stringFromURL(response?.url))")
		print("✅ Success ⬇️ \(loggerPrefix) response code: \(code)")

		if let httpResponse = response as? HTTPURLResponse {
			print("✅ Success ⬇️ \(loggerPrefix) response headers:")
			print(normalizeHeadersForLogs(httpResponse.allHeaderFields))
		}

    if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        print("✅ Success ⬇️ \(loggerPrefix) response JSON:")
        print(stringifyJSONForLogs(jsonData))
      }
		print("------------------------------------")
	}

	/// Stringify URL.
	/// - Parameter url: `URL?` to stringify.
	/// - Returns: String representation of `URL` string or "".
	private func stringFromURL(_ url: URL?) -> String {
		guard let requestURL = url else {return ""}
		return requestURL.absoluteString
	}

	/// Utility function to normalize request headers for logging.
	/// - Parameter headers: `[String : String]`, request headers.
	/// - Returns: `String` object, normalized headers string.
	private func normalizeRequestHeadersForLogs(_ headers: [String: String]) -> String {
		let stringifiedHeaders = headers.map({return "  \($0.key) : \($0.value)"}).joined(separator: "\n  ")

		return "[\n  \(stringifiedHeaders) \n]"
	}

	/// Utility function to normalize response headers for logging.
	/// - Parameter headers: `[AnyHashable : Any]`, response headers.
	/// - Returns: `String` object, normalized headers string.
	private func normalizeHeadersForLogs(_ headers: [AnyHashable: Any]) -> String {
		let stringifiedHeaders = headers.map({return "  \($0.key) : \($0.value)"}).joined(separator: "\n  ")

		return "[\n  \(stringifiedHeaders) \n]"
	}

	/// Limit string characters value to print.
	private var maxTextCountToPrintLimit: Int = 50000

	/// Stringify `JSON` for logging.
	/// - Parameter vgsJSON: `VGSJSONData` object.
	/// - Returns: `String` object, pretty printed `JSON`.
	private func stringifyJSONForLogs(_ vgsJSON: JsonData) -> String {
		if let json = try? JSONSerialization.data(withJSONObject: vgsJSON, options: .prettyPrinted) {
			let stringToPrint = String(decoding: json, as: UTF8.self)
			if stringToPrint.count > maxTextCountToPrintLimit {
				return "\(loggerPrefix) response size is too big to print. Use debugger if needed."
			} else {
				return stringToPrint
			}
		} else {
				return ""
		}
	}

	/// Stringify payload of `Any` type for logging.
	/// - Parameter payload: `Any` paylod.
	/// - Returns: `String` object, formatted stringified payload.
	private func stringifyRawRequestPayloadForLogs(_ payload: Any) -> String {
		if let json = payload as? JsonData {
			return stringifyJSONForLogs(json)
		}

		return ""
	}
}
