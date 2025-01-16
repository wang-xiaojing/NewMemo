//
//  MapViewContainer.swift
//  SearchMap
//
//  Created by Xiaojing Wang on 2025/01/06.
//
import SwiftUI
import UIKit
import MapKit

// MapViewをラップするビュー
struct MapViewContainer: View {
    @State private var searchResults = [MKMapItem]() // 検索結果を保持するプロパティ
    @State private var searchText = "" // 検索テキスト
    
    @State private var hereLocation: CLLocationCoordinate2D? // 現在地の座標を保持するプロパティ
    @State private var searchLocation: CLLocationCoordinate2D? // 検索結果の座標を保持するプロパティ
    @State private var longTapLocation: CLLocationCoordinate2D? // ロングタップの座標を保持するプロパティ
    
    @State private var shouldShowUserLocationPin = false // 現在地のピンを表示するかどうかを保持するプロパティ
    @State private var shouldShowSearchLocationPin = false // 検索結果座標にピンを表示するかどうかを保持するプロパティ
    @State private var shouldShowLongTapLocationPin = false // ロングタップ座標にピンを表示するかどうかを保持するプロパティ
    
    @State private var isSearchBarPresented = false // 検索バーの表示状態を管理するプロパティ
    @State private var searchBarHeight: CGFloat = 0
    @State private var showTelopOfDescriptionOfLongTap = true // テロップの表示状態を管理するプロパティ
    @State private var tooltipOffset: CGFloat = UIScreen.main.bounds.width // テロップの初期位置を画面の右端に設定
    @ObservedObject private var locationManager = LocationManager() // LocationManagerのインスタンス
    @State private var isSearchItemSelectorPresented = false // SearchItemSelectorViewの表示状態を管理するプロパティ
    @State private var selectedSearchResult: MKMapItem? // 選択されたSearch結果を保持するプロパティ
    @State private var hereResult: MKMapItem? // Here結果を保持するプロパティ
    @State private var longTapResult: MKMapItem? // LongTap結果を保持するプロパティ
    @State private var searchButtonClickCount = 0 // 検索ボタンがクリックされた回数を保持するプロパティ
    @State private var hereButtonClickCount = 0 // 現在地ボタンがクリックされた回数を保持するプロパティ
    @State private var removePinButtonClickCount = 0 // ピン削除ボタンがクリックされた回数を保持するプロパティ
    @State private var zoomInButtonClickCount = 0 // ズームインボタンがクリックされた回数を保持するプロパティ
    @State private var zoomOutButtonClickCount = 0 // ズームアウトボタンがクリックされた回数を保持するプロパティ
    @State private var registerButtonClickCount = 0 // レジスタボタンがクリックされた回数を保持するプロパティ
    @State private var isZooming = false // ズームインまたはズームアウトの状態を管理するプロパティ
    @State private var moveToPinButtonClickCount = 0 // ピン移動ボタンがクリックされた回数を保持するプロパティ
    @State private var registeredLocations = [MKMapItem]() // 登録された位置情報を保持するプロパティ
    @State private var isRegisterViewPresented = false // 追加: 位置登録画面の表示状態を管理するプロパティ
    @State private var registerLocationName = "" // 追加: 登録する位置の名称を保持するプロパティ
    @State private var justRegisteredFirst = false    // 追加: 登録フラグ
    @State private var justRegisteredSecond = false // 追加: 登録フラグ
    @State private var showAlreadyRegisteredAlertForHere = false
    @State private var showAlreadyRegisteredAlert = false // 追加: アラート表示状態を管理するプロパティ
    @State private var showAlreadyRegisteredAlertForLongTap = false
    @State private var showNoPinAlert = false
    @State private var showAlreadyRegisteredAlertForRemove = false
    @State private var showAlreadyRegisteredAlertForSearch = false
    @State private var tempSearchItem: MKMapItem?
    @Binding var showLocation: Bool  // 位置情報画面の表示フラグ
    @Binding var parentRegisteredLocations: [RegisteredLocation]  // NewViewから渡される登録された位置情報の配列

