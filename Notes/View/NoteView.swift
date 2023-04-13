//
//  NoteView.swift
//  Notes
//
//  Created by Patrik Špaňo on 26/02/2023.
//

import SwiftUI
import CoreData

struct NoteView: View {
    // MARK: - PROPERTIES
    
    @ObservedObject var locationManager = LocationManager.shared
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var note: Note
    
    @State private var title: String
    @State private var inputText: String
    @State private var group: String
    
    let groups = ["School", "Work", "Personal"]
    
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State private var userLocation: String?
    init(note: Note) {
        self.note = note
        _title = State(initialValue: note.title ?? "")
        _inputText = State(initialValue: note.inputText ?? "")
        _group = State(initialValue: note.group ?? "Personal")
    }
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // MARK: - HEADING
                    TextField("Title", text: $title)
                        .submitLabel(.done)
                    
                    // MARK: - LOCATION
                    if let userLocation = userLocation {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text(userLocation)
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                    }
                    
                    // MARK: - IMAGE
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 450, height: 450)
                    } else if let imageData = note.image, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
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
                        ForEach(self.groups, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // MARK: - UPDATE BUTTON
                    Button(action: {
                        if self.title != "" {
                            note.title = title
                            note.inputText = inputText
                            note.group = group
                            
                            // Store user location in the note
                            if let userAddress = locationManager.userAddress {
                                note.userLocation = userAddress
                            } else {
                                // Reset userLocation to nil if location is not available
                                note.userLocation = nil
                            }
                            
                            // Store the image in the note
                            if let selectedImage = selectedImage {
                                if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
                                    note.image = imageData
                                }
                            }
                            
                            do {
                                try managedObjectContext.save()
                                print("Note title: \(note.title ?? ""), Note text: \(note.inputText ?? ""), Note group: \(note.group ?? "")")
                            } catch {
                                print(error)
                            }
                        } else {
                            // Display error message
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Update")
                    } //: UPDATE BUTTON
                } //: FORM
            } //: VSTACK
            
            // MARK: - TOOLBAR
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        shareNote()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        locationManager.requestLocation()
                        if let userAddress = locationManager.userAddress {
                            userLocation = userAddress
                        }
                    } label: {
                        Image(systemName: "location")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isPickerShowing = true
                    } label: {
                        Image(systemName: "camera")
                    }
                    .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                        ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
                    }
                }
            }
            .onReceive(locationManager.$userAddress) { userAddress in
                if let userAddress = userAddress {
                    userLocation = userAddress
                    note.userLocation = userAddress
                }
            }
            .navigationBarTitle("Note", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func shareNote() {
        guard let noteTitle = note.title, let noteText = note.inputText else { return }
        
        var itemsToShare: [Any] = [
            """
            \(noteTitle)
            \(noteText)
            """
        ]
        
        if let noteLocation = note.userLocation {
            itemsToShare.append(noteLocation)
        }
        
        if let imageData = note.image, let image = UIImage(data: imageData) {
            itemsToShare.append(image)
        }
        
        let activityController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let firstWindow = windowScene.windows.first {
                firstWindow.rootViewController?.present(activityController, animated: true, completion: nil)
            }
        }
    }
    
    struct NoteView_Previews: PreviewProvider {
        static var previews: some View {
            let note = Note(context: PersistenceController.preview.container.viewContext)
            note.title = "Sample Note"
            note.inputText = "This is a sample note."
            note.group = "Personal"
            return NoteView(note: note)
        }
    }
}
