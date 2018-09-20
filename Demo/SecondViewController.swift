import UIKit
import SemiModalViewController

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func show(_ sender: AnyObject) {
        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: false
        ]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: SemiViewController.self)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        
        controller.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
        controller.view.backgroundColor = UIColor.red

        presentSemiViewController(controller, options: options, completion: {
            print("Completed!")
        }, dismissBlock: {
            print("Dismissed!")
        })
    }
}

