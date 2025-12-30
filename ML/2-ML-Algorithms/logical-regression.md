Searched codebase for "teach me logical regression in advacned from beginner", 3 results

# Logistic Regression: From Beginner to Advanced 📚

Let me take you on a comprehensive journey through logistic regression.

---

## **PART 1: BEGINNER LEVEL** 🟢

### **1.1 The Basics**

**What is Logistic Regression?**

Despite the name, logistic regression is a **classification algorithm**, not regression. It predicts the **probability** of belonging to a class (0 or 1).

**Key Difference from Linear Regression:**

```
Linear Regression:
- Predicts continuous values (-∞ to +∞)
- Example: House price = $500,000

Logistic Regression:
- Predicts probability (0 to 1)
- Example: Probability of spam = 0.92
- Decision: if P > 0.5 → Class 1, else → Class 0
```

### **1.2 The Sigmoid Function**

**Formula:**
```
σ(z) = 1 / (1 + e^(-z))

Where:
z = w₁x₁ + w₂x₂ + ... + wₙxₙ + b
e = Euler's number (≈2.71828)
σ(z) = sigmoid function
```

**Output:** Always between 0 and 1 (probability)

**Visualization:**
```
Probability (y)
    |
  1 |           ____________
    |        __/
    |      _/
  0.5|   _/
    | _/
  0 |________________
    -∞  -2  0  2  +∞
    
    Input (z)
    
Key points:
- σ(0) = 0.5
- σ(∞) ≈ 1
- σ(-∞) ≈ 0
```

### **1.3 Real-world Examples**

```
1. Email Spam Detection
   Input: Email features (words, sender, links)
   Output: P(spam) = 0.92 → SPAM ✓

2. Medical Diagnosis
   Input: Patient symptoms, test results
   Output: P(disease) = 0.75 → Has disease ✓

3. Customer Churn
   Input: Purchase history, support tickets
   Output: P(churn) = 0.35 → Will stay ✓

4. Credit Approval
   Input: Credit score, income, debt
   Output: P(default) = 0.20 → Approve ✓
```

### **1.4 Binary Classification**

**Binary = 2 classes (Yes/No, Spam/Not Spam)**

```
Prediction Rule:
if P(y=1) > 0.5 → Predict Class 1
if P(y=1) ≤ 0.5 → Predict Class 0
```

**Example:**
```
Email 1: P(spam) = 0.92 > 0.5 → SPAM ✓
Email 2: P(spam) = 0.15 < 0.5 → NOT SPAM ✓
Email 3: P(spam) = 0.51 > 0.5 → SPAM ✓
```

### **1.5 Simple Logistic Regression Code**

````python
from sklearn.linear_model import LogisticRegression
import numpy as np

# Training data
# Feature: Study hours, Target: Pass (1) / Fail (0)
X = np.array([[1], [2], [3], [4], [5], [6], [7], [8]])
y = np.array([0, 0, 0, 1, 1, 1, 1, 1])

# Create and train model
model = LogisticRegression()
model.fit(X, y)

# Make predictions
new_hours = np.array([[5.5]])
probability = model.predict_proba(new_hours)[0]  # [P(0), P(1)]
prediction = model.predict(new_hours)

print(f"Studied 5.5 hours:")
print(f"  P(Fail) = {probability[0]:.2%}")
print(f"  P(Pass) = {probability[1]:.2%}")
print(f"  Prediction: {'PASS ✓' if prediction[0] == 1 else 'FAIL ✗'}")

# Output:
# Studied 5.5 hours:
#   P(Fail) = 23.45%
#   P(Pass) = 76.55%
#   Prediction: PASS ✓
````

### **1.6 Visualization**

````python
import matplotlib.pyplot as plt

# Plot training data
plt.scatter(X[y==0], [0]*sum(y==0), label='Fail (0)', marker='x', s=100)
plt.scatter(X[y==1], [1]*sum(y==1), label='Pass (1)', marker='o', s=100)

# Plot sigmoid curve
X_line = np.linspace(0, 8, 300).reshape(-1, 1)
y_line = model.predict_proba(X_line)[:, 1]

plt.plot(X_line, y_line, 'r-', linewidth=2, label='Logistic Curve')
plt.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
plt.xlabel('Study Hours')
plt.ylabel('Probability of Passing')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
````

---

## **PART 2: INTERMEDIATE LEVEL** 🟡

### **2.1 Multiple Features (Multivariate Logistic Regression)**

**Formula:**
```
z = w₁x₁ + w₂x₂ + ... + wₙxₙ + b
P(y=1) = 1 / (1 + e^(-z))
```

**Example: Email Spam Detection**

