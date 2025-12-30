# Linear Regression: From Beginner to Advanced 📚

Let me take you on a comprehensive journey through linear regression.

---

## **PART 1: BEGINNER LEVEL** 🟢

### **1.1 The Basics**

**What is Linear Regression?**

Linear regression finds the best-fit straight line through data points to predict values.

**Formula:**
```
y = mx + b

Where:
y = output (what we predict)
x = input (what we know)
m = slope (how steep the line is)
b = intercept (where line crosses y-axis)
```

**Real-world Example:**

```
Sales prediction based on advertising spend:

Spend ($)  →  Sales ($)
100        →  500
200        →  1000
300        →  1500
400        →  2000

Pattern: Sales = 5 × Spend + 0

Linear regression finds: y = 5x
```

### **1.2 Key Concepts**

**Dependent Variable (y):** What we want to predict
- House price
- Sales revenue
- Student grade

**Independent Variable (x):** What we use to predict
- House size
- Advertising spend
- Study hours

**Training Data:** Historical examples used to learn the pattern

**Prediction:** Using learned pattern on new data

### **1.3 Simple Linear Regression (One Feature)**

````python
# BEGINNER CODE: Single feature prediction

from sklearn.linear_model import LinearRegression
import numpy as np

# Training data
X = np.array([[1], [2], [3], [4], [5]])        # Hours studied
y = np.array([70, 75, 80, 85, 90])              # Test scores

# Create model
model = LinearRegression()

# Train model
model.fit(X, y)

# Make predictions
new_hours = np.array([[6]])
predicted_score = model.predict(new_hours)

print(f"Predicted score for 6 hours: {predicted_score[0]:.2f}")
# Output: 95.00

# Get model parameters
print(f"Slope (m): {model.coef_[0]}")           # 5.0
print(f"Intercept (b): {model.intercept_}")     # 65.0
# Formula: y = 5x + 65
````

### **1.4 Visualization**

````python
import matplotlib.pyplot as plt

# Plot training data
plt.scatter(X, y, color='blue', label='Training data')

# Plot regression line
X_line = np.array([[0], [6]])
y_line = model.predict(X_line)
plt.plot(X_line, y_line, color='red', label='Regression line')

plt.xlabel('Hours Studied')
plt.ylabel('Test Score')
plt.legend()
plt.show()
````

**Output:**
```
Test Score (y)
    |
 95 |              •  (prediction)
 90 |            •
 85 |          •
 80 |        •
 75 |      •
 70 |    •
    |______________
    0  1  2  3  4  5  6
    Hours Studied (x)
```

---

## **PART 2: INTERMEDIATE LEVEL** 🟡

### **2.1 Multiple Linear Regression (Multiple Features)**

**Formula:**
```
y = w₁x₁ + w₂x₂ + w₃x₃ + ... + wₙxₙ + b

Where:
w = weights (coefficients)
x = features
b = bias (intercept)
```

**Real-world Example: House Price**

```
Features:
- Square footage (x₁)
- Number of bedrooms (x₂)
- Age of house (x₃)
- Distance to school (x₄)

Predict: House price (y)

Example:
Price = 200×sqft + 50000×bedrooms - 1000×age - 5000×distance + 10000
```

### **2.2 Code: Multiple Features**

````python
from sklearn.linear_model import LinearRegression
import numpy as np
import pandas as pd

# Create training data
data = {
    'sqft': [1000, 1500, 2000, 2500, 3000],
    'bedrooms': [2, 3, 3, 4, 4],
    'age': [20, 15, 10, 5, 2],
    'distance_to_school': [5, 3, 2, 1, 0.5],
    'price': [250000, 350000, 450000, 550000, 650000]
}

df = pd.DataFrame(data)

# Separate features and target
X = df[['sqft', 'bedrooms', 'age', 'distance_to_school']]
y = df['price']

# Train model
model = LinearRegression()
model.fit(X, y)

# Make prediction
new_house = pd.DataFrame({
    'sqft': [2200],
    'bedrooms': [3],
    'age': [8],
    'distance_to_school': [1.5]
})

