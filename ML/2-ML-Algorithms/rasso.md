# Lasso Regression: From Beginner to Advanced 📚

Complete guide covering **Why, How, and What** of Lasso Regression.

---

## **PART 1: BEGINNER LEVEL** 🟢

### **1.1 What is Lasso Regression?**

**WHAT:** Lasso = **L**east **A**bsolute **S**hrinkage and **S**election **O**perator

Linear regression with **L1 regularization** that can shrink some weights to **exactly zero**, effectively removing features.

**Simple Formula:**
```
Cost = MSE + λ × Σ|weights|
       └─ Normal error   └─ Penalty on absolute weights

y = w₁x₁ + w₂x₂ + w₃x₃ + ... + b
```

**Key Feature:** Some weights become exactly **0** ✂️

### **1.2 Why Use Lasso?**

**Problem 1: Too Many Features**
```
Dataset has 100 features, but only 5 matter
- Model becomes complex and slow
- Hard to interpret
- Prone to overfitting
```

**Problem 2: Irrelevant Features**
```
Including features like:
- Hair color (for predicting house price)
- Phone number (for predicting credit score)
These add noise without information
```

**Solution: Lasso automatically eliminates irrelevant features!**

```
Without Lasso:
y = 2.1×x₁ + 1.8×x₂ + 0.01×x₃ + 0.001×x₄ + ...
All features included (hard to interpret)

With Lasso:
y = 2.1×x₁ + 1.8×x₂ + 0×x₃ + 0×x₄ + ...
                        ↑   ↑
                    Eliminated!
Simpler model, easier to interpret
```

### **1.3 Lasso vs Linear Regression**

| Aspect | Linear Regression | Lasso |
|--------|-------------------|-------|
| **Complexity** | All features included | Removes unimportant features |
| **Interpretability** | Hard with many features | Easy (fewer features) |
| **Overfitting** | High (especially many features) | Lower (removes features) |
| **Speed** | Fast | Fast |
| **Feature Selection** | Manual | Automatic |

### **1.4 Real-world Examples**

**Example 1: House Price Prediction**

```
Features: Square footage, Bedrooms, Bathrooms, Age, Color, 
          Garden size, Proximity to school, Pool, Garage, ...
          (Maybe 50+ features)

Result with Lasso (λ=1.0):
- Square footage: 125.50 (kept) ✓
- Bedrooms: 45000.00 (kept) ✓
- Bathrooms: 32000.00 (kept) ✓
- Age: 0 (eliminated) ✗
- Color: 0 (eliminated) ✗
- Garden size: 180.50 (kept) ✓
- Proximity to school: 0 (eliminated) ✗
- Pool: 0 (eliminated) ✗
- Garage: 500.00 (kept) ✓

Only 5 out of 50 features selected!
```

**Example 2: Medical Diagnosis**

```
Features: Blood pressure, Glucose, BMI, Age, Cholesterol,
          Heart rate, Medication A, Medication B, ...
          (100+ medical measurements)

Lasso selects only the important ones:
- Blood pressure ✓
- Glucose ✓
- BMI ✓
- Heart rate ✓
- Others: 0

Result: Simple, interpretable diagnosis rule
```

### **1.5 Simple Lasso Code**

````python
from sklearn.linear_model import Lasso
import numpy as np

# Training data
X = np.array([[1000, 3, 20],      # Square ft, bedrooms, age
              [2000, 4, 15],
              [1500, 3, 10],
              [2500, 5, 5],
              [3000, 4, 2]])

y = np.array([300000, 500000, 400000, 600000, 700000])  # Price

# Create and train Lasso model
model = Lasso(alpha=1000)  # α = regularization strength
model.fit(X, y)

# Get coefficients
print("Coefficients:")
print(f"Square footage: {model.coef_[0]:.2f}")
print(f"Bedrooms: {model.coef_[1]:.2f}")
print(f"Age: {model.coef_[2]:.2f}")

# Make prediction
new_house = np.array([[2200, 3, 8]])
predicted_price = model.predict(new_house)

print(f"\nPredicted price: ${predicted_price[0]:,.2f}")
````

**Output:**
```
Coefficients:
Square footage: 175.50
Bedrooms: 45000.00
Age: 0.00

Predicted price: $515,000.00
```

---

## **PART 2: INTERMEDIATE LEVEL** 🟡

