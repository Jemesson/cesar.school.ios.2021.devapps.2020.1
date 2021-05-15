//
//  CarsTableViewController.swift
//  Carangas
//
//  Created by Eric Brito on 21/10/17.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {
    var cars: [Car] = []
    
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "main")
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = NSLocalizedString("Carregando dados...", comment: "")
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func loadData() {
        
        REST.loadCars(onComplete: { cars in
            self.cars = cars
            
            if self.cars.isEmpty {
                DispatchQueue.main.async {
                    // TODO setar o background
                    self.label.text = "Sem dados"
                    self.tableView.backgroundView = self.label
                }
            } else {
                // precisa recarregar a tableview usando a main UI thread
                DispatchQueue.main.async {
                    // parar animacao do refresh
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }) { error in

            var response: String = ""

            switch error {
                case .invalidJSON:
                    response = "invalidJSON"
                case .noData:
                    response = "noData"
                case .noResponse:
                    response = "noResponse"
                case .url:
                    response = "InvalidURL"
                case .taskError(let error):
                    response = "\(error.localizedDescription)"
                case .responseStatusCode(let code):
                    if code != 200 {
                        response = "Server error: [Error code: \(code)]"
                }
            }

            DispatchQueue.main.async {
                self.label.text = response
                self.tableView.backgroundView = self.label
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cars.count == 0 {
            self.tableView.backgroundView = self.label
        } else {
            self.label.text = ""
            self.tableView.backgroundView = nil
        }

        return cars.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let car = cars[indexPath.row]

            REST.delete(car: car) { success in
                if success {
                    // remover da estrutura local antes de atualizar
                    self.cars.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        // Delete the row from the data source
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlertOnDelete(withTitle: "Remover", withMessage: "Não foi possível remover o carro.")
                    }
                }
            }
        }
    }
    
    func showAlertOnDelete(withTitle titleMessage: String, withMessage message: String) {
        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "viewSegue" {
            
            let vc = segue.destination as? CarViewController
            let index = tableView.indexPathForSelectedRow!.row
            vc?.car = cars[index]
        }
    }
}
