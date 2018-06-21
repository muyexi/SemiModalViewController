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
            SemiModalOption.pushParentBack: true
        ]
        
        presentSemiView(view, options: options) {
            print("Completed!")            
        }
    }

}

