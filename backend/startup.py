"""Railway startup: khởi tạo database và model nếu chưa có."""
import os
import sys

# Đảm bảo thư mục data tồn tại
os.makedirs("data", exist_ok=True)
os.makedirs("ml", exist_ok=True)

db_path = "data/alertvn.db"
model_path = "ml/landslide_model.pkl"

if not os.path.exists(db_path):
    print("[startup] Tạo database và grid cells...")
    import subprocess
    subprocess.run([sys.executable, "scripts/generate_grid.py"], check=True)
    print("[startup] Database khởi tạo xong.")
else:
    print(f"[startup] Database đã có: {db_path}")

if not os.path.exists(model_path):
    print("[startup] Train ML model...")
    import subprocess
    subprocess.run([sys.executable, "ml/train.py"], check=True)
    print("[startup] Model train xong.")
else:
    print(f"[startup] Model đã có: {model_path}")

print("[startup] Sẵn sàng khởi động server.")
