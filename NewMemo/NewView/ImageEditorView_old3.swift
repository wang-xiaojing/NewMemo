//
//  ImageEditorView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/12.
//
import SwiftUI
import PhotosUI

struct ImageEditorView_old3: View {
    @State var image: UIImage
    var completion: (UIImage) -> Void
    
    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1
    @State private var cropRect: CGRect = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
    @State private var isCropping: Bool = false
    
    var body: some View {
        VStack {
            if isCropping {
                CroppingView(image: $image, cropRect: $cropRect)
            } else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
                    .brightness(brightness)
                    .contrast(contrast)
                    .saturation(saturation)
            }
            
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
                Button("Crop") {
                    isCropping.toggle()
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

// struct CroppingView: View {
//     @Binding var image: UIImage
//     @Binding var cropRect: CGRect
//
//     var body: some View {
//         GeometryReader { geometry in
//             let imageSize = image.size
//             let scale = min(geometry.size.width / imageSize.width, geometry.size.height / imageSize.height)
//             let scaledImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
//             let xOffset = (geometry.size.width - scaledImageSize.width) / 2
//             let yOffset = (geometry.size.height - scaledImageSize.height) / 2
//
//             ZStack {
//                 Image(uiImage: image)
//                     .resizable()
//                     .scaledToFit()
//                     .frame(width: scaledImageSize.width, height: scaledImageSize.height)
//                     .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
//
//                 Rectangle()
//                     .stroke(Color.red, lineWidth: 2)
//                     .frame(width: cropRect.width * scaledImageSize.width, height: cropRect.height * scaledImageSize.height)
//                     .position(x: cropRect.midX * scaledImageSize.width + xOffset, y: cropRect.midY * scaledImageSize.height + yOffset)
//                     .gesture(DragGesture()
//                         .onChanged { value in
//                             let newRect = CGRect(
//                                 x: max(0, min(1, (value.location.x - xOffset) / scaledImageSize.width)),
//                                 y: max(0, min(1, (value.location.y - yOffset) / scaledImageSize.height)),
//                                 width: cropRect.width,
//                                 height: cropRect.height
//                             )
//                             cropRect = newRect
//                         }
//                     )
//
//                 // Corner drag handles
//                 ForEach([Corner.topLeft, Corner.topRight, Corner.bottomLeft, Corner.bottomRight], id: \.self) { corner in
//                     Rectangle()
//                         .fill(Color.blue)
//                         .frame(width: 20, height: 20)
//                         .position(position(for: corner, in: cropRect, scaledImageSize: scaledImageSize, xOffset: xOffset, yOffset: yOffset))
//                         .gesture(DragGesture()
//                             .onChanged { value in
//                                 let newRect = resizeRect(corner: corner, value: value, cropRect: cropRect, scaledImageSize: scaledImageSize, // xOffset: xOffset, yOffset: yOffset)
//                                 cropRect = newRect
//                             }
//                         )
//                 }
//
//                 VStack {
//                     Spacer()
//                     Button("Apply") {
//                         applyCrop(scaledImageSize: scaledImageSize, xOffset: xOffset, yOffset: yOffset)
//                     }
//                 }
//             }
//         }
//     }
    
//     private func position(for corner: Corner, in cropRect: CGRect, scaledImageSize: CGSize, xOffset: CGFloat, yOffset: CGFloat) -> CGPoint {
//         switch corner {
//         case .topLeft:
//             return CGPoint(x: cropRect.minX * scaledImageSize.width + xOffset, y: cropRect.minY * scaledImageSize.height + yOffset)
//         case .topRight:
//             return CGPoint(x: cropRect.maxX * scaledImageSize.width + xOffset, y: cropRect.minY * scaledImageSize.height + yOffset)
//         case .bottomLeft:
//             return CGPoint(x: cropRect.minX * scaledImageSize.width + xOffset, y: cropRect.maxY * scaledImageSize.height + yOffset)
//         case .bottomRight:
//             return CGPoint(x: cropRect.maxX * scaledImageSize.width + xOffset, y: cropRect.maxY * scaledImageSize.height + yOffset)
//         }
//     }
//
//     private func resizeRect(corner: Corner, value: DragGesture.Value, cropRect: CGRect, scaledImageSize: CGSize, xOffset: CGFloat, yOffset: // CGFloat) -> CGRect {
//         var newRect = cropRect
//         let newX = max(0, min(1, (value.location.x - xOffset) / scaledImageSize.width))
//         let newY = max(0, min(1, (value.location.y - yOffset) / scaledImageSize.height))
//
//         switch corner {
//         case .topLeft:
//             newRect.origin.x = newX
//             newRect.origin.y = newY
//             newRect.size.width = cropRect.maxX - newX
//             newRect.size.height = cropRect.maxY - newY
//         case .topRight:
//             newRect.origin.y = newY
//             newRect.size.width = newX - cropRect.minX
//             newRect.size.height = cropRect.maxY - newY
//         case .bottomLeft:
//             newRect.origin.x = newX
//             newRect.size.width = cropRect.maxX - newX
//             newRect.size.height = newY - cropRect.minY
//         case .bottomRight:
//             newRect.size.width = newX - cropRect.minX
//             newRect.size.height = newY - cropRect.minY
//         }
//
//         return newRect
//     }
//
//     //　private func applyCrop(scaledImageSize: CGSize, xOffset: CGFloat, yOffset: CGFloat) {
//     //　    let ciImage = CIImage(image: image)
//     //　    let context = CIContext(options: nil)
//     //
//     //　    let cropX = cropRect.origin.x * CGFloat(image.size.width)
//     //　    let cropY = (1 - cropRect.maxY) * CGFloat(image.size.height) // 修正: Y座標の計算
//     //　    let cropWidth = cropRect.size.width * CGFloat(image.size.width)
//     //　    let cropHeight = cropRect.size.height * CGFloat(image.size.height)
//     //
//     //　    let croppedImage = ciImage?.cropped(to: CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight))
//     //
//     //　    if let output = croppedImage, let cgImage = context.createCGImage(output, from: output.extent) {
//     //　        // 画像の向きを考慮して回転させる
//     //　        let rotatedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
//     //　        image = rotatedImage
//     //　    }
//     //　}
//     private func applyCrop(scaledImageSize: CGSize, xOffset: CGFloat, yOffset: CGFloat) {
//         let ciImage = CIImage(image: image)
//         let context = CIContext(options: nil)
//
//         let cropX = cropRect.origin.x * CGFloat(image.size.width)
//         let cropY = (1 - cropRect.maxY) * CGFloat(image.size.height) // 修正: Y座標の計算
//         let cropWidth = cropRect.size.width * CGFloat(image.size.width)
//         let cropHeight = cropRect.size.height * CGFloat(image.size.height)
//
//         let croppedImage = ciImage?.cropped(to: CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight))
//
//         if let output = croppedImage, let cgImage = context.createCGImage(output, from: output.extent) {
//             // 回転処理をやめる
//             let croppedUIImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
//             image = croppedUIImage
//         }
//     }
// }

enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
}