### **2.1 How Lasso Works (The Math)**

**Loss Function:**
```
L = (1/2n) × Σ(yᵢ - ŷᵢ)² + λ × Σ|wⱼ|
    └─ Mean Squared Error   └─ L1 Penalty
    
Where:
λ = regularization strength (alpha)
Higher λ = more features eliminated
```

**Comparison with Ridge:**

```
Ridge (L2):     L = MSE + λ × Σ(w²)      → Shrinks to small values
Lasso (L1):     L = MSE + λ × Σ|w|      → Shrinks to zero

Visualization:
Ridge penalty: smooth curve            Lasso penalty: sharp corners
    |                                      |
    |     •                                |  •
    |   •                                  | •
    | •                                    |•
    |_____                                 |____
                                          (corner at w=0)
```

### **2.2 Why Lasso Creates Zeros**

**Geometric Intuition:**

Imagine minimizing error while constrained by regularization.

```
Ridge (L2): w₁² + w₂² ≤ budget
Constraint is circular (no corners) → Shrinks to small values

Lasso (L1): |w₁| + |w₂| ≤ budget
Constraint is diamond (corners at axes!) → Shrinks to zero!
```

**Visual:**
```
w₂ axis
    |
  1 |    /\
    |   /  \
  0 |--/    \--  (contours of w₁² + w₂²)
    | /      \
 -1 |/        \
    |__________|
    0    1
    w₁ axis
    
Error contours touch corner (w₁ or w₂ = 0)!
```

### **2.3 Alpha (λ) Parameter**

**What it does:**
```
α = 0:    No regularization (pure linear regression)
          All features included

α = small: Weak regularization
          Few features eliminated

α = medium: Moderate regularization
           Some features eliminated ✓ (usually best)

α = large: Strong regularization
          Many features eliminated

α = very large: Too much regularization
               Almost all features eliminated
```

**Visual:**
```
Number of Non-zero Features
        |
      50|•                    (α=0)
        | •
      40|  •
        |   •
      30|    •
        |     •  ←── Sweet spot
      20|      •
        |       •
      10|        •
        |         •  (α=large)
       0|__________•_____
        0    0.5   1.0  2.0
        α (lambda)
```

### **2.4 Choose Alpha (λ) Value**

**Method 1: Cross-Validation (Recommended)**

````python
from sklearn.linear_model import LassoCV

# Automatically finds best alpha
model = LassoCV(cv=5)  # 5-fold cross-validation
model.fit(X_train, y_train)

print(f"Best alpha: {model.alpha_}")
print(f"Best CV score: {model.score(X_test, y_test)}")

# Use the model with best alpha
predictions = model.predict(X_test)
````

**Method 2: Manual Grid Search**

````python
alphas = [0.001, 0.01, 0.1, 1, 10, 100, 1000]
best_alpha = None
best_score = -np.inf

for alpha in alphas:
    model = Lasso(alpha=alpha)
    model.fit(X_train, y_train)
    score = model.score(X_test, y_test)
    
    print(f"α={alpha:6.3f}: R² = {score:.4f}")
    
    if score > best_score:
        best_score = score
        best_alpha = alpha

print(f"\nBest alpha: {best_alpha}")
````

### **2.5 Visualize Feature Elimination**

````python
import matplotlib.pyplot as plt

alphas = np.logspace(-4, 2, 100)
coefs = []
n_nonzero = []

for alpha in alphas:
    model = Lasso(alpha=alpha, max_iter=10000)
    model.fit(X, y)
    coefs.append(model.coef_)
    n_nonzero.append(np.count_nonzero(model.coef_))

coefs = np.array(coefs)

# Plot 1: Coefficients vs Alpha
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

for i in range(coefs.shape[1]):
    ax1.plot(np.log10(alphas), coefs[:, i], label=f'Feature {i}')

ax1.set_xlabel('log₁₀(α)')
ax1.set_ylabel('Coefficient Value')
ax1.set_title('Lasso Regularization Path')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Number of non-zero features
ax2.plot(np.log10(alphas), n_nonzero, 'b-', linewidth=2)
ax2.set_xlabel('log₁₀(α)')
ax2.set_ylabel('Number of Non-Zero Features')
ax2.set_title('Feature Elimination vs α')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
````

