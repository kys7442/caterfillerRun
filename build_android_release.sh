#!/bin/bash

# Android 릴리스 빌드 스크립트
# Caterpillar Run 게임 앱

set -e

echo "=========================================="
echo "Caterpillar Run - Android 릴리스 빌드"
echo "=========================================="

# 프로젝트 디렉토리로 이동
cd "$(dirname "$0")"

# Flutter 정리
echo "Flutter 정리 중..."
flutter clean

# 의존성 설치
echo "의존성 설치 중..."
flutter pub get

# Android AAB 빌드 (Google Play Store용)
echo "Android AAB 빌드 중..."
flutter build appbundle --release

echo ""
echo "=========================================="
echo "빌드 완료!"
echo "=========================================="
echo "AAB 파일 위치:"
echo "  build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Google Play Console에 업로드하세요:"
echo "  https://play.google.com/console"
echo "=========================================="

