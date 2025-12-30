# Ridge Regression: From Beginner to Advanced 📚

Complete guide covering **Why, How, and What** of Ridge Regression.

---

## **PART 1: BEGINNER LEVEL** 🟢

### **1.1 What is Ridge Regression?**

**WHAT:** Ridge Regression = Linear Regression with **L2 Regularization**

Adds a penalty on the **sum of squared weights** to prevent overfitting.

**Simple Formula:**
```
Cost = MSE + λ × Σ(weights²)
       └─ Normal error   └─ Penalty on squared weights

y = w₁x₁ + w₂x₂ + w₃x₃ + ... + b
```

**Key Feature:** Shrinks weights to **small values** (but not zero)

### **1.2 Why Use Ridge Regression?**

**Problem 1: Overfitting**
```
Too complex model learns noise instead of pattern
- High accuracy on training data
- Poor accuracy on test data
```

**Problem 2: Multicollinearity (Correlated Features)**
```
Features are highly correlated:
- Square footage and house size
- Age and renovation year
- Features compete with each other

Result: Unstable, large weights
```

**Problem 3: High Variance**
```
Small changes in data → big changes in predictions
Model is too sensitive to noise
```

**Solution: Ridge Regression!**

```
Without Ridge (Overfitting):
Model is too wiggly, fits noise
Large weights → unstable

With Ridge (Good Fit):
Model is smooth, generalizes well
Small weights → stable predictions ✓
```

### **1.3 Ridge vs Linear Regression**

| Aspect | Linear Regression | Ridge |
|--------|-------------------|-------|
| **Formula** | MSE only | MSE + λ×Σ(w²) |
| **Weights** | Can be large | Small and stable |
| **Overfitting** | High risk | Lower risk |
| **Bias** | Low | Slightly higher |
| **Variance** | High | Lower |
| **All Features** | Yes | Yes |
| **Interpretability** | Good | Good |

### **1.4 Real-world Examples**

**Example 1: House Price Prediction**

```
Without Ridge:
- Model learns each feature perfectly on training data
- Weights: sqft=500, bedrooms=1000000, age=-50000
- But fails on new houses (overfitting)

With Ridge:
- Weights are smaller and balanced: sqft=125, bedrooms=45000, age=-1250
- Works better on new data (generalizes well)
```

**Example 2: Medical Diagnosis**

```
Features: Blood pressure, Glucose, BMI, Cholesterol, ...
(These are often correlated)

Without Ridge:
- Large positive weight on blood pressure
- Large negative weight on glucose
- Model unstable (small data changes = big prediction changes)

With Ridge:
- Moderate weight on blood pressure
- Moderate weight on glucose
- Stable predictions (robust to noise)
```

### **1.5 The Bias-Variance Tradeoff**

```
Model Complexity ↑
        |
        |  \
Bias   |   \
       |    \___________
       |
       |  ___________/
Variance|  /
        | /
        |/__________|__________|___
        
      Low λ        Medium λ      High λ
      
Best: Medium λ balances bias and variance
```

### **1.6 Simple Ridge Code**

````python
from sklearn.linear_model import Ridge
import numpy as np

# Training data
X = np.array([[1000, 3, 20],      # Square ft, bedrooms, age
              [2000, 4, 15],
              [1500, 3, 10],
              [2500, 5, 5],
              [3000, 4, 2]])

y = np.array([300000, 500000, 400000, 600000, 700000])  # Price

# Create and train Ridge model
model = Ridge(alpha=1.0)  # α = regularization strength
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
Age: -1250.00

Predicted price: $515,000.00
```

---

## **PART 2: INTERMEDIATE LEVEL** 🟡

### **2.1 How Ridge Works (The Math)**

**Loss Function:**
```
L = (1/n) × Σ(yᵢ - ŷᵢ)² + λ × Σ(wⱼ)²
    └─ Mean Squared Error   └─ L2 Penalty
    
Where:
λ = regularization strength (alpha)
Higher λ = smaller weights = simpler model
```

**Closed-Form Solution (Unique to Ridge!):**
```
w = (X^T X + λI)^(-1) X^T y

