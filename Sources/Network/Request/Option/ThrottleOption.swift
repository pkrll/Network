//
// Deta
//

import Foundation

public enum ThrottleOption: RequestOption {
    case always
    case never
    
    public static var defaultOption: Self { .always }
}
