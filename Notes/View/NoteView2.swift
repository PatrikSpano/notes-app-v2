//
//  NoteView.swift
//  Notes
//
//  Created by Patrik Špaňo on 26/02/2023.
//

import SwiftUI
import CoreData

struct NoteView2: View {
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
    
    @FetchRequest(entity: Note.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Note.title, ascending: true)])
    var notes: FetchedResults<Note>
    
    var body: some View {
        VStack {
            Form {
                // MARK: - NOTE NAME
                TextField("Title", text: $title)
                TextEditor(text: $inputText)
                    .frame(height: 480)
                
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
                        let noteToSave = notes.first ?? Note(context: managedObjectContext)
                        noteToSave.title = title
                        noteToSave.inputText = inputText
                        noteToSave.group = group
                        
                        do {
                            try managedObjectContext.save()
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
                    Text("Update")
                } //: SAVE BUTTON
            } //: FORM
        } //: VSTACK
        .navigationBarTitle("Note", displayMode: .inline)
        
        .onAppear {
            if let note = notes.first {
                _title = State(initialValue: note.title ?? "")
                _inputText = State(initialValue: note.inputText ?? "")
                _group = State(initialValue: note.group ?? "Personal")
            }
        }
        .alert(isPresented: $errorShowing) {
            Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct NoteView2_Previews: PreviewProvider {
    static var previews: some View {
        NoteView2()
    }
}
