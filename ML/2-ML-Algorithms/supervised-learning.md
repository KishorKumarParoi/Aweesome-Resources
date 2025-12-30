# Supervised Learning: Complete Guide (Beginner to Advanced)

## What is Supervised Learning?

Supervised learning is a type of machine learning where the model learns from **labeled data** — input-output pairs where the correct answer is known.

```
Input (Features) → Model → Output (Prediction)
      ↑                         ↓
      └──── Training Data ──────┘ (with known labels)
```

---

## Why Supervised Learning?

| Reason | Explanation |
|--------|-------------|
| **Predictable outcomes** | You know what output to expect |
| **Measurable accuracy** | Can compare predictions vs actual labels |
| **Wide applications** | Spam detection, medical diagnosis, price prediction |
| **Well-established** | Mature algorithms with proven track records |

---

## Types of Supervised Learning

```
Supervised Learning
├── Regression (Continuous output)
│   ├── Linear Regression
│   ├── Polynomial Regression
│   ├── Ridge/Lasso Regression
│   ├── Support Vector Regression
│   └── Decision Tree Regression
│
└── Classification (Discrete output)
    ├── Logistic Regression
    ├── K-Nearest Neighbors (KNN)
    ├── Support Vector Machines (SVM)
    ├── Decision Trees
    ├── Random Forest
    ├── Naive Bayes
    ├── Gradient Boosting (XGBoost, LightGBM)
    └── Neural Networks
```

---

# PART 1: REGRESSION ALGORITHMS

## 1. Linear Regression

### What?
Predicts continuous values by fitting a straight line through data.

### Why?
- Simple and interpretable
- Fast to train
- Good baseline model

### How?
Finds the line that minimizes the sum of squared errors.

**Formula:** `y = mx + b` (or `y = w₀ + w₁x₁ + w₂x₂ + ...`)

````python
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split

# Sample data: House size vs Price
X = np.array([[1000], [1500], [2000], [2500], [3000]])  # Square feet
y = np.array([150000, 200000, 250000, 300000, 350000])   # Price

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model
model = LinearRegression()
model.fit(X_train, y_train)

# Predict
prediction = model.predict([[1800]])
print(f"Predicted price for 1800 sq ft: ${prediction[0]:,.2f}")
print(f"Coefficient (slope): {model.coef_[0]}")
print(f"Intercept: {model.intercept_}")
````

---

## 2. Polynomial Regression

### What?
Extends linear regression to capture non-linear relationships.

### Why?
- Handles curved relationships
- More flexible than linear regression

### How?
Transforms features into polynomial features (x², x³, etc.)

````python
import numpy as np
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.pipeline import Pipeline

# Non-linear data
X = np.array([[1], [2], [3], [4], [5], [6]])
y = np.array([1, 4, 9, 16, 25, 36])  # y = x²

# Create polynomial pipeline
model = Pipeline([
    ('poly', PolynomialFeatures(degree=2)),
    ('linear', LinearRegression())
])

model.fit(X, y)
prediction = model.predict([[7]])
print(f"Prediction for x=7: {prediction[0]}")  # Should be ~49
````

---

## 3. Ridge & Lasso Regression (Regularization)

### What?
Linear regression with penalties to prevent overfitting.

### Why?
- **Ridge (L2):** Shrinks coefficients, keeps all features
- **Lasso (L1):** Can eliminate features (sparse solutions)
- Prevents overfitting on high-dimensional data

### How?
Adds penalty term to loss function.

````python
from sklearn.linear_model import Ridge, Lasso, ElasticNet
from sklearn.datasets import make_regression

# Generate data with many features
X, y = make_regression(n_samples=100, n_features=50, noise=10)

# Ridge Regression (L2 penalty)
ridge = Ridge(alpha=1.0)
ridge.fit(X, y)

# Lasso Regression (L1 penalty)
lasso = Lasso(alpha=1.0)
lasso.fit(X, y)

# ElasticNet (combines L1 + L2)
elastic = ElasticNet(alpha=1.0, l1_ratio=0.5)
elastic.fit(X, y)

