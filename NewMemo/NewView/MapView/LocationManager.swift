//
//  LocationManager.swift
//  SearchMap
//
//  Created by Xiaojing Wang on 2025/01/06.
//
import SwiftUI
import MapKit

// MARK: - 位置情報の管理を行うクラス
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager() // CLLocationManagerのインスタンス
    @Published var location: CLLocation? // MARK: 位置情報を公開するプロパティ

    override init() {
        super.init()
        self.locationManager.delegate = self // MARK: デリゲートの設定
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // MARK: 位置情報の精度を設定
        self.locationManager.requestWhenInUseAuthorization() // MARK: 位置情報の使用許可をリクエスト
        self.locationManager.startUpdatingLocation() // MARK: 位置情報の更新を開始
    }

    // MARK: - 位置情報が更新されたときに呼び出されるメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location // MARK: 最新の位置情報を保存
            self.locationManager.stopUpdatingLocation() // MARK: 位置情報の更新を停止
        }
    }

    // MARK: - 現在地の位置情報を取得するメソッド
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
}