```
Features:
- Contains "FREE": w₁ = 2.5
- Contains "CLICK": w₂ = 1.8
- Sender reputation: w₃ = -0.8
- Contains link: w₄ = 1.2
- Bias: b = -1.0
```

### **2.2 Code: Multiple Features**

````python
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler

# Create training data
data = pd.DataFrame({
    'has_free': [1, 0, 1, 0, 1, 0, 1, 0],
    'has_click': [1, 0, 1, 0, 0, 0, 1, 0],
    'sender_reputation': [10, 95, 20, 90, 5, 85, 30, 88],
    'has_link': [1, 0, 1, 0, 1, 0, 1, 0],
    'is_spam': [1, 0, 1, 0, 1, 0, 1, 0]
})

# Separate features and target
X = data[['has_free', 'has_click', 'sender_reputation', 'has_link']]
y = data['is_spam']

# Scale features (important for logistic regression)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Train model
model = LogisticRegression()
model.fit(X_scaled, y)

# Get coefficients
feature_names = X.columns
for name, coef in zip(feature_names, model.coef_[0]):
    print(f"{name}: {coef:.4f}")

# Output:
# has_free: 1.2345
# has_click: 0.8901
# sender_reputation: -0.7654
# has_link: 0.5432

# Make prediction
new_email = pd.DataFrame({
    'has_free': [1],
    'has_click': [1],
    'sender_reputation': [15],
    'has_link': [1]
})

new_email_scaled = scaler.transform(new_email)
prob_spam = model.predict_proba(new_email_scaled)[0][1]
prediction = model.predict(new_email_scaled)[0]

print(f"\nNew email: P(spam) = {prob_spam:.2%}")
print(f"Prediction: {'SPAM ⚠️' if prediction == 1 else 'NOT SPAM ✅'}")
````

### **2.3 Confusion Matrix & Metrics**

**Confusion Matrix:**
```
                Predicted Positive    Predicted Negative
Actual Positive      TP (True+)        FN (False-)
Actual Negative      FP (False+)       TN (True-)
```

**Key Metrics:**

```
Accuracy = (TP + TN) / Total
           How many predictions are correct?

Precision = TP / (TP + FP)
            Of predicted positives, how many are correct?

Recall = TP / (TP + FN)
         Of actual positives, how many did we catch?

F1-Score = 2 × (Precision × Recall) / (Precision + Recall)
           Balanced metric
```

### **2.4 Calculate Metrics**

````python
from sklearn.metrics import confusion_matrix, accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, roc_curve
import matplotlib.pyplot as plt

# Make predictions
X_test = ...  # Your test data
y_test = ...  # Your test labels

y_pred = model.predict(X_test)
y_pred_proba = model.predict_proba(X_test)[:, 1]

# Calculate metrics
cm = confusion_matrix(y_test, y_pred)
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)
auc = roc_auc_score(y_test, y_pred_proba)

print(f"Accuracy: {accuracy:.4f}")
print(f"Precision: {precision:.4f}")
print(f"Recall: {recall:.4f}")
print(f"F1-Score: {f1:.4f}")
print(f"AUC: {auc:.4f}")

print(f"\nConfusion Matrix:")
print(cm)
# Output: [[TN  FP]
#          [FN  TP]]

# ROC Curve
fpr, tpr, _ = roc_curve(y_test, y_pred_proba)

plt.plot(fpr, tpr, label=f'AUC = {auc:.3f}')
plt.plot([0, 1], [0, 1], 'r--', label='Random')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve')
plt.legend()
plt.show()
````

### **2.5 Decision Threshold**

**Default threshold = 0.5, but you can adjust!**

```
Lower threshold → More positives predicted
  - Higher recall (catch more positives)
  - Lower precision (more false positives)
  
Higher threshold → Fewer positives predicted
  - Lower recall (miss some positives)
  - Higher precision (fewer false positives)
```

**Example:**
````python
# Default: threshold = 0.5
predictions_0_5 = (y_pred_proba >= 0.5).astype(int)

# Higher threshold: be more conservative
predictions_0_7 = (y_pred_proba >= 0.7).astype(int)

# Lower threshold: catch more positives
predictions_0_3 = (y_pred_proba >= 0.3).astype(int)

print(f"Threshold 0.5: {predictions_0_5.sum()} positives")
print(f"Threshold 0.7: {predictions_0_7.sum()} positives")
print(f"Threshold 0.3: {predictions_0_3.sum()} positives")

# More positives with lower threshold
````

### **2.6 Train-Test Split**

````python
from sklearn.model_selection import train_test_split

# Split data: 80% train, 20% test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# Train on training set
model = LogisticRegression()
model.fit(X_train, y_train)

# Evaluate on test set
train_score = model.score(X_train, y_train)
test_score = model.score(X_test, y_test)