print(f"Ridge non-zero coefficients: {np.sum(ridge.coef_ != 0)}")
print(f"Lasso non-zero coefficients: {np.sum(lasso.coef_ != 0)}")  # Fewer!
````

---

## 4. Support Vector Regression (SVR)

### What?
Uses SVM principles for regression by fitting data within a margin.

### Why?
- Effective in high-dimensional spaces
- Robust to outliers
- Works with non-linear data using kernels

### How?
Finds a tube (epsilon) around the data where errors are tolerated.

````python
from sklearn.svm import SVR
from sklearn.preprocessing import StandardScaler
import numpy as np

# Data
X = np.array([[1], [2], [3], [4], [5], [6], [7], [8]])
y = np.array([1, 2.5, 2, 4, 3.5, 5, 5.5, 6])

# Scale features (important for SVR)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Different kernels
svr_linear = SVR(kernel='linear', C=1.0)
svr_rbf = SVR(kernel='rbf', C=1.0, gamma='scale')
svr_poly = SVR(kernel='poly', degree=2, C=1.0)

for name, model in [('Linear', svr_linear), ('RBF', svr_rbf), ('Poly', svr_poly)]:
    model.fit(X_scaled, y)
    print(f"{name} SVR Score: {model.score(X_scaled, y):.3f}")
````

---

# PART 2: CLASSIFICATION ALGORITHMS

## 5. Logistic Regression

### What?
Despite its name, it's a **classification** algorithm that predicts probabilities.

### Why?
- Simple and fast
- Outputs probabilities (0 to 1)
- Great for binary classification

### How?
Uses sigmoid function to map predictions to probabilities.

**Formula:** `P(y=1) = 1 / (1 + e^(-z))` where `z = w₀ + w₁x₁ + ...`

````python
from sklearn.linear_model import LogisticRegression
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report

# Load data
data = load_breast_cancer()
X, y = data.data, data.target

# Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train
model = LogisticRegression(max_iter=10000)
model.fit(X_train, y_train)

# Predict
y_pred = model.predict(X_test)
y_prob = model.predict_proba(X_test)  # Get probabilities

print(f"Accuracy: {accuracy_score(y_test, y_pred):.3f}")
print(f"\nClassification Report:\n{classification_report(y_test, y_pred)}")
````

---

## 6. K-Nearest Neighbors (KNN)

### What?
Classifies based on the majority class of K nearest neighbors.

### Why?
- Intuitive and simple
- No training phase (lazy learner)
- Works for multi-class problems

### How?
Calculates distance to all training points, votes from K nearest.

````python
from sklearn.neighbors import KNeighborsClassifier
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler

# Load data
iris = load_iris()
X, y = iris.data, iris.target

# Scale features (crucial for KNN - distance-based!)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Split
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2)

# Find best K
for k in [1, 3, 5, 7, 9]:
    knn = KNeighborsClassifier(n_neighbors=k)
    scores = cross_val_score(knn, X_train, y_train, cv=5)
    print(f"K={k}: Mean Accuracy = {scores.mean():.3f} (+/- {scores.std()*2:.3f})")

# Final model
best_knn = KNeighborsClassifier(n_neighbors=5)
best_knn.fit(X_train, y_train)
print(f"\nTest Accuracy: {best_knn.score(X_test, y_test):.3f}")
````

---

## 7. Support Vector Machines (SVM)

### What?
Finds the optimal hyperplane that maximizes margin between classes.

### Why?
- Effective in high-dimensional spaces
- Memory efficient (uses support vectors only)
- Versatile with different kernels

### How?
Maximizes the margin (distance) between the decision boundary and nearest points.

````python
from sklearn.svm import SVC
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Generate non-linear data
X, y = make_classification(n_samples=1000, n_features=20, 
                           n_informative=15, n_redundant=5, random_state=42)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Scale (important for SVM!)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Different kernels
kernels = ['linear', 'rbf', 'poly', 'sigmoid']

