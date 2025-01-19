//
//  AudioView.swift
//  VoicApp
//
//  Created by Xiaojing Wang on 2025/01/01.
//
import SwiftUI

// MARK: - 新しい AudioView
struct AudioView: View {
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @Binding var showAudioAlertFlag: Bool
    @Binding var audioAlertTitle: String
    @Binding var audioAlertMessage: String
    
    @Binding var isAudioSaveEnabled: Bool
    @Binding var showAudioOverlayWindow: Bool
    @Binding var isAudioPaused: Bool
    
    @Binding var audioWaveSamples: [CGFloat]
    @Binding var audioWaveTimer: Timer?
    
    @State private var showDeleteConfirmation = false
    @State private var fileNameToDelete: String?

    var body: some View {
        NavigationView {
            VStack {
                // MARK: - 録音一覧
                List {
                    ForEach(audioRecorder.audioRecordings) { recording in
                        VStack {
                            HStack(spacing: 5) {
                                Text(recording.fileName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                // MARK: - 停止ボタン
                                if recording.isPlaying {
                                    Button(action: {
                                        audioRecorder.stopPlay(fileName: recording.fileName)
                                    }) {
                                        Image(systemName: "stop.fill")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    Spacer()
                                }
                                // MARK: - 再生ボタン
                                Button(action: {
                                    if recording.isPlaying {
                                        if recording.isPaused {
                                            audioRecorder.resumeRecording(fileName: recording.fileName)
                                        } else {
                                            audioRecorder.pauseRecording(fileName: recording.fileName)
                                        }
                                    } else {
                                        audioRecorder.playRecording(fileName: recording.fileName)
                                    }
                                }) {
                                    Image(systemName: recording.isPlaying
                                          ? (recording.isPaused ? "play.fill" : "pause.fill")
                                          : "play.circle")
                                    .resizable()
                                    .frame(width: recording.isPlaying ? 18 : 20, height: recording.isPlaying ? 18 : 20)
                                    .foregroundColor(.blue)
                                    .opacity(audioRecorder.audioRecordings.contains { $0.isPlaying && $0.fileName != recording.fileName } ? 0.5 : 1.0)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(audioRecorder.audioRecordings.contains { $0.isPlaying && $0.fileName != recording.fileName })
                                Spacer()
                                // MARK: - 削除
                                Button(action: {
                                    if recording.isPlaying {
                                        showAlert(title: "削除不可", message: "再生中のため削除できません。")
                                    } else {
                                        showDeleteConfirmation = true
                                        fileNameToDelete = recording.fileName
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
                                        .opacity(audioRecorder.audioRecordings.contains { $0.isPlaying && $0.fileName != recording.fileName } ? 0.5 : 1.0)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(audioRecorder.audioRecordings.contains { $0.isPlaying && $0.fileName != recording.fileName })
                            }
                            // MARK: - 再生の進捗バー
                            ProgressView(value: recording.progress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        .padding(.vertical, 5)
                    }
                }
                .disabled(showAudioOverlayWindow)
            }
            .onAppear {
                audioRecorder.fetchRecordings()
            }
            .alert(audioAlertTitle, isPresented: $showAudioAlertFlag) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(audioAlertMessage)
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Confirmation"),
                    message: Text("Are you sure you want to delete this recording?"),
                    primaryButton: .destructive(Text("OK")) {
                        if let fileName = fileNameToDelete {
                            audioRecorder.deleteRecording(fileName: fileName)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        audioAlertTitle = title
        audioAlertMessage = message
        showAudioAlertFlag = true
    }
}

