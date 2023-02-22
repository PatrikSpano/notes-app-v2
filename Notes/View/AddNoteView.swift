//
//  AddNoteView.swift
//  Notes
//
//  Created by Patrik Špaňo on 23/02/2023.
//

import SwiftUI
import CoreData

struct AddNoteView: View {
    // MARK: - PROPERTIES
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var inputText: String = ""
    @State private var group: String = "Personal"
    
    let groups = ["School", "Work", "Personal"]
    
    @State private var errorShowing: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // MARK: - NOTE NAME
                    TextField("Title", text: $title)
                    TextEditor(text: $inputText)
                        .frame(height: 300)
                    
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
                            
                            do {
                                try self.managedObjectContext.save()
                                print("Note title: \(note.title ?? ""), Note text: \(note.inputText ?? ""), Note group: \(note.group ?? "")")
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
            .navigationBarTitle("New Note", displayMode: .inline)
             .navigationBarItems(trailing:
                Button(action: {
                 self.presentationMode.wrappedValue.dismiss()
             }) {
                 Image(systemName: "xmark")
             }
            )
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