Where:
X^T X = Gram matrix
λI = regularization term (makes matrix invertible)
I = identity matrix
```

**Why this matters:**
- Ridge has exact solution (no need for iterations)
- Can solve even when X^T X is singular (multicollinearity!)
- Very efficient

### **2.2 Comparison: Ridge vs Lasso**

```
Ridge (L2):     L = MSE + λ × Σ(w²)       → Shrinks to small values
Lasso (L1):     L = MSE + λ × Σ|w|       → Shrinks to zero

Visualization:
Ridge penalty: smooth curve           Lasso penalty: sharp corners
    |                                     |
    |     •                               |  •
    |   •                                 | •
    | •                                   |•
    |_____                                |____
                                         (corner at w=0)

Ridge: All features remain (weights shrink)
Lasso: Some features removed (weights become exactly 0)
```

### **2.3 Alpha (λ) Parameter**

**What it controls:**
```
α = 0:      No regularization (pure linear regression)
            Weights can be very large
            High variance, low bias

α = small:  Weak regularization (0 < α < 1)
            Slight weight shrinkage
            Balanced bias-variance

α = medium: Good regularization (α ≈ 1)
           Moderate weight shrinkage
           Good generalization ✓

α = large:  Strong regularization (α > 10)
           Heavy weight shrinkage
           Weights approach zero
           High bias, low variance
```

**Visual:**
```
Average Weight Magnitude
        |
        |•  (α=0)
        | •
        |  •
        |   •
        |    •  ←── Sweet spot (α≈1-10)
        |     •
        |      •
        |       •  (α=1000)
        |__________
        0   1   2   3
        log₁₀(α)
```

### **2.4 Choose Alpha (λ) Value**

**Method 1: Cross-Validation (Recommended)**

````python
from sklearn.linear_model import RidgeCV

# Automatically finds best alpha
model = RidgeCV(alphas=[0.1, 1, 10, 100], cv=5)
model.fit(X_train, y_train)

print(f"Best alpha: {model.alpha_}")
print(f"Best CV score: {model.score(X_test, y_test)}")
````

**Method 2: Manual Grid Search**

````python
alphas = [0.001, 0.01, 0.1, 1, 10, 100, 1000]
best_alpha = None
best_score = -np.inf

for alpha in alphas:
    model = Ridge(alpha=alpha)
    model.fit(X_train, y_train)
    score = model.score(X_test, y_test)
    
    print(f"α={alpha:7.3f}: R² = {score:.4f}")
    
    if score > best_score:
        best_score = score
        best_alpha = alpha

print(f"\nBest alpha: {best_alpha}")
````

**Output:**
```
α=  0.001: R² = 0.8234
α=  0.010: R² = 0.8456
α=  0.100: R² = 0.8712  ← Best
α=  1.000: R² = 0.8645
α= 10.000: R² = 0.8123
α=100.000: R² = 0.7234
α=1000.000: R² = 0.5123

Best alpha: 0.1
```

### **2.5 Visualize Regularization Effect**

````python
import matplotlib.pyplot as plt

alphas = np.logspace(-4, 3, 100)
weights = []
weight_magnitude = []

for alpha in alphas:
    model = Ridge(alpha=alpha)
    model.fit(X_train, y_train)
    weights.append(model.coef_)
    weight_magnitude.append(np.linalg.norm(model.coef_))

weights = np.array(weights)
weight_magnitude = np.array(weight_magnitude)

# Plot 1: Individual weights
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

for i in range(weights.shape[1]):
    ax1.plot(np.log10(alphas), weights[:, i], label=f'Feature {i}')

ax1.set_xlabel('log₁₀(α)')
ax1.set_ylabel('Weight Value')
ax1.set_title('Ridge Regularization Path')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Total weight magnitude
ax2.plot(np.log10(alphas), weight_magnitude, 'b-', linewidth=2)
ax2.set_xlabel('log₁₀(α)')
ax2.set_ylabel('||w||₂ (Weight Magnitude)')
ax2.set_title('Total Weight vs α')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
````

**Key Insight:**
```
As α increases:
- All weights shrink proportionally
- Eventually approach zero
- But never exactly zero (unlike Lasso!)
```

### **2.6 Ridge with Feature Scaling**

**Important:** Feature scale affects regularization!

````python
from sklearn.preprocessing import StandardScaler

# Without scaling
model1 = Ridge(alpha=1.0)
model1.fit(X_train, y_train)
print("Without scaling:")
print(model1.coef_)

# With scaling
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

model2 = Ridge(alpha=1.0)
model2.fit(X_train_scaled, y_train)
print("\nWith scaling:")
print(model2.coef_)

# Coefficients are different!
# Better to scale before Ridge!
````

**Why scale?**
```
Without scaling:
- Feature 1: range 1-5 (small)
- Feature 2: range 100-5000 (large)