for kernel in kernels:
    svm = SVC(kernel=kernel, C=1.0, gamma='scale')
    svm.fit(X_train_scaled, y_train)
    accuracy = svm.score(X_test_scaled, y_test)
    print(f"SVM ({kernel}): Accuracy = {accuracy:.3f}")
````

### Kernel Trick Explained:
```
Linear:   K(x,y) = x·y
RBF:      K(x,y) = exp(-γ||x-y||²)  → Most common, handles non-linear
Poly:     K(x,y) = (γx·y + r)^d
Sigmoid:  K(x,y) = tanh(γx·y + r)
```

---

## 8. Decision Trees

### What?
Tree-structured model that makes decisions based on feature thresholds.

### Why?
- Highly interpretable
- No feature scaling needed
- Handles both numerical and categorical data

### How?
Recursively splits data to maximize information gain (minimize impurity).

````python
from sklearn.tree import DecisionTreeClassifier, plot_tree
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt

# Load data
iris = load_iris()
X, y = iris.data, iris.target

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train with different depths
for depth in [2, 4, 6, None]:
    tree = DecisionTreeClassifier(
        max_depth=depth,
        criterion='gini',  # or 'entropy'
        min_samples_split=2,
        min_samples_leaf=1
    )
    tree.fit(X_train, y_train)
    train_acc = tree.score(X_train, y_train)
    test_acc = tree.score(X_test, y_test)
    print(f"Depth={depth}: Train={train_acc:.3f}, Test={test_acc:.3f}")

# Visualize the tree
final_tree = DecisionTreeClassifier(max_depth=3)
final_tree.fit(X_train, y_train)

plt.figure(figsize=(20, 10))
plot_tree(final_tree, feature_names=iris.feature_names, 
          class_names=iris.target_names, filled=True)
plt.savefig('decision_tree.png', dpi=150, bbox_inches='tight')
````

### Impurity Measures:
```
Gini:    G = 1 - Σ(pᵢ²)
Entropy: H = -Σ(pᵢ * log₂(pᵢ))
```

---

## 9. Random Forest (Ensemble)

### What?
Ensemble of decision trees using bagging (Bootstrap Aggregating).

### Why?
- Reduces overfitting compared to single tree
- Handles high-dimensional data well
- Provides feature importance

### How?
Trains multiple trees on random subsets of data and features, then votes.

````python
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_wine
from sklearn.model_selection import train_test_split
import numpy as np

# Load data
wine = load_wine()
X, y = wine.data, wine.target

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train Random Forest
rf = RandomForestClassifier(
    n_estimators=100,      # Number of trees
    max_depth=None,        # Maximum depth of each tree
    min_samples_split=2,   # Minimum samples to split a node
    max_features='sqrt',   # Features to consider for best split
    bootstrap=True,        # Use bootstrap samples
    oob_score=True,        # Out-of-bag score
    n_jobs=-1,             # Use all CPU cores
    random_state=42
)

rf.fit(X_train, y_train)

print(f"Training Accuracy: {rf.score(X_train, y_train):.3f}")
print(f"Test Accuracy: {rf.score(X_test, y_test):.3f}")
print(f"OOB Score: {rf.oob_score_:.3f}")

# Feature Importance
importance = rf.feature_importances_
indices = np.argsort(importance)[::-1]

print("\nTop 5 Important Features:")
for i in range(5):
    print(f"  {wine.feature_names[indices[i]]}: {importance[indices[i]]:.4f}")
````

---

## 10. Naive Bayes

### What?
Probabilistic classifier based on Bayes' theorem with "naive" independence assumption.

### Why?
- Very fast training and prediction
- Works well with high-dimensional data
- Great for text classification

### How?
Applies Bayes' theorem assuming features are independent.

**Formula:** `P(y|X) = P(X|y) * P(y) / P(X)`

````python
from sklearn.naive_bayes import GaussianNB, MultinomialNB, BernoulliNB
from sklearn.datasets import load_digits, fetch_20newsgroups
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