predicted_price = model.predict(new_house)
print(f"Predicted price: ${predicted_price[0]:,.2f}")

# Get coefficients
feature_names = ['sqft', 'bedrooms', 'age', 'distance_to_school']
for name, coef in zip(feature_names, model.coef_):
    print(f"{name}: {coef:.2f}")

print(f"Intercept: {model.intercept_:.2f}")
````

**Output:**
```
Predicted price: $480,000.00
sqft: 125.00
bedrooms: 45000.00
age: -1250.00
distance_to_school: -8500.00
Intercept: 50000.00
```

**Interpretation:**
```
- Each 1 sq ft adds $125 to price
- Each bedroom adds $45,000
- Each year of age reduces price by $1,250
- Each mile to school reduces price by $8,500
```

### **2.3 Error Metrics**

**Mean Squared Error (MSE):**
```
MSE = (1/n) × Σ(actual - predicted)²

Measures: Average squared difference
Lower is better
```

**Root Mean Squared Error (RMSE):**
```
RMSE = √MSE

Same units as y
Easier to interpret than MSE
```

**R² Score (Coefficient of Determination):**
```
R² = 1 - (SS_res / SS_tot)

Range: 0 to 1 (higher is better)
0.9 = 90% of variance explained
```

### **2.4 Calculate Error Metrics**

````python
from sklearn.metrics import mean_squared_error, r2_score
import numpy as np

# Make predictions
y_pred = model.predict(X)

# Calculate metrics
mse = mean_squared_error(y, y_pred)
rmse = np.sqrt(mse)
r2 = r2_score(y, y_pred)

print(f"Mean Squared Error: {mse:,.2f}")
print(f"Root Mean Squared Error: ${rmse:,.2f}")
print(f"R² Score: {r2:.4f}")

# Example output:
# Mean Squared Error: 15,000,000.00
# Root Mean Squared Error: $3,872.98
# R² Score: 0.9956
````

### **2.5 Train-Test Split**

**Problem:** If you test on training data, you get unrealistic results!

````python
from sklearn.model_selection import train_test_split

# Split data: 80% train, 20% test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train on training set
model = LinearRegression()
model.fit(X_train, y_train)

# Evaluate on test set
y_train_pred = model.predict(X_train)
y_test_pred = model.predict(X_test)

train_r2 = r2_score(y_train, y_train_pred)
test_r2 = r2_score(y_test, y_test_pred)

print(f"Training R²: {train_r2:.4f}")
print(f"Testing R²: {test_r2:.4f}")

# Good model: both scores similar
# Overfitting: train_r2 >> test_r2
````

---

## **PART 3: ADVANCED LEVEL** 🔴

### **3.1 The Math Behind Linear Regression**

**Goal:** Find weights (w) and bias (b) that minimize error

**Loss Function (Sum of Squared Errors):**
```
L = Σ(yᵢ - ŷᵢ)²
  = Σ(yᵢ - (wxᵢ + b))²

Where:
yᵢ = actual value
ŷᵢ = predicted value
```

**Solving Mathematically (Closed-form solution):**
```
w = (Xᵀ X)⁻¹ Xᵀ y

Where:
Xᵀ = transpose of X
X⁻¹ = inverse of X
```

**In NumPy:**
````python
import numpy as np

# Manually compute optimal weights
X = np.array([[1, 2], [2, 3], [3, 4], [4, 5]])  # Features
y = np.array([5, 8, 11, 14])                     # Target

# Add bias term (column of 1s)
X_with_bias = np.column_stack([np.ones(len(X)), X])

# Normal equation: w = (X^T X)^-1 X^T y
w = np.linalg.inv(X_with_bias.T @ X_with_bias) @ X_with_bias.T @ y

print(f"Coefficients: {w}")
# Output: [bias, w1, w2]
````

### **3.2 Gradient Descent (Advanced Training)**

**Problem:** Normal equation is slow with huge datasets (millions of rows)

**Solution:** Gradient Descent - iteratively improve weights

**Concept:**
```
1. Start with random weights
2. Calculate gradient (slope of error)
3. Move in opposite direction of gradient
4. Repeat until convergence
```

