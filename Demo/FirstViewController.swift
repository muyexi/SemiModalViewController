import UIKit
import SemiModalViewController

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func show(_ sender: AnyObject) {
        let view = UIView(frame: UIScreen.main.bounds)
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)
        view.backgroundColor = UIColor.red
        
        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: true
        ]
        
        presentSemiView(view, options: options) {
            print("Completed!")            
        }
    }

}

