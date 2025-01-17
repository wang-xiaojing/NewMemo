//
//  MapView.swift
//  SearchMap
//
//  Created by Xiaojing Wang on 2025/01/06.
//
import SwiftUI
import MapKit

// MARK: - 地図を表示するビュー
struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedSearchResult: MKMapItem?
    @Binding var hereResult: MKMapItem?
    @Binding var longTapResult: MKMapItem?
    @Binding var hereLocation: CLLocationCoordinate2D?
    @Binding var searchLocation: CLLocationCoordinate2D?
    @Binding var longTapLocation: CLLocationCoordinate2D?
    @Binding var memoLocation: CLLocationCoordinate2D?
    @Binding var shouldShowUserLocationPin: Bool
    @Binding var shouldShowSearchLocationPin: Bool // MARK: 検索結果座標にピンを表示するかどうかを保持するプロパティ
    @Binding var shouldShowLongTapLocationPin: Bool // MARK: ロングタップ座標にピンを表示するかどうかを保持するプロパティ
    @Binding var isZooming: Bool // MARK: ズームインまたはズームアウトの状態を管理するプロパティ
    @Binding var justRegisteredFirst: Bool
    @Binding var justRegisteredSecond: Bool
    @Binding var showAlreadyRegisteredAlertForLongTap: Bool
    @Binding var annotationTitle: String?

    var onLongTap: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onLongTap: onLongTap,
                    justRegisteredFirst: $justRegisteredFirst,
                    justRegisteredSecond: $justRegisteredSecond,
                    showAlreadyRegisteredAlertForLongTap: $showAlreadyRegisteredAlertForLongTap)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
       
        // MARK: - ズームインとズームアウトの通知を受け取る
        NotificationCenter.default.addObserver(forName: .zoomIn, object: nil, queue: .main) { _ in
            let region = uiView.region
            let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2, longitudeDelta: region.span.longitudeDelta / 2)
            let newRegion = MKCoordinateRegion(center: region.center, span: span)
            uiView.setRegion(newRegion, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .zoomOut, object: nil, queue: .main) { _ in
            let region = uiView.region
            let span = MKCoordinateSpan(
                latitudeDelta: min(region.span.latitudeDelta * 2, 180),
                longitudeDelta: min(region.span.longitudeDelta * 2, 360)
            )
            let newRegion = MKCoordinateRegion(center: region.center, span: span)
            uiView.setRegion(newRegion, animated: true)
        }

        NotificationCenter.default.addObserver(forName: .moveToPin, object: nil, queue: .main) { notification in
            if let region = notification.object as? MKCoordinateRegion {
                uiView.setRegion(region, animated: true)
            }
        }

        NotificationCenter.default.addObserver(forName: .addAnnotation, object: nil, queue: .main) { notification in
            if let annotation = notification.object as? MKPointAnnotation {
                uiView.addAnnotation(annotation)
            }
        }
        
        // MARK: - ロングタップの位置情報が取得できた場合
        if let coordinate = longTapLocation, !justRegisteredSecond {   // MARK: ロングタップの座標が設定されている場合
            // MARK: - 既存のアノテーションを削除
            uiView.removeAnnotations(uiView.annotations)
            // MARK: - ロングタップの位置にピンを追加
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
                if let selectedResult = longTapResult {
                    annotation.title = selectedResult.name
                    if justRegisteredFirst {    // MARK: 登録済みかを判定
                        annotation.subtitle = "登録済み"
                    } else {
                        annotation.subtitle = "未登録"
                    }
                } else {
                    if justRegisteredFirst {    // MARK: 登録済みかを判定
                        annotation.subtitle = "登録済み"
                    } else {
                        annotation.title = ""
                        annotation.subtitle = "未登録"
                    }
                }
            uiView.addAnnotation(annotation)
            annotationTitle = annotation.title
            print("Debug annotationTitle 1 = \(annotationTitle)")
        } else if let coordinate = searchLocation, !justRegisteredSecond {     // MARK: 検索結果の座標が設定されている場合
            // MARK: - 既存のアノテーションを削除
            uiView.removeAnnotations(uiView.annotations)
            // MARK: - 検索結果の位置情報が取得できた場合
            if !isZooming {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // MARK: 表示範囲を設定
                let region = MKCoordinateRegion(center: coordinate, span: span) // MARK: 表示領域を設定
                uiView.setRegion(region, animated: true) // MARK: 地図の表示領域を更新
            }
            // MARK: - 検索結果座標にピンを追加
            let annotation = MKPointAnnotation() // MARK: アノテーションを作成
            annotation.coordinate = coordinate // MARK: アノテーションの座標を設定
            if let selectedResult = selectedSearchResult {
                annotation.title = selectedResult.name // アノテーションのタイトルを設定
                if justRegisteredFirst {    // MARK: 登録済みかを判定
                    annotation.subtitle = "登録済み"
                } else {
                    annotation.subtitle = "未登録"
                }
            } else {
                if justRegisteredFirst {    // MARK: 登録済みかを判定
                    annotation.subtitle = "登録済み"
                } else {
                    annotation.title = ""
                    annotation.subtitle = "未登録"
                }
            }
            uiView.addAnnotation(annotation) // MARK: アノテーションをマップに追加
        } else if let coordinate = hereLocation, !justRegisteredSecond {       // MARK: 現在地の座標が設定されている場合
            // MARK: - 既存のアノテーションを削除
            uiView.removeAnnotations(uiView.annotations)
            // MARK: - 現在地の位置情報が取得できた場合
            if !isZooming {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // MARK: 表示範囲を設定
                let region = MKCoordinateRegion(center: coordinate, span: span) // MARK: 表示領域を設定
                uiView.setRegion(region, animated: true) // MARK: 地図の表示領域を更新
            }
            // MARK: - 現在地にピンを追加
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            if justRegisteredFirst {    // MARK: 登録済みかを判定
                if let selectedResult = hereResult {
                    annotation.title = selectedResult.name // アノテーションのタイトルを設定
                    annotation.subtitle = "登録済み"
                } else {
                    annotation.title = "Current"
                    annotation.subtitle = "未登録"
                }
            } else {
                annotation.title = "Current"
                annotation.subtitle = "未登録"
            }
            uiView.addAnnotation(annotation)
            annotationTitle = annotation.title
            print("Debug annotationTitle 2 = \(annotationTitle)")
        } else if let coordinate = memoLocation, !justRegisteredSecond {
            uiView.removeAnnotations(uiView.annotations)
            if !isZooming {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                uiView.setRegion(region, animated: true)
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            if justRegisteredFirst {
                annotation.title = hereResult?.name ?? "Saved"
                annotation.subtitle = "登録済み"
            } else {
                annotation.title = "New"
                annotation.subtitle = "未登録"
            }
            uiView.addAnnotation(annotation)
            annotationTitle = annotation.title
            print("Debug annotationTitle 3 = \(annotationTitle)")
        } else if let coordinate = locationManager.location?.coordinate, !justRegisteredSecond {       // MARK: 画面にピンが置かれていない状態）
            // MARK: - 既存のアノテーションを削除
            uiView.removeAnnotations(uiView.annotations)
            // MARK: - 初期表示範囲を設定
            if !isZooming {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // MARK: 表示範囲を設定
                let region = MKCoordinateRegion(center: coordinate, span: span) // MARK: 表示領域を設定
                uiView.setRegion(region, animated: true) //  MARK: 地図の表示領域を更新
            }
        }
            }
}

extension Notification.Name {
    static let zoomIn = Notification.Name("zoomIn")
    static let zoomOut = Notification.Name("zoomOut")
    static let moveToPin = Notification.Name("moveToPin")
    static let addAnnotation = Notification.Name("addAnnotation")
}
