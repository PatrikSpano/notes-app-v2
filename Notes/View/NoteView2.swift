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
                ForEach(self.notes, id: \.self) { note in
                    TextField("Title", text: $title)
                    TextEditor(text: $inputText)
                        .frame(height: 480)
                    Picker("Group", selection: $group) {
                        ForEach(self.groups, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onAppear(perform: {
                        self.title = note.title ?? ""
                        self.inputText = note.inputText ?? ""
                        self.group = note.group ?? ""
                    })
                } //: FOREACH
            } //: FORM
            
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
                    self.errorMessage = "Make sure to fill in all fields."
                    return
                }
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Update")
            } //: SAVE BUTTON
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
