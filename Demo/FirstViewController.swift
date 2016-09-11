import UIKit

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func show(sender: AnyObject) {
        let view = UIView(frame: UIScreen.mainScreen().bounds)
        view.height = 300
        view.backgroundColor = UIColor.redColor()
        
        let options = [
            SemiModalOptionKey.PushParentBack.rawValue: true
        ]
        
        presentSemiView(view, options: options) {
            print("Completed!")            
        }
    }

}