# --- Gaussian Naive Bayes (continuous features) ---
digits = load_digits()
X, y = digits.data, digits.target
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

gnb = GaussianNB()
gnb.fit(X_train, y_train)
print(f"Gaussian NB Accuracy: {gnb.score(X_test, y_test):.3f}")

# --- Multinomial Naive Bayes (text/count data) ---
# Text classification example
categories = ['sci.med', 'sci.space', 'rec.sport.baseball']
newsgroups = fetch_20newsgroups(subset='train', categories=categories)

# Convert text to features
vectorizer = TfidfVectorizer(stop_words='english', max_features=5000)
X_text = vectorizer.fit_transform(newsgroups.data)
y_text = newsgroups.target

X_train, X_test, y_train, y_test = train_test_split(X_text, y_text, test_size=0.2)

mnb = MultinomialNB(alpha=1.0)  # alpha = smoothing parameter
mnb.fit(X_train, y_train)
print(f"Multinomial NB (Text) Accuracy: {mnb.score(X_test, y_test):.3f}")
````

### Types of Naive Bayes:
| Type | Use Case | Feature Distribution |
|------|----------|---------------------|
| Gaussian | Continuous data | Normal distribution |
| Multinomial | Text/count data | Discrete counts |
| Bernoulli | Binary features | Binary (0/1) |

---

## 11. Gradient Boosting (XGBoost, LightGBM, CatBoost)

### What?
Ensemble method that builds trees sequentially, each correcting previous errors.

### Why?
- State-of-the-art performance on tabular data
- Handles missing values
- Built-in regularization

### How?
Each new tree fits the residual errors of the ensemble.

````python
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split

# Try importing advanced libraries
try:
    import xgboost as xgb
    import lightgbm as lgb
    ADVANCED_AVAILABLE = True
except ImportError:
    ADVANCED_AVAILABLE = False
    print("Install xgboost and lightgbm: pip install xgboost lightgbm")

# Generate data
X, y = make_classification(n_samples=10000, n_features=20, 
                           n_informative=15, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Sklearn Gradient Boosting
gb = GradientBoostingClassifier(
    n_estimators=100,
    learning_rate=0.1,
    max_depth=3,
    subsample=0.8,
    random_state=42
)
gb.fit(X_train, y_train)
print(f"Sklearn GradientBoosting: {gb.score(X_test, y_test):.3f}")

if ADVANCED_AVAILABLE:
    # XGBoost
    xgb_model = xgb.XGBClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=3,
        subsample=0.8,
        colsample_bytree=0.8,
        use_label_encoder=False,
        eval_metric='logloss'
    )
    xgb_model.fit(X_train, y_train)
    print(f"XGBoost: {xgb_model.score(X_test, y_test):.3f}")

    # LightGBM
    lgb_model = lgb.LGBMClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=3,
        subsample=0.8,
        colsample_bytree=0.8,
        verbose=-1
    )
    lgb_model.fit(X_train, y_train)
    print(f"LightGBM: {lgb_model.score(X_test, y_test):.3f}")
````

### Comparison:
| Library | Speed | Memory | Categorical Support |
|---------|-------|--------|---------------------|
| XGBoost | Fast | Medium | Manual encoding |
| LightGBM | Fastest | Low | Native support |
| CatBoost | Medium | Medium | Best native support |

---

## 12. Neural Networks (Deep Learning)

### What?
Interconnected layers of neurons that learn hierarchical representations.

### Why?
- Universal function approximators
- Automatic feature learning
- State-of-the-art for complex patterns

### How?
Forward propagation → Loss calculation → Backpropagation → Weight updates

````python
from sklearn.neural_network import MLPClassifier
from sklearn.datasets import load_digits
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Load data
digits = load_digits()
X, y = digits.data, digits.target

# Scale features (crucial for neural networks!)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2)

