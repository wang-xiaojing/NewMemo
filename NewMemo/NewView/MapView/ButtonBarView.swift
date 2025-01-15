//
//  ButtonBarView.swift
//  SearchMap
//
//  Created by Xiaojing Wang on 2025/01/06.
//
import SwiftUI
import MapKit
import CoreLocation

struct ButtonBarView: View {
    private let buttonBackColor: Color = Color.white.opacity(0.4)
    private let buttonFrameSizeSmall: CGSize = CGSize(width: 20, height: 20) // 追加: ボタンのフレームサイズを定義
    private let buttonFrameSizeLarge: CGSize = CGSize(width: 30, height: 30) // 追加: ボタンのフレームサイズを定義
    var onSearchButtonClicked: () -> Void
    var searchButtonClickCount: Int // 検索ボタンがクリックされた回数を受け取るプロパティ
    var hereButtonClickCount: Int // 現在地ボタンがクリックされた回数を受け取るプロパティ
    var removePinButtonClickCount: Int // ピン削除ボタンがクリックされた回数を受け取るプロパティ
    var zoomInButtonClickCount: Int // ズームインボタンがクリックされた回数を受け取るプロパティ
    var zoomOutButtonClickCount: Int // ズームアウトボタンがクリックされた回数を受け取るプロパティ
    var registerButtonClickCount: Int // レジスタボタンがクリックされた回数を受け取るプロパティ
    var moveToPinButtonClickCount: Int // ピン移動ボタンがクリックされた回数を受け取るプロパティ
    var onMoveToPinButtonClicked: () -> Void
    var onHereButtonClicked: () -> Void
    var onRemovePinButtonClicked: () -> Void
    var onZoomInButtonClicked: () -> Void
    var onZoomOutButtonClicked: () -> Void
    var onRegisterButtonClicked: () -> Void // 追加: onRegisterButtonClickedプロパティ

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
                .frame(height: 50)
            HStack {
                Spacer()
                Button(action:
                        onSearchButtonClicked
                ) {
                    if searchButtonClickCount < 3 {
                        Text("search")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    Image(systemName: "binoculars")  // MARK: 検索
                        .resizable()
                        .frame(width: buttonFrameSizeSmall.width, height: buttonFrameSizeSmall.height) // 変更: フレームサイズを使用
                        .foregroundColor(.blue)
                }
                .background(buttonBackColor)
                .cornerRadius(6)
                .shadow(radius: 3)
            }
            HStack {
                Spacer()
                Button(action: onHereButtonClicked) {
                    if hereButtonClickCount < 3 {
                        Text("here")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    Image(systemName: "location")  // MARK: 現在地
                        .resizable()
                        .frame(width: buttonFrameSizeSmall.width, height: buttonFrameSizeSmall.height) // 変更: フレームサイズを使用
                        .foregroundColor(.blue)
                }
                .background(buttonBackColor)
                .cornerRadius(6)
                .shadow(radius: 3)
            }
            HStack {
                Spacer()
                Button(action: onMoveToPinButtonClicked) {
                    if moveToPinButtonClickCount < 3 {
                        Text("move to Pin")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    Image(systemName: "mappin.and.ellipse")  // MARK: goto pin that out of display
                        .resizable()
                        .frame(width: buttonFrameSizeSmall.width, height: buttonFrameSizeSmall.height) // 変更: フレームサイズを使用
                        .foregroundColor(.red)
                }
                .background(buttonBackColor)
                .cornerRadius(6)
                .shadow(radius: 3)
            }
            Spacer()
                .frame(height: 20)
            HStack {
                Spacer()
                Button(action: onRemovePinButtonClicked) {
                    if removePinButtonClickCount < 3 {
                        Text("remove Pin")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    Image(systemName: "trash")  // MARK: remove all Pin
                        .resizable()
                        .frame(width: buttonFrameSizeSmall.width, height: buttonFrameSizeSmall.height) // 変更: フレームサイズを使用
                        .foregroundColor(.blue)
                }
                .background(buttonBackColor)
                .cornerRadius(6)
                .shadow(radius: 3)
            }
            Spacer()
                .frame(height: 50)
            HStack {
                Spacer()
                Button(action: onZoomInButtonClicked) {
                    if zoomInButtonClickCount < 3 {
                        Text("zoom in")
                            .font(.subheadline)
                            .foregroundColor(.pink)
                    }
                    Image(systemName: "plus.magnifyingglass")  // MARK: remove all Pin
                        .resizable()
                        .frame(width: buttonFrameSizeSmall.width, height: buttonFrameSizeSmall.height) // 変更: フレームサイズを使用
                        .foregroundColor(.blue)
                }
                .background(buttonBackColor)
                .cornerRadius(6)
                .shadow(radius: 3)
            }
            HStack {
                Spacer()
                Button(action: onZoomOutButtonClicked) {
                    if zoomOutButtonClickCount < 3 {
                        Text("zoom out")
                            .font(.subheadline)
                            .foregroundColor(.pink)
                    }
                    Image(systemName: "minus.magnifyingglass")  // MARK: remove all Pin
                        .resizable()
                        .frame(width: buttonFrameSizeSmall.width, height: buttonFrameSizeSmall.height) // 変更: フレームサイズを使用
                        .foregroundColor(.blue)
                }
                .background(buttonBackColor)
                .cornerRadius(6)
                .shadow(radius: 3)
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: onRegisterButtonClicked) {
                    if registerButtonClickCount < 3 {
                        Text("register")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    Image(systemName: "tray.and.arrow.down.fill")  // MARK: 地点を登録
                        .resizable()
                        .frame(width: buttonFrameSizeLarge.width, height: buttonFrameSizeLarge.height) // 変更: フレームサイズを使用
                        .foregroundColor(.blue)
                }
                .background(buttonBackColor)
                .cornerRadius(6)
                .shadow(radius: 3)
            }
            Spacer()
                .frame(height: 50)
        }
        .background(Color.clear)
        .padding()
    }
}