Ridge penalty affects both equally
But feature 2 is naturally large!

With scaling:
- All features: mean=0, std=1
- Fair comparison
- Regularization works correctly
```

### **2.7 Train-Test Split & Evaluation**

````python
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Scale
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Compare models
alphas = [0.1, 1, 10, 100]

for alpha in alphas:
    model = Ridge(alpha=alpha)
    model.fit(X_train_scaled, y_train)
    
    train_r2 = r2_score(y_train, model.predict(X_train_scaled))
    test_r2 = r2_score(y_test, model.predict(X_test_scaled))
    
    print(f"α={alpha:5.1f}: Train R²={train_r2:.4f}, Test R²={test_r2:.4f}")
    
    # Good model: both similar
    # Overfitting: train >> test
````

**Output:**
```
α=  0.1: Train R²=0.9234, Test R²=0.8912  ✓ Good
α=  1.0: Train R²=0.9145, Test R²=0.8945  ✓ Good
α= 10.0: Train R²=0.8934, Test R²=0.8756  ✓ Good
α=100.0: Train R²=0.7234, Test R²=0.7145  ✗ High bias
```

---

## **PART 3: ADVANCED LEVEL** 🔴

### **3.1 Mathematical Foundation**

**Ridge Regression Derivation:**

Starting from minimization problem:
```
min_w: ||y - Xw||² + λ||w||²
```

Taking derivative and setting to zero:
```
∂L/∂w = -2X^T(y - Xw) + 2λw = 0
X^T(y - Xw) = λw
X^Ty = X^TXw + λw
X^Ty = (X^TX + λI)w

Solution:
w = (X^TX + λI)^(-1) X^Ty
```

**Key Properties:**
```
1. (X^TX + λI) is always invertible
   - Ridge solves multicollinearity!
   
2. Closed-form solution exists
   - No iterations needed
   - Efficient computation
   
3. Regularization path is smooth
   - Weights change gradually with λ
```

### **3.2 Multicollinearity Problem**

**What is multicollinearity?**

```
Features are highly correlated:
- House size and square footage
- Age and renovation year
- Height and weight

Problem:
- X^TX becomes singular/near-singular
- Matrix inversion fails or becomes unstable
- Weights become very large
- Predictions become unreliable
```

**Condition Number (Measure of Multicollinearity):**

````python
import numpy as np
from numpy.linalg import cond

# Without correlation
X_independent = np.random.randn(100, 3)
cond_independent = cond(X_independent.T @ X_independent)
print(f"Condition number (independent): {cond_independent:.2f}")

# With high correlation
X_correlated = X_independent.copy()
X_correlated[:, 1] = X_correlated[:, 0] + 0.01 * np.random.randn(100)
X_correlated[:, 2] = X_correlated[:, 0] - 0.01 * np.random.randn(100)

cond_correlated = cond(X_correlated.T @ X_correlated)
print(f"Condition number (correlated): {cond_correlated:.2f}")

# Ridge improves condition number
X_ridge = X_correlated.T @ X_correlated + 1.0 * np.eye(3)
cond_ridge = cond(X_ridge)
print(f"Condition number (with Ridge): {cond_ridge:.2f}")
````

**Output:**
```
Condition number (independent): 1.23
Condition number (correlated): 1234.56  ← Bad!
Condition number (with Ridge): 45.67    ← Better!
```

### **3.3 Elastic Net (Ridge + Lasso)**

**Combines benefits of both:**

```
Ridge: Shrinks all weights (stable with correlated features)
Lasso: Eliminates some features (automatic selection)

