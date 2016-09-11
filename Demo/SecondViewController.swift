import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func show(sender: AnyObject) {
        let options = [
            SemiModalOptionKey.PushParentBack.rawValue: true
        ]
        
        let controller = SecondViewController()
        
        controller.view.height = 200
        controller.view.backgroundColor = UIColor.redColor()

        presentSemiViewController(controller, options: options, completion: {
            print("Completed!")
            }, dismissBlock: {
                print("Dismissed!")
        })
    }
}

