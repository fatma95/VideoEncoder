//
//  ContentView.swift
//  VideoEncoder
//
//  Created by Fatma Mohamed on 12/08/2021.
//

import SwiftUI
import Photos
struct ContentView: View {
    
    @State var showImagePicker: Bool = false
    @State var openLoading: Bool = false
    @State var videoString: URL!
  //  @ObservedObject var viewModel: EncodeViewModel

    var body: some View {
        VStack {
            Button(action:{
                self.showImagePicker.toggle()
            }) {
                Text("Select Video")
                    .foregroundColor(.white)
            }.frame(width: 150, height: 50)
            .background(Color.gray)
            .sheet(isPresented: $showImagePicker, content: {
                ImagePickerView(isPresented: self.$showImagePicker, openLoading: self.$openLoading, videoURL: self.$videoString)
            }).navigate(to: LoadingView(videoString: self.videoString), when: $openLoading)
        }
     
    }
}



struct ImagePickerView: UIViewControllerRepresentable  {
    @Binding var isPresented: Bool
    @Binding var openLoading: Bool
    @Binding var videoURL: URL!

    func makeCoordinator() -> ImagePickerView.Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIImagePickerController()
        controller.mediaTypes = ["public.movie","public.image"]
        controller.delegate = context.coordinator
        return controller
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        init(parent: ImagePickerView) {
            self.parent = parent
        }
        
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
            if let videoURL = info[.mediaURL] as? URL {
                self.parent.openLoading = true
                self.parent.videoURL = videoURL
            }
            
            self.parent.isPresented = false
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}


extension View {
    
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)

                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
    }
}
