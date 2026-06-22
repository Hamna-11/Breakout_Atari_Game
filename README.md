# 🎮 Atari Breakout x86 Assembly

A fully playable Breakout arcade game built in x86 Assembly language, running on DOS via DOSBox. Made as a COAL (Computer Organization & Assembly Language) Lab project.

**By: Hamna Mariyam & Maryam Fatima**

---

## 🕹️ How to Run

1. Install [DOSBox](https://www.dosbox.com/)
2. Assemble using NASM:
\```
nasm -f bin breakout.asm -o breakout.com
\```
3. Open DOSBox and mount your folder:
\```
mount c C:\path\to\your\folder
c:
breakout.com
\```

---

## 🎯 Controls

| Key | Action |
|-----|--------|
| ← Left Arrow | Move paddle left |
| → Right Arrow | Move paddle right |
| ESC | Exit game |
| ENTER | Start game |

---

## ✨ Features

- 4 rows of colored bricks (Red, Yellow, Green, Cyan)
- Real-time paddle movement
- Ball physics & collision detection
- Live score, timer and lives system
- Start screen, Game Over & Winner screen
- Direct video memory access via `0xB800`
- No external libraries; pure assembly from scratch

---

## 🛠️ Built With

- x86 Assembly (NASM)
- BIOS & DOS interrupts
- DOSBox

---

## 📌 Notes

- Ball speed adjustable via `ball_timer_limit` in source code
- 10 points per brick | 60 bricks total | 600 max score
- 3 lives per game