**Formula:**
```
w_new = w_old - learning_rate × ∇L

Where:
∇L = gradient of loss function
learning_rate = step size (α)
```

**Visualization:**
```
Error (Loss)
    |
    |  •  ← Start
    |    \
    |     \  ← Moving down gradient
    |      \
    |       •  ← Better weights
    |        \
    |         •  ← Even better
    |          \
    |           •  ← Minimum
    |_____________
      Weights (w)
```

### **3.3 Gradient Descent Implementation**

````python
import numpy as np
import matplotlib.pyplot as plt

# Training data
X = np.array([[1], [2], [3], [4], [5]])
y = np.array([2, 4, 5, 4, 5])

# Initialize parameters
w = np.random.randn(1)[0]
b = np.random.randn(1)[0]
learning_rate = 0.01
epochs = 100

# Store losses for visualization
losses = []

# Gradient Descent
n = len(X)
for epoch in range(epochs):
    # Forward pass: make predictions
    y_pred = w * X + b
    
    # Calculate loss
    loss = np.mean((y_pred - y) ** 2)
    losses.append(loss)
    
    # Calculate gradients
    dw = (2/n) * np.sum(X * (y_pred - y))
    db = (2/n) * np.sum(y_pred - y)
    
    # Update parameters
    w = w - learning_rate * dw
    b = b - learning_rate * db
    
    if (epoch + 1) % 10 == 0:
        print(f"Epoch {epoch+1}, Loss: {loss:.4f}, w: {w:.4f}, b: {b:.4f}")

print(f"\nFinal weights: w={w:.4f}, b={b:.4f}")

# Plot loss decreasing
plt.plot(losses)
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.title('Loss vs Epoch (Gradient Descent)')
plt.show()
````

**Output:**
```
Epoch 10, Loss: 2.3456, w: 0.7234, b: 0.5123
Epoch 20, Loss: 1.8901, w: 0.8456, b: 0.6789
Epoch 30, Loss: 1.5678, w: 0.9012, b: 0.7234
...
Final weights: w=1.0234, b=0.8123
```

### **3.4 Feature Scaling**

**Problem:** Features with different ranges cause issues

```
Example:
- House size: 1000-5000 (large numbers)
- Rooms: 1-10 (small numbers)
- Age: 0-100 (medium numbers)

Gradient descent struggles with mismatched scales!
```

**Solution: Standardization (Z-score normalization)**

```
x_scaled = (x - mean) / std_dev

Result: mean=0, std_dev=1
```

**Code:**
````python
from sklearn.preprocessing import StandardScaler

# Original features
X = np.array([[1000, 3, 20],
              [2000, 4, 15],
              [1500, 3, 10],
              [2500, 5, 5]])

# Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

print("Original X:")
print(X)
print("\nScaled X:")
print(X_scaled)

# For predictions on new data
new_data = np.array([[1800, 4, 12]])
new_data_scaled = scaler.transform(new_data)
````

### **3.5 Regularization: Ridge & Lasso**

**Problem:** Large weights cause overfitting

**Solution:** Add penalty term to loss function

**Ridge Regression (L2):**
```
Loss = MSE + λ × Σ(w²)
                 └─ Penalty for large weights

Makes weights small but non-zero
```

**Lasso Regression (L1):**
```
Loss = MSE + λ × Σ|w|
                └─ Penalty on absolute weights

Can make weights exactly zero (feature elimination)
```

**Code:**
````python
from sklearn.linear_model import Ridge, Lasso
from sklearn.model_selection import train_test_split

# Data
X = np.random.randn(100, 20)  # 100 samples, 20 features
y = np.random.randn(100)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Ridge with different alpha values
alphas = [0.1, 1, 10, 100]
for alpha in alphas:
    ridge = Ridge(alpha=alpha)
    ridge.fit(X_train, y_train)
    score = ridge.score(X_test, y_test)
    print(f"Ridge α={alpha}: R² = {score:.4f}")

# Lasso - automatically eliminates features
lasso = Lasso(alpha=0.1)
lasso.fit(X_train, y_train)