# Multi-layer Perceptron
mlp = MLPClassifier(
    hidden_layer_sizes=(128, 64, 32),  # 3 hidden layers
    activation='relu',                  # ReLU activation
    solver='adam',                      # Optimizer
    alpha=0.0001,                       # L2 regularization
    batch_size=32,
    learning_rate='adaptive',
    max_iter=500,
    early_stopping=True,
    validation_fraction=0.1,
    random_state=42
)

mlp.fit(X_train, y_train)
print(f"MLP Accuracy: {mlp.score(X_test, y_test):.3f}")
print(f"Number of iterations: {mlp.n_iter_}")
````

### PyTorch Deep Learning Example:
````python
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset
from sklearn.datasets import load_digits
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Load and prepare data
digits = load_digits()
X, y = digits.data, digits.target

scaler = StandardScaler()
X = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Convert to PyTorch tensors
X_train_t = torch.FloatTensor(X_train)
y_train_t = torch.LongTensor(y_train)
X_test_t = torch.FloatTensor(X_test)
y_test_t = torch.LongTensor(y_test)

# DataLoader
train_dataset = TensorDataset(X_train_t, y_train_t)
train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)

# Define Network
class NeuralNet(nn.Module):
    def __init__(self, input_size, hidden_sizes, num_classes):
        super(NeuralNet, self).__init__()
        layers = []
        prev_size = input_size
        
        for hidden_size in hidden_sizes:
            layers.append(nn.Linear(prev_size, hidden_size))
            layers.append(nn.ReLU())
            layers.append(nn.Dropout(0.2))
            prev_size = hidden_size
        
        layers.append(nn.Linear(prev_size, num_classes))
        self.network = nn.Sequential(*layers)
    
    def forward(self, x):
        return self.network(x)

# Initialize model
model = NeuralNet(input_size=64, hidden_sizes=[128, 64, 32], num_classes=10)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

# Training loop
epochs = 50
for epoch in range(epochs):
    model.train()
    for batch_X, batch_y in train_loader:
        optimizer.zero_grad()
        outputs = model(batch_X)
        loss = criterion(outputs, batch_y)
        loss.backward()
        optimizer.step()
    
    if (epoch + 1) % 10 == 0:
        model.eval()
        with torch.no_grad():
            outputs = model(X_test_t)
            _, predicted = torch.max(outputs, 1)
            accuracy = (predicted == y_test_t).sum().item() / len(y_test_t)
            print(f"Epoch [{epoch+1}/{epochs}], Accuracy: {accuracy:.3f}")
````

---

# PART 3: ADVANCED CONCEPTS

## Model Selection & Hyperparameter Tuning

````python
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV, cross_val_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_breast_cancer
import numpy as np

# Load data
X, y = load_breast_cancer(return_X_y=True)

# --- Grid Search ---
param_grid = {
    'n_estimators': [50, 100, 200],
    'max_depth': [3, 5, 10, None],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4]
}

rf = RandomForestClassifier(random_state=42)

grid_search = GridSearchCV(
    estimator=rf,
    param_grid=param_grid,
    cv=5,
    scoring='accuracy',
    n_jobs=-1,
    verbose=1
)

grid_search.fit(X, y)

print(f"Best Parameters: {grid_search.best_params_}")
print(f"Best CV Score: {grid_search.best_score_:.3f}")

# --- Randomized Search (faster for large param spaces) ---
param_distributions = {
    'n_estimators': np.arange(50, 500, 50),
    'max_depth': [3, 5, 10, 15, 20, None],
    'min_samples_split': np.arange(2, 20),
    'min_samples_leaf': np.arange(1, 10)
}

random_search = RandomizedSearchCV(
    estimator=rf,
    param_distributions=param_distributions,
    n_iter=50,  # Number of random combinations to try
    cv=5,
    scoring='accuracy',
    n_jobs=-1,
    random_state=42
)

random_search.fit(X, y)
print(f"\nRandomized Search Best Score: {random_search.best_score_:.3f}")
````

---

## Handling Imbalanced Data

````python
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix
from imblearn.over_sampling import SMOTE, ADASYN
from imblearn.under_sampling import RandomUnderSampler
from imblearn.combine import SMOTETomek