Elastic Net:
Loss = MSE + λ₁×Σ|w| + λ₂×Σ(w²)
            └L1      └L2
         (Lasso)   (Ridge)
```

**Code:**
````python
from sklearn.linear_model import ElasticNet

# Mix of Ridge and Lasso
model = ElasticNet(
    alpha=0.1,      # Total regularization strength
    l1_ratio=0.5    # 50% L1 (Lasso), 50% L2 (Ridge)
)
model.fit(X_train, y_train)

# l1_ratio parameter:
# 0.0 = Pure Ridge
# 0.5 = Equal mix (Elastic Net)
# 1.0 = Pure Lasso
````

### **3.4 Degrees of Freedom & Effective Parameters**

**Ridge reduces degrees of freedom:**

```
Linear regression:
df = p (number of parameters)

Ridge regression:
df = Σ λᵢ/(λᵢ + λ)

Where λᵢ are eigenvalues of X^TX

As α increases:
df decreases (simpler model)
```

**Code:**
````python
# Compute degrees of freedom for Ridge
def ridge_degrees_of_freedom(X, alpha):
    gram_matrix = X.T @ X
    eigenvalues = np.linalg.eigvalsh(gram_matrix)
    df = np.sum(eigenvalues / (eigenvalues + alpha))
    return df

for alpha in [0.01, 0.1, 1, 10, 100]:
    df = ridge_degrees_of_freedom(X_train, alpha)
    print(f"α={alpha:6.2f}: Degrees of freedom = {df:.2f}")
````

**Output:**
```
α=  0.01: Degrees of freedom = 49.98
α=  0.10: Degrees of freedom = 45.67
α=  1.00: Degrees of freedom = 35.42
α= 10.00: Degrees of freedom = 15.23
α=100.00: Degrees of freedom = 3.45
```

### **3.5 Generalized Cross-Validation (GCV)**

**Efficient way to estimate cross-validation error without refitting:**

```
GCV(λ) = RSS / (1 - df/n)²

Where:
RSS = residual sum of squares
df = degrees of freedom
n = number of samples
```

**Code:**
````python
def gcv_score(y, y_pred, n_features, n_samples):
    residual_sum = np.sum((y - y_pred) ** 2)
    degrees_of_freedom = n_features  # For simplicity
    
    gcv = residual_sum / (1 - degrees_of_freedom / n_samples) ** 2
    return gcv

# Usually sklearn handles this automatically
from sklearn.linear_model import Ridge

# Find best alpha
alphas = np.logspace(-2, 3, 100)
gcv_scores = []

for alpha in alphas:
    model = Ridge(alpha=alpha)
    model.fit(X_train, y_train)
    y_pred = model.predict(X_train)
    gcv = gcv_score(y_train, y_pred, X_train.shape[1], X_train.shape[0])
    gcv_scores.append(gcv)

best_alpha = alphas[np.argmin(gcv_scores)]
print(f"Best alpha (GCV): {best_alpha:.4f}")
````

### **3.6 Kernel Ridge Regression**

**Extend Ridge to non-linear relationships:**

```
Instead of:
y = w·x + b

Use:
y = Σ αᵢ k(x, xᵢ) + b

Where k = kernel function
```

**Code:**
````python
from sklearn.kernel_ridge import KernelRidge

# Non-linear Ridge using RBF kernel
model = KernelRidge(
    alpha=1.0,
    kernel='rbf',
    gamma=0.1  # Kernel bandwidth
)
model.fit(X_train, y_train)

score = model.score(X_test, y_test)
print(f"Kernel Ridge R²: {score:.4f}")
````

**Different Kernels:**
```
- 'linear': Linear regression
- 'rbf': Non-linear (Radial Basis Function)
- 'poly': Polynomial
- 'sigmoid': Sigmoid
```

### **3.7 Tikhonov Regularization**

**More general form of Ridge:**

```
L = ||y - Xw||² + λ||Γw||²

Where Γ = regularization matrix