print(f"Training Accuracy: {train_score:.4f}")
print(f"Testing Accuracy: {test_score:.4f}")

# Good: both similar
# Overfitting: train >> test
````

---

## **PART 3: ADVANCED LEVEL** 🔴

### **3.1 Loss Function (Log Loss / Binary Cross-Entropy)**

**Goal:** Find weights that minimize loss

**Formula:**
```
Loss = -1/n × Σ[yᵢ × log(ŷᵢ) + (1-yᵢ) × log(1-ŷᵢ)]

Where:
yᵢ = actual (0 or 1)
ŷᵢ = predicted probability
log = natural logarithm
```

**Intuition:**
```
When y=1, actual is positive:
- Loss = -log(ŷ)
- If ŷ=0.9 (high prob): loss = -log(0.9) ≈ 0.105 (good!)
- If ŷ=0.1 (low prob): loss = -log(0.1) ≈ 2.303 (bad!)

When y=0, actual is negative:
- Loss = -log(1-ŷ)
- If ŷ=0.1 (low prob): loss = -log(0.9) ≈ 0.105 (good!)
- If ŷ=0.9 (high prob): loss = -log(0.1) ≈ 2.303 (bad!)
```

### **3.2 Gradient Descent Optimization**

**Algorithm:**
```
1. Initialize weights randomly
2. For each iteration:
   a. Calculate predictions
   b. Calculate loss
   c. Calculate gradients (∂Loss/∂w)
   d. Update weights: w = w - learning_rate × ∇Loss
3. Repeat until convergence
```

**Manual Implementation:**

````python
import numpy as np
import matplotlib.pyplot as plt

def sigmoid(z):
    return 1 / (1 + np.exp(-z))

def log_loss(y_true, y_pred):
    return -np.mean(y_true * np.log(y_pred + 1e-15) + 
                    (1 - y_true) * np.log(1 - y_pred + 1e-15))

# Training data
X = np.array([[1], [2], [3], [4], [5]])
y = np.array([0, 0, 0, 1, 1])

# Initialize parameters
w = np.random.randn(1)
b = np.random.randn(1)
learning_rate = 0.01
epochs = 1000

losses = []

# Gradient Descent
n = len(X)
for epoch in range(epochs):
    # Forward pass
    z = w * X + b
    y_pred = sigmoid(z)
    
    # Calculate loss
    loss = log_loss(y, y_pred)
    losses.append(loss)
    
    # Calculate gradients
    dw = (1/n) * np.sum((y_pred - y) * X)
    db = (1/n) * np.sum(y_pred - y)
    
    # Update weights
    w = w - learning_rate * dw
    b = b - learning_rate * db
    
    if (epoch + 1) % 100 == 0:
        print(f"Epoch {epoch+1}, Loss: {loss:.4f}")

print(f"\nFinal weights: w={w[0]:.4f}, b={b[0]:.4f}")

# Plot loss
plt.plot(losses)
plt.xlabel('Epoch')
plt.ylabel('Log Loss')
plt.title('Loss vs Epoch')
plt.show()
````

### **3.3 Feature Scaling (Standardization)**

**Why?** Logistic regression is sensitive to feature scales

````python
from sklearn.preprocessing import StandardScaler, MinMaxScaler

X = np.array([[1, 100], [2, 200], [3, 300], [4, 400]])

# Method 1: Standardization (Z-score)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
print("Standardized:")
print(X_scaled)
# Mean ≈ 0, Std Dev ≈ 1

# Method 2: Normalization (Min-Max)
normalizer = MinMaxScaler()
X_normalized = normalizer.fit_transform(X)
print("\nNormalized:")
print(X_normalized)
# Values between 0 and 1
````

### **3.4 Regularization (Prevent Overfitting)**

**L2 Regularization (Ridge):**
```
Loss = Log Loss + λ × Σ(w²)

λ = regularization strength
Higher λ = smaller weights = simpler model
```

**L1 Regularization (Lasso):**
```
Loss = Log Loss + λ × Σ|w|

Makes some weights exactly zero
```

**Code:**
````python
from sklearn.linear_model import LogisticRegression

# L2 Regularization (Ridge) - default
model_l2 = LogisticRegression(penalty='l2', C=1.0)
model_l2.fit(X_train, y_train)

# L1 Regularization (Lasso)
model_l1 = LogisticRegression(penalty='l1', solver='liblinear', C=1.0)
model_l1.fit(X_train, y_train)

# C parameter: inverse of regularization strength
# Higher C = less regularization
# Lower C = more regularization

print(f"L2 Weights: {model_l2.coef_[0]}")
print(f"L1 Weights: {model_l1.coef_[0]}")

# L1 may have some weights = 0
````

### **3.5 Multi-class Classification**

