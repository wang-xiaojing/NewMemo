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
    @State private var showCropView: Bool = false

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
                Button(action: {
                    showCropView = true
                }) {
                    Image(systemName: "crop")
                }
            }
        }
        .padding()
        .sheet(isPresented: $showCropView) {
            ImageCropView(image: image) { croppedImage in
                self.image = croppedImage
                showCropView = false
            }
        }
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

struct ImageCropView: View {
    @State var image: UIImage
    var completion: (UIImage) -> Void

    @State private var cropRect: CGRect = .zero
    @State private var startLocation: CGPoint = .zero
    @State private var isDragging: Bool = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
//                        .overlay(
                            Rectangle()
                                .stroke(Color.red, lineWidth: 2)
                                .frame(width: cropRect.width, height: cropRect.height)
                                .position(x: cropRect.midX, y: cropRect.midY)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if isDragging {
                                                let newWidth = max(20, cropRect.width + value.translation.width)
                                                let newHeight = max(20, cropRect.height + value.translation.height)
                                                cropRect.size = CGSize(width: newWidth, height: newHeight)
                                            } else {
                                                cropRect.origin = CGPoint(
                                                    x: min(max(0, startLocation.x + value.translation.width), geometry.size.width - cropRect.width),
                                                    y: min(max(0, startLocation.y + value.translation.height), geometry.size.height - cropRect.height)
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            isDragging = false
                                        }
                                )
                                .onTapGesture {
                                    isDragging.toggle()
                                }
//                        )
                        .onAppear {
                            let imageSize = image.size
                            let scale = min(geometry.size.width / imageSize.width, geometry.size.height / imageSize.height)
                            let displaySize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
                            let cropWidth = displaySize.width / 2
                            let cropHeight = displaySize.height / 2
                            let xOffset = (geometry.size.width - displaySize.width) / 2
                            let yOffset = (geometry.size.height - displaySize.height) / 2
                            cropRect = CGRect(
                                x: xOffset + (displaySize.width - cropWidth) / 2,
                                y: yOffset + (displaySize.height - cropHeight) / 2,
                                width: cropWidth,
                                height: cropHeight
                            )
                        }
                    // トリミング枠の各角に赤色の正方形を配置
                    ForEach([Corner.topLeft, Corner.topRight, Corner.bottomLeft, Corner.bottomRight], id: \.self) { corner in
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                            .position(position(for: corner, in: cropRect))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newRect = resizeRect(corner: corner, value: value, cropRect: cropRect, geometry: geometry)
                                        cropRect = newRect
                                    }
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)

                HStack {
                    Button("戻り") {
                        completion(image)
                    }
                    Spacer()
                    Button("決定") {
                        let croppedImage = cropImage(image: image, toRect: cropRect, viewSize: geometry.size)
                        completion(croppedImage)
                    }
                }
                .padding()
            }
        }
    }

    private func position(for corner: Corner, in cropRect: CGRect) -> CGPoint {
        switch corner {
        case .topLeft:
            return CGPoint(x: cropRect.minX, y: cropRect.minY)
        case .topRight:
            return CGPoint(x: cropRect.maxX, y: cropRect.minY)
        case .bottomLeft:
            return CGPoint(x: cropRect.minX, y: cropRect.maxY)
        case .bottomRight:
            return CGPoint(x: cropRect.maxX, y: cropRect.maxY)
        }
    }

    private func resizeRect(corner: Corner, value: DragGesture.Value, cropRect: CGRect, geometry: GeometryProxy) -> CGRect {
        var newRect = cropRect
        let newX = max(0, min(geometry.size.width, value.location.x))
        let newY = max(0, min(geometry.size.height, value.location.y))

        switch corner {
        case .topLeft:
            newRect.origin.x = newX
            newRect.origin.y = newY
            newRect.size.width = cropRect.maxX - newX
            newRect.size.height = cropRect.maxY - newY
        case .topRight:
            newRect.origin.y = newY
            newRect.size.width = newX - cropRect.minX
            newRect.size.height = cropRect.maxY - newY
        case .bottomLeft:
            newRect.origin.x = newX
            newRect.size.width = cropRect.maxX - newX
            newRect.size.height = newY - cropRect.minY
        case .bottomRight:
            newRect.size.width = newX - cropRect.minX
            newRect.size.height = newY - cropRect.minY
        }

        return newRect
    }

    private func cropImage(image: UIImage, toRect cropRect: CGRect, viewSize: CGSize) -> UIImage {
        let scale = image.size.width / viewSize.width
        let scaledCropRect = CGRect(x: cropRect.origin.x * scale, y: cropRect.origin.y * scale, width: cropRect.width * scale, height: cropRect.height * scale)
        
        if let cgImage = image.cgImage?.cropping(to: scaledCropRect) {
            return UIImage(cgImage: cgImage)
        }
        
        return image
    }
}

enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
}
