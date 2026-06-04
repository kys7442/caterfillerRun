#!/bin/bash

# iOS 릴리스 빌드 스크립트
# Caterpillar Run 게임 앱

set -e

echo "=========================================="
echo "Caterpillar Run - iOS 릴리스 빌드"
echo "=========================================="

# 프로젝트 디렉토리로 이동
cd "$(dirname "$0")"

# Flutter 정리
echo "Flutter 정리 중..."
flutter clean

# 의존성 설치
echo "의존성 설치 중..."
flutter pub get

# iOS Pod 설치
echo "iOS Pod 설치 중..."
cd ios
pod install
cd ..

# iOS IPA 빌드
echo "iOS IPA 빌드 중..."
flutter build ipa --release

echo ""
echo "=========================================="
echo "빌드 완료!"
echo "=========================================="
echo "IPA 파일 위치:"
echo "  build/ios/ipa/caterpillar_run.ipa"
echo ""
echo "Transporter 앱을 사용하여 App Store Connect에 업로드하세요:"
echo "  1. Transporter 앱 실행"
echo "  2. IPA 파일 드래그 앤 드롭"
echo "  3. 업로드"
echo "=========================================="