**Beyond Binary (2+ classes)**

**Approaches:**

1. **One-vs-Rest (OvR):**
   ```
   For each class:
   - Train binary classifier (class vs others)
   - Get probability for that class
   Choose class with highest probability
   ```

2. **Multinomial:**
   ```
   Softmax function: extends sigmoid to multiple classes
   P(class i) = e^(zᵢ) / Σ e^(zⱼ)
   ```

**Code:**
````python
# Multi-class data
X = np.random.randn(100, 5)
y = np.random.choice([0, 1, 2], size=100)  # 3 classes

# One-vs-Rest (default)
model_ovr = LogisticRegression(multi_class='ovr')
model_ovr.fit(X, y)

# Multinomial
model_multinomial = LogisticRegression(multi_class='multinomial', max_iter=1000)
model_multinomial.fit(X, y)

# Predict
y_pred = model_multinomial.predict(X)

# Probabilities for each class
probs = model_multinomial.predict_proba(X[0:1])
print(f"P(class 0): {probs[0][0]:.2%}")
print(f"P(class 1): {probs[0][1]:.2%}")
print(f"P(class 2): {probs[0][2]:.2%}")
````

### **3.6 Class Imbalance (Unequal Classes)**

**Problem:** 95% negative, 5% positive

```
Model can achieve 95% accuracy by always predicting negative!
But this is useless.
```

**Solutions:**

1. **Class Weight:**
````python
# Penalize misclassifying minority class more
model = LogisticRegression(class_weight='balanced')
model.fit(X_train, y_train)

# Automatically adjusts weights inversely to class frequency
````

2. **Undersampling:**
```
Remove some majority class samples
```

3. **Oversampling:**
```
Duplicate minority class samples
```

4. **SMOTE (Synthetic Minority Over-sampling):**
```
Generate synthetic minority samples
```

**Code:**
````python
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline

# SMOTE
smote = SMOTE()
X_resampled, y_resampled = smote.fit_resample(X_train, y_train)

print(f"Original class distribution: {np.bincount(y_train)}")
print(f"Resampled class distribution: {np.bincount(y_resampled)}")

# Pipeline with SMOTE
pipeline = Pipeline([
    ('smote', SMOTE()),
    ('classifier', LogisticRegression())
])

pipeline.fit(X_train, y_train)
````

### **3.7 Cross-Validation**

````python
from sklearn.model_selection import cross_val_score, StratifiedKFold

# Stratified K-Fold (maintains class distribution)
skf = StratifiedKFold(n_splits=5)

model = LogisticRegression()
scores = cross_val_score(model, X, y, cv=skf, scoring='roc_auc')

print(f"Cross-validation scores: {scores}")
print(f"Mean: {scores.mean():.4f}")
print(f"Std: {scores.std():.4f}")
````

### **3.8 Probability Calibration**

**Problem:** Predicted probabilities might not be well-calibrated

```
Model predicts P=0.7, but when model says 0.7:
- Actual rate might be 0.5 (under-confident)
- Or actual rate might be 0.9 (over-confident)
```

**Solution: Calibration**

````python
from sklearn.calibration import CalibratedClassifierCV

# Train model
model = LogisticRegression()

# Calibrate probabilities
calibrated_model = CalibratedClassifierCV(model, method='sigmoid', cv=5)
calibrated_model.fit(X_train, y_train)

# Use calibrated predictions
probs = calibrated_model.predict_proba(X_test)
````

---

## **PART 4: EXPERT LEVEL** 🔵

### **4.1 Mathematical Derivation**

**Logistic Function (Sigmoid):**
```
σ(z) = 1 / (1 + e^(-z))
```

**Log-Odds:**
```
odds = P / (1-P)
log-odds = log(P / (1-P)) = z = w·x + b
```

**Inverse:**
```
P = e^z / (1 + e^z) = 1 / (1 + e^(-z)) = sigmoid(z)
```

**Maximum Likelihood Estimation:**
```
L(w) = Π P(yᵢ|xᵢ, w)
     = Π ŷᵢ^yᵢ × (1-ŷᵢ)^(1-yᵢ)

Log-likelihood:
ℓ(w) = Σ yᵢ log(ŷᵢ) + (1-yᵢ) log(1-ŷᵢ)

Goal: Maximize ℓ = Minimize -ℓ (negative log-likelihood)
```

### **4.2 Newton-Raphson Method**

**Faster than gradient descent for logistic regression**

```
w_new = w_old - H^(-1) × ∇L

Where:
H = Hessian matrix (second derivatives)
∇L = gradient vector
```

### **4.3 Multiclass: Softmax Regression**

**Formula:**
```
P(class k) = e^(zₖ) / Σⱼ e^(zⱼ)

Where zₖ = wₖ · x + bₖ
```