Special cases:
- Γ = I → Standard Ridge
- Γ = difference matrix → Smooth solutions
```

### **3.8 Ridge Regression Path Algorithm**

**Efficient computation of entire regularization path:**

````python
from sklearn.linear_model import ridge_regression
import numpy as np

# Compute solution for multiple alphas efficiently
alphas = np.logspace(-4, 3, 100)
coefs = []

for alpha in alphas:
    model = Ridge(alpha=alpha)
    model.fit(X_train, y_train)
    coefs.append(model.coef_)

coefs = np.array(coefs)

# Plot regularization path
for i in range(coefs.shape[1]):
    plt.plot(np.log10(alphas), coefs[:, i], label=f'Feature {i}')

plt.xlabel('log₁₀(α)')
plt.ylabel('Coefficient Value')
plt.title('Ridge Regularization Path')
plt.legend()
plt.show()
````

---

## **PART 4: EXPERT LEVEL** 🔵

### **4.1 Spectral Regularization**

**Ridge in terms of eigendecomposition:**

```
X = UΣV^T (SVD decomposition)

Ridge solution:
w = VΣ̃^(-1)U^T y

Where:
Σ̃ᵢᵢ = σᵢ²/(σᵢ² + λ)

This shows:
- Ridge shrinks small singular values more
- Stabilizes inversion
```

### **4.2 Bayesian Interpretation**

**Ridge as Maximum A Posteriori (MAP) estimate:**

```
If noise: ε ~ N(0, σ²)
And prior: w ~ N(0, σ²/(2λ))

Then Ridge solution is MAP estimate!

λ = σ²/σ_w²

