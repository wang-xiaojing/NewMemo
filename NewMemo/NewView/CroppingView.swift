//
//  CroppingView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/14.
//
import SwiftUI
import PhotosUI

// struct CroppingView: View {
//     @Binding var image: UIImage
//     @Binding var cropRect: CGRect
//
//     var body: some View {
//         GeometryReader { geometry in
//             let imageSize = image.size
//             let scale = CGPoint(x: geometry.size.width / imageSize.width, y: geometry.size.height / imageSize.height) // スケールをCGPoint型に変更
//             let scaledImageSize = CGSize(width: imageSize.width * scale.x, height: imageSize.height * scale.y) // スケールされた画像のサイズを計算
//             let xOffset = (geometry.size.width - scaledImageSize.width) / 2 // 画像を中央に配置するためのX方向のオフセットを計算
//             let yOffset = (geometry.size.height - scaledImageSize.height) / 2 // 画像を中央に配置するためのY方向のオフセットを計算
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
//                                 let newRect = resizeRect(corner: corner, value: value, cropRect: cropRect, scaledImageSize: scaledImageSize, xOffset: xOffset, yOffset: yOffset)
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
//
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
//     private func resizeRect(corner: Corner, value: DragGesture.Value, cropRect: CGRect, scaledImageSize: CGSize, xOffset: CGFloat, yOffset: CGFloat) -> CGRect {
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
//     private func applyCrop(scaledImageSize: CGSize, xOffset: CGFloat, yOffset: CGFloat) {
//         let ciImage = CIImage(image: image)
//         let context = CIContext(options: nil)
//
//         let cropX = cropRect.origin.x * CGFloat(image.size.width)
//         let cropY = cropRect.origin.y * CGFloat(image.size.height)
//         let cropWidth = cropRect.size.width * CGFloat(image.size.width)
//         let cropHeight = cropRect.size.height * CGFloat(image.size.height)
//
//         let croppedImage = ciImage?.cropped(to: CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight))
//
//         if let output = croppedImage, let cgImage = context.createCGImage(output, from: output.extent) {
//             // 回転処理をやめる
//             // let croppedUIImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
//             let croppedUIImage = UIImage(cgImage: cgImage)
//             image = croppedUIImage
//         }
//     }
// }