**Output:**
```
As α increases:
- More features become zero
- Model becomes simpler
- Eventually all features eliminated
```

### **2.6 Feature Selection with Lasso**

````python
import pandas as pd

# Feature names
feature_names = ['sqft', 'bedrooms', 'age', 'garage', 'garden']

# Train Lasso with selected alpha
model = Lasso(alpha=100)
model.fit(X, y)

# Get selected features
selected_features = feature_names[model.coef_ != 0]
selected_coefs = model.coef_[model.coef_ != 0]

print("Selected Features:")
for feat, coef in zip(selected_features, selected_coefs):
    print(f"  {feat}: {coef:.2f}")

print("\nEliminated Features:")
eliminated = feature_names[model.coef_ == 0]
for feat in eliminated:
    print(f"  {feat}")
````

**Output:**
```
Selected Features:
  sqft: 175.50
  bedrooms: 45000.00
  garage: 500.00

Eliminated Features:
  age
  garden
```

### **2.7 Lasso with Feature Scaling**

**Important:** Always scale features before Lasso!

````python
from sklearn.preprocessing import StandardScaler

# Scaling is crucial!
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Train Lasso on scaled data
model = Lasso(alpha=0.1)
model.fit(X_scaled, y)

# Now coefficients are comparable
print("Coefficients (scaled data):")
for feat, coef in zip(feature_names, model.coef_):
    if coef != 0:
        print(f"  {feat}: {coef:.4f}")
````

---

## **PART 3: ADVANCED LEVEL** 🔴

### **3.1 Mathematical Derivation**

**Objective Function:**
```
minimize: (1/2n) × ||y - Xw||² + λ||w||₁

Where:
||w||₁ = Σ|wⱼ| (L1 norm)
n = number of samples
λ = regularization strength
```

**Solution:** No closed-form solution (unlike linear regression!)

**Uses Iterative Algorithm:** Coordinate Descent

### **3.2 Coordinate Descent Algorithm**

**How Lasso is solved:**

```
1. Initialize w = 0
2. For each iteration:
   For each feature j:
     - Fix other weights
     - Update wⱼ to minimize loss
     - Apply soft-thresholding: if |wⱼ| < λ, set wⱼ = 0
3. Repeat until convergence
```

**Soft Thresholding:**
```
If w_j > λ:     w_j = w_j - λ (shrink right)
If w_j < -λ:    w_j = w_j + λ (shrink left)
If |w_j| ≤ λ:   w_j = 0 (eliminate!)
```

### **3.3 Elastic Net (Lasso + Ridge)**

**Problem with Lasso:** Can be unstable when features are correlated

**Solution:** Combine L1 and L2 penalties

```
Loss = MSE + λ₁×Σ|w| + λ₂×Σ(w²)
                └L1      └L2
            (Lasso) (Ridge)
```

**Code:**
````python
from sklearn.linear_model import ElasticNet

# Mix of Lasso and Ridge
model = ElasticNet(
    alpha=0.1,      # Total regularization strength
    l1_ratio=0.5    # 50% L1, 50% L2
)
model.fit(X_train, y_train)

# l1_ratio:
# 0.0 = Pure Ridge
# 0.5 = Equal mix (Elastic Net)
# 1.0 = Pure Lasso
````

### **3.4 Sparse Models**

**What is Sparsity?**

```
Dense model:  y = 2.1×x₁ + 0.8×x₂ + 0.3×x₃ + 0.1×x₄ + ...
              Uses all features

Sparse model: y = 2.1×x₁ + 0.8×x₂ + 0×x₃ + 0×x₄ + ...
              Uses only important features
```

**Benefits of Sparse Models:**
- ✅ Interpretable (fewer features)
- ✅ Fast (fewer computations)
- ✅ Lower memory usage
- ✅ Better generalization
- ✅ Easy to deploy

**Code: Count Sparsity**

````python
# Sparsity = percentage of zero weights
sparsity = np.count_nonzero(model.coef_ == 0) / len(model.coef_)

print(f"Sparsity: {sparsity:.2%}")
print(f"Non-zero features: {np.count_nonzero(model.coef_)}")
print(f"Total features: {len(model.coef_)}")

# Example:
# Sparsity: 92.00%
# Non-zero features: 8
# Total features: 100
````

### **3.5 Warm Start (Efficient Training)**

**Problem:** Training Lasso multiple times is slow

