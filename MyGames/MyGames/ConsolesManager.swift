//
//  ConsolesManager.swift
//  MyGames
//
//  Created by Douglas Frari on 4/29/21.
//

import Foundation

import CoreData

class ConsolesManager {
 
    static let shared = ConsolesManager()
    var consoles: [Console] = []
 
    func loadConsoles(with context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Console> = Console.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
     
        do {
            consoles = try context.fetch(fetchRequest)
        } catch  {
            print(error.localizedDescription)
        }
    }
 
 
    func deleteConsole(index: Int, context: NSManagedObjectContext) {
        if (!consoles.isEmpty) {
            let console = consoles[index]
            context.delete(console)
         
            do {
                try context.save()
                // tirar da lista local de consoles para manter a estrutura dos dados atualizados
                consoles.remove(at: index)
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
 
    private init() {
     
    }
}
