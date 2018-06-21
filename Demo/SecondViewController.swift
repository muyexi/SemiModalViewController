import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func show(_ sender: AnyObject) {
        let options = [
            SemiModalOption.pushParentBack: false
        ]
        
        let controller = UIViewController()
        
        controller.view.height = 200
        controller.view.backgroundColor = UIColor.red

        presentSemiViewController(controller, options: options, completion: {
            print("Completed!")
            }, dismissBlock: {
                print("Dismissed!")
        })
    }
}