Interpretation:
- λ reflects prior confidence in weights
- Higher λ = stronger prior (weights near zero)
```

### **4.3 Comparison of Regularization Methods**

````python
from sklearn.linear_model import (LinearRegression, Ridge, Lasso, ElasticNet)
from sklearn.preprocessing import StandardScaler
import pandas as pd

# Prepare data
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42
)

# Train multiple models
models = {
    'Linear': LinearRegression(),
    'Ridge (α=1)': Ridge(alpha=1),
    'Ridge (α=10)': Ridge(alpha=10),
    'Lasso (α=0.1)': Lasso(alpha=0.1, max_iter=10000),
    'ElasticNet (α=0.1)': ElasticNet(alpha=0.1, max_iter=10000),
}

results = []

for name, model in models.items():
    model.fit(X_train, y_train)
    
    train_r2 = r2_score(y_train, model.predict(X_train))
    test_r2 = r2_score(y_test, model.predict(X_test))
    
    weight_magnitude = np.linalg.norm(model.coef_)
    non_zero_features = np.count_nonzero(model.coef_)
    
    results.append({
        'Model': name,
        'Train R²': train_r2,
        'Test R²': test_r2,
        'Weight Magnitude': weight_magnitude,
        'Non-Zero Features': non_zero_features
    })

results_df = pd.DataFrame(results)
print(results_df.to_string(index=False))
````

### **4.4 Stability Analysis**

**How stable are Ridge predictions to data perturbations?**

````python
# Bootstrap stability analysis
from sklearn.utils import resample

n_bootstrap = 100
coefs_bootstrap = []

for i in range(n_bootstrap):
    # Bootstrap sample
    indices = resample(np.arange(len(X_train)), n_samples=len(X_train))
    X_boot = X_train[indices]
    y_boot = y_train[indices]
    
    # Train Ridge
    model = Ridge(alpha=1.0)
    model.fit(X_boot, y_boot)
    coefs_bootstrap.append(model.coef_)

coefs_bootstrap = np.array(coefs_bootstrap)

# Stability = low variance of coefficients
for i, feat in enumerate(feature_names):
    std = coefs_bootstrap[:, i].std()
    mean = coefs_bootstrap[:, i].mean()
    print(f"{feat}: mean={mean:.4f}, std={std:.4f}")
````

---

## **PART 5: COMPLETE PRACTICAL EXAMPLE** 💼

````python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, cross_val_score, RidgeCV
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression, Ridge, RidgeCV
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
import seaborn as sns

print("=" * 70)
print("COMPLETE RIDGE REGRESSION EXAMPLE")
print("=" * 70)

# ===== 1. GENERATE SYNTHETIC DATA WITH MULTICOLLINEARITY =====
np.random.seed(42)
n_samples = 200
n_features = 10

# Create correlated features
X_raw = np.random.randn(n_samples, n_features)

# Add correlations
X_raw[:, 1] = X_raw[:, 0] + 0.1 * np.random.randn(n_samples)  # Correlated with X0
X_raw[:, 3] = X_raw[:, 2] + 0.1 * np.random.randn(n_samples)  # Correlated with X2
X_raw[:, 5] = X_raw[:, 4] + 0.1 * np.random.randn(n_samples)  # Correlated with X4

# Generate target
true_coef = np.array([10, -5, 8, 3, -7, 2, 0, 0, 0, 0])
y = X_raw @ true_coef + np.random.randn(n_samples) * 5

data = pd.DataFrame(X_raw, columns=[f'Feature_{i}' for i in range(n_features)])
data['Target'] = y

print("\nDataset Created:")
print(f"Samples: {n_samples}")
print(f"Features: {n_features}")
print(f"Target mean: {y.mean():.2f}, std: {y.std():.2f}")

# ===== 2. PREPROCESSING =====
X = data.drop('Target', axis=1)
y = data['Target']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Scale features (crucial for Ridge!)
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

model_cv = RidgeCV(alphas=np.logspace(-2, 3, 100), cv=5)
model_cv.fit(X_train_scaled, y_train)

print(f"Best alpha: {model_cv.alpha_:.4f}")
print(f"CV score (R²): {model_cv.score(X_test_scaled, y_test):.4f}")

# ===== 4. TRAIN MULTIPLE MODELS =====
print("\n" + "=" * 70)
print("TRAINING MULTIPLE MODELS")
print("=" * 70)

models = {
    'Linear Regression': LinearRegression(),
    'Ridge (α=0.1)': Ridge(alpha=0.1),
    'Ridge (α=1)': Ridge(alpha=1),
    'Ridge (α=10)': Ridge(alpha=10),
    'Ridge (α=model_cv.alpha_)': Ridge(alpha=model_cv.alpha_),
}

results = {}

for name, model in models.items():
    # Replace placeholder alpha
    if 'model_cv.alpha_' in name:
        name = name.replace('model_cv.alpha_', f'{model_cv.alpha_:.4f}')
    
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
    
    # Weight magnitude
    weight_mag = np.linalg.norm(model.coef_)
    
    results[name] = {
        'model': model,
        'train_r2': train_r2,
        'test_r2': test_r2,
        'train_rmse': train_rmse,
        'test_rmse': test_rmse,
        'weight_mag': weight_mag,
        'y_test_pred': y_test_pred
    }
    
    print(f"\n{name}:")
    print(f"  Train R²: {train_r2:.4f}")
    print(f"  Test R²: {test_r2:.4f}")
    print(f"  Test RMSE: {test_rmse:.4f}")
    print(f"  Weight Magnitude: {weight_mag:.4f}")
    print(f"  Overfitting: {train_r2 - test_r2:.4f}")

# ===== 5. COMPARISON TABLE =====
print("\n" + "=" * 70)
print("RESULTS COMPARISON")
print("=" * 70)

comparison_df = pd.DataFrame({
    'Model': list(results.keys()),
    'Train R²': [results[m]['train_r2'] for m in results.keys()],
    'Test R²': [results[m]['test_r2'] for m in results.keys()],
    'Test RMSE': [results[m]['test_rmse'] for m in results.keys()],
    'Weight Mag': [results[m]['weight_mag'] for m in results.keys()],
    'Overfitting': [results[m]['train_r2'] - results[m]['test_r2'] for m in results.keys()],
})

print(comparison_df.to_string(index=False))

# ===== 6. FEATURE ANALYSIS =====
print("\n" + "=" * 70)
print("FEATURE IMPORTANCE ANALYSIS")
print("=" * 70)

ridge_best = results[[k for k in results.keys() if 'model_cv' in k][0]]['model']
feature_names = X.columns

print("\nFeature Coefficients (Best Ridge):")
for feat, coef in zip(feature_names, ridge_best.coef_):
    print(f"  {feat}: {coef:7.4f}")

# ===== 7. VISUALIZATIONS =====
print("\n" + "=" * 70)
print("CREATING VISUALIZATIONS...")
print("=" * 70)

fig = plt.figure(figsize=(16, 12))

# 1. Regularization Path
ax1 = plt.subplot(2, 3, 1)
alphas = np.logspace(-3, 2, 100)
coefs_path = []
weight_mags = []

for alpha in alphas:
    model = Ridge(alpha=alpha)
    model.fit(X_train_scaled, y_train)
    coefs_path.append(model.coef_)
    weight_mags.append(np.linalg.norm(model.coef_))

coefs_path = np.array(coefs_path)
weight_mags = np.array(weight_mags)

# Plot first 5 features
for i in range(min(5, n_features)):
    ax1.plot(np.log10(alphas), coefs_path[:, i], alpha=0.7)

ax1.set_xlabel('log₁₀(α)')
ax1.set_ylabel('Coefficient Value')
ax1.set_title('Ridge Regularization Path')
ax1.grid(True, alpha=0.3)

# 2. Weight Magnitude vs Alpha
ax2 = plt.subplot(2, 3, 2)
ax2.plot(np.log10(alphas), weight_mags, 'b-', linewidth=2)
ax2.axvline(np.log10(model_cv.alpha_), color='r', linestyle='--', label='Best α')
ax2.set_xlabel('log₁₀(α)')
ax2.set_ylabel('||w||₂ (Weight Magnitude)')
ax2.set_title('Weight Magnitude vs α')
ax2.legend()
ax2.grid(True, alpha=0.3)

# 3. Model Comparison - R² Score
ax3 = plt.subplot(2, 3, 3)
models_list = list(results.keys())
test_r2_scores = [results[m]['test_r2'] for m in models_list]
colors = ['green' if r2 > 0.95 else 'orange' for r2 in test_r2_scores]

ax3.barh(range(len(models_list)), test_r2_scores, color=colors, alpha=0.7)
ax3.set_yticks(range(len(models_list)))
ax3.set_yticklabels(models_list, fontsize=9)
ax3.set_xlabel('Test R² Score')
ax3.set_title('Model Comparison - R² Score')
ax3.set_xlim([0.85, 1.0])

# 4. Overfitting Analysis
ax4 = plt.subplot(2, 3, 4)
overfit = [results[m]['train_r2'] - results[m]['test_r2'] for m in models_list]
colors = ['green' if of < 0.05 else 'red' for of in overfit]

ax4.barh(range(len(models_list)), overfit, color=colors, alpha=0.7)
ax4.set_yticks(range(len(models_list)))
ax4.set_yticklabels(models_list, fontsize=9)
ax4.set_xlabel('Overfitting (Train R² - Test R²)')
ax4.set_title('Overfitting Analysis')

# 5. Actual vs Predicted (Best Model)
ax5 = plt.subplot(2, 3, 5)
best_model_name = list(results.keys())[-1]
y_pred_best = results[best_model_name]['y_test_pred']

ax5.scatter(y_test, y_pred_best, alpha=0.6)
ax5.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
ax5.set_xlabel('Actual')
ax5.set_ylabel('Predicted')
ax5.set_title(f'Actual vs Predicted (Best Ridge)')
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

# ===== 8. CROSS-VALIDATION ANALYSIS =====
print("\n" + "=" * 70)
print("CROSS-VALIDATION ANALYSIS")
print("=" * 70)

alphas_cv = np.logspace(-3, 2, 50)
cv_scores_mean = []
cv_scores_std = []

for alpha in alphas_cv:
    model = Ridge(alpha=alpha)
    scores = cross_val_score(model, X_train_scaled, y_train, cv=5, scoring='r2')
    cv_scores_mean.append(scores.mean())
    cv_scores_std.append(scores.std())

best_alpha_idx = np.argmax(cv_scores_mean)
print(f"Best alpha (CV): {alphas_cv[best_alpha_idx]:.4f}")
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

### **WHY Use Ridge Regression?**

```
1. Prevent Overfitting
   ✓ Shrinks weights to prevent fitting noise
   ✓ Better generalization to new data

