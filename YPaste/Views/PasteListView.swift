//
//  PasteListView.swift
//  YPaste
//
//  Created by 虚幻 on 2020/10/31.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import SwiftUI
import Combine
import Carbon

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

class KeyboardInput: ObservableObject {
    @Published var keyEvent: NSEvent = NSEvent()
}

// Environment key to hold even publisher
struct WindowEventPublisherKey: EnvironmentKey {
    static let defaultValue: AnyPublisher<NSEvent, Never> =
        Just(NSEvent()).eraseToAnyPublisher() // just default stub
}


// Environment value for keyPublisher access
extension EnvironmentValues {
    var keyPublisher: AnyPublisher<NSEvent, Never> {
        get { self[WindowEventPublisherKey.self] }
        set { self[WindowEventPublisherKey.self] = newValue }
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

//struct KeyboardEvent: NSViewRepresentable {
//    @Binding private var event: NSEvent
//    init(_ event: Binding<NSEvent>) {
//        self._event = event
//    }
//    class KeyView: NSView {
//        var owner: KeyboardEvent?   // << view holder
//        override var acceptsFirstResponder: Bool { true }
//        override func keyDown(with event: NSEvent) {
//            super.keyDown(with: event)
//            print(">> key \(event)")
//            owner?.event = event
//        }
//    }
//
//    func makeNSView(context: Context) -> NSView {
//        let view = KeyView()
//        view.owner = self
//        DispatchQueue.main.async { // wait till next event cycle
//            view.window?.makeFirstResponder(view)
//        }
//        return view
//    }
//
//    func updateNSView(_ nsView: NSView, context: Context) {
//    }
//}

struct FilteredList<T: NSManagedObject, Content: View>: View {
    var fetchRequest: FetchRequest<T>
    var items: FetchedResults<T> { fetchRequest.wrappedValue }

    let content: (Int, T) -> Content

    var body: some View {
        let list = items.count >= 100 ? items[0...100] : items[0...]
        return List(Array(list.enumerated()), id: \.element) { (index, item) in
            self.content(index, item)
        }
        .delayedAnimation(delay: 0.2, animation: .easeInOut)
        .id(UUID())
    }

    init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor] = [], @ViewBuilder content: @escaping (Int, T) -> Content) {
        fetchRequest = FetchRequest<T>(entity: T.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }
}


struct PasteListView: View {
    @State var selectedIndex = 0
    
    @State private var keyword = ""
    
    @State private var predicate: NSPredicate?
    
    @Environment(\.keyPublisher) private var keyEventPublisher

    // MARK: Core Data性能太差，后面建议弃用
    var body: some View {
        VStack {
            Spacer()
            TextField("enter keyword", text: $keyword, onCommit: {
                updatePredicate()
            })
            .textFieldStyle(PlainTextFieldStyle())
            .padding([.leading, .trailing], 12)
            .padding([.top, .bottom], 8)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
            .padding([.leading, .trailing], 24)
//                .onReceive(
//                    Just(keyword)
//                        .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: true)
//                        .removeDuplicates()
//                ) { (val) in
//                    updatePredicate()
//                }
            
            FilteredList<PasteItem, PasteItemView>(
                predicate: predicate,
                sortDescriptors: [NSSortDescriptor(key: "updated_at", ascending: false)]
            ) { (index, pasteItem) in
                PasteItemView(selected: index == selectedIndex, pasteItem: pasteItem)
            }
        }
        .onReceive(keyEventPublisher) { event in // << listen to events
            keyDown(event)
        }
        .background(Color.white)
//        .background(
//            KeyboardEvent($keyboardInput.keyEvent)
//        )
    }
    
    func updatePredicate() {
        predicate = keyword.count > 0
            ? NSPredicate(format: "value contains[cd] %@", self.$keyword.wrappedValue)
            : nil
    }
    
    func keyDown(_ event: NSEvent) {
        print(event)
        switch (Int(event.keyCode)) {
        case kVK_DownArrow:
            selectedIndex += 1
            break
        case kVK_UpArrow:
            selectedIndex = selectedIndex <= 0 ? 0 : selectedIndex - 1
            break
        case kVK_Return:
            print("paste item")
        default:
            print(event)
        }
    }
}

struct PasteListView_Previews: PreviewProvider {
    static var previews: some View {
        PasteListView()
    }
}
