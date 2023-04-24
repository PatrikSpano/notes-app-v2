//
//  FormRowStaticView.swift
//  Notes
//
//  Created by Patrik Špaňo on 23/04/2023.
//

import SwiftUI

struct FormRowStaticView: View {
  // MARK: - PROPERTIES
  
  var icon: String
  var firstText: String
  var secondText: String
  
  // MARK: - BODY
  
  var body: some View {
    HStack {
      ZStack {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(Color.blue)
          
        Image(systemName: icon)
          .foregroundColor(Color.white)
      }
      .frame(width: 36, height: 36, alignment: .center)
      
      Text(firstText).foregroundColor(Color.gray)
      Spacer()
      Text(secondText)
    }
  }
}

// MARK: - PREVIEW

struct FormRowStaticView_Previews: PreviewProvider {
  static var previews: some View {
    FormRowStaticView(icon: "gear", firstText: "Application", secondText: "Note")
      .previewLayout(.fixed(width: 375, height: 60))
      .padding()
  }
}