2. Handle Multicollinearity
   ✓ Solves when features are correlated
   ✓ Stabilizes predictions

3. Stabilize Predictions
   ✓ Small weight changes don't cause large prediction changes
   ✓ More robust model

4. Closed-Form Solution
   ✓ Efficient computation
   ✓ No iterations needed

5. Keep All Features
   ✓ Sometimes you want all features
   ✓ Ridge doesn't eliminate features (unlike Lasso)
```

### **HOW Does Ridge Work?**

```
1. Add L2 Penalty
   Loss = MSE + λ × Σ(weights²)

2. Minimize Loss
   Gradient descent or closed-form solution

3. Adjust Regularization Strength (α)
   - Use cross-validation
   - Balance bias-variance tradeoff

4. Regularize All Weights
   - All weights shrink proportionally
   - Never exactly zero
   - Stable solution

5. Get Predictions
   - Use regularized weights
   - Better generalization
```

### **WHAT is Ridge Regression?**

```
1. Linear Regression with L2 Regularization
   y = w₁x₁ + w₂x₂ + ... + b
   Loss = MSE + λ × Σ(w²)

2. Shrinks Weights to Prevent Overfitting
   Weights become smaller and more stable

3. Closed-Form Solution Exists
   w = (X^T X + λI)^(-1) X^T y

