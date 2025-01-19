//
//  MapViewContainer.swift
//  SearchMap
//
//  Created by Xiaojing Wang on 2025/01/06.
//
import SwiftUI
import UIKit
import MapKit

// MARK: - MapViewをラップするビュー
struct MapViewContainer: View {
    @State private var searchResults = [MKMapItem]() // MARK: 検索結果を保持するプロパティ
    @State private var searchText = "" // MARK: 検索テキスト
    @State private var hereLocation: CLLocationCoordinate2D? // MARK: 現在地の座標を保持するプロパティ
    @State private var searchLocation: CLLocationCoordinate2D? // MARK: 検索結果の座標を保持するプロパティ
    @State private var longTapLocation: CLLocationCoordinate2D? // MARK: ロングタップの座標を保持するプロパティ
    @State private var shouldShowUserLocationPin = false // MARK: 現在地のピンを表示するかどうかを保持するプロパティ
    @State private var shouldShowSearchLocationPin = false // MARK: 検索結果座標にピンを表示するかどうかを保持するプロパティ
    @State private var shouldShowLongTapLocationPin = false // MARK: ロングタップ座標にピンを表示するかどうかを保持するプロパティ
    @State private var isSearchBarPresented = false // MARK: 検索バーの表示状態を管理するプロパティ
    @State private var searchBarHeight: CGFloat = 0
    @State private var showTelopOfDescriptionOfLongTap = true // MARK: テロップの表示状態を管理するプロパティ
    @State private var tooltipOffset: CGFloat = UIScreen.main.bounds.width // MARK: テロップの初期位置を画面の右端に設定
    @ObservedObject private var locationManager = LocationManager() // MARK: LocationManagerのインスタンス
    @State private var isSearchItemSelectorPresented = false // MARK: SearchItemSelectorViewの表示状態を管理するプロパティ
    @State private var selectedSearchResult: MKMapItem? // MARK: 選択されたSearch結果を保持するプロパティ
    @State private var hereResult: MKMapItem? // MARK: Here結果を保持するプロパティ
    @State private var longTapResult: MKMapItem? // MARK: LongTap結果を保持するプロパティ
    @State private var searchButtonClickCount = 0 // MARK: 検索ボタンがクリックされた回数を保持するプロパティ
    @State private var hereButtonClickCount = 0 // MARK: 現在地ボタンがクリックされた回数を保持するプロパティ
    @State private var removePinButtonClickCount = 0 // MARK: ピン削除ボタンがクリックされた回数を保持するプロパティ
    @State private var zoomInButtonClickCount = 0 // MARK: ズームインボタンがクリックされた回数を保持するプロパティ
    @State private var zoomOutButtonClickCount = 0 // MARK: ズームアウトボタンがクリックされた回数を保持するプロパティ
    @State private var registerButtonClickCount = 0 // MARK: レジスタボタンがクリックされた回数を保持するプロパティ
    @State private var isZooming = false // MARK: ズームインまたはズームアウトの状態を管理するプロパティ
    @State private var moveToPinButtonClickCount = 0 // MARK: ピン移動ボタンがクリックされた回数を保持するプロパティ
    @State private var registeredLocations = [MKMapItem]() // MARK: 登録された位置情報を保持するプロパティ
    @State private var isRegisterViewPresented = false // MARK: 位置登録画面の表示状態を管理するプロパティ
    @State private var registerLocationName = "" // MARK: 登録する位置の名称を保持するプロパティ
    @State private var justRegisteredFirst = false    // MARK: 登録フラグ
    @State private var justRegisteredSecond = false // MARK: 登録フラグ
    @State private var showAlreadyRegisteredAlertForHere = false
    @State private var showAlreadyRegisteredAlert = false // MARK: アラート表示状態を管理するプロパティ
    @State private var showAlreadyRegisteredAlertForLongTap = false
    @State private var showNoPinAlert = false
    @State private var showAlreadyRegisteredAlertForRemove = false
    @State private var showAlreadyRegisteredAlertForSearch = false
    @State private var tempSearchItem: MKMapItem?
    @Binding var showLocation: Bool  // MARK: 位置情報画面の表示フラグ
    @Binding var registeredLocationArray: [RegisteredLocation]  // MARK: NewViewから渡される登録された位置情報の配列
    @State private var initialLocation: CLLocationCoordinate2D? // MARK: 初期表示位置を保持するプロパティ
    @State private var selectedRegisteredLocation: RegisteredLocation? // MARK: 選択された登録済み地点を保持するプロパティ
    @State private var memoLocation: CLLocationCoordinate2D?
    @State var annotationTitle: String? = nil

