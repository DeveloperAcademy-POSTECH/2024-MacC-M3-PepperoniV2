//
//  SpeechGrader.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/20/24.
//

import SwiftUI
import AVFoundation
import Accelerate

/// 발음 정확도를 측정합니다.
func calculatePronunciation(original: [String], sttText: String) -> Double {
    // 일본어 단어 배열을 하나의 문자열로 합침
    let originalText = original.joined()
    
    // Levenshtein Distance 계산
    let distance = levenshteinDistance(originalText, sttText)
    
    // 정확도 계산: (원본 길이 - 거리) / 원본 길이 비율
    let accuracy = Double(originalText.count - distance) / Double(originalText.count) * 100
    return max(accuracy, 0) // 정확도는 최소 0으로 반환
}

/// 사용자 음성 시작지점 - 종료시점을 계산 합니다.
/// 편집 거리 알고리즘(Levenshtein Distance)
func calculateVoiceSpeed(originalLength: Double, sttVoicingTime: Double) -> Double {
    // 음성 시간이 0 이하인 경우 처리
    guard sttVoicingTime > 0 else {
        return 0.0 // 음성이 측정되지 않음
    }
    
    // 100% 점수 기준 시간 (±0.5초)
    let acceptableRange: Double = 0.8
    
    // 원래 음원 길이에 따라 점수 계산
    let minAcceptableTime = originalLength - acceptableRange
    let maxAcceptableTime = originalLength + acceptableRange
    
    if sttVoicingTime < minAcceptableTime {
        // sttVoicingTime이 너무 짧은 경우
        return max(0.0, 100.0 * (sttVoicingTime / originalLength))
    } else if sttVoicingTime > maxAcceptableTime {
        // sttVoicingTime이 너무 긴 경우
        return max(0.0, 100.0 * (originalLength / sttVoicingTime))
    } else {
        // sttVoicingTime이 허용된 범위 안에 있는 경우
        return 100.0 // 100% 점수
    }
}

/// Levenshtein Distance 함수
private func levenshteinDistance(_ source: String, _ target: String) -> Int {
    // target이 비어있거나 길이가 0인 경우 처리
    if target.isEmpty {
        return source.count
    }
    
    let (sourceCount, targetCount) = (source.count, target.count)
    var distanceMatrix = [[Int]](repeating: [Int](repeating: 0, count: targetCount + 1), count: sourceCount + 1)
    
    for i in 0...sourceCount { distanceMatrix[i][0] = i }
    for j in 0...targetCount { distanceMatrix[0][j] = j }
    
    for i in 1...sourceCount {
        for j in 1...targetCount {
            let cost = source[source.index(source.startIndex, offsetBy: i - 1)] == target[target.index(target.startIndex, offsetBy: j - 1)] ? 0 : 1
            distanceMatrix[i][j] = min(
                distanceMatrix[i - 1][j] + 1, // 삭제
                distanceMatrix[i][j - 1] + 1, // 추가
                distanceMatrix[i - 1][j - 1] + cost // 대체
            )
        }
    }
    
    return distanceMatrix[sourceCount][targetCount]
}

