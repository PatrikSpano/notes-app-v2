//
//  NoteView.swift
//  Notes
//
//  Created by Patrik Špaňo on 26/02/2023.
//

import SwiftUI

struct NoteView: View {
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
                    /*
                    Button(action: {
                        if self.title != "" {
                            let noteToSave = self.note ?? Note(context: self.managedObjectContext) // Use the passed note or create a new one if it doesn't exist
                            noteToSave.title = self.title
                            noteToSave.inputText = self.inputText
                            noteToSave.group = self.group
                            
                            do {
                                try self.managedObjectContext.save()
                                print("Note title: \(noteToSave.title ?? ""), Note text: \(noteToSave.inputText ?? ""), Note group: \(noteToSave.group ?? "")")
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
                */
                } //: FORM
            } //: VSTACK
            .navigationBarTitle("Note", displayMode: .inline)
             .alert(isPresented: $errorShowing) {
                 Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
             }
        }
    }

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView()
    }
}
