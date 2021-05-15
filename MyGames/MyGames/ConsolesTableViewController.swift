//
//  ConsolesTableViewController.swift
//  MyGames
//
//  Created by Douglas Frari on 4/27/21.
//

import UIKit
import CoreData

class ConsolesTableViewController: UITableViewController {
    var fetchedResultController: NSFetchedResultsController<Console>!

    lazy var label : UILabel = {
        let label = UILabel()
        label.text = "Você não tem plataformas cadastradas"
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadConsoles()
        
        tableView.allowsSelection = true
        tableView.reloadData()
    }
    
    func loadConsoles() {
        ConsolesManager.shared.loadConsoles(with: context)
        tableView.reloadData()
        
        let fetchRequest: NSFetchRequest<Console> = Console.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self

        do {
            try fetchedResultController.performFetch()
        } catch  {
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Devemos obter os dados do COREDATA aqui ou qualquer estrutura que contem os dados de origem
        let count = fetchedResultController?.fetchedObjects?.count ?? 0
        tableView.backgroundView = count == 0 ? label : nil
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConsoleTableViewCell

        guard let consoleOk = fetchedResultController.fetchedObjects?[indexPath.row] else {
            return cell
        }

        cell.prepareConsole(with: consoleOk)
        return cell
    }

    // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
            ConsolesManager.shared.deleteConsole(index: indexPath.row, context: context)
            tableView.reloadData()
         }
     }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "consoleSegue" {
            let vc = segue.destination as! ConsoleViewController
            
            if let consoles = fetchedResultController.fetchedObjects {
                vc.console = consoles[tableView.indexPathForSelectedRow!.row]
            }
        }
    }

    @IBAction func addConsole(_ sender: Any) {
        showAlert(with: nil)
    }

    func showAlert(with console: Console?) {
        let title = console == nil ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: title + " plataforma", message: nil, preferredStyle: .alert)

        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Nome da plataforma"
            
            if let name = console?.name {
                textField.text = name
            }
        })

        alert.addAction(UIAlertAction(title: title, style: .default, handler: {(action) in
            let console = console ?? Console(context: self.context)
            console.name = alert.textFields?.first?.text
            do {
                try self.context.save()
                self.loadConsoles()
            } catch {
                print(error.localizedDescription)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.view.tintColor = UIColor(named: "second")

        present(alert, animated: true, completion: nil)
    }
} // fim da classe

extension ConsolesTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
         case .delete:
             if let indexPath = indexPath {
                 tableView.deleteRows(at: [indexPath], with: .fade)
             }
             break
         default:
             tableView.reloadData()
        }
    }
}