// calculateIntonation 함수
func calculateIntonation(referenceFileName: String, comparisonFileURL: URL) -> Double {
    
    var referenceURL: URL?

    // Documents 이하 경로 추출
    if let documentRange = referenceFileName.range(of: "/Documents/") {
        let relativePath = String(referenceFileName[documentRange.upperBound...]) // "CHOIAE_008.m4a"
        
        // 현재 앱의 Document 디렉토리 경로 가져오기
        let currentDocumentDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // 새로운 URL 생성
        referenceURL = currentDocumentDirectory.appendingPathComponent(relativePath)
        
        print("Updated URL: \(referenceURL)") // /var/mobile/Containers/Data/Application/NEW_UUID/Documents/CHOIAE_008.m4a
    } else {
        print("Invalid path: \(referenceFileName)")
    }
    
    
    if let referenceURL = referenceURL {
        
        // 파일 존재 여부 확인
        guard FileManager.default.fileExists(atPath: referenceURL.path) else {
            print("참조 파일을 찾을 수 없습니다: \(referenceURL.path)")
            return 0.0
        }
        guard let referencePitchData = extractPitchData(from: referenceURL, applyVolumeThreshold: false), // 볼륨 기준 미적용
              let comparisonPitchData = extractPitchData(from: comparisonFileURL, applyVolumeThreshold: true) else { // 볼륨 기준 적용
            print("피치 데이터를 추출할 수 없습니다.")
            return 0.0
        }
        
        // 이후 코드는 동일
        let validReferenceData = referencePitchData.compactMap { $0 > 0 ? $0 : nil }
        let validComparisonData = comparisonPitchData.compactMap { $0 > 0 ? $0 : nil }
        
        guard !validReferenceData.isEmpty, !validComparisonData.isEmpty else {
            print("유효한 피치 데이터가 부족합니다.")
            return 0.0
        }
        
        let resampledComparisonData = resamplePitchData(source: validComparisonData, targetLength: validReferenceData.count)
        let referenceMean = validReferenceData.reduce(0, +) / CGFloat(validReferenceData.count)
        let comparisonMean = resampledComparisonData.reduce(0, +) / CGFloat(resampledComparisonData.count)
        let normalizedReferenceData = validReferenceData.map { $0 - referenceMean }
        let normalizedComparisonData = resampledComparisonData.map { $0 - comparisonMean }
        
        var matchingStates = 0
        for i in 1..<validReferenceData.count {
            let referenceDiff = normalizedReferenceData[i] - normalizedReferenceData[i - 1]
            let comparisonDiff = normalizedComparisonData[i] - normalizedComparisonData[i - 1]
            
            let referenceState = referenceDiff > 0 ? 1 : (referenceDiff < 0 ? -1 : 0)
            let comparisonState = comparisonDiff > 0 ? 1 : (comparisonDiff < 0 ? -1 : 0)
            
            if referenceState == comparisonState {
                matchingStates += 1
            }
        }
        
        let similarity = Double(matchingStates) / Double(validReferenceData.count - 1)
        let intonationScore = similarity * 100
        let referenceLength = Double(validReferenceData.count)
        let comparisonLength = Double(validComparisonData.count)
        let lengthScore = max(0.0, 100.0 * (min(comparisonLength, referenceLength) / max(comparisonLength, referenceLength)))
        
        let score = (intonationScore * 0.7) + (lengthScore * 0.3)
        let finalScore: Double
        switch similarity {
        case 0.55...1.0:
            finalScore = Double(90 + (similarity - 0.55) / 0.15 * 10)
        case 0.45..<0.55:
            finalScore = Double(75 + (similarity - 0.45) / 0.10 * 15)
        case 0.30..<0.45:
            finalScore = Double(50 + (similarity - 0.30) / 0.15 * 25)
        case 0.0..<0.30:
            finalScore = Double(similarity / 0.30 * 50)
        default:
            finalScore = 0
        }
        
        return min(100.0, finalScore)
        
    } else {
        
        print("Error: referenceURL is not valid")
        return 0
        
    }
}


/// 리샘플링 함수
func resamplePitchData(source: [CGFloat], targetLength: Int) -> [CGFloat] {
    let sourceLength = source.count
    guard sourceLength > 1 else { return Array(repeating: source.first ?? 0, count: targetLength) }
    
    var resampledData = [CGFloat]()
    for i in 0..<targetLength {
        let sourceIndex = CGFloat(i) * CGFloat(sourceLength - 1) / CGFloat(targetLength - 1)
        let lowerIndex = Int(floor(sourceIndex))
        let upperIndex = Int(ceil(sourceIndex))
        if lowerIndex == upperIndex {
            resampledData.append(source[lowerIndex])
        } else {
            let lowerWeight = CGFloat(upperIndex) - sourceIndex
            let upperWeight = sourceIndex - CGFloat(lowerIndex)
            let interpolatedValue = source[lowerIndex] * lowerWeight + source[upperIndex] * upperWeight
            resampledData.append(interpolatedValue)
        }
    }
    return resampledData
}

