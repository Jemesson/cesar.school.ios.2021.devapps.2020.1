//
//  ConsoleTableViewCell.swift
//  MyGames
//
//  Created by Jemesson Lima on 15/05/21.
//

import UIKit

class ConsoleTableViewCell: UITableViewCell {
    @IBOutlet weak var lbConsole: UILabel!
    @IBOutlet weak var ivImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func prepareConsole(with console: Console) {
        lbConsole.text = console.name ?? ""

        if let image = console.image as? UIImage {
            ivImage.image = image
        } else {
            ivImage.image = UIImage(named: "noCover")
        }
    }
}