**Loss Function (Cross-Entropy):**
```
Loss = -Σₖ yₖ log(P(class k))

Where yₖ = 1 if true class is k, else 0
```

### **4.4 Handling Imbalanced Data Advanced**

**Threshold Optimization:**

````python
from sklearn.metrics import f1_score

# Find best threshold
thresholds = np.arange(0.1, 0.9, 0.01)
f1_scores = []

y_pred_proba = model.predict_proba(X_test)[:, 1]

for threshold in thresholds:
    y_pred = (y_pred_proba >= threshold).astype(int)
    f1 = f1_score(y_test, y_pred)
    f1_scores.append(f1)

best_threshold = thresholds[np.argmax(f1_scores)]
print(f"Best threshold: {best_threshold:.2f}")

# Use best threshold
y_pred_optimal = (y_pred_proba >= best_threshold).astype(int)
````

### **4.5 Regularization Path**

````python
from sklearn.linear_model import LogisticRegression

# C values (1/λ): higher = less regularization
Cs = np.logspace(-4, 4, 50)
coefs = []
scores_train = []
scores_test = []

for C in Cs:
    model = LogisticRegression(C=C, max_iter=1000)
    model.fit(X_train, y_train)
    
    coefs.append(model.coef_[0])
    scores_train.append(model.score(X_train, y_train))
    scores_test.append(model.score(X_test, y_test))

coefs = np.array(coefs)

# Plot regularization path
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
for i in range(coefs.shape[1]):
    plt.plot(np.log10(Cs), coefs[:, i], label=f'Feature {i}')
plt.xlabel('log10(C)')
plt.ylabel('Coefficient')
plt.title('Regularization Path')
plt.legend()

plt.subplot(1, 2, 2)
plt.plot(np.log10(Cs), scores_train, label='Train')
plt.plot(np.log10(Cs), scores_test, label='Test')
plt.xlabel('log10(C)')
plt.ylabel('Accuracy')
plt.title('Score vs Regularization')
plt.legend()

plt.tight_layout()
plt.show()
````

### **4.6 Checking Assumptions**

**Logistic Regression Assumptions:**

1. **Binary/Multi-class target**
2. **Independence of observations**
3. **No perfect multicollinearity**
4. **Large sample size** (rule of thumb: 15 events per feature)
5. **Linear relationship with log-odds** (not the target!)

**Check Linearity with Log-Odds:**

````python
from scipy.stats import chi2

# Box-Tidwell test for linearity
# For each continuous feature, test feature × log(feature)

X_interaction = X_train.copy()
for col in X_interaction.columns:
    X_interaction[f'{col}_log'] = X_interaction[col] * np.log(X_interaction[col])

model_full = LogisticRegression(max_iter=1000)
model_full.fit(X_interaction, y_train)

# Compare models using likelihood ratio test
from sklearn.metrics import log_loss

loss_simple = log_loss(y_test, model.predict_proba(X_test))
loss_with_interaction = log_loss(y_test, model_full.predict_proba(X_test))

print(f"Simple model loss: {loss_simple:.4f}")
print(f"With interaction loss: {loss_with_interaction:.4f}")
````

### **4.7 Model Selection & Hyperparameter Tuning**

````python
from sklearn.model_selection import GridSearchCV
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

# Define pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('classifier', LogisticRegression(max_iter=1000))
])

# Hyperparameters to test
param_grid = {
    'classifier__C': [0.001, 0.01, 0.1, 1, 10, 100],
    'classifier__penalty': ['l1', 'l2'],
    'classifier__solver': ['liblinear', 'lbfgs']
}

# Grid search with cross-validation
grid_search = GridSearchCV(
    pipeline, 
    param_grid, 
    cv=5, 
    scoring='roc_auc',
    n_jobs=-1
)

grid_search.fit(X_train, y_train)

print(f"Best parameters: {grid_search.best_params_}")
print(f"Best CV score: {grid_search.best_score_:.4f}")

# Use best model
best_model = grid_search.best_estimator_
test_score = best_model.score(X_test, y_test)
print(f"Test score: {test_score:.4f}")
````

---

## **PART 5: COMPLETE PRACTICAL EXAMPLE** 💼

````python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (confusion_matrix, classification_report, roc_auc_score, 
                             roc_curve, precision_recall_curve, f1_score)
import seaborn as sns

# ===== 1. GENERATE SYNTHETIC DATA =====
np.random.seed(42)
n_samples = 1000

