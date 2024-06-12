////
//
//import SwiftUI
//
//struct SlideUpTransition: ViewModifier {
//    @Binding var show: Bool
//
//    func body(content: Content) -> some View {
//        ZStack {
//            content
//                .opacity(show ? 1 : 0)
//                .offset(y: show ? 0 : UIScreen.main.bounds.height)
//        }
//    }
//}
//
//extension View {
//    func slideUpTransition(show: Binding<Bool>) -> some View {
//        self.modifier(SlideUpTransition(show: show))
//    }
//}
