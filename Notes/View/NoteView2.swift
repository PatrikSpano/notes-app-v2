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

    @ObservedObject var note: Note

    @State private var title: String
    @State private var inputText: String
    @State private var group: String

    let groups = ["School", "Work", "Personal"]

    init(note: Note) {
        self.note = note
        _title = State(initialValue: note.title ?? "")
        _inputText = State(initialValue: note.inputText ?? "")
        _group = State(initialValue: note.group ?? "Personal")
    }

    // MARK: - BODY
    var body: some View {
        VStack {
            Form {
                TextField("Title", text: $title)
                TextEditor(text: $inputText)
                    .frame(height: 480)
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
        .navigationBarTitle("Note", displayMode: .inline)
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

