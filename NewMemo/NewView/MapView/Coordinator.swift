//
//  Coordinator.swift
//  SearchMap
//
//  Created by Xiaojing Wang on 2025/01/06.
//

import SwiftUI
import UIKit
import MapKit

// MARK: - MKMapViewDelegateを実装するコーディネータクラス
class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    var onLongTap: () -> Void
    @Binding var justRegisteredFirst: Bool
    @Binding var justRegisteredSecond: Bool
    @Binding var showAlreadyRegisteredAlertForLongTap: Bool
    
    init(_ parent: MapView,
         onLongTap: @escaping () -> Void,
         justRegisteredFirst: Binding<Bool>,
         justRegisteredSecond: Binding<Bool>,
         showAlreadyRegisteredAlertForLongTap: Binding<Bool>) {
        self.parent = parent
        self.onLongTap = onLongTap
        self._justRegisteredFirst = justRegisteredFirst
        self._justRegisteredSecond = justRegisteredSecond
        self._showAlreadyRegisteredAlertForLongTap = showAlreadyRegisteredAlertForLongTap
    }
    
    // MARK: - アノテーションビューをカスタマイズするメソッド
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CurrentLocation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.pinTintColor = .red // MARK: ピンの色を赤に設定
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    // MARK: - ロングタップを処理するメソッド
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if justRegisteredFirst {
                // MARK: - ロングタップの位置を取得
                let location = gestureRecognizer.location(in: gestureRecognizer.view)
                let coordinate = (gestureRecognizer.view as! MKMapView)
                    .convert(location, toCoordinateFrom: gestureRecognizer.view)
                
                // MARK: - アラートを作成
                let alert = UIAlertController(
                    title: "すでに登録した場所が存在します。新しい場所に移動しますか？",
                    message: nil,
                    preferredStyle: .alert
                )
                // MARK: - Cancelボタンを追加
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                // MARK: - OKボタンを追加
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.showAlreadyRegisteredAlertForLongTap = false
                    self.justRegisteredFirst = false
                    self.justRegisteredSecond = false
                    self.parent.longTapLocation = coordinate
                    self.onLongTap()
                })
                
                // MARK: - UIKitのビューコントローラを取得してアラートを表示
                if let rootVC = topViewController() {
                    rootVC.present(alert, animated: true)
                }
            } else {
                // MARK: - ロングタップの位置を取得
                let location = gestureRecognizer.location(in: gestureRecognizer.view)
                let coordinate = (gestureRecognizer.view as! MKMapView)
                    .convert(location, toCoordinateFrom: gestureRecognizer.view)
                parent.longTapLocation = coordinate
                // MARK: - ロングタップの処理を実行
                onLongTap()
            }
        }
    }
    // MARK: - SwiftUIのビューから現在の表示中のビューコントローラを再帰的に取得するtopViewController()メソッドを使用しています。
    // MARK: これにより、SwiftUIの最上層から正しいビューコントローラを取得し、アラートを表示することができます。
    func topViewController(controller: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
}