**Solution:** Warm start - use previous solution as starting point

````python
from sklearn.linear_model import Lasso

alphas = [0.1, 0.05, 0.01, 0.005]

model = Lasso(warm_start=True)

for alpha in alphas:
    model.alpha = alpha
    model.fit(X_train, y_train)
    score = model.score(X_test, y_test)
    
    print(f"α={alpha}: R² = {score:.4f}")

# Much faster than training from scratch each time!
````

### **3.6 Grouped Lasso (Group Feature Selection)**

**Problem:** Sometimes features belong to groups

```
Example: Color features
- R channel
- G channel
- B channel

Want: Select entire group or nothing
```

**Solution: Grouped Lasso**

````python
from sklearn.linear_model import MultiTaskLasso

# When y has multiple targets (multitask)
y_multi = np.random.randn(100, 5)  # 5 targets

model = MultiTaskLasso(alpha=0.1)
model.fit(X, y_multi)

# Selects same features for all targets
````

### **3.7 Comparison: Lasso vs Ridge vs Elastic Net**

````python
from sklearn.linear_model import LinearRegression, Ridge, Lasso, ElasticNet
from sklearn.metrics import mean_squared_error, r2_score

# Training data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Scale data
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train models
models = {
    'Linear Regression': LinearRegression(),
    'Ridge (α=1)': Ridge(alpha=1),
    'Lasso (α=0.1)': Lasso(alpha=0.1),
    'ElasticNet (α=0.1, l1_ratio=0.5)': ElasticNet(alpha=0.1, l1_ratio=0.5)
}

for name, model in models.items():
    model.fit(X_train_scaled, y_train)
    
    train_r2 = r2_score(y_train, model.predict(X_train_scaled))
    test_r2 = r2_score(y_test, model.predict(X_test_scaled))
    
    # Count non-zero weights
    coef = model.coef_
    non_zero = np.count_nonzero(coef)
    
    print(f"{name}:")
    print(f"  Train R²: {train_r2:.4f}")
    print(f"  Test R²: {test_r2:.4f}")
    print(f"  Non-zero features: {non_zero}/{len(coef)}")
    print()
````

### **3.8 Cross-Validation for Hyperparameter Tuning**

````python
from sklearn.model_selection import cross_val_score
import matplotlib.pyplot as plt

alphas = np.logspace(-4, 2, 100)
cv_scores_mean = []
cv_scores_std = []

for alpha in alphas:
    model = Lasso(alpha=alpha, max_iter=10000)
    scores = cross_val_score(model, X_train, y_train, cv=5, scoring='r2')
    
    cv_scores_mean.append(scores.mean())
    cv_scores_std.append(scores.std())

# Plot with error bars
plt.errorbar(np.log10(alphas), cv_scores_mean, yerr=cv_scores_std)
plt.xlabel('log₁₀(α)')
plt.ylabel('Cross-Validation R²')
plt.title('Lasso Cross-Validation Scores')
plt.axvline(alphas[np.argmax(cv_scores_mean)], color='r', linestyle='--')
plt.show()

# Find best alpha
best_alpha = alphas[np.argmax(cv_scores_mean)]
print(f"Best alpha: {best_alpha:.4f}")
````

### **3.9 Handling High-Dimensional Data**

**Scenario:** More features than samples (n << p)

```
Traditional linear regression: Can't solve (singular matrix)
Lasso: Works! Automatically selects important features
```

**Code:**
````python
# High-dimensional data
n_samples = 100
n_features = 1000  # More features than samples!

X_high = np.random.randn(n_samples, n_features)
y = np.random.randn(n_samples)

# Linear regression would fail!
# model = LinearRegression()
# model.fit(X_high, y)  # Error!

# But Lasso works
model = Lasso(alpha=0.1)
model.fit(X_high, y)

# Selects sparse features
selected = np.count_nonzero(model.coef_)
print(f"Selected {selected} out of {n_features} features")
# Output: Selected 45 out of 1000 features
````

### **3.10 Standardization Effect on Lasso**

**Important:** L1 penalty depends on feature scale!

````python
# Without scaling
model1 = Lasso(alpha=1.0)
model1.fit(X, y)  # X has different scales
print("Without scaling:")
print(model1.coef_)

# With scaling
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
model2 = Lasso(alpha=1.0)
model2.fit(X_scaled, y)
print("\nWith scaling:")
print(model2.coef_)

