"""
Train Random Forest classifier for landslide prediction.
Uses synthetic dataset based on physical rules + noise.
Run: python ml/train.py
"""
import numpy as np
import pickle
import os
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score

np.random.seed(42)
N = 2000

slope = np.random.uniform(0, 60, N)
elevation = np.random.uniform(20, 1500, N)
rain_24h = np.random.exponential(20, N)
rain_72h = rain_24h * np.random.uniform(2.0, 3.5, N)
rain_7d = rain_72h * np.random.uniform(1.8, 2.5, N)
soil_type = np.random.randint(1, 6, N)
vegetation_index = np.random.uniform(0.1, 0.9, N)
historical_count = np.random.randint(0, 15, N)

# Label generation based on physical rules
landslide_prob = (
    np.clip(slope / 60, 0, 1) * 0.4 +
    np.clip(rain_24h / 120, 0, 1) * 0.35 +
    np.clip(rain_72h / 250, 0, 1) * 0.1 +
    np.clip(historical_count / 10, 0, 1) * 0.1 +
    (soil_type >= 3).astype(float) * 0.05
)
noise = np.random.normal(0, 0.08, N)
label = ((landslide_prob + noise) >= 0.45).astype(int)

X = np.column_stack([slope, elevation, rain_24h, rain_72h, rain_7d,
                     soil_type, vegetation_index, historical_count])
y = label

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

clf = RandomForestClassifier(
    n_estimators=150,
    max_depth=12,
    min_samples_leaf=5,
    class_weight="balanced",
    random_state=42,
    n_jobs=-1,
)
clf.fit(X_train, y_train)

y_pred = clf.predict(X_test)
acc = accuracy_score(y_test, y_pred)
print(f"Accuracy: {acc:.3f}")
print(classification_report(y_test, y_pred, target_names=["Safe", "Landslide"]))

feature_names = ["slope", "elevation", "rain_24h", "rain_72h", "rain_7d",
                 "soil_type", "vegetation_index", "historical_count"]
importances = clf.feature_importances_
for name, imp in sorted(zip(feature_names, importances), key=lambda x: -x[1]):
    print(f"  {name}: {imp:.3f}")

out_path = os.path.join(os.path.dirname(__file__), "landslide_model.pkl")
with open(out_path, "wb") as f:
    pickle.dump(clf, f)
print(f"\nModel saved to {out_path}")