    init(showLocation: Binding<Bool>,
         registeredLocationArray: Binding<[RegisteredLocation]>,
         selectedRegisteredLocation: RegisteredLocation? = nil) {
        self._showLocation = showLocation
        self._registeredLocationArray = registeredLocationArray
        self._initialLocation = State(initialValue: selectedRegisteredLocation?.coordinate)
        self._selectedRegisteredLocation = State(initialValue: selectedRegisteredLocation)
        if let location = selectedRegisteredLocation?.coordinate {
            self._memoLocation = State(initialValue: location)
            self._justRegisteredFirst = State(initialValue: true)
            self._justRegisteredSecond = State(initialValue: true)   
        }
        if let searchLocation = searchLocation {
            print("Debug-200 searchLocation: \(searchLocation)")
            self._searchLocation = State(initialValue: nil)
        }
        if let hereLocation = hereLocation {
            print("Debug-200 hereLocation: \(hereLocation)")
            self._hereLocation = State(initialValue: nil)
        }
        if let longTapLocation = longTapLocation {
            print("Debug-200 longTapLocation: \(longTapLocation)")
            self._longTapLocation = State(initialValue: nil)
        }
 }

    var body: some View {
        HStack {
            Button(action: {
                showLocation = false  // MARK: Cancelボタンが押されたらシートを閉じる
            }) {
                Text("Cancel")
            }
            Spacer()
            Text("Map View")  // タMARK: イトルを表示
            Spacer()
            Button(action: {
                // MARK: - 追加ボタンが押された時の処理
                if let coordinate = searchLocation ?? hereLocation ?? longTapLocation {
                    // MARK: -  UIApplication.shared.windowsを使用して
                    //          アプリケーションのすべてのウィンドウを取得し、
                    //          その中からキーウィンドウ（現在アクティブなウィンドウ）を見つけます。
                    //          キーウィンドウはユーザーが操作しているウィンドウであり、
                    //          このウィンドウを使ってスナップショットを取得します。
                    let window = UIApplication.shared.windows.first { $0.isKeyWindow }
                    // MARK: -  UIGraphicsImageRendererを初期化し、レンダリングする画像のサイズをキーウィンドウのサイズに設定します。
                    //          window?.bounds.sizeがnilの場合は.zero（サイズ0）を使用します。
                    let renderer = UIGraphicsImageRenderer(size: window?.bounds.size ?? .zero)
                    // MARK: -  スナップショットの作成
                    //          現在のウィンドウのヒエラルキー（階層構造）全体を描画します。
                    //          最新の表示内容がスナップショットに反映されます。
                    let image = renderer.image { ctx in
                        window?.drawHierarchy(in: window?.bounds ?? .zero, afterScreenUpdates: true)
                    }
                    // MARK: - 新しい登録位置+情報の作成
                    let newLocation = RegisteredLocation(name: registerLocationName, coordinate: coordinate, date: Date(), image: image)
                    registeredLocationArray.append(newLocation)
                    showLocation = false  // MARK: 位置情報登録状態中はシートを閉じる
                } else {
                    showLocation = false  // MARK: 情報登録状態中はシートを閉じる
                }
            }) {
                Text("追加")
                    .foregroundColor(justRegisteredFirst ? .blue : .gray)  // MARK: 位置情報登録状態中は青色、そうでない場合は灰色
            }
            .disabled(!justRegisteredFirst)  // MARK: 位置情報登録状態中でない場合はボタンを無効化
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
                memoLocation: $memoLocation,
                shouldShowUserLocationPin: $shouldShowUserLocationPin,
                shouldShowSearchLocationPin: $shouldShowSearchLocationPin,
                shouldShowLongTapLocationPin: $shouldShowLongTapLocationPin,
                isZooming: $isZooming,
                justRegisteredFirst: $justRegisteredFirst,
                justRegisteredSecond: $justRegisteredSecond,
                showAlreadyRegisteredAlertForLongTap: $showAlreadyRegisteredAlertForLongTap,
                annotationTitle: $annotationTitle,
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
                SearchItemSelectorView(searchResults: $searchResults, selectedSearchResult: $selectedSearchResult, onCancelOfSearchItemSelectorView: {
                    selectedSearchResult = nil // 検索結果を無効にする
                    isSearchItemSelectorPresented = false
                }, onConfirmOfSearchItemSelectorView: {
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
                        annotationTitle = selectedResult.name
                        print("Debug annotationTitle 0 = \(annotationTitle)")
                    } else {
                        selectedSearchResult = nil // MARK: 検索結果を無効にする
                    }
                    isSearchItemSelectorPresented = false
                })
            }
            ButtonBarView(
                onSearchButtonClicked: {
                    searchButtonClickCount += 1
                    isSearchBarPresented = true
                },
                searchButtonClickCount: searchButtonClickCount, // MARK: searchButtonClickCountを渡す
                hereButtonClickCount: hereButtonClickCount, // MARK: hereButtonClickCountを渡す
                removePinButtonClickCount: removePinButtonClickCount, // MARK: removePinButtonClickCountを渡す
                zoomInButtonClickCount: zoomInButtonClickCount, // MARK: zoomInButtonClickCountを渡す
                zoomOutButtonClickCount: zoomOutButtonClickCount, //MARK: zoomOutButtonClickCountを渡す
                registerButtonClickCount: registerButtonClickCount, // MARK: registerButtonClickCountを渡す
                moveToPinButtonClickCount: moveToPinButtonClickCount, // MARK: moveToPinButtonClickCountを渡す
                onMoveToPinButtonClicked: { // MARK: onMoveToPinButtonClickedを渡す
                    moveToPinButtonClickCount += 1
                    moveToPin()
                },
                onHereButtonClicked: {
                    if (justRegisteredFirst) {    // MARK: 登録済みかを判定
                        justRegisteredSecond = true
                        showAlreadyRegisteredAlertForHere = true
                    } else {
                        isZooming = false
                        hereButtonClickCount += 1
                        showHereLocation()
                    }
                },
                onRemovePinButtonClicked: {
                    if (justRegisteredFirst) {     // MARK: 登録済みかを判定
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
                onRegisterButtonClicked: { // MARK: 位置登録画面を表示する
                    registerButtonClickCount += 1
                    if hereLocation == nil && searchLocation == nil && longTapLocation == nil && memoLocation == nil {      // MARK: Pinが設置されたかを判定
                        showNoPinAlert = true
                    } else {
                        isRegisterViewPresented = true
                    }
                }
            )
            // MARK: - ロングタップ説明のテーロップ表示処理
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
                .frame(height: 50) // MARK: テロップの高さを設定
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
                    isRegisterViewPresented: $isRegisterViewPresented, // MARK: 引数の順序を変更
                    justRegisteredFirst: $justRegisteredFirst, // MARK: 引数の順序を変更
                    hereLocation: $hereLocation,
                    searchLocation: $searchLocation,
                    longTapLocation: $longTapLocation,
                    annotationTitle: $annotationTitle
                )
                .background(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            if let initialLocation = initialLocation {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // MARK: 表示範囲を設定
                let region = MKCoordinateRegion(center: initialLocation, span: span) // MARK: 表示領域を設定
                NotificationCenter.default.post(name: .moveToPin, object: region)
                if let selectedLocation = selectedRegisteredLocation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = selectedLocation.coordinate
                        annotation.title = selectedLocation.name
                        annotation.subtitle = "登録済み"
                        NotificationCenter.default.post(name: .addAnnotation, object: annotation)
                    }
                }
            } else {
                getHereLocation()
            }
            if let location = memoLocation, !justRegisteredSecond {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: location, span: span)
                NotificationCenter.default.post(name: .moveToPin, object: region)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    annotation.title = registerLocationName.isEmpty ? "新規" : registerLocationName
                    annotation.subtitle = justRegisteredFirst ? "登録済み" : "未登録"
                    NotificationCenter.default.post(name: .addAnnotation, object: annotation)
                }
            }
        }
        .alert("すでに登録した場所が存在します。新しい場所に移動しますか？", isPresented: $showAlreadyRegisteredAlertForHere) {
            Button("Cancel", role: .cancel) {
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
    
    // MARK: - 現在地の位置情報を取得するメソッド
    func getHereLocation() {
        locationManager.startUpdatingLocation()
        if let location = locationManager.location {
            hereLocation = location.coordinate
        }
    }
    
    // MARK: - 現在地ボタンがクリックされたときの処理
    func showHereLocation() {
        locationManager.startUpdatingLocation()
        if let location = locationManager.location {
            hereLocation = location.coordinate
            searchLocation = nil    // MARK: 検索結果の位置情報をクリアする
            longTapLocation = nil   // MARK: ロングタップの位置情報をクリアする
        }
    }
    
    // MARK: - 検索バーの検索ボタンがクリックされたときの処理
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
                annotationTitle = singleResult.name
                print("Debug annotationTitle 0 = \(annotationTitle)")
                if justRegisteredFirst {
                    tempSearchItem = singleResult
                    showAlreadyRegisteredAlertForSearch = true
                } else {
                    selectedSearchResult = singleResult
                    searchLocation = singleResult.placemark.coordinate
                    hereLocation = nil
                    longTapLocation = nil
                    searchResults = [singleResult] // MARK: - 選択された結果のみを保持する
                }
            } else if let _ = searchResults.first {
                isSearchItemSelectorPresented = true // MARK: - 検索結果が複数ある場合、SearchItemSelectorViewを表示
            }
            completion()
            // MARK: - 下記保留
            // for item in searchResults {
            //     print("Debuge Name: \(item.name ?? "No name")")
            //     print("Debuge Phone Number: \(item.phoneNumber ?? "No phone number")")
            //     print("Debuge URL: \(item.url?.absoluteString ?? "No URL")")
            //     print("Debuge Time Zone: \(item.timeZone?.identifier ?? "No time zone")")
            //     print("Debuge Placemark: \(item.placemark)")
            // }
        }
    }
    
    // MARK: - 検索ボタンがクリックされたときの処理と検索バーを閉じる処理
    func searchAndDismiss() {
        search {
            isSearchBarPresented = false
            isZooming = false // MARK: 検索結果が有効な地点選択後に設定
        }
    }
    
    // すべてのピンを削除するメソッド
    func removeAllPins() {
        hereLocation = nil
        searchLocation = nil
        longTapLocation = nil
        memoLocation = nil
        searchResults.removeAll()
        annotationTitle = ""
        print("Debug annotationTitle 4 = \(annotationTitle)")
   }
    
    // MARK: - ズームインボタンがクリックされたときの処理
    func zoomIn() {
        NotificationCenter.default.post(name: .zoomIn, object: nil)
    }

    // MARK: - ズームアウトボタンがクリックされたときの処理
    func zoomOut() {
        NotificationCenter.default.post(name: .zoomOut, object: nil)
    }

    // MARK: - ピンの位置に移動するメソッド
    func moveToPin() {
        if let coordinate = searchLocation ?? hereLocation ?? longTapLocation ?? memoLocation{ // MARK: Pinが設置されたかを判定
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // 表示範囲を設定
            let region = MKCoordinateRegion(center: coordinate, span: span) // 表示領域を設定
            NotificationCenter.default.post(name: .moveToPin, object: region)
        }
    }
    
    // MARK: - ピンの位置を登録するメソッド
    func registerLocation() {
        if let coordinate = searchLocation ?? hereLocation ?? longTapLocation {     // MARK: Pinが設置されたかを判定
            // MARK: - 新規MapItemを作りリストに追加
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = registerLocationName
            registeredLocations.append(mapItem)
            printRegisteredLocations()

            // MARK: - 登録したピンを再表示
            if let _ = searchLocation {
                selectedSearchResult = mapItem
                hereResult = nil
                longTapResult = nil
                hereLocation = nil
                longTapLocation = nil
            } else if let _ = longTapLocation {
                selectedSearchResult = nil
                hereResult = nil
                longTapResult = mapItem
                searchLocation = nil
                hereLocation = nil
            } else if let _ = hereLocation {
                selectedSearchResult = nil
                hereResult = mapItem
                longTapResult = nil
                searchLocation = nil
                longTapLocation = nil
            }
            justRegisteredFirst = true // MARK: 登録扱い
        }
    }

    // MARK: - 登録された全ての位置情報を表示するメソッド
    func printRegisteredLocations() {
        for (index, location) in registeredLocations.enumerated() {
            print("\(index + 1): \(location)")
        }
    }
}