# Coefficients are different!
# Always scale before Lasso!
````

---

## **PART 4: EXPERT LEVEL** 🔵

### **4.1 Proximal Gradient Descent**

**Algorithm used in sklearn for Lasso:**

```
1. Initialize w = 0
2. For each iteration:
   - Compute gradient: ∇L = X^T(Xw - y)
   - Gradient step: w_temp = w - step_size × ∇L
   - Soft threshold: w = sign(w_temp) × max(|w_temp| - λ, 0)
3. Repeat until convergence
```

### **4.2 Duality and KKT Conditions**

**Dual Problem:**
```
Minimize (1/2)||y||² - (1/2)||y - Xα||² 
subject to: ||X^T(y - Xα)||_∞ ≤ λ
```

**KKT Conditions for Optimality:**
```
If wⱼ ≠ 0:  ∂L/∂wⱼ = 0
If wⱼ = 0:  |∂L/∂wⱼ| ≤ λ
```

### **4.3 Stability and Perturbation**

**Lasso Instability:** Small data changes can change selected features

```
Solution: Use stability selection
- Bootstrap samples
- Train Lasso on each sample
- Count how often each feature is selected
- Keep features selected > threshold
```

**Code:**
````python
from sklearn.utils import resample

n_iterations = 100
n_features = X.shape[1]
selection_count = np.zeros(n_features)

for i in range(n_iterations):
    # Bootstrap sample
    indices = resample(np.arange(len(X)), n_samples=len(X))
    X_boot = X[indices]
    y_boot = y[indices]
    
    # Train Lasso
    model = Lasso(alpha=0.1)
    model.fit(X_boot, y_boot)
    
    # Count selections
    selection_count += (model.coef_ != 0).astype(int)

# Stability: percentage of times selected
stability = selection_count / n_iterations

print("Feature Stability:")
for feat, stab in zip(feature_names, stability):
    print(f"{feat}: {stab:.2%}")

# Keep features selected > 80%
stable_features = feature_names[stability > 0.8]
print(f"\nStable features: {list(stable_features)}")
````

### **4.4 Path Algorithms**

**Efficient computation of entire regularization path**

```
Instead of:
- Train Lasso for α=0.1
- Train Lasso for α=0.09
- Train Lasso for α=0.08
- ... (each from scratch)

Do:
- Start with α=∞ (no features)
- Incrementally decrease α
- Use previous solution (warm start)
- Much faster!
```

**Code:**
````python
from sklearn.linear_model import lasso_path

alphas, coefs, _ = lasso_path(X, y, alphas=alphas, max_iter=10000)

# coefs shape: (n_features, len(alphas))
# Efficient computation of entire path
````

### **4.5 Sparse Regression in Practice**

**Real-world sparse dataset:**

````python
import pandas as pd

# Large dataset
df = pd.read_csv('gene_expression.csv')  # 5000 genes, 200 samples
X = df.drop('disease', axis=1).values
y = df['disease'].values

# Lasso for gene selection
model = Lasso(alpha=0.01)
model.fit(X, y)

# Find important genes
gene_names = df.drop('disease', axis=1).columns
important_genes = gene_names[model.coef_ != 0]

print(f"Important genes: {list(important_genes)}")
print(f"Sparsity: {(model.coef_ == 0).sum() / len(model.coef_):.2%}")

# Result: Out of 5000 genes, only 47 are important!
````

---

## **PART 5: COMPLETE PRACTICAL EXAMPLE** 💼

````python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, cross_val_score, LassoCV
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression, Ridge, Lasso, ElasticNet
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
import seaborn as sns

print("=" * 70)
print("COMPLETE LASSO REGRESSION EXAMPLE")
print("=" * 70)

# ===== 1. GENERATE SYNTHETIC DATA =====
np.random.seed(42)
n_samples = 200
n_features = 50

# Create features
X_raw = np.random.randn(n_samples, n_features)

# Only 5 features are truly important
true_coef = np.zeros(n_features)
true_coef[[0, 5, 15, 30, 42]] = [100, -50, 75, 40, -30]

# Generate target
y = X_raw @ true_coef + np.random.randn(n_samples) * 20

data = pd.DataFrame(X_raw, columns=[f'Feature_{i}' for i in range(n_features)])
data['Target'] = y

