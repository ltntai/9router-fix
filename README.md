# 9Router Fix — Antigravity trắng màn hình / agent error

Script `.bat` tự động sửa lỗi 9Router (MITM) làm Antigravity bị trắng màn hình / agent báo lỗi.

## Nó làm gì

1. Tắt 9Router / MITM cũ đang chạy (port 20128, 443)
2. Áp patch vào MITM (`%APPDATA%\9router\9router-mitm-fix.js`)
3. Mở lại 9Router ở cửa sổ riêng, chờ MITM khởi động (tối đa 90 giây)
4. Kiểm tra: port 20128 (9Router), port 443 (MITM), patch đã áp đúng chưa

## Nguyên nhân gốc (xác định từ log thực tế)

1. MITM lọc sai chunk → agent bị "terminated" (đã fix ở V8)
2. Thiếu `uncaughtException` handler → MITM tự chết (đã fix)
3. Error-frame xen giữa stream → language server panic (đã fix)

## Cách dùng

1. Chuột phải file `NANG_CAP_9Router_sua_loi_vang.bat` → **Run as administrator**
   (hoặc chạy thường, script sẽ tự xin quyền Admin qua UAC)
2. Đợi script chạy xong 4 bước kiểm tra
3. Mở Antigravity và chat thử

## Yêu cầu

- Windows + quyền Admin
- Đã cài 9Router
- Node.js (để chạy patch `9router-mitm-fix.js`)
- File patch đặt tại `%APPDATA%\9router\9router-mitm-fix.js`

## Xử lý sự cố

- Nếu MITM không lên sau 90s: xem cửa sổ 9Router vừa mở để biết lỗi
- Log crash: `%APPDATA%\9router\mitm-crash.log`
