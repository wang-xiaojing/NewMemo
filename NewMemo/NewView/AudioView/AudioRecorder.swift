//
//  AudioRecording.swift
//  VoicApp
//
//  Created by Xiaojing Wang on 2025/01/01.
//
import SwiftUI
import AVFoundation
import Foundation

// MARK: - 録音データのモデル
struct AudioRecording: Identifiable {
    let id = UUID()
    let fileName: String
    let createdAt: Date
    var isPlaying = false
    var isPaused = false
    var progress: Double = 0.0 // 再生の進捗を保持するプロパティを追加
}

// MARK: - AudioRecorderクラス (録音/再生/削除 ロジックと状態管理)
class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioRecordings = [AudioRecording]()
    @Published var playingStates: [String: Bool] = [:]

    @Published var internalRecorder: AVAudioRecorder?
    @Published var audioPlayer: AVAudioPlayer?
    var progressTimer: Timer?

    // MARK: - 録音メータリング関連
    func enableMetering() {
        internalRecorder?.isMeteringEnabled = true
    }

    func updateMeters() {
        internalRecorder?.updateMeters()
    }

    func averagePower(forChannel channel: Int) -> Float {
        internalRecorder?.averagePower(forChannel: channel) ?? -160.0
    }

    override init() {
        super.init()
        setupAudioSession()
        fetchRecordings()
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("オーディオセッションの設定に失敗しました: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = formatter.string(from: Date()) + ".m4a"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)     // MARK: 録音音量の試しコード
            try session.setActive(true)
            internalRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            internalRecorder?.isMeteringEnabled = true
            internalRecorder?.record()
            isRecording = true
        } catch {
            print("録音に失敗しました: \(error.localizedDescription)")
        }
    }

    func pauseRecording(fileName: String) {
        audioPlayer?.pause()
        updateRecordingState(fileName: fileName, isPlaying: true, isPaused: true)
        progressTimer?.invalidate()
    }

    func resumeRecording(fileName: String) {
        audioPlayer?.play()
        updateRecordingState(fileName: fileName, isPlaying: true, isPaused: false)
        startProgressTimer(fileName: fileName)
    }

    func stopRecording() {
        internalRecorder?.stop()
        isRecording = false
        fetchRecordings()
    }

    func fetchRecordings() {
        let files = getAllRecordingFiles()
        var existingFileNames = Set(audioRecordings.map { $0.fileName })
        let currentFileNames = Set(files.map { $0.lastPathComponent })

        // MARK: - 新しいファイルを追加
        for url in files {
            let fileName = url.lastPathComponent
            if !existingFileNames.contains(fileName) {
                let rec = AudioRecording(fileName: fileName, createdAt: fileCreatedDate(for: url))
                audioRecordings.append(rec)
                existingFileNames.insert(fileName)
                if playingStates[rec.fileName] == nil {
                    playingStates[rec.fileName] = false
                }
            }
        }
    
        // MARK: - 存在しないファイルを除外
        audioRecordings.removeAll { !currentFileNames.contains($0.fileName) }
    }
    
    func playRecording(fileName: String) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            // MARK: - ファイルが存在するか確認
            guard FileManager.default.fileExists(atPath: audioFilename.path) else {
                print("ファイルが存在しません: \(audioFilename.path)")
                return
            }
            
            // MARK: - オーディオセッションの設定
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            // MARK: - AVAudioPlayerのインスタンスを作成
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0 // MARK: ここで音量を調整（0.0 から 1.0 の範囲）
            audioPlayer?.play()
            
            // MARK: - 再生状態を更新
            DispatchQueue.main.async {
                withAnimation {
                    for key in self.playingStates.keys {
                        self.playingStates[key] = false
                    }
                    self.playingStates[fileName] = true
                }
            }
            
            // 録音状態を更新し、進捗タイマーを開始
            updateRecordingState(fileName: fileName, isPlaying: true, isPaused: false)
            startProgressTimer(fileName: fileName)
        } catch {
            print("再生中にエラーが発生しました: \(error.localizedDescription)")
        }
    }

    func deleteRecording(fileName: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("削除に失敗しました: \(error.localizedDescription)")
        }
        fetchRecordings()
    }

    func stopPlay(fileName: String) {
        if let index = audioRecordings.firstIndex(where: { $0.fileName == fileName }) {
            audioRecordings[index].isPlaying = false
            audioRecordings[index].isPaused = false
            audioRecordings[index].progress = 0.0
        }
        audioPlayer?.stop()
        audioPlayer = nil
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func getAllRecordingFiles() -> [URL] {
        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: getDocumentsDirectory(),
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            return urls.filter { $0.pathExtension == "m4a" }
        } catch {
            print("録音ファイルの一覧取得に失敗しました: \(error)")
            return []
        }
    }

    private func fileCreatedDate(for url: URL) -> Date {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.creationDate] as? Date ?? Date()
        } catch {
            print("ファイル作成日時の取得に失敗しました: \(error.localizedDescription)")
            return Date()
        }
    }

    func updateRecordingState(fileName: String, isPlaying: Bool, isPaused: Bool) {
        if let index = audioRecordings.firstIndex(where: { $0.fileName == fileName }) {
            audioRecordings[index].isPlaying = isPlaying
            audioRecordings[index].isPaused = isPaused
        }
    }

    private func startProgressTimer(fileName: String) {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            if let index = self.audioRecordings.firstIndex(where: { $0.fileName == fileName }) {
                self.audioRecordings[index].progress = player.currentTime / player.duration
            }
        }
    }
}

extension AudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            withAnimation {
                for key in self.playingStates.keys {
                    self.playingStates[key] = false
                }
                if let fileName = self.audioPlayer?.url?.lastPathComponent {
                    self.updateRecordingState(fileName: fileName, isPlaying: false, isPaused: false)
                    if let index = self.audioRecordings.firstIndex(where: { $0.fileName == fileName }) {
                        self.audioRecordings[index].progress = 0.0
                    }
                }
            }
        }
        progressTimer?.invalidate()
    }
}