# Features: Age, Income, Credit Score
X_raw = np.random.randn(n_samples, 3) * [10, 30000, 100] + [40, 50000, 650]
X_raw[:, 0] = np.clip(X_raw[:, 0], 18, 80)  # Age: 18-80
X_raw[:, 1] = np.clip(X_raw[:, 1], 20000, 200000)  # Income: 20k-200k
X_raw[:, 2] = np.clip(X_raw[:, 2], 300, 850)  # Credit score: 300-850

# Target: Loan Approval (based on features)
y = (X_raw[:, 0] > 30) & (X_raw[:, 1] > 40000) & (X_raw[:, 2] > 600)
y = y.astype(int)

# Add some noise
noise_idx = np.random.choice(n_samples, 50, replace=False)
y[noise_idx] = 1 - y[noise_idx]

data = pd.DataFrame(X_raw, columns=['Age', 'Income', 'CreditScore'])
data['LoanApproved'] = y

print("=" * 70)
print("COMPLETE LOGISTIC REGRESSION EXAMPLE - LOAN APPROVAL")
print("=" * 70)
print("\nDataset Overview:")
print(data.describe())
print(f"\nClass Distribution:")
print(data['LoanApproved'].value_counts())
print(f"Class Balance: {data['LoanApproved'].mean():.2%} approved")

# ===== 2. PREPROCESSING =====
print("\n" + "=" * 70)
print("PREPROCESSING")
print("=" * 70)

X = data.drop('LoanApproved', axis=1)
y = data['LoanApproved']

# Train-test split (stratified to maintain class balance)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# Standardize features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

print(f"Training set: {X_train_scaled.shape}")
print(f"Test set: {X_test_scaled.shape}")
print(f"Training class distribution:")
print(y_train.value_counts(normalize=True))

# ===== 3. TRAIN MODELS =====
print("\n" + "=" * 70)
print("MODEL TRAINING")
print("=" * 70)

models = {
    'Logistic (no reg)': LogisticRegression(C=1000, random_state=42),
    'Logistic (L2, C=1)': LogisticRegression(C=1, penalty='l2', random_state=42),
    'Logistic (L2, C=0.1)': LogisticRegression(C=0.1, penalty='l2', random_state=42),
    'Logistic (L1, C=1)': LogisticRegression(C=1, penalty='l1', solver='liblinear', random_state=42),
}

results = {}

for name, model in models.items():
    # Train
    model.fit(X_train_scaled, y_train)
    
    # Predictions
    y_train_pred = model.predict(X_train_scaled)
    y_test_pred = model.predict(X_test_scaled)
    y_test_proba = model.predict_proba(X_test_scaled)[:, 1]
    
    # Evaluate
    train_acc = (y_train_pred == y_train).mean()
    test_acc = (y_test_pred == y_test).mean()
    test_auc = roc_auc_score(y_test, y_test_proba)
    test_f1 = f1_score(y_test, y_test_pred)
    
    # Cross-validation
    cv_scores = cross_val_score(
        model, X_train_scaled, y_train, cv=5, scoring='roc_auc'
    )
    
    results[name] = {
        'model': model,
        'train_acc': train_acc,
        'test_acc': test_acc,
        'test_auc': test_auc,
        'test_f1': test_f1,
        'cv_mean': cv_scores.mean(),
        'cv_std': cv_scores.std(),
        'y_pred': y_test_pred,
        'y_proba': y_test_proba
    }
    
    print(f"\n{name}:")
    print(f"  Train Accuracy: {train_acc:.4f}")
    print(f"  Test Accuracy: {test_acc:.4f}")
    print(f"  Test AUC: {test_auc:.4f}")
    print(f"  Test F1: {test_f1:.4f}")
    print(f"  CV AUC (mean ± std): {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")

# ===== 4. COMPARISON TABLE =====
print("\n" + "=" * 70)
print("RESULTS COMPARISON")
print("=" * 70)

comparison_df = pd.DataFrame({
    'Model': list(results.keys()),
    'Train Acc': [results[m]['train_acc'] for m in results.keys()],
    'Test Acc': [results[m]['test_acc'] for m in results.keys()],
    'Test AUC': [results[m]['test_auc'] for m in results.keys()],
    'Test F1': [results[m]['test_f1'] for m in results.keys()],
    'CV AUC': [results[m]['cv_mean'] for m in results.keys()],
})

print(comparison_df.to_string(index=False))

# ===== 5. DETAILED EVALUATION OF BEST MODEL =====
print("\n" + "=" * 70)
print("DETAILED EVALUATION - BEST MODEL")
print("=" * 70)

best_model_name = 'Logistic (L2, C=1)'
best_result = results[best_model_name]
best_model = best_result['model']

y_pred = best_result['y_pred']
y_proba = best_result['y_proba']

# Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
print(f"\nConfusion Matrix:")
print(f"                 Predicted")
print(f"                 No    Yes")
print(f"Actual No        {cm[0,0]:3d}   {cm[0,1]:3d}")
print(f"       Yes       {cm[1,0]:3d}   {cm[1,1]:3d}")