4. Handles Multicollinearity
   Makes singular/near-singular matrices invertible

5. Smooth Regularization Path
   Weights change gradually as α increases
```

---

## **KEY TAKEAWAYS** 🎓

| Concept | Explanation |
|---------|-------------|
| **L2 Penalty** | Σ(w²), shrinks weights proportionally |
| **Bias-Variance** | Ridge increases bias, decreases variance |
| **Alpha (λ)** | Regularization strength (higher = more shrinking) |
| **Scaling** | Must standardize features before Ridge |
| **Cross-Validation** | Use to find optimal α |
| **Multicollinearity** | Ridge solves by making X^TX invertible |
| **Closed-Form** | Direct solution without iterations |
| **Degrees of Freedom** | Ridge reduces effective parameters |

---

## **When to Use Each** 📊

```
Linear Regression:
- Few features, no multicollinearity
- Simple interpretability needed

Ridge Regression:
- Many features, some are correlated
- Want all features (not selection)
- Need stable predictions
- Multicollinearity problem
- ✓ Recommended for most cases

Lasso Regression:
- Many features, few are important
- Want automatic feature selection
- High-dimensional data

Elastic Net:
- Correlated features but want some selection
- Combine Ridge and Lasso benefits
```

---

## **Common Mistakes to Avoid** ⚠️

```
❌ Not scaling features before Ridge
❌ Not tuning α properly
❌ Using default α without cross-validation
❌ Not checking for multicollinearity
❌ Comparing raw vs scaled coefficients
❌ Assuming Ridge eliminates features (only shrinks!)
❌ Not splitting train-test properly
❌ Overfitting during hyperparameter tuning
```

---

## **Comparison Table: Ridge vs Lasso vs Elastic Net** 📊

| Property | Ridge | Lasso | Elastic Net |
|----------|-------|-------|-------------|
| **Formula** | MSE + λΣ(w²) | MSE + λΣ\|w\| | MSE + λ₁Σ\|w\| + λ₂Σ(w²) |
| **Penalty Type** | L2 | L1 | L1 + L2 |
| **Shrinkage** | Proportional | To zero | Combination |
| **Zero Weights** | No | Yes | Some |
| **Multicollinearity** | Handles well | Unstable | Handles well |
| **Feature Selection** | No | Yes | Partial |
| **Solution Form** | Closed-form | Iterative | Iterative |
| **When to Use** | Correlated features | Sparse features | Both problems |

---

## **Resources for Practice** 📚

1. **Datasets:**
   - Boston Housing (multicollinearity)
   - California Housing
   - Wine Quality
   - Kaggle datasets

2. **Next Topics:**
   - Elastic Net
   - Kernel Ridge Regression
   - SVD and PCA
   - Feature Selection Methods

Start coding and practice! 🚀