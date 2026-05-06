"""Railway startup: khởi tạo database và model khi runtime."""
import os
import sys
import subprocess

# Chuyển về đúng thư mục backend (tránh lỗi relative path)
backend_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(backend_dir)
print(f"[startup] Working dir: {backend_dir}")

# Tạo thư mục cần thiết
os.makedirs(os.path.join(backend_dir, "data"), exist_ok=True)
os.makedirs(os.path.join(backend_dir, "ml"), exist_ok=True)

db_path = os.path.join(backend_dir, "data", "alertvn.db")
model_path = os.path.join(backend_dir, "ml", "landslide_model.pkl")

if not os.path.exists(db_path):
    print("[startup] Tao database va grid cells...")
    subprocess.run([sys.executable, os.path.join(backend_dir, "scripts", "generate_grid.py")], check=True)
    print("[startup] Database OK")
else:
    print(f"[startup] Database da co: {db_path}")

if not os.path.exists(model_path):
    print("[startup] Train ML model...")
    subprocess.run([sys.executable, os.path.join(backend_dir, "ml", "train.py")], check=True)
    print("[startup] Model OK")
else:
    print(f"[startup] Model da co: {model_path}")

print("[startup] San sang!")