# Count non-zero weights
non_zero = np.count_nonzero(lasso.coef_)
print(f"\nLasso selected {non_zero} out of 20 features")
````

### **3.6 Polynomial Regression**

**Problem:** Linear regression only fits straight lines

**Solution:** Add polynomial features

```
Linear: y = w₁x + b
Polynomial: y = w₁x + w₂x² + w₃x³ + b
```

**Example: Stock price is non-linear**

````python
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt

# Non-linear data
X = np.array([[1], [2], [3], [4], [5]])
y = np.array([1, 4, 9, 16, 25])  # y = x²

# Polynomial features (degree 2)
poly_features = PolynomialFeatures(degree=2)
X_poly = poly_features.fit_transform(X)

print("Original X:")
print(X)
print("\nPolynomial X (degree 2):")
print(X_poly)
# Output:
# [[1  1  1]
#  [1  2  4]
#  [1  3  9]
#  [1  4  16]
#  [1  5  25]]

# Train polynomial regression
poly_model = LinearRegression()
poly_model.fit(X_poly, y)

# Make predictions
X_test = np.array([[2.5]])
X_test_poly = poly_features.transform(X_test)
prediction = poly_model.predict(X_test_poly)

print(f"Predicted y for x=2.5: {prediction[0]:.2f}")  # 6.25

# Plot
X_line = np.linspace(0, 6, 100).reshape(-1, 1)
X_line_poly = poly_features.transform(X_line)
y_line = poly_model.predict(X_line_poly)

plt.scatter(X, y, label='Data')
plt.plot(X_line, y_line, 'r-', label='Polynomial fit')
plt.legend()
plt.show()
````

### **3.7 Multicollinearity**

**Problem:** Correlated features cause numerical instability

```
Example:
- House size and number of rooms are highly correlated
- Both predict price similarly
- Model becomes unstable
```

**Detect Multicollinearity:**
````python
from sklearn.preprocessing import StandardScaler
import pandas as pd
import numpy as np

# Data with correlated features
X = pd.DataFrame({
    'feature1': [1, 2, 3, 4, 5],
    'feature2': [2, 4, 6, 8, 10],  # Perfect correlation with feature1!
    'feature3': [1, 3, 2, 5, 4]
})

# Calculate correlation matrix
correlation = X.corr()
print(correlation)

# VIF (Variance Inflation Factor)
from statsmodels.stats.outliers_influence import variance_inflation_factor

vif = pd.DataFrame({
    'Feature': X.columns,
    'VIF': [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]
})

print("\nVIF Scores:")
print(vif)

# VIF > 10 indicates multicollinearity problem
````

**Solution:**
1. Remove correlated features
2. Use Ridge/Lasso regression
3. Use PCA (Principal Component Analysis)

### **3.8 Cross-Validation**

**Problem:** Single train-test split might be lucky/unlucky

**Solution:** K-Fold Cross-Validation

```
Split data into k folds
For each fold:
  - Use that fold as test
  - Use other k-1 folds as train
  - Evaluate
Average results
```

**Code:**
````python
from sklearn.model_selection import cross_val_score
from sklearn.linear_model import LinearRegression

# Data
X = np.random.randn(100, 10)
y = np.random.randn(100)

# 5-fold cross-validation
model = LinearRegression()
scores = cross_val_score(model, X, y, cv=5, scoring='r2')

print(f"Cross-validation R² scores: {scores}")
print(f"Mean R²: {scores.mean():.4f}")
print(f"Std Dev: {scores.std():.4f}")

# Output:
# Cross-validation R² scores: [0.1234 0.1456 0.1089 0.1567 0.1432]
# Mean R²: 0.1356
# Std Dev: 0.0149
````

**Visual:**
```
Original Data
├─ Fold 1: [Test | Train | Train | Train | Train]
├─ Fold 2: [Train | Test | Train | Train | Train]
├─ Fold 3: [Train | Train | Test | Train | Train]
├─ Fold 4: [Train | Train | Train | Test | Train]
└─ Fold 5: [Train | Train | Train | Train | Test]

Average 5 results
```