# Create imbalanced dataset
X, y = make_classification(n_samples=10000, n_classes=2, weights=[0.95, 0.05],
                           n_features=20, n_informative=15, random_state=42)

print(f"Class distribution: {np.bincount(y)}")

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, stratify=y)

# --- Method 1: Class weights ---
rf_weighted = RandomForestClassifier(class_weight='balanced', random_state=42)
rf_weighted.fit(X_train, y_train)

# --- Method 2: SMOTE (Synthetic Minority Over-sampling) ---
smote = SMOTE(random_state=42)
X_train_smote, y_train_smote = smote.fit_resample(X_train, y_train)

rf_smote = RandomForestClassifier(random_state=42)
rf_smote.fit(X_train_smote, y_train_smote)

# Compare
for name, model in [('Weighted', rf_weighted), ('SMOTE', rf_smote)]:
    y_pred = model.predict(X_test)
    print(f"\n{name} Model:")
    print(classification_report(y_test, y_pred))
````

---

## Feature Engineering & Selection

````python
from sklearn.feature_selection import (
    SelectKBest, f_classif, mutual_info_classif,
    RFE, SelectFromModel
)
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_breast_cancer
import numpy as np

# Load data
data = load_breast_cancer()
X, y = data.data, data.target

# --- Method 1: Univariate Selection ---
selector_univariate = SelectKBest(score_func=f_classif, k=10)
X_univariate = selector_univariate.fit_transform(X, y)
selected_features = np.array(data.feature_names)[selector_univariate.get_support()]
print(f"Univariate Selection: {selected_features}")

# --- Method 2: Recursive Feature Elimination (RFE) ---
rf = RandomForestClassifier(n_estimators=100, random_state=42)
rfe = RFE(estimator=rf, n_features_to_select=10, step=1)
X_rfe = rfe.fit_transform(X, y)
rfe_features = np.array(data.feature_names)[rfe.support_]
print(f"\nRFE Selection: {rfe_features}")

# --- Method 3: Feature Importance based selection ---
rf.fit(X, y)
selector_model = SelectFromModel(rf, prefit=True, threshold='median')
X_model = selector_model.transform(X)
print(f"\nModel-based Selection: {X_model.shape[1]} features selected")
````

---

## Cross-Validation Strategies

````python
from sklearn.model_selection import (
    KFold, StratifiedKFold, LeaveOneOut, TimeSeriesSplit,
    cross_val_score, cross_validate
)
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_iris

X, y = load_iris(return_X_y=True)
model = RandomForestClassifier(random_state=42)

# --- K-Fold ---
kfold = KFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(model, X, y, cv=kfold)
print(f"K-Fold: {scores.mean():.3f} (+/- {scores.std()*2:.3f})")

# --- Stratified K-Fold (maintains class proportions) ---
stratified = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(model, X, y, cv=stratified)
print(f"Stratified K-Fold: {scores.mean():.3f} (+/- {scores.std()*2:.3f})")

# --- Multiple metrics ---
results = cross_validate(
    model, X, y, cv=5,
    scoring=['accuracy', 'precision_macro', 'recall_macro', 'f1_macro'],
    return_train_score=True
)

print("\nMultiple Metrics:")
for metric in ['accuracy', 'precision_macro', 'recall_macro', 'f1_macro']:
    print(f"  {metric}: {results[f'test_{metric}'].mean():.3f}")
````

---

## Evaluation Metrics Summary

| Metric | Formula | Use Case |
|--------|---------|----------|
| **Accuracy** | (TP+TN)/(TP+TN+FP+FN) | Balanced classes |
| **Precision** | TP/(TP+FP) | Minimize false positives |
| **Recall** | TP/(TP+FN) | Minimize false negatives |
| **F1 Score** | 2*(P*R)/(P+R) | Balance precision & recall |
| **ROC-AUC** | Area under ROC curve | Overall discriminative ability |
| **MSE** | Mean(y-ŷ)² | Regression |
| **MAE** | Mean|y-ŷ| | Regression (robust to outliers) |
| **R²** | 1 - SS_res/SS_tot | Regression (variance explained) |