    var body: some View {
        HStack {
            Button(action: {
                showLocation = false  // Cancelボタンが押されたらシートを閉じる
            }) {
                Text("Cancel")
            }
            Spacer()
            Text("Map View")  // タイトルを表示
            Spacer()
            Button(action: {
                // 追加ボタンが押された時の処理
                if let coordinate = searchLocation ?? hereLocation ?? longTapLocation {
                    // UIApplication.shared.windowsを使用して
                    // アプリケーションのすべてのウィンドウを取得し、
                    // その中からキーウィンドウ（現在アクティブなウィンドウ）を見つけます。
                    // キーウィンドウはユーザーが操作しているウィンドウであり、
                    // このウィンドウを使ってスナップショットを取得します。
                    let window = UIApplication.shared.windows.first { $0.isKeyWindow }
                    // UIGraphicsImageRendererを初期化し、レンダリングする画像のサイズをキーウィンドウのサイズに設定します。
                    // window?.bounds.sizeがnilの場合は.zero（サイズ0）を使用します。
                    let renderer = UIGraphicsImageRenderer(size: window?.bounds.size ?? .zero)
                    // スナップショットの作成
                    // 現在のウィンドウのヒエラルキー（階層構造）全体を描画します。
                    // 最新の表示内容がスナップショットに反映されます。
                    let image = renderer.image { ctx in
                        window?.drawHierarchy(in: window?.bounds ?? .zero, afterScreenUpdates: true)
                    }
                    // 新しい登録位置+情報の作成
                    let newLocation = RegisteredLocation(name: registerLocationName, coordinate: coordinate, date: Date(), image: image)
                    parentRegisteredLocations.append(newLocation)
                    showLocation = false  // 位置情報登録状態中はシートを閉じる
                } else {
                    showLocation = false  // 位置情報登録状態中はシートを閉じる
                }
            }) {
                Text("追加")
                    .foregroundColor(justRegisteredFirst ? .blue : .gray)  // 位置情報登録状態中は青色、そうでない場合は灰色
            }
            .disabled(!justRegisteredFirst)  // 位置情報登録状態中でない場合はボタンを無効化
        }
        .padding()
        Divider()
        ZStack(alignment: .topTrailing) {
            MapView(
                locationManager: locationManager,
                selectedSearchResult: $selectedSearchResult,
                hereResult: $hereResult,
                longTapResult: $longTapResult,
                hereLocation: $hereLocation,
                searchLocation: $searchLocation,
                longTapLocation: $longTapLocation,
                shouldShowUserLocationPin: $shouldShowUserLocationPin,
                shouldShowSearchLocationPin: $shouldShowSearchLocationPin,
                shouldShowLongTapLocationPin: $shouldShowLongTapLocationPin,
                isZooming: $isZooming,
                justRegisteredFirst: $justRegisteredFirst,
                justRegisteredSecond: $justRegisteredSecond,
                showAlreadyRegisteredAlertForLongTap: $showAlreadyRegisteredAlertForLongTap,
                onLongTap: {
                    showTelopOfDescriptionOfLongTap = false
                }
            )
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $isSearchBarPresented) {
                SearchBar(searchText: $searchText, onSearchBarSearchButtonClicked: searchAndDismiss)
                    .background(GeometryReader { geometry in
                        Color.clear.onAppear {
                            searchBarHeight = geometry.size.height
                        }
                    })
                    .presentationDetents([.height(searchBarHeight)])
            }
            .sheet(isPresented: $isSearchItemSelectorPresented) {
                SearchItemSelectorView(searchResults: $searchResults, selectedSearchResult: $selectedSearchResult, onCancel: {
                    selectedSearchResult = nil // 検索結果を無効にする
                    isSearchItemSelectorPresented = false
                }, onConfirm: {
                    if let selectedResult = selectedSearchResult {
                        if justRegisteredFirst {
                            tempSearchItem = selectedResult
                            showAlreadyRegisteredAlertForSearch = true
                        } else {
                            searchLocation = selectedResult.placemark.coordinate
                            hereLocation = nil
                            longTapLocation = nil
                            searchResults = [selectedResult] // 選択された結果のみを保持する
                        }
                    } else {
                        selectedSearchResult = nil // 検索結果を無効にする
                    }
                    isSearchItemSelectorPresented = false
                })
            }
            ButtonBarView(
                onSearchButtonClicked: {
                    searchButtonClickCount += 1
                    isSearchBarPresented = true
                },
                searchButtonClickCount: searchButtonClickCount, // 追加: searchButtonClickCountを渡す
                hereButtonClickCount: hereButtonClickCount, // 追加: hereButtonClickCountを渡す
                removePinButtonClickCount: removePinButtonClickCount, // 追加: removePinButtonClickCountを渡す
                zoomInButtonClickCount: zoomInButtonClickCount, // 追加: zoomInButtonClickCountを渡す
                zoomOutButtonClickCount: zoomOutButtonClickCount, // 追加: zoomOutButtonClickCountを渡す
                registerButtonClickCount: registerButtonClickCount, // 追加: registerButtonClickCountを渡す
                moveToPinButtonClickCount: moveToPinButtonClickCount, // 追加: moveToPinButtonClickCountを渡す
                onMoveToPinButtonClicked: { // 追加: onMoveToPinButtonClickedを渡す
                    moveToPinButtonClickCount += 1
                    moveToPin()
                },
                onHereButtonClicked: {
                    if justRegisteredFirst {
                        justRegisteredSecond = true
                        showAlreadyRegisteredAlertForHere = true
                    } else {
                        isZooming = false
                        hereButtonClickCount += 1
                        showHereLocation()
                    }
                },
                onRemovePinButtonClicked: {
                    if justRegisteredFirst {
                        justRegisteredSecond = true
                        showAlreadyRegisteredAlertForRemove = true
                    } else {
                        isZooming = true
                        removePinButtonClickCount += 1
                        removeAllPins()
                    }
                },
                onZoomInButtonClicked: {
                    isZooming = true
                    zoomInButtonClickCount += 1
                    zoomIn()
                },
                onZoomOutButtonClicked: {
                    isZooming = true
                    zoomOutButtonClickCount += 1
                    zoomOut()
                },
                onRegisterButtonClicked: { // 変更: 位置登録画面を表示する
                    registerButtonClickCount += 1
                    if hereLocation == nil && searchLocation == nil && longTapLocation == nil {
                        showNoPinAlert = true
                    } else {
                        isRegisterViewPresented = true
                    }
                }
            )
            // ロングタップ説明のテーロップ表示処理
            if showTelopOfDescriptionOfLongTap {
                GeometryReader { geometry in
                    Text("ロングタップジェスチャーで注目地変更可能")
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.clear)
                        .offset(x: tooltipOffset)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: false)) {
                                tooltipOffset = -geometry.size.width
                            }
                        }
                }
                .frame(height: 50) // テロップの高さを設定
            }
            
            if isRegisterViewPresented {
                RegisterLocationView(
                    locationName: $registerLocationName,
                    onCancel: {
                        isRegisterViewPresented = false
                    },
                    onConfirm: {
                        if justRegisteredFirst {
                            showAlreadyRegisteredAlert = true
                        } else {
                            registerLocation()
                            isRegisterViewPresented = false
                        }
                    },
                    isRegisterViewPresented: $isRegisterViewPresented, // 追加: isRegisterViewPresentedを渡す
                    justRegisteredFirst: $justRegisteredFirst // 追加: justRegisteredFirstを渡す
                )
                .background(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            getHereLocation()
        }
        .alert("すでに登録した場所が存在します。新しい場所に移動しますか？", isPresented: $showAlreadyRegisteredAlertForHere) {
            Button("Cancel", role: .cancel) {
                // selectedSearchResult = nil
                // searchResults.removeAll()
                showAlreadyRegisteredAlertForHere = false
            }
            Button("OK") {
                justRegisteredFirst = false
                justRegisteredSecond = false
                isZooming = false
                hereButtonClickCount += 1
                showHereLocation()
                showAlreadyRegisteredAlertForHere = false
            }
        }
        .alert("登録したい場所を決めてください", isPresented: $showNoPinAlert) {
            Button("OK") {
                showNoPinAlert = false
            }
        }
        .alert("すでに登録した場所が存在します。登録した場所を削除しますか？", isPresented: $showAlreadyRegisteredAlertForRemove) {
            Button("Cancel", role: .cancel) {}
            Button("OK") {
                justRegisteredFirst = false
                justRegisteredSecond = false
                isZooming = true
                removePinButtonClickCount += 1
                removeAllPins()
            }
        }
        .alert("すでに登録した場所が存在します。新しい場所に移動しますか？", isPresented: $showAlreadyRegisteredAlertForSearch) {
            Button("Cancel", role: .cancel) {
                isSearchBarPresented = false
                isSearchItemSelectorPresented = false
                showAlreadyRegisteredAlertForSearch = false
            }
            Button("OK") {
                if let item = tempSearchItem {
                    selectedSearchResult = item
                    searchLocation = item.placemark.coordinate
                    hereLocation = nil
                    longTapLocation = nil
                }
                justRegisteredFirst = false
                justRegisteredSecond = false
                isSearchBarPresented = false
                isSearchItemSelectorPresented = false
                showAlreadyRegisteredAlertForSearch = false
            }
        }
    }
    
    // 現在地の位置情報を取得するメソッド
    func getHereLocation() {
        locationManager.startUpdatingLocation()
        if let location = locationManager.location {
            hereLocation = location.coordinate
        }
    }
    
    // 現在地ボタンがクリックされたときの処理
    func showHereLocation() {
        locationManager.startUpdatingLocation()
        if let location = locationManager.location {
            hereLocation = location.coordinate
            searchLocation = nil    // 検索結果の位置情報をクリアする
            longTapLocation = nil   // ロングタップの位置情報をクリアする
        }
    }
    
    // 検索バーの検索ボタンがクリックされたときの処理
    func search(completion: @escaping () -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion()
                return
            }
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            searchResults = response.mapItems
            if searchResults.count == 1, let singleResult = searchResults.first {
                if justRegisteredFirst {
                    tempSearchItem = singleResult
                    showAlreadyRegisteredAlertForSearch = true
                } else {
                    selectedSearchResult = singleResult
                    searchLocation = singleResult.placemark.coordinate
                    hereLocation = nil
                    longTapLocation = nil
                    searchResults = [singleResult] // 選択された結果のみを保持する
                }
            } else if let _ = searchResults.first {
                isSearchItemSelectorPresented = true // 検索結果が複数ある場合、SearchItemSelectorViewを表示
            }
            completion()
            for item in searchResults {
                print("Name: \(item.name ?? "No name")")
                print("Phone Number: \(item.phoneNumber ?? "No phone number")")
                print("URL: \(item.url?.absoluteString ?? "No URL")")
                print("Time Zone: \(item.timeZone?.identifier ?? "No time zone")")
                print("Placemark: \(item.placemark)")
            }
        }
    }
    
    // 検索ボタンがクリックされたときの処理と検索バーを閉じる処理
    func searchAndDismiss() {
        search {
            isSearchBarPresented = false
            isZooming = false // 検索結果が有効な地点選択後に設定
        }
    }
    
    // すべてのピンを削除するメソッド
    func removeAllPins() {
        hereLocation = nil
        searchLocation = nil
        longTapLocation = nil
        searchResults.removeAll()
    }
    
    // ズームインボタンがクリックされたときの処理
    func zoomIn() {
        NotificationCenter.default.post(name: .zoomIn, object: nil)
    }

    // ズームアウトボタンがクリックされたときの処理
    func zoomOut() {
        NotificationCenter.default.post(name: .zoomOut, object: nil)
    }

    // ピンの位置に移動するメソッド
    func moveToPin() {
        if let coordinate = searchLocation ?? hereLocation ?? longTapLocation {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // 表示範囲を設定
            let region = MKCoordinateRegion(center: coordinate, span: span) // 表示領域を設定
            NotificationCenter.default.post(name: .moveToPin, object: region)
        }
    }
    
    // ピンの位置を登録するメソッド
    func registerLocation() {
        if let coordinate = searchLocation ?? hereLocation ?? longTapLocation {
            // 全ピンを消去
            // hereLocation = nil
            // searchLocation = nil
            // longTapLocation = nil

            // 新規MapItemを作りリストに追加
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = registerLocationName
            registeredLocations.append(mapItem)
            printRegisteredLocations()

            // 登録したピンを再表示
            if let _ = searchLocation {
                selectedSearchResult = mapItem
                hereResult = nil
                longTapResult = nil
                // searchLocation = nil
                hereLocation = nil
                longTapLocation = nil
            } else if let _ = longTapLocation {
                selectedSearchResult = nil
                hereResult = nil
                longTapResult = mapItem
                searchLocation = nil
                hereLocation = nil
                // longTapLocation = nil
            } else if let _ = hereLocation {
                selectedSearchResult = nil
                hereResult = mapItem
                longTapResult = nil
                searchLocation = nil
                // hereLocation = nil
                longTapLocation = nil
            }
            justRegisteredFirst = true // 追加: 登録扱い
        }
    }

    // 登録された全ての位置情報を表示するメソッド
    func printRegisteredLocations() {
        for (index, location) in registeredLocations.enumerated() {
            print("\(index + 1): \(location)")
        }
    }
}
