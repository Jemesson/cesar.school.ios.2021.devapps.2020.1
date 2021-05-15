//
//  ConsoleAddEditViewController.swift
//  MyGames
//
//  Created by Jemesson Lima on 15/05/21.
//

import UIKit
import Photos

class ConsoleAddEditViewController: UIViewController {
    var console: Console!

    @IBOutlet weak var tfConsole: UITextField!
    @IBOutlet weak var ivConsole: UIImageView!
    @IBOutlet weak var btConsole: UIButton!
    @IBOutlet weak var btAddEdit: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        ConsolesManager.shared.loadConsoles(with: context)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if console != nil {
            title = "Edit Console"
            btConsole.setTitle("Edit", for: .normal)
            tfConsole.text = console.name
            
            ivConsole.image = console.image as? UIImage
            if console.image != nil {
                btConsole.setTitle(nil, for: .normal)
            }
        }
    }

    @IBAction func addEditImage(_ sender: Any) {
        let alert = UIAlertController(title: "Select image", message: "Choose image:", preferredStyle: .actionSheet)

        let libraryAction = UIAlertAction(title: "Biblioteca", style: .default, handler: {(action: UIAlertAction) in
            self.selectPictureForConsole(sourceType: .photoLibrary)
        })

        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default, handler: {(action: UIAlertAction) in
            self.selectPictureForConsole(sourceType: .savedPhotosAlbum)
        })

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)

        alert.addAction(libraryAction)
        alert.addAction(photosAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func chooseImageFromLibrary(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.navigationBar.tintColor = UIColor(named: "main")
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    private func selectPictureForConsole(sourceType: UIImagePickerController.SourceType) {
        let photos = PHPhotoLibrary.authorizationStatus()

        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.chooseImageFromLibrary(sourceType: sourceType)
                } else {
                    print("You are unauthorized")
                }
            })
        } else if photos == .authorized {
            self.chooseImageFromLibrary(sourceType: sourceType)
        }
    }

    @IBAction func addEditConsole(_ sender: Any) {
        //Acao de salvar um novo jogo ou editar um existente
        
        if console == nil {
            console = Console(context: context)
        }

        console.name = tfConsole.text
        console.image = ivConsole.image
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }

        navigationController?.popViewController(animated: true)
    }
    
}

extension ConsoleAddEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.ivConsole.image = pickerImage
                self.ivConsole.setNeedsDisplay()

                self.btConsole.setTitle(nil, for: .normal)
                self.btConsole.setNeedsDisplay()
            }
        }

        dismiss(animated: true, completion: nil)
    }
}