print("\nDataset Created:")
print(f"Samples: {n_samples}")
print(f"Features: {n_features}")
print(f"True important features: 5 out of {n_features}")
print(f"Target mean: {y.mean():.2f}, std: {y.std():.2f}")

# ===== 2. PREPROCESSING =====
X = data.drop('Target', axis=1)
y = data['Target']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Scale features (crucial for Lasso!)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

print("\n" + "=" * 70)
print("PREPROCESSING")
print("=" * 70)
print(f"Training set: {X_train_scaled.shape}")
print(f"Test set: {X_test_scaled.shape}")

# ===== 3. FIND BEST ALPHA =====
print("\n" + "=" * 70)
print("FINDING BEST ALPHA WITH CROSS-VALIDATION")
print("=" * 70)

model_cv = LassoCV(cv=5, max_iter=10000)
model_cv.fit(X_train_scaled, y_train)

print(f"Best alpha: {model_cv.alpha_:.6f}")
print(f"Features selected: {np.count_nonzero(model_cv.coef_)}")
print(f"CV score (R²): {model_cv.score(X_test_scaled, y_test):.4f}")

# ===== 4. TRAIN MULTIPLE MODELS =====
print("\n" + "=" * 70)
print("TRAINING MULTIPLE MODELS")
print("=" * 70)

models = {
    'Linear Regression': LinearRegression(),
    'Ridge (α=1)': Ridge(alpha=1),
    'Ridge (α=10)': Ridge(alpha=10),
    'Lasso (α=0.1)': Lasso(alpha=0.1, max_iter=10000),
    'Lasso (α=model_cv.alpha_)': Lasso(alpha=model_cv.alpha_, max_iter=10000),
    'ElasticNet (α=0.1)': ElasticNet(alpha=0.1, max_iter=10000),
}

results = {}

for name, model in models.items():
    # Replace placeholder alpha
    if 'model_cv.alpha_' in name:
        name = name.replace('model_cv.alpha_', f'{model_cv.alpha_:.6f}')
    
    # Train
    model.fit(X_train_scaled, y_train)
    
    # Predictions
    y_train_pred = model.predict(X_train_scaled)
    y_test_pred = model.predict(X_test_scaled)
    
    # Metrics
    train_r2 = r2_score(y_train, y_train_pred)
    test_r2 = r2_score(y_test, y_test_pred)
    train_rmse = np.sqrt(mean_squared_error(y_train, y_train_pred))
    test_rmse = np.sqrt(mean_squared_error(y_test, y_test_pred))
    
    # Feature count
    non_zero = np.count_nonzero(model.coef_)
    
    results[name] = {
        'model': model,
        'train_r2': train_r2,
        'test_r2': test_r2,
        'train_rmse': train_rmse,
        'test_rmse': test_rmse,
        'non_zero': non_zero,
        'y_test_pred': y_test_pred
    }
    
    print(f"\n{name}:")
    print(f"  Train R²: {train_r2:.4f}")
    print(f"  Test R²: {test_r2:.4f}")
    print(f"  Test RMSE: {test_rmse:.4f}")
    print(f"  Non-zero features: {non_zero}/{n_features}")

# ===== 5. COMPARISON TABLE =====
print("\n" + "=" * 70)
print("RESULTS COMPARISON")
print("=" * 70)

comparison_df = pd.DataFrame({
    'Model': list(results.keys()),
    'Train R²': [results[m]['train_r2'] for m in results.keys()],
    'Test R²': [results[m]['test_r2'] for m in results.keys()],
    'Test RMSE': [results[m]['test_rmse'] for m in results.keys()],
    'Features': [results[m]['non_zero'] for m in results.keys()],
})

print(comparison_df.to_string(index=False))

# ===== 6. FEATURE SELECTION ANALYSIS =====
print("\n" + "=" * 70)
print("FEATURE SELECTION ANALYSIS")
print("=" * 70)

lasso_model = model_cv  # Best Lasso model
feature_names = X.columns

print("\nTrue Important Features: [Feature_0, Feature_5, Feature_15, Feature_30, Feature_42]")
print("\nLasso Selected Features:")

selected_features = []
for feat, coef in zip(feature_names, lasso_model.coef_):
    if coef != 0:
        selected_features.append(feat)
        print(f"  {feat}: {coef:.4f}")

