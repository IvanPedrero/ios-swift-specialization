import UIKit

// Use this String extension method to encode a string to be passed in a URL request.
// When sending a string as a parameter in a URL query, you must replace certain characters with escape sequences.
// This function will return a string that is safe to embed in a URL query.
// It will escape any non-alphanumeric characters, except for the specified exceptions.

extension String {
    func encodedStringForURLEncodedFormData() -> String? {
        let exceptions = "*-._"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: exceptions)
        
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

// Use this class to communicate with the Microsoft Cognitive Services API.
// Our sample implementation has one instance method that lets you use MSCS's image analysis service.
// You can find more APIs by browsing the MSCS documentation.
// Use the analyzeImage function as a guide on constructing a request and parsing the returned data.

class MSCSAPIClient {
    
    fileprivate let subscriptionKey: String
    
    // enter your MS endpoint base URL here
    static let endpointBaseURL = "https://westcentralus.api.cognitive.microsoft.com/vision/v3.0"
    static let analyzeURL = endpointBaseURL + "/analyze"
    
    enum MSCSAPIClientError: Int {
        case urlError
        case imageFormatError
        case imageSizeError
        case imageDimensionsError
        case jsonFormatError
        case stringEncodingError
        case missingData
    }
    
    enum FeatureTypes: String {
        case Categories = "Categories"
        case Tags = "Tags"
        case Description = "Description"
        case Faces = "Faces"
        case ImageType = "ImageType"
        case Color = "Color"
        case Adult = "Adult"
    }
    
    // Note a Computer Vision subscription key is required to analyze images with this service.
    // You may need additional subscription keys to access additional services.
    init(subscriptionKey: String) {
        self.subscriptionKey = subscriptionKey
    }
    
    // Extract a set of visual features based on image content.
    // See here for more documentation of this service: https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fa
    
    func analyzeImage(_ image: UIImage, detectFeatures featureTypes: [FeatureTypes], completion:@escaping (AnyObject?, Error?) -> Void) {
        
        // Note how calls to our completion block are wrapped in 'dispatch_async(dispatch_get_main_queue()) {}'.
        // This is necessary to ensure the completion block is called on the main queue. Only code on the main queue
        // may update user interface elements, call Cocoa APIs, etc.
        // It's also done to ensure the completion block is not called before this function returns, in case
        // the user of this function doesn't expect that to happen.
        
        // Check image properties to make sure it conforms to the API requirements.
        // Size must be > 50px by 50px
        guard image.size.height > 50 && image.size.width > 50 else {
            DispatchQueue.main.async(execute: {
                let error = NSError(domain: "MSCSAPIClient", code: MSCSAPIClientError.imageSizeError.rawValue, userInfo: [NSLocalizedDescriptionKey:"Image is too small."])
                completion(nil, error)
            })
            return
        }
        
        // Make sure we can create a valid JPEG version of the images.
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {
            DispatchQueue.main.async(execute: {
                let error = NSError(domain: "MSCSAPIClient", code: MSCSAPIClientError.imageFormatError.rawValue, userInfo: [NSLocalizedDescriptionKey:"Image could not be converted to JPEG."])
                completion(nil, error)
            })
            return
        }
        
        // Image data size must be < 4MB total.
        guard imageData.count < 4 * 1024 * 1024 else {
            DispatchQueue.main.async(execute: {
                let error = NSError(domain: "MSCSAPIClient", code: MSCSAPIClientError.imageSizeError.rawValue, userInfo: [NSLocalizedDescriptionKey:"Image must be < 4 MB in size after being converted to JPEG."])
                completion(nil, error)
            })
            return
        }
        
        // Construct the URL for the request.
        let allFeatures = featureTypes.map { $0.rawValue }.joined(separator: ",")
        
        let parameters: [String] = ["visualFeatures=\(allFeatures)", "language=en"]
        let queryString = "?" + parameters.joined(separator: "&")
        let requestString = MSCSAPIClient.analyzeURL + queryString
        guard let requestURL = URL(string: requestString) else {
            DispatchQueue.main.async(execute: {
                let error = NSError(domain: "MSCSAPIClient", code: MSCSAPIClientError.urlError.rawValue, userInfo: [NSLocalizedDescriptionKey:"There was a problem constructing the request URL."])
                completion(nil, error)
            })
            return
        }
        
        // Create the request and add the required HTTP fields and values.
        var request = URLRequest(url: requestURL)
        request.setValue(self.subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = imageData
        
        // Send the network data task.
        // Don't forget to call resume() on the new data task!
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
                return
            }
            
            // Make sure some data was returned.
            guard let responseData = data else {
                let error = NSError(domain: "MSCSAPIClient", code: MSCSAPIClientError.missingData.rawValue, userInfo: [NSLocalizedDescriptionKey:"No data was returned."])
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
                return
            }
            
            // Parse the raw text data into an object.
            guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                let error = NSError(domain: "MSCSAPIClient", code: MSCSAPIClientError.jsonFormatError.rawValue, userInfo: [NSLocalizedDescriptionKey:"Coul not decode JSON data from response."])
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
                return
            }
            
            // Return the JSON object if everything is ok.
            
            DispatchQueue.main.async(execute: { 
                completion(jsonObject as AnyObject?, error)
            })
            
            
        }) .resume()
        
    }
 
}
