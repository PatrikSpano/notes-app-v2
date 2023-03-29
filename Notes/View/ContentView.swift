//
//  ContentView.swift
//  Notes
//
//  Created by Patrik Špaňo on 22/02/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - PROPERTIES
    
    @ObservedObject var locationManager = LocationManager.shared
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var showingAddNoteView: Bool = false
    
    @FetchRequest(fetchRequest: getNoteFetchRequest)
    
    var notes: FetchedResults<Note>
    
    static var getNoteFetchRequest: NSFetchRequest<Note> {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Note.title, ascending: true)]
        return request
    }
    
    @State private var searchText = ""
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            List {
                ForEach(self.notes.filter { note in
                    searchText.isEmpty ||
                    note.group?.localizedStandardContains(searchText) ?? false
                }, id: \.self) { note in
                    NavigationLink(destination: NoteView(note: note)) {
                        Text(note.title ?? "Unknown")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(note.group ?? "Unknown")
                    }
                } //: FOREACH
                .onDelete(perform: deleteNote)
            }
            .searchable(text: $searchText)
            .navigationBarTitle("My Notes", displayMode: .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        //.foregroundColor(.yellow)
                }
                ToolbarItem(placement : .navigationBarTrailing) {
                    Button(action: {
                        locationManager.userAddress = nil // Reset userAddress
                        self.showingAddNoteView.toggle()
                    }) {
                        Label("Add Item", systemImage: "square.and.pencil")
                    }
                    .sheet(isPresented: $showingAddNoteView){
                        AddNoteView().environment(\.managedObjectContext, self.managedObjectContext)
                        //.foregroundColor(.yellow)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Text("\(notes.count) Notes")
                        .font(.footnote)
                }
            }
            Text("Select an item")
        }
    }
    
    private func deleteNote(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            managedObjectContext.delete(note)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

