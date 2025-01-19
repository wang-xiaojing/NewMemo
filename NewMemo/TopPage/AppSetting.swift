//
//  SizeStyle.swift
//  GolfGear
//
//  Created by 王暁晶 on 2024/09/18.
//
// ファオンとサイズ、カラーなどの設定値
import SwiftUI

struct AppSetting {
    // MARK: AudioView用
    public static let voiceRecodeSamplePoints:Int = 60
    public static let voiceRecodeSampleTimeInterval:TimeInterval = 0.1
    
    public static let cornerRadius: CGFloat = 10
    public static let shadowRadius: CGFloat = 10
    public static let sideHandrailWidth: CGFloat = 5
    public static let sideHandrailHeight: CGFloat = 60
    public static let menuSheetItems: [[String]] = [
        ["text.document", "Text", " of Text Memo."],
        ["calendar", "Date", " of Date Memo."],
        ["clock.badge.checkmark", "Time", " of Time Memo."],
        ["globe.asia.australia", "Location", " of Location Memo."],
        ["alarm.waves.left.and.right", "Alarm", " of Alarm Memo."],
        ["music.microphone", "Voice Rec.", " of Voice Rec. Memo."],
        ["medical.thermometer", "Thermometer", " of Thermometer Memo."],
        ["heart", "Heart Rate", " of Heart Rate Memo."],
        ["waveform.path.ecg.rectangle", "Blood Pressure", " of Blood Pressure Memo."],
        ["figure.mixed.cardio", "Weight Scale", " of Weight Scale Memo."],
        ["coat", "Wear", " of Wear Memo."],
        ["basket", "Shopping", " of Shopping Memo."],
        ["dollarsign", "Money", " of Money Memo."],
        ["calendar.badge.checkmark", " of Schedule", "Schedule Memo."],
        ["book", "Diary", " of Diary Memo."],
        ["photo.artframe", "Picture", " of Picture Memo."],
        ["frying.pan", "Cooking", " of Cooking Memo."],
        ["books.vertical.fill", "Reading", " of Reading Memo."],
        ["cloud.sun", "Weather", " of Weather Memo."],
        ["figure.run", "Running", " of Running Memo."]
    ]
}

