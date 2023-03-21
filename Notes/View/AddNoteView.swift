//
//  AddNoteView.swift
//  Notes
//
//  Created by Patrik Špaňo on 23/02/2023.
//

import SwiftUI
import CoreData
import CoreLocation
import CoreLocationUI

struct AddNoteView: View {
    // MARK: - PROPERTIES
    
    @ObservedObject var locationManager = LocationManager.shared
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var inputText: String = ""
    @State private var group: String = "Personal"
    
    let groups = ["School", "Work", "Personal"]
    
    @State private var errorShowing: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    
    @State private var showLocation = false
    @State private var showLocationButton = true
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // MARK: - HEADING
                    TextField("Title", text: $title)
                        .submitLabel(.done)
                    
                    //MARK: - LOCATION
                    if locationManager.userAddress != nil {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text(locationManager.userAddress!)
                                .foregroundColor(.gray)
                                .font(.footnote)
                            }
                        }
                    
                    // MARK: - IMAGE
                     if selectedImage != nil {
                         Image(uiImage: selectedImage!)
                             .resizable()
                             .scaledToFit()
                             .frame(width: 450, height: 450)
                     }
                    
                    // MARK: - TEXT EDITOR
                    TextEditor(text: $inputText)
                        .frame(height: 400)
                        .submitLabel(.done)
                    
                    // MARK: - NOTE GROUP
                    Picker("Group", selection: $group) {
                        ForEach(groups, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // MARK: - SAVE BUTTON
                    Button(action: {
                        if self.title != "" {
                            let note = Note(context: self.managedObjectContext)
                            note.title = self.title
                            note.inputText = self.inputText
                            note.group = self.group
                            
                            // Store user location in the note
                            if let userAddress = locationManager.userAddress {
                                note.userLocation = userAddress
                            }
                            
                            // Store the image in the note
                            if let selectedImage = selectedImage {
                                if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
                                        note.image = imageData
                                }
                            }
                            
                            do {
                                try self.managedObjectContext.save()
                                print("title: \(note.title ?? ""), text: \(note.inputText ?? ""), group: \(note.group ?? ""), location: \(note.userLocation ?? "")")
                            } catch {
                                print(error)
                            }
                        } else {
                            self.errorShowing = true
                            self.errorTitle = "Invalid Name"
                            self.errorMessage = "Make sure to fill in all field."
                            return
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                    } //: SAVE BUTTON
                } //: FORM
            } //: VSTACK
            // MARK: - TOOLBAR
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                     locationManager.userAddress = nil // Reset userAddress
                     self.presentationMode.wrappedValue.dismiss()
                 }) {
                     Image(systemName: "xmark")
                 }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        if showLocationButton {
                            LocationManager.shared.requestLocation()
                        } else {
                            showLocation.toggle()
                            LocationManager.shared.requestLocation()
                        }
                    } label: {
                        Image(systemName: "location")
                    }
                }
                                
                ToolbarItem(placement: .bottomBar) {
                    Button{
                        isPickerShowing = true
                    } label: {
                        Image(systemName: "camera")
                    }
                    .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                        ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
                    }
                }
            }
            .onReceive(locationManager.$userLocation) { userLocation in
                showLocationButton = userLocation == nil
            }
            .navigationBarTitle("New Note", displayMode: .inline)
             .alert(isPresented: $errorShowing) {
                 Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
             }
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView()
    }
}
