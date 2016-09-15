import UIKit

class ClosureWrapper: NSObject, NSCopying {
    var closure: (() -> Void)?
    
    convenience init(closure: (() -> Void)?) {
        self.init()
        self.closure = closure
    }
    
    func copy(with zone: NSZone?) -> Any {
        let wrapper: ClosureWrapper = ClosureWrapper()
        
        wrapper.closure = self.closure
        
        return wrapper;
    }
    
}
