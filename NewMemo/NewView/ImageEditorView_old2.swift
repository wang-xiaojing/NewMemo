//
//  ImageEditorView 2.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/14.
//


import SwiftUI
import PhotosUI

struct ImageEditorView: View {
    @State var image: UIImage
    var completion: (UIImage) -> Void

    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding()
                .brightness(brightness)
                .contrast(contrast)
                .saturation(saturation)

            Slider(value: $brightness, in: -1...1, step: 0.1) {
                Text("Brightness")
            }
            Slider(value: $contrast, in: 0...2, step: 0.1) {
                Text("Contrast")
            }
            Slider(value: $saturation, in: 0...2, step: 0.1) {
                Text("Saturation")
            }

            HStack {
                Button("Cancel") {
                    completion(image)
                }
                Button("Save") {
                    let editedImage = applyAdjustments(to: image)
                    completion(editedImage)
                }
            }
        }
        .padding()
    }

    private func applyAdjustments(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)
        let context = CIContext(options: nil)

        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(brightness, forKey: kCIInputBrightnessKey)
        filter?.setValue(contrast, forKey: kCIInputContrastKey)
        filter?.setValue(saturation, forKey: kCIInputSaturationKey)

        if let output = filter?.outputImage, let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }

        return image
    }}
