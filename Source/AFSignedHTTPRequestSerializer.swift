import AFNetworking
import IGDigest

open class AFSignedHTTPRequestSerializer : AFJSONRequestSerializer {
  
  open var clientVersion = "3"
  open var clientId: String
  open var clientSecret: String
  
  public init(clientId : String, clientSecret : String) {
    
    self.clientId = clientId
    self.clientSecret = clientSecret
    
    super.init()
  }
  
  open override func encode(with aCoder: NSCoder) {
    super.encode(with: aCoder)
    
    aCoder.encode(self.clientId, forKey: "clientId")
    aCoder.encode(self.clientSecret, forKey: "clientSecret")
  }
  
  required public init?(coder aDecoder: NSCoder) {
    self.clientId = aDecoder.decodeObject(forKey: "clientId") as! String
    self.clientSecret = aDecoder.decodeObject(forKey: "clientSecret") as! String
    
    super.init(coder: aDecoder)
  }
  
  override open func request(withMethod method: String, urlString URLString: String, parameters: Any?, error: NSErrorPointer) -> NSMutableURLRequest {
    
    var newParams = [String : Any]()
    if let currentParams = parameters as? [String : Any] {
      newParams = currentParams
    }
    
    let signedParams = self.signatureParams(method, urlString: URLString, params: newParams)
    for key in signedParams.keys {
      newParams[key] = signedParams[key]
    }
    
    let request = super.request(withMethod: method, urlString: URLString, parameters: newParams, error: error)
    
    return request
  }
  
  
  open func signatureParams(_ method : String, urlString : String, params : [String : Any?]) -> [String : Any] {
    
    let timestamp = String(format: "%d", Int(Date().timeIntervalSince1970))
    
    let components = [
      method,
      urlString,
      parameterString(params)
    ]
    
    let signatureParam = components.joined(separator: "\n")
    let signature = signatureParam.sha256HMAC(withKey: clientSecret)
    
    var signedParams = [String : Any]()
    
    signedParams["auth_version"] = self.clientVersion
    signedParams["auth_client_id"] = self.clientId
    signedParams["auth_timestamp"] = timestamp
    signedParams["auth_signature"] = signature
    
    return signedParams
  }
  
  open func parameterString(_ params : [String : Any?]) -> String {
    
    var lowerCaseParams = [String : Any?]()
    
    for (key, value) in params {
      lowerCaseParams[key.lowercased()] = value
    }
    
    let keys = lowerCaseParams.keys
    let sortedKeys = keys.sorted { $0 < $1 }
    
    let encodedParamerers = NSMutableArray()
    for (_, key) in sortedKeys.enumerated() {
      
      if let value = lowerCaseParams[key] {
        encodedParamerers.add(encode(key, value: value))
      } else {
        encodedParamerers.add(encode(key, value: ""))
      }
    }
    
    return encodedParamerers.componentsJoined(by: "&")
  }
  
  open func encode(_ key : String, value : Any?) -> String {
    
    if let currentValue = value as? [String : Any] {
      if currentValue.count == 0 {
        return ""
      }
      
      do {
        let json = try JSONSerialization.data(withJSONObject: currentValue, options: [])
        
        if let jsonString = String(data: json, encoding: String.Encoding.utf8) {
          
          return String(format: "%@=%@", key.af_urlEncodedString(), jsonString.af_urlEncodedString())
        }
        
      }
      catch _ as NSError {
      }
    } else if let currentValue = value as? Array<Any> {
      if currentValue.count == 0 {
        return ""
      }
      
      
      do {
        let json = try JSONSerialization.data(withJSONObject: currentValue, options: [])
        
        if let jsonString = String(data: json, encoding: String.Encoding.utf8) {
          return String(format: "%@=%@", key.af_urlEncodedString(), jsonString.af_urlEncodedString())
        }
        
      }
      catch _ as NSError {
      }
    } else if let currentValue = value as? String {
      return String(format: "%@=%@", key.af_urlEncodedString(), currentValue.af_urlEncodedString())
    } else if let currentValue = value as? NSNumber {
      return String(format: "%@=%@", key.af_urlEncodedString(), currentValue)
    } else if let currentValue = value as? Int {
      return String(format: "%@=%@", key.af_urlEncodedString(), NSNumber(value: currentValue))
    } else if let currentValue = value as? Double {
      return String(format: "%@=%@", key.af_urlEncodedString(), NSNumber(value: currentValue))
    }
    
    return ""
  }
}

extension String {
  
  public func af_urlEncodedString() -> String {
    let charactersToBeEscaped = "!*'\"();:@&=+$,/?%#[]% " as CFString
    
    let result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, self as CFString!, nil, charactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
    
    return result as! String
  }
}
