import UIKit

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func show(_ sender: AnyObject) {
        let view = UIView(frame: UIScreen.main.bounds)
        view.height = 300
        view.backgroundColor = UIColor.red
        
        let options = [
            SemiModalOptionKey.PushParentBack.rawValue: true
        ]
        
        presentSemiView(view, options: options) {
            print("Completed!")            
        }
    }

}