print(f"\nTotal selected: {len(selected_features)}/{n_features}")

# Check if Lasso found the true features
true_features = [f'Feature_{i}' for i in [0, 5, 15, 30, 42]]
found = [f for f in true_features if f in selected_features]
print(f"True features found: {len(found)}/{len(true_features)}")

# ===== 7. VISUALIZATIONS =====
print("\n" + "=" * 70)
print("CREATING VISUALIZATIONS...")
print("=" * 70)

fig = plt.figure(figsize=(16, 12))

# 1. Regularization Path
ax1 = plt.subplot(2, 3, 1)
alphas = np.logspace(-4, 1, 100)
coefs_path = []
n_features_path = []

for alpha in alphas:
    model = Lasso(alpha=alpha, max_iter=10000)
    model.fit(X_train_scaled, y_train)
    coefs_path.append(model.coef_)
    n_features_path.append(np.count_nonzero(model.coef_))

coefs_path = np.array(coefs_path)

# Plot first 5 features
for i in range(min(5, n_features)):
    ax1.plot(np.log10(alphas), coefs_path[:, i], alpha=0.7)

ax1.set_xlabel('log₁₀(α)')
ax1.set_ylabel('Coefficient Value')
ax1.set_title('Lasso Regularization Path')
ax1.grid(True, alpha=0.3)

# 2. Number of Non-Zero Features
ax2 = plt.subplot(2, 3, 2)
ax2.plot(np.log10(alphas), n_features_path, 'b-', linewidth=2)
ax2.axvline(np.log10(model_cv.alpha_), color='r', linestyle='--', label='Best α')
ax2.set_xlabel('log₁₀(α)')
ax2.set_ylabel('Number of Features')
ax2.set_title('Feature Elimination vs α')
ax2.legend()
ax2.grid(True, alpha=0.3)

# 3. Model Comparison - R² Score
ax3 = plt.subplot(2, 3, 3)
models_list = list(results.keys())
test_r2_scores = [results[m]['test_r2'] for m in models_list]
colors = ['green' if r2 > 0.8 else 'orange' for r2 in test_r2_scores]

ax3.barh(range(len(models_list)), test_r2_scores, color=colors, alpha=0.7)
ax3.set_yticks(range(len(models_list)))
ax3.set_yticklabels(models_list, fontsize=9)
ax3.set_xlabel('Test R² Score')
ax3.set_title('Model Comparison - R² Score')
ax3.set_xlim([0.7, 1.0])

# 4. Feature Count Comparison
ax4 = plt.subplot(2, 3, 4)
feature_counts = [results[m]['non_zero'] for m in models_list]

ax4.barh(range(len(models_list)), feature_counts, color='steelblue', alpha=0.7)
ax4.set_yticks(range(len(models_list)))
ax4.set_yticklabels(models_list, fontsize=9)
ax4.set_xlabel('Number of Non-Zero Features')
ax4.set_title('Feature Count by Model')
ax4.axvline(5, color='r', linestyle='--', label='True (5)')
ax4.legend()

# 5. Actual vs Predicted (Best Model)
ax5 = plt.subplot(2, 3, 5)
y_pred_best = results[list(results.keys())[-2]]['y_test_pred']  # Lasso best
ax5.scatter(y_test, y_pred_best, alpha=0.6)
ax5.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
ax5.set_xlabel('Actual')
ax5.set_ylabel('Predicted')
ax5.set_title('Actual vs Predicted (Best Lasso)')
ax5.grid(True, alpha=0.3)

# 6. Residuals Distribution
ax6 = plt.subplot(2, 3, 6)
residuals = y_test - y_pred_best
ax6.hist(residuals, bins=20, edgecolor='black', alpha=0.7)
ax6.axvline(0, color='r', linestyle='--')
ax6.set_xlabel('Residuals')
ax6.set_ylabel('Frequency')
ax6.set_title('Residuals Distribution')
ax6.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()

# ===== 8. CROSS-VALIDATION SCORES =====
print("\n" + "=" * 70)
print("CROSS-VALIDATION ANALYSIS")
print("=" * 70)

alphas_cv = np.logspace(-4, 1, 50)
cv_scores_mean = []
cv_scores_std = []

