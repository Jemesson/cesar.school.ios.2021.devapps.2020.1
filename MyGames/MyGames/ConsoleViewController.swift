//
//  ConsoleViewController.swift
//  MyGames
//
//  Created by Jemesson Lima on 15/05/21.
//

import UIKit

class ConsoleViewController: UIViewController {
    var console: Console?

    @IBOutlet weak var lbConsole: UILabel!
    @IBOutlet weak var ivConsole: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        lbConsole.text = console?.name ?? ""

        if let image = console?.image as? UIImage {
            ivConsole.image = image
        } else {
            ivConsole.image = UIImage(named: "noCoverFull")
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "consoleEditSegue") {
            let vc = segue.destination as! ConsoleAddEditViewController
            vc.console = console!
        }
    }
}
