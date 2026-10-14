#!/usr/bin/env python3
"""生成 KidToys 的 watchOS App 图标：1024x1024，3 岁小男孩卡通大头照。

程序化绘制（3 倍超采样后缩到 1024，边缘平滑），改成想要的样子直接调下面的常量：
    python3 Tools/make_appicon.py

产物：KidToys Watch App/Assets.xcassets/AppIcon.appiconset/AppIcon.png
注意：watchOS 会用圆形遮罩裁切，所以五官都收在中心安全区内。
"""

import os
from PIL import Image, ImageDraw, ImageFilter, ImageChops

SIZE = 1024          # 最终尺寸
SS = 3               # 超采样倍数
W = SIZE * SS

# ---------------- 配色 ----------------
BG_TOP = (255, 217, 112)
BG_BOTTOM = (255, 156, 40)
GLOW = (255, 246, 205)
SKIN = (252, 212, 170)
SKIN_DARK = (233, 173, 126)
SKIN_LINE = (225, 158, 115)
HAIR = (74, 50, 38)
HAIR_LIGHT = (106, 75, 57)
EYE = (46, 42, 40)
BLUSH = (255, 138, 138)
MOUTH = (126, 51, 51)
TONGUE = (240, 138, 138)
TOOTH = (255, 255, 255)

# ---------------- 关键坐标（1024 设计坐标系）----------------
FACE_CX, FACE_CY = 512, 585
FACE_RX, FACE_RY = 298, 290
HAIR_CY, HAIR_R = 476, 292      # 头发是半个圆盘，发际线基准落在 y = HAIR_CY
EYE_Y, EYE_DX, EYE_R = 590, 92, 46
MOUTH_CX, MOUTH_CY, MOUTH_R = 512, 700, 64


def s(v):
    """设计坐标 -> 超采样坐标"""
    return int(round(v * SS))


def box(cx, cy, rx, ry):
    return [s(cx - rx), s(cy - ry), s(cx + rx), s(cy + ry)]


