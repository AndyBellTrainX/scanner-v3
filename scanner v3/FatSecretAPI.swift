import Foundation

class FatSecretAPI {
    private let clientId: String
    private let clientSecret: String
    private var accessToken: String?
    private let baseURL = "https://platform.fatsecret.com/rest/server.api"
    
    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    private func authenticate() async throws {
        let tokenURL = "https://oauth.fatsecret.com/connect/token"
        
        guard let url = URL(string: tokenURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Create Basic Auth header
        let credentials = "\(clientId):\(clientSecret)".data(using: .utf8)!
        let base64Credentials = credentials.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Create form data
        let formItems = [
            "grant_type": "client_credentials",
            "scope": "basic premier"
        ]
        
        let formBody = formItems
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        request.httpBody = formBody.data(using: .utf8)
        
        print("Authentication Request Headers: \(String(describing: request.allHTTPHeaderFields))")  // Debug print
        print("Authentication Request Body: \(formBody)")  // Debug print
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Print response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("Authentication Status Code: \(httpResponse.statusCode)")
                print("Authentication Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Authentication Response: \(jsonString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.authenticationFailed
            }
            
            let decoder = JSONDecoder()
            let authResponse = try decoder.decode(AuthResponse.self, from: data)
            self.accessToken = authResponse.access_token
            
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw APIError.invalidResponse
        } catch {
            print("Authentication error: \(error)")
            throw APIError.authenticationFailed
        }
    }
    
    func searchFood(query: String) async throws -> [Food] {
        if accessToken == nil {
            try await authenticate()
        }
        
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "method", value: "foods.search"),
            URLQueryItem(name: "search_expression", value: query),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "oauth_token", value: accessToken)
        ]
        
        guard let finalURL = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Print response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("Search Status Code: \(httpResponse.statusCode)")
                print("Search Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Search Response: \(jsonString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(FoodSearchResponse.self, from: data)
            return searchResponse.foods.food
            
        } catch {
            print("Search error: \(error)")
            throw error
        }
    }
    
    func getFoodById(id: String) async throws -> FoodDetails {
        if accessToken == nil {
            try await authenticate()
        }
        
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "method", value: "food.get"),
            URLQueryItem(name: "food_id", value: id),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "oauth_token", value: accessToken)
        ]
        
        guard let finalURL = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Print response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("Food Details Status Code: \(httpResponse.statusCode)")
                print("Food Details Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Food Details Response: \(jsonString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let foodResponse = try decoder.decode(FoodDetailsResponse.self, from: data)
            return foodResponse.food
            
        } catch {
            print("Food details error: \(error)")
            throw error
        }
    }
}

// MARK: - Models

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let token_type: String
}

struct FoodSearchResponse: Codable {
    let foods: Foods
}

struct Foods: Codable {
    let food: [Food]
}

struct Food: Codable {
    let food_id: String
    let food_name: String
    let food_description: String?
    let brand_name: String?
}

struct FoodDetailsResponse: Codable {
    let food: FoodDetails
}

struct FoodDetails: Codable {
    let food_id: String
    let food_name: String
    let servings: Servings
}

struct Servings: Codable {
    let serving: [Serving]
}

struct Serving: Codable {
    let calories: String
    let serving_description: String
    let metric_serving_amount: String?
    let metric_serving_unit: String?
    let protein: String?
    let carbohydrate: String?
    let fat: String?
}

enum APIError: Error {
    case invalidURL
    case authenticationFailed
    case invalidResponse
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .authenticationFailed:
            return "Failed to authenticate with FatSecret API"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError:
            return "Network error occurred"
        }
    }
} 