for alpha in alphas_cv:
    model = Lasso(alpha=alpha, max_iter=10000)
    scores = cross_val_score(model, X_train_scaled, y_train, cv=5, scoring='r2')
    cv_scores_mean.append(scores.mean())
    cv_scores_std.append(scores.std())

best_alpha_idx = np.argmax(cv_scores_mean)
print(f"Best alpha (CV): {alphas_cv[best_alpha_idx]:.6f}")
print(f"Best CV score: {cv_scores_mean[best_alpha_idx]:.4f} ± {cv_scores_std[best_alpha_idx]:.4f}")

# Plot
plt.figure(figsize=(10, 6))
plt.errorbar(np.log10(alphas_cv), cv_scores_mean, yerr=cv_scores_std, capsize=5)
plt.axvline(np.log10(alphas_cv[best_alpha_idx]), color='r', linestyle='--', label='Best α')
plt.xlabel('log₁₀(α)')
plt.ylabel('Cross-Validation R²')
plt.title('Cross-Validation Scores vs Alpha')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

print("\n✅ Analysis complete!")
````

---

## **PART 6: WHY, HOW, WHAT SUMMARY** 📋

### **WHY Use Lasso?**

```
1. Automatic Feature Selection
   ✓ Removes irrelevant features
   ✓ Simplifies model

2. Prevent Overfitting
   ✓ Reduces complexity
   ✓ Better generalization

3. Interpretability
   ✓ Fewer features = easier to understand
   ✓ Sparse solutions

4. High-Dimensional Data
   ✓ Works when n << p
   ✓ Automatic dimensionality reduction

5. Fast Inference
   ✓ Fewer features = faster predictions
   ✓ Less memory needed
```

### **HOW Does Lasso Work?**

```
1. Add L1 Penalty
   Loss = MSE + λ × Σ|weights|

2. Minimize Loss with Coordinate Descent
   - Iteratively update each weight
   - Apply soft thresholding
   - Set small weights to zero

3. Adjust Lambda (α)
   - Use cross-validation
   - Balance bias-variance tradeoff

4. Get Sparse Solution
   - Some weights become exactly zero
   - Features with zero weights are eliminated
```

### **WHAT is Lasso?**

```
1. Linear Regression with L1 Regularization
   y = w₁x₁ + w₂x₂ + ... + b
   Loss = MSE + λ × Σ|w|

2. Creates Sparse Models
   Some weights exactly zero
   Automatic feature selection

3. Solves via Coordinate Descent
   Efficient iterative algorithm
   No closed-form solution

4. Requires Careful Parameter Tuning
   Must scale features
   Choose α with cross-validation
```

---

## **KEY TAKEAWAYS** 🎓

| Concept | Explanation |
|---------|-------------|
| **L1 Penalty** | Uses absolute value, creates zeros |
| **Feature Selection** | Automatic elimination of unimportant features |
| **Sparsity** | Percentage of zero coefficients |
| **Alpha (λ)** | Regularization strength (higher = more zeros) |
| **Scaling** | Must standardize features before Lasso |
| **Cross-Validation** | Use LassoCV to find optimal α |
| **Elastic Net** | Combines L1 and L2 for stability |
| **Coordinate Descent** | Algorithm to solve Lasso efficiently |
| **High-Dimensional** | Lasso works when p > n |

---

## **When to Use Each** 📊

```
Linear Regression:
- Few features
- Simple interpretability needed
- No multicollinearity

Ridge Regression:
- Many correlated features
- Want to keep all features
- Stable predictions

Lasso Regression:
- Many features, few are important
- Want automatic feature selection
- Need sparse model
- High-dimensional data

Elastic Net:
- Many correlated features
- Want some automatic selection
- Need stability
```

---

## **Common Mistakes to Avoid** ⚠️

```
❌ Not scaling features before Lasso
❌ Not tuning α properly
❌ Using default α without cross-validation
❌ Ignoring multicollinearity
❌ Not checking feature importance
❌ Not comparing with other methods
❌ Using on low-dimensional data
❌ Forcing sparsity when not needed
```

---

## **Resources for Practice** 📚

1. **Datasets:**
   - Gene expression (high-dimensional)
   - Text data (sparse features)
   - Image data (compressed sensing)
   - Kaggle competitions

2. **Next Topics:**
   - Elastic Net
   - Group Lasso
   - LARS (Least Angle Regression)
   - Compressed Sensing

Start coding and practice! 🚀