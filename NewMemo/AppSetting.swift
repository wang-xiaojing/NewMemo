//
//  SizeStyle.swift
//  GolfGear
//
//  Created by 王暁晶 on 2024/09/18.
//
// ファオンとサイズ、カラーなどの設定値
import SwiftUI

struct AppSetting {

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




    public static let ClubTypeBarFontSize: Font = .headline
    
    public static let titleFontSizeSmall: Font = .caption2
    public static let titleFontSizeLight: Font = .subheadline
    public static let titleFontSizeHeavy: Font = .body
    
    public static let titleColorLight = Color.black
    public static let titleColorHeavy = Color.green
    public static let subTitleColorLight = Color.gray
    
    public static let fieldFontSizeLight: Font = .caption
    public static let fieldFontSizeHeavy: Font = .subheadline
    
    public static let fieldFontColorLight = Color.black
    public static let fieldFontColorHeavy = Color.green
    
    public static let fieldBackColorHeavy = Color.blue.opacity(0.1)
    public static let fieldBackColorLight = Color.white
    
    public static let fieldBodyColorLight = Color.black.opacity(0.01)
    public static let fieldBodyColorHeavy = Color.green.opacity(0.8)
    public static let fieldBodyLineWidth: CGFloat = 0.5
    
    public static let pickerFontSizeSmall: Font = .caption2
    public static let pickerFontSizeLight: Font = .caption
    public static let pickerFontSizeHeavy: Font = .subheadline
    
    public static let operationGuidFontSize: Font = .caption
    public static let operationGuidWidth: CGFloat = 90
    public static var operationGuidHeight: CGFloat { return operationGuidWidth * 0.618 / 2 }
    public static let operationGuidShortWidth: CGFloat = 70
    public static var operationGuidShortHeight: CGFloat { return operationGuidHeight }
    public static let operationGuidLineWidth: CGFloat = 0.8
    public static let operationGuidCornerRadius: CGFloat = 8
    
    public static let operationGuidFontColor = Color.white.opacity(1.0)
    public static let operationGuidBorderColor = Color.blue.opacity(0.6)
    public static var operationGuidBackColor: Color { return operationGuidBorderColor }
    public static let announcementMessageFontColor = Color.red
    
    public static let formBackColorLight = Color.gray.opacity(0.4)
    public static let formBackColorHeavy = Color.green.opacity(0.4)
    
    public static let modifyModeColor10 = Color.white
    public static let modifyModeColor09 = Color.white
    
    public static let inputAreaBorderWidth = 1.0
    public static let inputAreaColor = Color.yellow.opacity(0.3)
    
    public static let shadowSetting = CGFloat(1)
    
    public static let detentsOfMessageBox:Set<PresentationDetent> = [
        /*.large,
         .medium
         .fraction(0.85),
         .height(UIScreen.main.bounds.height / 3),*/
        .height(UIScreen.main.bounds.height / 5)/*,
                                                 .height(UIScreen.main.bounds.height / 6)*/
     ]
    
    enum ClubTextType {
        case isNoFieldText
        case isFieldOnly
        case decimalPlace0NumField    // 小数点なしの数字
        case decimalPlace1NumField    // 小数点以下1桁の数字及び小数点
        case decimalPlace2NumField    // 小数点以下2桁の数字及び小数点
        case isDateField
        case isTextPicker
    }
}