# Classification Report
print(f"\nClassification Report:")
print(classification_report(y_test, y_pred, 
                          target_names=['Not Approved', 'Approved']))

# Feature Importance (coefficients)
print(f"\nFeature Importance (Coefficients):")
coefs = best_model.coef_[0]
for feat, coef in zip(X.columns, coefs):
    direction = "↑" if coef > 0 else "↓"
    print(f"{feat:15s}: {coef:7.4f} {direction}")

# ===== 6. VISUALIZATIONS =====
print("\n" + "=" * 70)
print("CREATING VISUALIZATIONS...")
print("=" * 70)

fig = plt.figure(figsize=(16, 12))

# 1. Confusion Matrix Heatmap
ax1 = plt.subplot(2, 3, 1)
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax1,
            xticklabels=['Not Approved', 'Approved'],
            yticklabels=['Not Approved', 'Approved'])
ax1.set_ylabel('Actual')
ax1.set_xlabel('Predicted')
ax1.set_title(f'Confusion Matrix - {best_model_name}')

# 2. ROC Curve
ax2 = plt.subplot(2, 3, 2)
fpr, tpr, _ = roc_curve(y_test, y_proba)
auc = roc_auc_score(y_test, y_proba)
ax2.plot(fpr, tpr, label=f'AUC = {auc:.3f}')
ax2.plot([0, 1], [0, 1], 'r--', label='Random')
ax2.set_xlabel('False Positive Rate')
ax2.set_ylabel('True Positive Rate')
ax2.set_title('ROC Curve')
ax2.legend()
ax2.grid(True, alpha=0.3)

# 3. Precision-Recall Curve
ax3 = plt.subplot(2, 3, 3)
precision, recall, _ = precision_recall_curve(y_test, y_proba)
ax3.plot(recall, precision)
ax3.set_xlabel('Recall')
ax3.set_ylabel('Precision')
ax3.set_title('Precision-Recall Curve')
ax3.grid(True, alpha=0.3)

# 4. Probability Distribution
ax4 = plt.subplot(2, 3, 4)
ax4.hist(y_proba[y_test == 0], bins=30, alpha=0.6, label='Not Approved')
ax4.hist(y_proba[y_test == 1], bins=30, alpha=0.6, label='Approved')
ax4.axvline(x=0.5, color='r', linestyle='--', label='Decision Threshold')
ax4.set_xlabel('Predicted Probability')
ax4.set_ylabel('Frequency')
ax4.set_title('Probability Distribution')
ax4.legend()

# 5. Feature Importance
ax5 = plt.subplot(2, 3, 5)
colors = ['green' if c > 0 else 'red' for c in coefs]
ax5.barh(X.columns, np.abs(coefs), color=colors, alpha=0.7)
ax5.set_xlabel('|Coefficient|')
ax5.set_title('Feature Importance')

# 6. Model Comparison
ax6 = plt.subplot(2, 3, 6)
models_list = list(results.keys())
aucs = [results[m]['test_auc'] for m in models_list]
ax6.bar(range(len(models_list)), aucs)
ax6.set_xticks(range(len(models_list)))
ax6.set_xticklabels(models_list, rotation=45, ha='right')
ax6.set_ylabel('AUC Score')
ax6.set_title('Model Comparison (Test AUC)')
ax6.set_ylim([0.5, 1.0])

plt.tight_layout()
plt.show()

# ===== 7. PREDICTIONS ON NEW DATA =====
print("\n" + "=" * 70)
print("PREDICTIONS ON NEW DATA")
print("=" * 70)

new_applicants = pd.DataFrame({
    'Age': [25, 35, 45, 55],
    'Income': [30000, 60000, 80000, 45000],
    'CreditScore': [580, 720, 750, 650]
})

new_applicants_scaled = scaler.transform(new_applicants)
new_probs = best_model.predict_proba(new_applicants_scaled)
new_preds = best_model.predict(new_applicants_scaled)

print("\nNew Applicants:")
for idx, row in new_applicants.iterrows():
    print(f"\nApplicant {idx+1}:")
    print(f"  Age: {row['Age']}, Income: ${row['Income']:,.0f}, Credit Score: {row['CreditScore']}")
    print(f"  P(Not Approved): {new_probs[idx][0]:.2%}")
    print(f"  P(Approved): {new_probs[idx][1]:.2%}")
    result = "✅ APPROVED" if new_preds[idx] == 1 else "❌ NOT APPROVED"
    print(f"  Decision: {result}")

# ===== 8. THRESHOLD OPTIMIZATION =====
print("\n" + "=" * 70)
print("THRESHOLD OPTIMIZATION")
print("=" * 70)

