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

    /*
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    */
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            List {
                ForEach(self.notes, id: \.self) { note in
                    NavigationLink(destination: NoteView(note: note)) {
                       Text(note.title ?? "Unknown")
                           .font(.headline)
                       
                        //Text("Note at \(note.timestamp!, formatter: itemFormatter)")
                        //   .font(.footnote)
                        
                       Spacer()
                       
                       Text(note.group ?? "Unknown")
                       }
                   } //: FOREACH
                /*ForEach(items) { item in
                    /*
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                    */
                    NavigationLink(destination: NoteView()){
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                    .navigationTitle("My Notes")
                } */
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

    /*
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    } */
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
