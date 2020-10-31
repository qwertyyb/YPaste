//
//  PasteListView.swift
//  YPaste
//
//  Created by 虚幻 on 2020/10/31.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import SwiftUI

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

struct DelayedAnimation: ViewModifier {
  var delay: Double
  var animation: Animation

  @State private var animating = false

  func delayAnimation() {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      self.animating = true
    }
  }

  func body(content: Content) -> some View {
    content
      .animation(animating ? animation : nil)
      .onAppear(perform: delayAnimation)
  }
}

extension View {
  func delayedAnimation(delay: Double = 1.0, animation: Animation = .default) -> some View {
    self.modifier(DelayedAnimation(delay: delay, animation: animation))
  }
}

struct PasteListView: View {
    @State var selectedIndex = 0
    let managedObjectContext: NSManagedObjectContext =  ((NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!

    @FetchRequest(
        entity: PasteItem.entity(),
        sortDescriptors: [NSSortDescriptor(key: "updated_at", ascending: false)],
        predicate: nil, animation: nil
    ) var pasteList: FetchedResults<PasteItem>
    
    @State private var keyword = ""
    
    var body: some View {
        print(managedObjectContext)
        return VStack {
            Spacer()
            TextField("enter keyword", text: $keyword)
                .textFieldStyle(PlainTextFieldStyle())
                .padding([.leading, .trailing], 12)
                .padding([.top, .bottom], 8)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
                .padding([.leading, .trailing], 24)
                .focusable()

            List(Array(pasteList.enumerated()), id: \.element) { (index, item) -> PasteItemView in
                PasteItemView(selected: index == selectedIndex, pasteItem: item)
            }
            .delayedAnimation(delay: 0.2, animation: .easeInOut)
        }
        .background(Color.white)
    }
    
    func selectNext() {
        selectedIndex += 1
    }
    
    func selectPrev() {
        selectedIndex -= 1
    }
}

struct PasteListView_Previews: PreviewProvider {
    static var previews: some View {
        PasteListView()
    }
}
