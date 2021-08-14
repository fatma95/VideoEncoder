//
//  LoadingView.swift
//  VideoEncoder
//
//  Created by Fatma Mohamed on 12/08/2021.
//

import SwiftUI
import Photos
struct LoadingView: View {
    
    @State var frameNo = 0.0
    @State var totalFrames = 0.0
    @State var encodingDone: Bool = false
    @State private var showMessage = false
    @State var navigate: Bool = false

    let viewModel = EncodeViewModel()
    var videoString: URL?
    

    var body: some View {
        VStack {
            ProgressView("Please Wait", value: frameNo, total: self.totalFrames)
           
        }.padding()
        .onAppear(perform: encode)
        .alert(isPresented: $showMessage) {
            Alert(title: Text("Encoding is completed successfully"), dismissButton: .default(Text("Ok")) {
                self.navigate = true
            })
        }
        .navigate(to: ContentView(), when: $navigate)
       
    
    }
        
    private func encode() {
        let destination = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressedVideo.mp4")
        try? FileManager.default.removeItem(at: destination)
        guard let videoURL = videoString else { return }
        let asset = AVURLAsset(url: videoURL, options: nil)
        let reader = try? AVAssetReader(asset: asset)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil) // NB: nil, should give you raw frames
        reader?.add(readerOutput)
        reader?.startReading()

            var nFrames = 0

            while true {
                let sampleBuffer = readerOutput.copyNextSampleBuffer()
                if sampleBuffer == nil {
                    break
                }

               nFrames += 1
            }
        self.totalFrames = Double(nFrames)
        print(self.totalFrames)
        _ = viewModel.encodeVideo(videoToCompress: videoURL, destinationPath: destination, size: (540, 960), compressionTransform: .keepSame, compressionConfig: .defaultConfig) { url in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { saved, error in
                if saved {
                    self.encodingDone = true
                    self.showMessage = true
                 print("Success")
                }
            }
        } errorHandler: { error in
            print(error)
        } cancelHandler: {
            print("Cancelled")
        } framesDone: { frame in
            self.frameNo = frame
            print("Frame no")
            print(frame)
        }

    }
}