/// m4a 파일에서 피치 데이터를 추출하는 함수
func extractPitchData(from fileURL: URL, applyVolumeThreshold: Bool = true) -> [CGFloat]? {
    do {
        let audioFile = try AVAudioFile(forReading: fileURL)
        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("PCM 버퍼 생성 실패")
            return nil
        }
        
        try audioFile.read(into: buffer)
        
        // AudioManager2에서 참조한 calculateRelativePitch 함수의 기능을 구현
        return calculateRelativePitch(buffer: buffer, applyVolumeThreshold: applyVolumeThreshold)
    } catch {
        print("오디오 파일을 읽는 데 실패했습니다: \(error)")
        return nil
    }
}

/// calculateRelativePitch 함수 구현
func calculateRelativePitch(buffer: AVAudioPCMBuffer, applyVolumeThreshold: Bool) -> [CGFloat] {
    let frameLength = buffer.frameLength
    guard let channelData = buffer.floatChannelData else { return [] }
    
    var pitchData: [CGFloat] = []
    let frameDuration: Double = 0.05
    let sampleRate = buffer.format.sampleRate
    let frameSize = Int(Double(sampleRate) * frameDuration)
    
    var frameStart = 0
    let volumeThreshold: Float = 0.03
    let minVoiceFrequency: CGFloat = 85.0
    let maxVoiceFrequency: CGFloat = 300.0
    
    while frameStart + frameSize <= frameLength {
        let frameData = Array(UnsafeBufferPointer(start: channelData[0] + frameStart, count: frameSize))
        let rms = calculateRMS(data: frameData)
        var pitch: CGFloat
        
        // 볼륨 임계값 적용 여부 확인
        if applyVolumeThreshold && rms > volumeThreshold {
            pitch = calculatePitch(data: frameData, sampleRate: Float(sampleRate))
            
            if pitch < minVoiceFrequency || pitch > maxVoiceFrequency {
                pitch = pitchData.last ?? 0
            }
        } else if !applyVolumeThreshold {
            // 볼륨 임계값을 무시하고 피치 계산
            pitch = calculatePitch(data: frameData, sampleRate: Float(sampleRate))
            
            if pitch < minVoiceFrequency || pitch > maxVoiceFrequency {
                pitch = pitchData.last ?? 0
            }
        } else {
            pitch = pitchData.last ?? 0
        }
        
        if pitchData.isEmpty {
            pitchData.append(0)
        } else {
            pitchData.append(pitch - pitchData.first!)
        }
        
        frameStart += frameSize
    }
    
    return pitchData
}

/// RMS 계산 함수
func calculateRMS(data: [Float]) -> Float {
    let squareSum = data.reduce(0) { $0 + $1 * $1 }
    return sqrt(squareSum / Float(data.count))
}

/// 피치 계산 함수
func calculatePitch(data: [Float], sampleRate: Float) -> CGFloat {
    let originalCount = data.count
    let log2n = vDSP_Length(log2(Float(8192)).rounded(.up))
    let fftSize = Int(1 << log2n)
    
    var paddedData = data
    if originalCount < fftSize {
        paddedData.append(contentsOf: [Float](repeating: 0, count: fftSize - originalCount))
    }
    
    guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
        return 0.0
    }
    
    var frequency: CGFloat = 0.0
    var realParts = paddedData
    var imaginaryParts = [Float](repeating: 0.0, count: fftSize)
    
    realParts.withUnsafeMutableBufferPointer { realPointer in
        imaginaryParts.withUnsafeMutableBufferPointer { imaginaryPointer in
            var splitComplex = DSPSplitComplex(realp: realPointer.baseAddress!, imagp: imaginaryPointer.baseAddress!)
            vDSP_fft_zip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
            
            var magnitudes = [Float](repeating: 0.0, count: fftSize / 2)
            vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))
            
            if let maxMagnitude = magnitudes.max(), maxMagnitude > 0 {
                let maxIndex = magnitudes.firstIndex(of: maxMagnitude) ?? 0
                frequency = CGFloat(Float(maxIndex) * sampleRate / Float(fftSize))
            }
        }
    }
    
    vDSP_destroy_fftsetup(fftSetup)
    return frequency
}