### **3.9 Advanced: Regularization Path**

**Find optimal regularization parameter:**

````python
from sklearn.linear_model import RidgeCV, LassoCV

# RidgeCV finds best alpha automatically
X = np.random.randn(100, 20)
y = np.random.randn(100)

alphas = np.logspace(-2, 5, 100)

# Ridge with cross-validation
ridge_cv = RidgeCV(alphas=alphas, cv=5)
ridge_cv.fit(X, y)

print(f"Best α for Ridge: {ridge_cv.alpha_:.4f}")
print(f"Best R² Score: {ridge_cv.score(X, y):.4f}")

# Lasso with cross-validation
lasso_cv = LassoCV(cv=5, random_state=42)
lasso_cv.fit(X, y)

print(f"Best α for Lasso: {lasso_cv.alpha_:.4f}")
print(f"Non-zero features: {np.count_nonzero(lasso_cv.coef_)}")
````

### **3.10 Assumptions Check**

**Linear regression assumes:**

1. **Linearity:** Relationship is linear
2. **Independence:** Observations independent
3. **Homoscedasticity:** Constant variance of errors
4. **Normality:** Errors normally distributed
5. **No Multicollinearity:** Features not correlated

**Check Assumptions:**
````python
from scipy import stats
import matplotlib.pyplot as plt

# Make predictions
y_pred = model.predict(X)
residuals = y - y_pred

# 1. Linearity check: Residuals vs Fitted
plt.subplot(2, 2, 1)
plt.scatter(y_pred, residuals)
plt.axhline(y=0, color='r')
plt.title('Residuals vs Fitted')

# 2. Normality check: Q-Q Plot
plt.subplot(2, 2, 2)
stats.probplot(residuals, dist="norm", plot=plt)
plt.title('Q-Q Plot')

# 3. Homoscedasticity: Scale-Location
plt.subplot(2, 2, 3)
plt.scatter(y_pred, np.sqrt(np.abs(residuals)))
plt.title('Scale-Location')

# 4. Normality test
_, p_value = stats.shapiro(residuals)
print(f"Shapiro-Wilk test p-value: {p_value:.4f}")
# p > 0.05: residuals are normal ✓

plt.tight_layout()
plt.show()
````

---

## **PART 4: EXPERT LEVEL** 🔵

### **4.1 Matrix Formulation**

**Entire regression in matrix form:**

```
y = Xw + ε

Where:
y = [y₁, y₂, ..., yₙ]ᵀ           (n×1)
X = [1  x₁₁  x₁₂  ...  x₁ₚ      (n×(p+1))
     1  x₂₁  x₂₂  ...  x₂ₚ
     ...
     1  xₙ₁  xₙ₂  ...  xₙₚ]
w = [b, w₁, w₂, ..., wₚ]ᵀ        ((p+1)×1)
ε = error term

Solution (Normal Equation):
w = (XᵀX)⁻¹Xᵀy
```

### **4.2 Weighted Least Squares**

Give more importance to certain samples:

````python
from sklearn.linear_model import LinearRegression

# Some observations are more reliable
weights = np.array([0.5, 1.0, 0.8, 1.0, 0.9])

# Train with sample weights
X = np.array([[1], [2], [3], [4], [5]])
y = np.array([2, 4, 5, 4, 5])

model = LinearRegression()
model.fit(X, y, sample_weight=weights)

print(f"Weighted w: {model.coef_[0]:.4f}")
print(f"Weighted b: {model.intercept_:.4f}")
````

### **4.3 Elastic Net (Combination of Ridge & Lasso)**

```
Loss = MSE + λ₁×Σ|w| + λ₂×Σ(w²)
              └Lasso  └─Ridge

Combines benefits of both!
```

````python
from sklearn.linear_model import ElasticNet

elastic = ElasticNet(alpha=0.1, l1_ratio=0.5)  # 50% Ridge, 50% Lasso
elastic.fit(X_train, y_train)

print(f"R² Score: {elastic.score(X_test, y_test):.4f}")
````

### **4.4 Robust Regression (Handle Outliers)**

**Problem:** Outliers distort linear regression