---

## Complete Pipeline Example

````python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, GridSearchCV
import pandas as pd
import numpy as np

# Create sample dataset with mixed types
np.random.seed(42)
data = pd.DataFrame({
    'age': np.random.randint(18, 80, 1000),
    'income': np.random.randint(20000, 150000, 1000),
    'credit_score': np.random.randint(300, 850, 1000),
    'gender': np.random.choice(['M', 'F'], 1000),
    'education': np.random.choice(['High School', 'Bachelor', 'Master', 'PhD'], 1000),
    'approved': np.random.randint(0, 2, 1000)
})

# Add some missing values
data.loc[np.random.choice(1000, 50), 'income'] = np.nan
data.loc[np.random.choice(1000, 30), 'education'] = np.nan

X = data.drop('approved', axis=1)
y = data['approved']

# Define column types
numeric_features = ['age', 'income', 'credit_score']
categorical_features = ['gender', 'education']

# Preprocessing pipelines
numeric_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

categorical_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('encoder', OneHotEncoder(handle_unknown='ignore'))
])

# Combine transformers
preprocessor = ColumnTransformer([
    ('num', numeric_transformer, numeric_features),
    ('cat', categorical_transformer, categorical_features)
])

# Full pipeline
pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('feature_selection', SelectKBest(f_classif, k=5)),
    ('classifier', RandomForestClassifier(random_state=42))
])

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Hyperparameter tuning
param_grid = {
    'feature_selection__k': [3, 5, 7],
    'classifier__n_estimators': [50, 100, 200],
    'classifier__max_depth': [3, 5, 10]
}

grid_search = GridSearchCV(pipeline, param_grid, cv=5, scoring='accuracy', n_jobs=-1)
grid_search.fit(X_train, y_train)

print(f"Best Parameters: {grid_search.best_params_}")
print(f"Best CV Score: {grid_search.best_score_:.3f}")
print(f"Test Score: {grid_search.score(X_test, y_test):.3f}")
````

---

## Algorithm Selection Cheat Sheet

```
                        START
                          │
                          ▼
              ┌─── Is target continuous? ───┐
              │                             │
             YES                           NO
              │                             │
              ▼                             ▼
         REGRESSION                  CLASSIFICATION
              │                             │
              ▼                             ▼
    ┌── Linear relationship? ──┐   ┌── # of classes? ──┐
    │                         │    │                   │
   YES                       NO    2                  >2
    │                         │    │                   │
    ▼                         ▼    ▼                   ▼
Linear/Ridge              Tree-based  Binary        Multi-class
Regression                  or SVR    (Logistic)   (Softmax/OvR)
                                          │             │
                                          └──────┬──────┘
                                                 ▼
                                    ┌─── Data size? ───┐
                                    │                  │
                                 Small             Large
                                    │                  │
                                    ▼                  ▼
                              SVM, KNN          Gradient Boosting
                              Naive Bayes       Neural Networks
                              Random Forest
```

---

## Summary Table

| Algorithm | Type | Pros | Cons | Best For |
|-----------|------|------|------|----------|
| Linear Regression | Regression | Simple, fast | Only linear | Baseline |
| Logistic Regression | Classification | Probabilistic | Linear boundary | Binary classification |
| KNN | Both | Simple, no training | Slow prediction | Small datasets |
| SVM | Both | Effective in high-dim | Slow on large data | High-dimensional |
| Decision Tree | Both | Interpretable | Overfits easily | Explainability |
| Random Forest | Both | Robust, accurate | Less interpretable | General purpose |
| Gradient Boosting | Both | Best accuracy | Can overfit, slow | Competitions |
| Naive Bayes | Classification | Very fast | Independence assumption | Text classification |
| Neural Networks | Both | Universal | Needs lots of data | Complex patterns |

---

This comprehensive guide covers all major supervised learning algorithms from beginner to advanced levels. Would you like me to elaborate on any specific topic or create additional examples?