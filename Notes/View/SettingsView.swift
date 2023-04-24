//
//  Settings.swift
//  Notes
//
//  Created by Patrik Špaňo on 23/04/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // MARK: - SECTION 1
                    Section(header: Text("Appearance")) {
                        Toggle(isOn: $isDarkMode) {
                            Text("Dark Mode")
                        }
                    } //: SECTION 1
                    // MARK: - SECTION 2
                    Section(header: Text("About the application")) {
                        FormRowStaticView(icon: "gear", firstText: "Application", secondText: "Notes")
                        FormRowStaticView(icon: "checkmark.seal", firstText: "Compatibility", secondText: "iPhone")
                        FormRowStaticView(icon: "keyboard", firstText: "Developer", secondText: "Patrik Špaňo")
                        FormRowStaticView(icon: "flag", firstText: "Version", secondText: "1.0.0")
                    } //: SECTION 2
                    .padding(.vertical, 3)
                } //: FORM
                // MARK: - FOOTER
                Text("Copyright © All rights reserved.")
                  .font(.footnote)
                  .padding(.top, 6)
                  .padding(.bottom, 8)
                  .foregroundColor(Color.secondary)
            } //: VStack
            // MARK: - TOOLBAR
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            } //: TOOLBAR
            .navigationBarTitle("Settings", displayMode: .inline)
        } //: NAVIGATION
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}