def main():
    # ---- 背景：暖色竖向渐变 ----
    strip = Image.new("RGB", (1, W))
    sd = ImageDraw.Draw(strip)
    for y in range(W):
        t = y / (W - 1)
        sd.point((0, y), fill=tuple(int(BG_TOP[i] + (BG_BOTTOM[i] - BG_TOP[i]) * t) for i in range(3)))
    img = strip.resize((W, W), Image.BILINEAR).convert("RGBA")

    # ---- 头部后方的柔光 ----
    glow = Image.new("L", (W, W), 0)
    ImageDraw.Draw(glow).ellipse(box(FACE_CX, FACE_CY - 20, 400, 400), fill=95)
    glow = glow.filter(ImageFilter.GaussianBlur(s(70)))
    img.paste(Image.new("RGBA", (W, W), GLOW + (255,)), (0, 0), glow)

    # ---- 背景小圆点装饰 ----
    dots = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    dd = ImageDraw.Draw(dots)
    for cx, cy, r, a in [(196, 210, 26, 70), (836, 268, 20, 60), (150, 800, 30, 55),
                         (880, 760, 24, 65), (512, 130, 16, 50), (300, 880, 18, 45)]:
        dd.ellipse(box(cx, cy, r, r), fill=(255, 255, 255, a))
    img = Image.alpha_composite(img, dots)

    # ---- 头部投影 ----
    shadow = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse(box(FACE_CX, FACE_CY + 60, 300, 288), fill=(120, 70, 20, 70))
    shadow = shadow.filter(ImageFilter.GaussianBlur(s(34)))
    img = Image.alpha_composite(img, shadow)

    layer = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)

    # ---- 耳朵（先画，被脸盖住一部分）----
    for ex in (FACE_CX - 292, FACE_CX + 292):
        d.ellipse(box(ex, FACE_CY + 22, 58, 66), fill=SKIN, outline=SKIN_LINE, width=s(5))
        d.ellipse(box(ex, FACE_CY + 22, 28, 34), fill=SKIN_DARK)

    # ---- 脸 ----
    d.ellipse(box(FACE_CX, FACE_CY, FACE_RX, FACE_RY), fill=SKIN, outline=SKIN_LINE, width=s(5))

    # ---- 头发：上半个圆盘 + 中间下压的刘海弧，避免"平底锅盖"感 ----
    d.pieslice(box(FACE_CX, HAIR_CY, HAIR_R, HAIR_R), 180, 360, fill=HAIR)
    d.ellipse(box(FACE_CX, HAIR_CY - 8, 250, 42), fill=HAIR)

    # ---- 头发柔光：单独一层模糊后按头发形状裁切，做出体积感而不是生硬的笔画 ----
    hair_mask = Image.new("L", (W, W), 0)
    hm = ImageDraw.Draw(hair_mask)
    hm.pieslice(box(FACE_CX, HAIR_CY, HAIR_R, HAIR_R), 180, 360, fill=255)
    hm.ellipse(box(FACE_CX, HAIR_CY - 8, 250, 42), fill=255)
    sheen = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    ImageDraw.Draw(sheen).ellipse(box(FACE_CX - 118, HAIR_CY - 126, 150, 126),
                                  fill=HAIR_LIGHT + (125,))
    sheen = sheen.filter(ImageFilter.GaussianBlur(s(26)))
    sheen.putalpha(ImageChops.multiply(sheen.getchannel("A"), hair_mask))
    layer = Image.alpha_composite(layer, sheen)
    d = ImageDraw.Draw(layer)

    # ---- 眼睛：大圆眼 + 高光 ----
    for ex in (FACE_CX - EYE_DX, FACE_CX + EYE_DX):
        d.ellipse(box(ex, EYE_Y, EYE_R, EYE_R + 2), fill=EYE)
        d.ellipse(box(ex - 15, EYE_Y - 17, 16, 16), fill=(255, 255, 255, 255))
        d.ellipse(box(ex + 13, EYE_Y + 15, 8, 8), fill=(255, 255, 255, 200))

    # ---- 腮红（单独一层做模糊，柔一点）----
    blush = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    bd = ImageDraw.Draw(blush)
    for bx in (FACE_CX - 152, FACE_CX + 152):
        bd.ellipse(box(bx, 678, 62, 46), fill=BLUSH + (130,))
    blush = blush.filter(ImageFilter.GaussianBlur(s(20)))
    layer = Image.alpha_composite(layer, blush)
    d = ImageDraw.Draw(layer)

    # ---- 鼻子 ----
    d.ellipse(box(FACE_CX, 656, 21, 16), fill=SKIN_DARK)

    # ---- 嘴巴：下半个圆盘 = 张嘴笑 ----
    d.pieslice(box(MOUTH_CX, MOUTH_CY, MOUTH_R, MOUTH_R), 0, 180, fill=MOUTH)
    # 舌头
    d.ellipse(box(MOUTH_CX, MOUTH_CY + 42, 36, 22), fill=TONGUE)
    # 上排小牙
    d.rounded_rectangle([s(MOUTH_CX - 34), s(MOUTH_CY), s(MOUTH_CX + 34), s(MOUTH_CY + 15)],
                        radius=s(6), fill=TOOTH)

    img = Image.alpha_composite(img, layer)

    # ---- 缩到 1024 并去掉 alpha（App Store 图标不允许透明通道）----
    out = img.convert("RGB").resize((SIZE, SIZE), Image.LANCZOS)

    here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    dst = os.path.join(here, "KidToys Watch App", "Assets.xcassets",
                       "AppIcon.appiconset", "AppIcon.png")
    out.save(dst, "PNG")
    print("wrote", dst, out.size)

    # 便于自查：再输出一张套了圆形遮罩的预览（不进仓库）
    mask = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, SIZE - 1, SIZE - 1], fill=255)
    prev = Image.new("RGB", (SIZE, SIZE), (28, 28, 30))
    prev.paste(out, (0, 0), mask)
    prev.save("/tmp/appicon-masked-preview.png")
    print("wrote /tmp/appicon-masked-preview.png")


if __name__ == "__main__":
    main()
