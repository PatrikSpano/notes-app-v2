 //
//  ImagePicker.swift
//  Notes
//
//  Created by Patrik Špaňo on 09/03/2023.
//

import Foundation
import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Binding var isPickerShowing: Bool
    
    //var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        //imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

class Coordinator: NSObject, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    var parent: ImagePicker
    
    init(_ picker: ImagePicker) {
        self.parent = picker
    }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Run code when the user has selected an image
            print("image selected")
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                
                // We are able to get image
                DispatchQueue.main.async {
                    self.parent.selectedImage = image
                }
            }
            // Dismiss the picker
            parent.isPickerShowing = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Run code when the user has cancelled the picker UI
            print("cancelled")
            
            // Dismiss the picker
            parent.isPickerShowing = false
        }
    }