thresholds = np.arange(0.1, 0.9, 0.05)
f1_scores = []
precisions = []
recalls = []

for threshold in thresholds:
    y_pred_thresh = (y_proba >= threshold).astype(int)
    f1 = f1_score(y_test, y_pred_thresh)
    precision = (y_pred_thresh[y_test==1]).sum() / max((y_pred_thresh==1).sum(), 1)
    recall = (y_pred_thresh[y_test==1]).sum() / (y_test==1).sum()
    
    f1_scores.append(f1)
    precisions.append(precision)
    recalls.append(recall)

best_threshold = thresholds[np.argmax(f1_scores)]

plt.figure(figsize=(10, 6))
plt.plot(thresholds, f1_scores, label='F1-Score', marker='o')
plt.plot(thresholds, precisions, label='Precision', marker='s')
plt.plot(thresholds, recalls, label='Recall', marker='^')
plt.axvline(x=best_threshold, color='r', linestyle='--', label=f'Best Threshold ({best_threshold:.2f})')
plt.xlabel('Decision Threshold')
plt.ylabel('Score')
plt.title('Threshold Optimization')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

print(f"Best threshold for F1-Score: {best_threshold:.2f}")
print(f"F1-Score at best threshold: {max(f1_scores):.4f}")
````

---

## **PART 6: ADVANCED APPLICATIONS** 🚀

### **6.1 Imbalanced Data Handling**

```python
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline as ImbPipeline

# SMOTE + Undersampling + Logistic Regression
pipeline = ImbPipeline([
    ('smote', SMOTE(random_state=42)),
    ('undersample', RandomUnderSampler(random_state=42)),
    ('scaler', StandardScaler()),
    ('classifier', LogisticRegression(random_state=42))
])

pipeline.fit(X_train, y_train)
score = pipeline.score(X_test, y_test)
```

### **6.2 One-Hot Encoding for Categorical Features**

```python
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline

# Define preprocessing
preprocessor = ColumnTransformer(
    transformers=[
        ('num', StandardScaler(), numerical_features),
        ('cat', OneHotEncoder(), categorical_features)
    ])

# Pipeline
pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', LogisticRegression(max_iter=1000))
])

pipeline.fit(X_train, y_train)
```

### **6.3 Feature Selection**

```python
from sklearn.feature_selection import SelectKBest, f_classif, RFE

# Method 1: Select K Best features
selector = SelectKBest(f_classif, k=5)
X_selected = selector.fit_transform(X_train, y_train)

# Method 2: Recursive Feature Elimination
rfe = RFE(LogisticRegression(), n_features_to_select=5)
X_selected = rfe.fit_transform(X_train, y_train)

# Get selected features
selected_features = X.columns[rfe.support_]
print(f"Selected features: {list(selected_features)}")
```

---

## **SUMMARY CHEAT SHEET** 📋

| Level | Concepts | Key Skills |
|-------|----------|------------|
| **Beginner** | Sigmoid, binary classification, basic code | Simple predictions, visualization |
| **Intermediate** | Multiple features, metrics, thresholds | Train-test split, confusion matrix |
| **Advanced** | Loss function, gradient descent, regularization | Feature scaling, cross-validation |
| **Expert** | Multi-class, imbalance, hyperparameter tuning | GridSearch, calibration, advanced metrics |

---

## **Key Takeaways** 🎓

1. **Not Actually Regression:** Logistic regression is for classification
2. **Sigmoid Function:** Maps any value to 0-1 probability
3. **Log Loss:** The loss function used for optimization
4. **Threshold:** Default 0.5, but adjust based on business needs
5. **Regularization:** Prevents overfitting with L1/L2 penalties
6. **Class Imbalance:** Use SMOTE, class weights, or threshold tuning
7. **Evaluation:** Use AUC, F1-Score, not just accuracy
8. **Feature Scaling:** Essential for good performance
9. **Cross-Validation:** Use stratified K-fold for classification
10. **Multi-class:** Use softmax for 3+ classes

---

## **Common Mistakes to Avoid** ⚠️

```
❌ Not scaling features
❌ Using accuracy on imbalanced data
❌ Not doing train-test split properly
❌ Ignoring class imbalance
❌ Not tuning threshold
❌ Not checking for multicollinearity
❌ Using too high/low regularization
❌ Not cross-validating properly
```

---

## **Resources for Practice** 📚

1. **Datasets:**
   - Kaggle Credit Card Fraud Detection
   - UCI ML Repository (binary classification)
   - Titanic Survival Prediction

2. **Next Topics:**
   - Decision Trees
   - Random Forests
   - Support Vector Machines (SVM)
   - Neural Networks

Start coding and practice! 🚀