#!/usr/bin/env python3
"""
게임 효과음 합성 스크립트 (표준 라이브러리만 사용).
귀여운 캐주얼 게임 톤에 맞춘 짧은 효과음 WAV를 생성한다.
ffmpeg로 mp3 변환은 별도 셸에서 수행.
"""
import wave
import struct
import math

SR = 44100  # 샘플레이트


def _write_wav(path, samples):
    """[-1,1] float 샘플 리스트를 16bit PCM WAV로 저장"""
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = bytearray()
        for s in samples:
            s = max(-1.0, min(1.0, s))
            frames += struct.pack("<h", int(s * 32767))
        w.writeframes(bytes(frames))


def _adsr(i, n, attack=0.01, release=0.15):
    """간단한 어택/릴리즈 엔벨로프 (0~1)"""
    t = i / SR
    dur = n / SR
    a = attack
    r = release
    if t < a:
        return t / a
    if t > dur - r:
        return max(0.0, (dur - t) / r)
    return 1.0


def tone(freq, dur, vol=0.5, wave_type="sine", attack=0.005, release=0.08,
         freq_end=None):
    """단일 음 합성. freq_end 지정 시 글라이드(피치 슬라이드)."""
    n = int(SR * dur)
    out = []
    phase = 0.0
    for i in range(n):
        frac = i / n
        f = freq if freq_end is None else freq + (freq_end - freq) * frac
        phase += 2 * math.pi * f / SR
        if wave_type == "sine":
            v = math.sin(phase)
        elif wave_type == "square":
            v = 1.0 if math.sin(phase) >= 0 else -1.0
        elif wave_type == "triangle":
            v = 2 / math.pi * math.asin(math.sin(phase))
        else:
            v = math.sin(phase)
        out.append(v * vol * _adsr(i, n, attack, release))
    return out


def mix(*tracks):
    """여러 트랙을 길이에 맞춰 합산"""
    n = max(len(t) for t in tracks)
    out = [0.0] * n
    for t in tracks:
        for i, s in enumerate(t):
            out[i] += s
    # 클리핑 방지 정규화
    peak = max(1e-9, max(abs(s) for s in out))
    if peak > 1.0:
        out = [s / peak for s in out]
    return out


def concat(*tracks):
    out = []
    for t in tracks:
        out += t
    return out


def silence(dur):
    return [0.0] * int(SR * dur)


# ===== eat.mp3: 짧고 밝은 "뽁" — 음정이 살짝 올라가는 블립 =====
# 사인 + 약간의 삼각파로 통통 튀는 느낌, 빠른 글라이드 업
eat = mix(
    tone(660, 0.09, vol=0.55, wave_type="sine", freq_end=990, release=0.06),
    tone(1320, 0.07, vol=0.18, wave_type="triangle", freq_end=1760, release=0.05),
)

# ===== combo.mp3: 콤보용 화려한 상승 아르페지오 (3음 또띠) =====
# C-E-G 상승 + 마지막에 반짝이는 고음, 신남
combo = concat(
    tone(523, 0.06, vol=0.5, wave_type="triangle", release=0.03),   # C5
    tone(659, 0.06, vol=0.5, wave_type="triangle", release=0.03),   # E5
    tone(784, 0.06, vol=0.5, wave_type="triangle", release=0.03),   # G5
    mix(
        tone(1047, 0.18, vol=0.5, wave_type="sine", release=0.14),  # C6
        tone(1568, 0.18, vol=0.18, wave_type="triangle", release=0.14),  # 반짝
    ),
)

# ===== button_click.mp3: 짧고 경쾌한 클릭 "톡" =====
# 짧은 사인 블립 + 약한 고음 클릭감
button = mix(
    tone(880, 0.05, vol=0.45, wave_type="sine", attack=0.002, release=0.04),
    tone(1760, 0.03, vol=0.12, wave_type="triangle", attack=0.001, release=0.02),
)

# ===== special.mp3: 특수먹이 획득 — 반짝이는 "치링" =====
# 두 음 빠른 상승 + 고음 반짝, eat보다 화려하고 길게
special = concat(
    tone(784, 0.05, vol=0.45, wave_type="triangle", release=0.03),   # G5
    mix(
        tone(1175, 0.22, vol=0.45, wave_type="sine", release=0.18),   # D6
        tone(1760, 0.22, vol=0.16, wave_type="triangle", release=0.18),  # 반짝
        tone(2349, 0.18, vol=0.08, wave_type="sine", release=0.16),   # 고음 sparkle
    ),
)

# ===== shield.mp3: 방패 방어 — 묵직한 "퉁" + 금속 울림 =====
# 낮은 사각파 임팩트 + 약간의 고음 링잉
shield = mix(
    tone(180, 0.18, vol=0.55, wave_type="square", attack=0.002, release=0.14,
         freq_end=120),
    tone(540, 0.16, vol=0.18, wave_type="sine", release=0.13),
    tone(900, 0.12, vol=0.10, wave_type="triangle", release=0.10),
)

# ===== coin.mp3: 코인/보상 획득 — 동전 "팅-링" (2음) =====
# 클래식 코인 사운드: 짧은 고음 + 더 높은 음 지속
coin = concat(
    tone(988, 0.06, vol=0.45, wave_type="square", release=0.03),    # B5
    tone(1319, 0.20, vol=0.45, wave_type="square", release=0.16),   # E6 (길게)
)

if __name__ == "__main__":
    import sys
    outdir = sys.argv[1] if len(sys.argv) > 1 else "."
    targets = {
        "eat": eat,
        "combo": combo,
        "button_click": button,
        "special": special,
        "shield": shield,
        "coin": coin,
    }
    for name, data in targets.items():
        _write_wav(f"{outdir}/{name}.wav", data)
    print("생성 완료:", ", ".join(f"{n}.wav" for n in targets))