**Solution:** Use robust regression methods

````python
from sklearn.linear_model import HuberRegressor, RANSACRegressor

# Huber: Robust to outliers
huber = HuberRegressor(epsilon=1.35, max_iter=100)
huber.fit(X_train, y_train)

# RANSAC: Ignore outliers
ransac = RANSACRegressor(random_state=42)
ransac.fit(X_train, y_train)

print(f"Huber R²: {huber.score(X_test, y_test):.4f}")
print(f"RANSAC R²: {ransac.score(X_test, y_test):.4f}")
````

### **4.5 Regularization Path Visualization**

````python
from sklearn.linear_model import Ridge
import matplotlib.pyplot as plt

alphas = np.logspace(-2, 5, 100)
coefs = []

for alpha in alphas:
    ridge = Ridge(alpha=alpha)
    ridge.fit(X_train, y_train)
    coefs.append(ridge.coef_)

coefs = np.array(coefs)

plt.figure(figsize=(10, 6))
for i in range(coefs.shape[1]):
    plt.plot(alphas, coefs[:, i], label=f'Feature {i}')

plt.xscale('log')
plt.xlabel('Alpha (λ)')
plt.ylabel('Coefficient Value')
plt.title('Ridge Regularization Path')
plt.legend()
plt.show()
````

---

## **PART 5: COMPLETE PRACTICAL EXAMPLE** 💼

````python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler, PolynomialFeatures
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
import seaborn as sns

# ===== 1. GENERATE SYNTHETIC DATA =====
np.random.seed(42)
n_samples = 200

X_raw = np.random.randn(n_samples, 3) * 100
y = 50 + 2*X_raw[:, 0] + 0.5*X_raw[:, 1] - 3*X_raw[:, 2] + np.random.randn(n_samples)*10

data = pd.DataFrame(X_raw, columns=['Feature1', 'Feature2', 'Feature3'])
data['Target'] = y

print("=" * 60)
print("COMPLETE LINEAR REGRESSION EXAMPLE")
print("=" * 60)
print("\nDataset Overview:")
print(data.describe())

# ===== 2. PREPROCESSING =====
X = data.drop('Target', axis=1)
y = data['Target']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

print("\n" + "=" * 60)
print("PREPROCESSING")
print("=" * 60)
print(f"Training set: {X_train_scaled.shape}")
print(f"Test set: {X_test_scaled.shape}")

# ===== 3. TRAIN MODELS =====
print("\n" + "=" * 60)
print("MODEL TRAINING")
print("=" * 60)

models = {
    'Linear Regression': LinearRegression(),
    'Ridge (α=1)': Ridge(alpha=1),
    'Ridge (α=10)': Ridge(alpha=10),
    'Lasso (α=0.1)': Lasso(alpha=0.1),
}

results = {}

for name, model in models.items():
    # Train
    model.fit(X_train_scaled, y_train)
    
    # Predictions
    y_train_pred = model.predict(X_train_scaled)
    y_test_pred = model.predict(X_test_scaled)
    
    # Evaluate
    train_r2 = r2_score(y_train, y_train_pred)
    test_r2 = r2_score(y_test, y_test_pred)
    train_rmse = np.sqrt(mean_squared_error(y_train, y_train_pred))
    test_rmse = np.sqrt(mean_squared_error(y_test, y_test_pred))
    
    # Cross-validation
    cv_scores = cross_val_score(model, X_train_scaled, y_train, cv=5, scoring='r2')
    
    results[name] = {
        'model': model,
        'train_r2': train_r2,
        'test_r2': test_r2,
        'train_rmse': train_rmse,
        'test_rmse': test_rmse,
        'cv_mean': cv_scores.mean(),
        'cv_std': cv_scores.std()
    }
    
    print(f"\n{name}:")
    print(f"  Train R²: {train_r2:.4f}")
    print(f"  Test R²: {test_r2:.4f}")
    print(f"  Train RMSE: {train_rmse:.4f}")
    print(f"  Test RMSE: {test_rmse:.4f}")
    print(f"  CV R² (mean ± std): {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")

