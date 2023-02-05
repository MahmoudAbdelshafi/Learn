//
//  LessonCellView.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import SwiftUI

struct LessonCellView: View {
    var imageURL: String
    var title: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        // - Lesson image
        HStack(spacing: 16) {
            
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(4.0)
                    .padding([.leading], 8)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 70, height: 60)
            .background(Color.gray)
            
            
            // - Lesson Title
            Text(title)
                .font(.system(size: 14).weight(.medium))
                .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                .multilineTextAlignment(.leading)
                .padding(.leading)
        }
    }
}

struct LessonCellView_Previews: PreviewProvider {
    static var previews: some View {
        LessonCellView(imageURL: "", title: "Lesson Title")
    }
}
