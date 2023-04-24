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
    @State private var showingSettingsView: Bool = false
    
    @FetchRequest(fetchRequest: getNoteFetchRequest)
    
    var notes: FetchedResults<Note>
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
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
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(note.title ?? "Unknown")
                                    .font(.headline)
                                
                                if let timestamp = note.timestamp {
                                    Text(itemFormatter.string(from: timestamp))
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            
                            Text(note.group ?? "Unknown")
                        }
                    }
                } //: FOREACH
                .onDelete(perform: deleteNote)
            } //: LIST
            .searchable(text: $searchText)
            .navigationBarTitle("My Notes", displayMode: .large)
           
            // MARK: - TOOLBAR
            .toolbar {
                /*
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        //.foregroundColor(.yellow)
                }
                */
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.showingSettingsView.toggle()
                    }) {
                        Label("Add Item", systemImage: "gear.circle")
                    }
                    .sheet(isPresented: $showingSettingsView){
                        SettingsView().environment(\.managedObjectContext, self.managedObjectContext)
                        //.foregroundColor(.yellow)
                    }
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
            } //: TOOLBAR
            Text("Select an item")
        } //: NAVIGATION
        .onAppear {
            updateAppAppearance()
        }
        .onChange(of: isDarkMode) { _ in
            updateAppAppearance()
        }
    }
    
    private func updateAppAppearance() {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                windowScene.windows.first?.rootViewController?.view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
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
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