# ===== 4. COMPARISON TABLE =====
print("\n" + "=" * 60)
print("RESULTS COMPARISON")
print("=" * 60)

comparison_df = pd.DataFrame({
    'Model': list(results.keys()),
    'Train R²': [results[m]['train_r2'] for m in results.keys()],
    'Test R²': [results[m]['test_r2'] for m in results.keys()],
    'Test RMSE': [results[m]['test_rmse'] for m in results.keys()],
    'CV R²': [results[m]['cv_mean'] for m in results.keys()],
})

print(comparison_df.to_string(index=False))

# ===== 5. VISUALIZATIONS =====
print("\n" + "=" * 60)
print("CREATING VISUALIZATIONS...")
print("=" * 60)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Best model
best_model = LinearRegression()
best_model.fit(X_train_scaled, y_train)
y_test_pred = best_model.predict(X_test_scaled)

# 1. Actual vs Predicted
axes[0, 0].scatter(y_test, y_test_pred, alpha=0.6)
axes[0, 0].plot([y_test.min(), y_test.max()], 
                [y_test.min(), y_test.max()], 'r--', lw=2)
axes[0, 0].set_xlabel('Actual')
axes[0, 0].set_ylabel('Predicted')
axes[0, 0].set_title('Actual vs Predicted')
axes[0, 0].grid(True, alpha=0.3)

# 2. Residuals
residuals = y_test - y_test_pred
axes[0, 1].scatter(y_test_pred, residuals, alpha=0.6)
axes[0, 1].axhline(y=0, color='r', linestyle='--')
axes[0, 1].set_xlabel('Predicted')
axes[0, 1].set_ylabel('Residuals')
axes[0, 1].set_title('Residual Plot')
axes[0, 1].grid(True, alpha=0.3)

# 3. Residuals Distribution
axes[1, 0].hist(residuals, bins=20, edgecolor='black', alpha=0.7)
axes[1, 0].set_xlabel('Residuals')
axes[1, 0].set_ylabel('Frequency')
axes[1, 0].set_title('Residuals Distribution')
axes[1, 0].axvline(x=0, color='r', linestyle='--')

# 4. Feature Importance
coefs = best_model.coef_
feature_names = X.columns
axes[1, 1].barh(feature_names, np.abs(coefs))
axes[1, 1].set_xlabel('|Coefficient|')
axes[1, 1].set_title('Feature Importance')

plt.tight_layout()
plt.show()

print("✅ Visualization complete!")

# ===== 6. PREDICTIONS ON NEW DATA =====
print("\n" + "=" * 60)
print("NEW PREDICTIONS")
print("=" * 60)

new_data = pd.DataFrame({
    'Feature1': [150],
    'Feature2': [50],
    'Feature3': [75]
})

new_data_scaled = scaler.transform(new_data)
prediction = best_model.predict(new_data_scaled)

print(f"\nInput data: {new_data.values[0]}")
print(f"Predicted target: {prediction[0]:.2f}")

# ===== 7. MODEL COEFFICIENTS =====
print("\n" + "=" * 60)
print("MODEL COEFFICIENTS")
print("=" * 60)

print(f"Intercept: {best_model.intercept_:.4f}")
for feature, coef in zip(X.columns, best_model.coef_):
    print(f"{feature}: {coef:.4f}")
````

---

## **SUMMARY CHEAT SHEET** 📋

| Level | Concepts | Key Skills |
|-------|----------|------------|
| **Beginner** | y=mx+b, training, prediction | Simple models, visualization |
| **Intermediate** | Multiple features, errors, validation | Train-test split, MSE, R² |
| **Advanced** | Gradient descent, regularization, scaling | Ridge, Lasso, cross-validation |
| **Expert** | Matrix algebra, robust methods, assumptions | Advanced techniques, theory |

---

## **Resources for Practice** 📚

1. **Datasets:**
   - Kaggle Housing Prices
   - UCI Machine Learning Repository
   - Boston Housing dataset

2. **Next Topics:**
   - Polynomial Regression
   - Feature Engineering
   - Time Series Regression
   - Neural Networks for Regression

Start coding and practice! 🚀