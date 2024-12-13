//
//  ImageEditorView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/13.
//


import SwiftUI
import PhotosUI

struct ImageEditorView_old2: View {
    @State var image: UIImage
    var completion: (UIImage) -> Void

    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1
    @State private var exposure: Double = 0
    @State private var highlights: Double = 0
    @State private var shadows: Double = 0
    @State private var blackPoint: Double = 0
    @State private var vibrance: Double = 0
    @State private var warmth: Double = 0
    @State private var tint: Double = 0
    @State private var sharpness: Double = 0
    @State private var definition: Double = 0
    @State private var noiseReduction: Double = 0
    @State private var vignette: Double = 0

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

            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        SliderView(value: $brightness, range: -1...1, label: "Brightness")
                        SliderView(value: $contrast, range: 0...2, label: "Contrast")
                        SliderView(value: $saturation, range: 0...2, label: "Saturation")
                        SliderView(value: $exposure, range: -2...2, label: "Exposure")
                        SliderView(value: $highlights, range: -1...1, label: "Highlights")
                        SliderView(value: $shadows, range: -1...1, label: "Shadows")
                        SliderView(value: $blackPoint, range: 0...1, label: "Black Point")
                        SliderView(value: $vibrance, range: 0...1, label: "Vibrance")
                        SliderView(value: $warmth, range: -1...1, label: "Warmth")
                        SliderView(value: $tint, range: -1...1, label: "Tint")
                        SliderView(value: $sharpness, range: 0...2, label: "Sharpness")
                        SliderView(value: $definition, range: 0...2, label: "Definition")
                        SliderView(value: $noiseReduction, range: 0...1, label: "Noise Reduction")
                        SliderView(value: $vignette, range: 0...2, label: "Vignette")
                    }
                }
                .padding()
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
    }
}

struct SliderView: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var label: String

    var body: some View {
        VStack {
            Text(label)
            Slider(value: $value, in: range)
        }
    }
}
