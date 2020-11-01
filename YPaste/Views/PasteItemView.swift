//
//  PasteItemView.swift
//  YPaste
//
//  Created by 虚幻 on 2020/10/31.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import SwiftUI
import HotKey

struct PasteItemView: View {
    @State var selected = false
    @ObservedObject var pasteItem: MPasteItem = MPasteItem()
    
    private let normalColor = Color(red: 0.28, green: 0.79, blue: 0.69)
    private let selectedColor = Color(red: 0.078, green: 0.56, blue: 0.467)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text("链接")
                        .font(.system(size: 16))
                    Spacer(minLength: 3)
                    Text(TimeTransformer().transformedValue(pasteItem.updated_at) as! String)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                Spacer()
                Image(pasteItem.favorite ? "favoriteOn" : "favoriteOff")
                    .colorInvert()
                    .onTapGesture {
                        self.pasteItem.favorite.toggle()
                    }
                Image("delete")
                    .colorInvert()
                    .onTapGesture {
                        withAnimation { () -> Void in
//                            pasteItem.managedObjectContext?.delete(pasteItem)
                        }
                    }
            }
            .padding(16)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 54,
                maxHeight: 54,
                alignment: .leading
            )
            .foregroundColor(.white)
            .background(selected ? selectedColor : normalColor)
            HStack(alignment: .top) {
                Text(pasteItem.value ?? "(空)")
            }
            .padding(16)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 120,
                maxHeight: 120,
                alignment: .topLeading
            )
            .background(Color(red: 0.83, green: 0.83, blue: 0.83, opacity: 1))
            .onTapGesture {
//                PasteboardHandler.shared.paste(pasteItem: pasteItem)
            }
        }
        .clipped()
        .cornerRadius(12)
        .animation(nil)
    }
}

struct PasteItemView_Previews: PreviewProvider {
    static var previews: some View {
        PasteItemView()
    }
}
