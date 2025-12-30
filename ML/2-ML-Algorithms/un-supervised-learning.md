# Unsupervised Learning: Complete Guide (Beginner to Advanced)

## What is Unsupervised Learning?

Unsupervised learning is a type of machine learning where algorithms learn patterns from **unlabeled data** — data without predefined categories or outcomes.

| Supervised Learning | Unsupervised Learning |
|---------------------|----------------------|
| Has labels (X → Y) | No labels (X only) |
| Predicts outcomes | Discovers structure |
| Classification/Regression | Clustering/Dimensionality Reduction |

---

## Why Use Unsupervised Learning?

1. **Real-world data is mostly unlabeled** — labeling is expensive and time-consuming
2. **Discover hidden patterns** — find structures humans might miss
3. **Data preprocessing** — reduce dimensions, detect anomalies before supervised learning
4. **Customer segmentation** — group users without predefined categories
5. **Anomaly detection** — fraud detection, network intrusion

---

## Types of Unsupervised Learning

```
Unsupervised Learning
├── 1. Clustering
│   ├── Partition-based (K-Means, K-Medoids)
│   ├── Hierarchical (Agglomerative, Divisive)
│   ├── Density-based (DBSCAN, OPTICS, HDBSCAN)
│   ├── Distribution-based (Gaussian Mixture Models)
│   └── Graph-based (Spectral Clustering)
├── 2. Dimensionality Reduction
│   ├── Linear (PCA, SVD, LDA)
│   └── Non-linear (t-SNE, UMAP, Autoencoders)
├── 3. Association Rule Learning
│   └── Apriori, FP-Growth
├── 4. Anomaly Detection
│   └── Isolation Forest, One-Class SVM, LOF
└── 5. Self-Supervised Learning
    └── Contrastive Learning, Autoencoders
```

---

## 1. CLUSTERING

### 1.1 K-Means Clustering (Beginner)

**What?** Partitions data into K clusters by minimizing within-cluster variance.

**Why?** Simple, fast, works well with spherical clusters.

**How?**
1. Choose K (number of clusters)
2. Initialize K centroids randomly
3. Assign each point to nearest centroid
4. Update centroids as mean of assigned points
5. Repeat until convergence

````python
import numpy as np
from sklearn.cluster import KMeans
from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt

# Generate sample data
X, y_true = make_blobs(n_samples=300, centers=4, cluster_std=0.60, random_state=42)

# Apply K-Means
kmeans = KMeans(n_clusters=4, random_state=42, n_init=10)
y_pred = kmeans.fit_predict(X)

# Visualize
plt.scatter(X[:, 0], X[:, 1], c=y_pred, cmap='viridis')
plt.scatter(kmeans.cluster_centers_[:, 0], kmeans.cluster_centers_[:, 1], 
            s=300, c='red', marker='X', label='Centroids')
plt.title('K-Means Clustering')
plt.legend()
plt.show()

# Finding optimal K using Elbow Method
inertias = []
K_range = range(1, 11)
for k in K_range:
    km = KMeans(n_clusters=k, random_state=42, n_init=10)
    km.fit(X)
    inertias.append(km.inertia_)

plt.plot(K_range, inertias, 'bo-')
plt.xlabel('Number of clusters (K)')
plt.ylabel('Inertia')
plt.title('Elbow Method')
plt.show()
````

**Limitations:**
- Must specify K in advance
- Sensitive to initialization
- Assumes spherical clusters
- Sensitive to outliers

---

### 1.2 K-Medoids (PAM) (Intermediate)

**What?** Like K-Means but uses actual data points (medoids) as centers.

**Why?** More robust to outliers than K-Means.

````python
from sklearn_extra.cluster import KMedoids
import numpy as np

X = np.array([[1, 2], [1, 4], [1, 0], [10, 2], [10, 4], [10, 0], [50, 50]])  # outlier

kmedoids = KMedoids(n_clusters=2, random_state=42)
labels = kmedoids.fit_predict(X)

print(f"Medoid indices: {kmedoids.medoid_indices_}")
print(f"Labels: {labels}")
````

---

### 1.3 Hierarchical Clustering (Intermediate)

**What?** Builds a tree (dendrogram) of clusters through successive merging or splitting.

**Why?** No need to specify K upfront; provides hierarchical structure.

**Types:**
- **Agglomerative (Bottom-up):** Start with each point as cluster, merge closest
- **Divisive (Top-down):** Start with one cluster, split recursively

**Linkage Methods:**
- **Single:** Min distance between clusters
- **Complete:** Max distance
- **Average:** Mean distance
- **Ward:** Minimizes variance increase

````python
import numpy as np
from scipy.cluster.hierarchy import dendrogram, linkage, fcluster
from sklearn.cluster import AgglomerativeClustering
import matplotlib.pyplot as plt

# Generate data
np.random.seed(42)
X = np.vstack([
    np.random.randn(30, 2) + [0, 0],
    np.random.randn(30, 2) + [5, 5],
    np.random.randn(30, 2) + [10, 0]
])

# Method 1: Using scipy for dendrogram
Z = linkage(X, method='ward')

plt.figure(figsize=(12, 5))
plt.subplot(1, 2, 1)
dendrogram(Z, truncate_mode='lastp', p=12)
plt.title('Dendrogram')
plt.xlabel('Cluster Size')
plt.ylabel('Distance')

# Method 2: Using sklearn
agg = AgglomerativeClustering(n_clusters=3, linkage='ward')
labels = agg.fit_predict(X)

plt.subplot(1, 2, 2)
plt.scatter(X[:, 0], X[:, 1], c=labels, cmap='viridis')
plt.title('Agglomerative Clustering')
plt.tight_layout()
plt.show()
````

---

### 1.4 DBSCAN (Intermediate-Advanced)

**What?** Density-Based Spatial Clustering of Applications with Noise.

**Why?** 
- Discovers clusters of arbitrary shapes
- Automatically detects outliers
- No need to specify number of clusters

**Parameters:**
- `eps`: Maximum distance between two points in same neighborhood
- `min_samples`: Minimum points to form a dense region

````python
import numpy as np
from sklearn.cluster import DBSCAN
from sklearn.datasets import make_moons, make_blobs
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# Generate non-spherical data
X_moons, _ = make_moons(n_samples=300, noise=0.05, random_state=42)
X_moons = StandardScaler().fit_transform(X_moons)

# DBSCAN
dbscan = DBSCAN(eps=0.3, min_samples=5)
labels = dbscan.fit_predict(X_moons)

# Identify core samples, outliers
core_samples_mask = np.zeros_like(labels, dtype=bool)
core_samples_mask[dbscan.core_sample_indices_] = True

n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
n_noise = list(labels).count(-1)

print(f"Estimated clusters: {n_clusters}")
print(f"Noise points: {n_noise}")

# Visualize
plt.figure(figsize=(10, 4))

plt.subplot(1, 2, 1)
plt.scatter(X_moons[:, 0], X_moons[:, 1])
plt.title('Original Data')

plt.subplot(1, 2, 2)
plt.scatter(X_moons[:, 0], X_moons[:, 1], c=labels, cmap='viridis')
plt.title(f'DBSCAN (clusters={n_clusters}, noise={n_noise})')
plt.tight_layout()
plt.show()

# Finding optimal eps using k-distance graph
from sklearn.neighbors import NearestNeighbors

neighbors = NearestNeighbors(n_neighbors=5)
neighbors_fit = neighbors.fit(X_moons)
distances, indices = neighbors_fit.kneighbors(X_moons)
distances = np.sort(distances[:, -1])

plt.plot(distances)
plt.xlabel('Points')
plt.ylabel('5th Nearest Neighbor Distance')
plt.title('K-Distance Graph (Elbow = eps)')
plt.show()
````

---

### 1.5 HDBSCAN (Advanced)

**What?** Hierarchical DBSCAN — extends DBSCAN with hierarchical clustering.

**Why?** 
- Handles varying density clusters
- More robust parameter selection
- Provides cluster stability scores

````python
import hdbscan
import numpy as np
from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt

# Create data with varying densities
X1, _ = make_blobs(n_samples=200, centers=1, cluster_std=0.5, center_box=(-5, -5))
X2, _ = make_blobs(n_samples=100, centers=1, cluster_std=2.0, center_box=(5, 5))
X = np.vstack([X1, X2])

# HDBSCAN
clusterer = hdbscan.HDBSCAN(min_cluster_size=15, gen_min_span_tree=True)
labels = clusterer.fit_predict(X)

# Cluster probabilities (soft clustering)
print(f"Cluster probabilities shape: {clusterer.probabilities_.shape}")
print(f"Number of clusters: {len(set(labels)) - (1 if -1 in labels else 0)}")

# Visualize
plt.scatter(X[:, 0], X[:, 1], c=labels, cmap='viridis', alpha=0.7)
plt.title('HDBSCAN Clustering')
plt.colorbar(label='Cluster')
plt.show()

# Condensed tree visualization
clusterer.condensed_tree_.plot(select_clusters=True)
plt.title('Condensed Tree')
plt.show()
````

---

### 1.6 Gaussian Mixture Models (GMM) (Advanced)

**What?** Probabilistic model assuming data comes from mixture of Gaussian distributions.

**Why?**
- Soft clustering (probabilistic assignments)
- Can model elliptical clusters
- Provides uncertainty estimates

**How?** Uses Expectation-Maximization (EM) algorithm.

````python
import numpy as np
from sklearn.mixture import GaussianMixture
from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt

# Generate data
X, y_true = make_blobs(n_samples=400, centers=4, cluster_std=0.60, random_state=42)

# Fit GMM
gmm = GaussianMixture(n_components=4, covariance_type='full', random_state=42)
gmm.fit(X)

# Hard predictions
labels = gmm.predict(X)

# Soft predictions (probabilities)
probs = gmm.predict_proba(X)
print(f"Probability of first point belonging to each cluster:\n{probs[0]}")

# Model selection using BIC/AIC
n_components_range = range(1, 10)
bics = []
aics = []

for n in n_components_range:
    gm = GaussianMixture(n_components=n, random_state=42)
    gm.fit(X)
    bics.append(gm.bic(X))
    aics.append(gm.aic(X))

plt.figure(figsize=(12, 4))

plt.subplot(1, 2, 1)
plt.scatter(X[:, 0], X[:, 1], c=labels, cmap='viridis')
plt.title('GMM Clustering')

plt.subplot(1, 2, 2)
plt.plot(n_components_range, bics, 'b-', label='BIC')
plt.plot(n_components_range, aics, 'r-', label='AIC')
plt.xlabel('Number of Components')
plt.ylabel('Score')
plt.legend()
plt.title('Model Selection')
plt.tight_layout()
plt.show()

# Covariance types comparison
cov_types = ['spherical', 'diag', 'tied', 'full']
for cov_type in cov_types:
    gm = GaussianMixture(n_components=4, covariance_type=cov_type, random_state=42)
    gm.fit(X)
    print(f"{cov_type}: BIC={gm.bic(X):.2f}")
````

---

### 1.7 Spectral Clustering (Advanced)

**What?** Uses eigenvalues of similarity matrix for dimensionality reduction before clustering.

**Why?** Can identify non-convex clusters by leveraging graph structure.

````python
import numpy as np
from sklearn.cluster import SpectralClustering, KMeans
from sklearn.datasets import make_circles
import matplotlib.pyplot as plt

# Generate concentric circles (K-Means fails here)
X, y = make_circles(n_samples=500, noise=0.05, factor=0.5, random_state=42)

fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Original data
axes[0].scatter(X[:, 0], X[:, 1])
axes[0].set_title('Original Data')

# K-Means (fails)
kmeans = KMeans(n_clusters=2, random_state=42)
labels_km = kmeans.fit_predict(X)
axes[1].scatter(X[:, 0], X[:, 1], c=labels_km, cmap='viridis')
axes[1].set_title('K-Means (Fails)')

# Spectral Clustering (works!)
spectral = SpectralClustering(n_clusters=2, affinity='rbf', gamma=10, random_state=42)
labels_sp = spectral.fit_predict(X)
axes[2].scatter(X[:, 0], X[:, 1], c=labels_sp, cmap='viridis')
axes[2].set_title('Spectral Clustering (Works!)')

plt.tight_layout()
plt.show()
````

---

## 2. DIMENSIONALITY REDUCTION

### 2.1 Principal Component Analysis (PCA) (Beginner)

**What?** Linear technique that projects data onto principal components (directions of maximum variance).

**Why?**
- Reduce dimensions while preserving variance
- Remove multicollinearity
- Visualization of high-dimensional data
- Speed up other algorithms

**How?**
1. Standardize the data
2. Compute covariance matrix
3. Calculate eigenvectors and eigenvalues
4. Select top k eigenvectors
5. Transform data

````python
import numpy as np
from sklearn.decomposition import PCA
from sklearn.datasets import load_iris
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# Load data
iris = load_iris()
X = iris.data
y = iris.target

# Standardize
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# PCA
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_scaled)

print(f"Original shape: {X.shape}")
print(f"Reduced shape: {X_pca.shape}")
print(f"Explained variance ratio: {pca.explained_variance_ratio_}")
print(f"Total variance explained: {sum(pca.explained_variance_ratio_):.2%}")

# Visualize
plt.figure(figsize=(12, 4))

plt.subplot(1, 2, 1)
plt.scatter(X_pca[:, 0], X_pca[:, 1], c=y, cmap='viridis')
plt.xlabel('PC1')
plt.ylabel('PC2')
plt.title('PCA of Iris Dataset')
plt.colorbar()

# Explained variance plot
plt.subplot(1, 2, 2)
pca_full = PCA()
pca_full.fit(X_scaled)
cumsum = np.cumsum(pca_full.explained_variance_ratio_)
plt.plot(range(1, len(cumsum) + 1), cumsum, 'bo-')
plt.axhline(y=0.95, color='r', linestyle='--', label='95% threshold')
plt.xlabel('Number of Components')
plt.ylabel('Cumulative Explained Variance')
plt.legend()
plt.title('Choosing Number of Components')

plt.tight_layout()
plt.show()

# PCA from scratch
class PCAFromScratch:
    def __init__(self, n_components):
        self.n_components = n_components
        
    def fit_transform(self, X):
        # Center the data
        self.mean = np.mean(X, axis=0)
        X_centered = X - self.mean
        
        # Covariance matrix
        cov_matrix = np.cov(X_centered.T)
        
        # Eigendecomposition
        eigenvalues, eigenvectors = np.linalg.eig(cov_matrix)
        
        # Sort by eigenvalues
        idx = eigenvalues.argsort()[::-1]
        eigenvalues = eigenvalues[idx]
        eigenvectors = eigenvectors[:, idx]
        
        # Select top k components
        self.components = eigenvectors[:, :self.n_components]
        self.explained_variance_ratio = eigenvalues[:self.n_components] / eigenvalues.sum()
        
        return X_centered @ self.components

# Test from scratch implementation
pca_scratch = PCAFromScratch(n_components=2)
X_pca_scratch = pca_scratch.fit_transform(X_scaled)
print(f"\nFrom scratch variance ratio: {pca_scratch.explained_variance_ratio}")
````

---

### 2.2 Singular Value Decomposition (SVD) (Intermediate)

**What?** Matrix factorization: A = UΣV^T

**Why?**
- More numerically stable than PCA
- Works with sparse matrices (TruncatedSVD)
- Used in recommender systems, LSA

````python
import numpy as np
from sklearn.decomposition import TruncatedSVD
from sklearn.feature_extraction.text import TfidfVectorizer

# Example: Latent Semantic Analysis for text
documents = [
    "Machine learning is great",
    "Deep learning is a subset of machine learning",
    "Natural language processing uses machine learning",
    "Computer vision is another AI field",
    "Neural networks power deep learning",
    "AI and machine learning are transforming industries"
]

# Create TF-IDF matrix
vectorizer = TfidfVectorizer()
X_tfidf = vectorizer.fit_transform(documents)

print(f"TF-IDF shape: {X_tfidf.shape}")

# Apply Truncated SVD (LSA)
svd = TruncatedSVD(n_components=2, random_state=42)
X_lsa = svd.fit_transform(X_tfidf)

print(f"LSA shape: {X_lsa.shape}")
print(f"Explained variance: {svd.explained_variance_ratio_.sum():.2%}")

# Visualize document similarity
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 6))
plt.scatter(X_lsa[:, 0], X_lsa[:, 1])
for i, doc in enumerate(documents):
    plt.annotate(f"Doc {i}", (X_lsa[i, 0], X_lsa[i, 1]))
plt.xlabel('Component 1')
plt.ylabel('Component 2')
plt.title('Document Similarity (LSA)')
plt.show()
````

---

### 2.3 t-SNE (Advanced)

**What?** t-Distributed Stochastic Neighbor Embedding — non-linear technique for visualization.

**Why?**
- Excellent for 2D/3D visualization
- Preserves local structure
- Reveals clusters in high-dimensional data

**Limitations:**
- Computationally expensive
- Non-deterministic
- Not suitable for new data points
- Perplexity parameter sensitive

````python
import numpy as np
from sklearn.manifold import TSNE
from sklearn.datasets import load_digits
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# Load digits dataset (64 dimensions)
digits = load_digits()
X = digits.data
y = digits.target

# Standardize
X_scaled = StandardScaler().fit_transform(X)

# t-SNE
tsne = TSNE(n_components=2, perplexity=30, n_iter=1000, random_state=42)
X_tsne = tsne.fit_transform(X_scaled)

# Compare with PCA
from sklearn.decomposition import PCA
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_scaled)

# Visualize
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

scatter1 = axes[0].scatter(X_pca[:, 0], X_pca[:, 1], c=y, cmap='tab10', alpha=0.7)
axes[0].set_title('PCA')
axes[0].set_xlabel('PC1')
axes[0].set_ylabel('PC2')

scatter2 = axes[1].scatter(X_tsne[:, 0], X_tsne[:, 1], c=y, cmap='tab10', alpha=0.7)
axes[1].set_title('t-SNE')
axes[1].set_xlabel('Dimension 1')
axes[1].set_ylabel('Dimension 2')

plt.colorbar(scatter2, ax=axes[1], label='Digit')
plt.tight_layout()
plt.show()

# Perplexity comparison
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
perplexities = [5, 30, 50, 100]

for ax, perp in zip(axes.flat, perplexities):
    tsne = TSNE(n_components=2, perplexity=perp, random_state=42)
    X_embedded = tsne.fit_transform(X_scaled)
    ax.scatter(X_embedded[:, 0], X_embedded[:, 1], c=y, cmap='tab10', alpha=0.7)
    ax.set_title(f'Perplexity = {perp}')

plt.tight_layout()
plt.show()
````

---

### 2.4 UMAP (Advanced)

**What?** Uniform Manifold Approximation and Projection — modern alternative to t-SNE.

**Why?**
- Faster than t-SNE
- Better preserves global structure
- Can transform new data points
- Works for general dimensionality reduction (not just visualization)

````python
import numpy as np
import umap
from sklearn.datasets import load_digits
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# Load data
digits = load_digits()
X = digits.data
y = digits.target

# UMAP
reducer = umap.UMAP(n_neighbors=15, min_dist=0.1, n_components=2, random_state=42)
X_umap = reducer.fit_transform(X)

# Visualize
plt.figure(figsize=(10, 8))
scatter = plt.scatter(X_umap[:, 0], X_umap[:, 1], c=y, cmap='tab10', alpha=0.7)
plt.colorbar(scatter, label='Digit')
plt.title('UMAP of Digits Dataset')
plt.xlabel('UMAP 1')
plt.ylabel('UMAP 2')
plt.show()

# Parameter exploration
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
params = [
    {'n_neighbors': 5, 'min_dist': 0.1},
    {'n_neighbors': 50, 'min_dist': 0.1},
    {'n_neighbors': 15, 'min_dist': 0.01},
    {'n_neighbors': 15, 'min_dist': 0.5}
]

for ax, param in zip(axes.flat, params):
    reducer = umap.UMAP(**param, random_state=42)
    embedding = reducer.fit_transform(X)
    ax.scatter(embedding[:, 0], embedding[:, 1], c=y, cmap='tab10', alpha=0.5, s=5)
    ax.set_title(f"n_neighbors={param['n_neighbors']}, min_dist={param['min_dist']}")

plt.tight_layout()
plt.show()

# UMAP for supervised dimensionality reduction
reducer_supervised = umap.UMAP(n_neighbors=15, min_dist=0.1, random_state=42)
X_umap_supervised = reducer_supervised.fit_transform(X, y)  # Uses labels!

plt.figure(figsize=(10, 8))
plt.scatter(X_umap_supervised[:, 0], X_umap_supervised[:, 1], c=y, cmap='tab10', alpha=0.7)
plt.title('Supervised UMAP')
plt.show()
````

---

### 2.5 Autoencoders (Advanced)

**What?** Neural networks that learn compressed representations by encoding and reconstructing data.

**Why?**
- Non-linear dimensionality reduction
- Feature learning
- Anomaly detection
- Generative models (VAE)

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from sklearn.datasets import load_digits
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
import matplotlib.pyplot as plt

# Load and preprocess data
digits = load_digits()
X = digits.data
y = digits.target

scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

# Build Autoencoder
input_dim = X_train.shape[1]  # 64
encoding_dim = 2  # Compressed to 2D for visualization

# Encoder
encoder_input = keras.Input(shape=(input_dim,))
x = layers.Dense(32, activation='relu')(encoder_input)
x = layers.Dense(16, activation='relu')(x)
encoded = layers.Dense(encoding_dim, activation='linear', name='bottleneck')(x)

# Decoder
x = layers.Dense(16, activation='relu')(encoded)
x = layers.Dense(32, activation='relu')(x)
decoded = layers.Dense(input_dim, activation='sigmoid')(x)

# Models
autoencoder = keras.Model(encoder_input, decoded)
encoder = keras.Model(encoder_input, encoded)

# Compile and train
autoencoder.compile(optimizer='adam', loss='mse')
history = autoencoder.fit(
    X_train, X_train,
    epochs=100,
    batch_size=32,
    validation_data=(X_test, X_test),
    verbose=0
)

# Encode test data
X_encoded = encoder.predict(X_test)

# Visualize
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Training loss
axes[0].plot(history.history['loss'], label='Train')
axes[0].plot(history.history['val_loss'], label='Validation')
axes[0].set_xlabel('Epoch')
axes[0].set_ylabel('Loss')
axes[0].set_title('Training History')
axes[0].legend()

# Latent space
scatter = axes[1].scatter(X_encoded[:, 0], X_encoded[:, 1], c=y_test, cmap='tab10', alpha=0.7)
axes[1].set_xlabel('Latent Dim 1')
axes[1].set_ylabel('Latent Dim 2')
axes[1].set_title('Autoencoder Latent Space')
plt.colorbar(scatter, ax=axes[1])

# Reconstruction
reconstructed = autoencoder.predict(X_test[:10])
for i in range(10):
    axes[2].imshow(np.hstack([
        X_test[i].reshape(8, 8),
        reconstructed[i].reshape(8, 8)
    ]), cmap='gray')
axes[2].set_title('Original | Reconstructed')
axes[2].axis('off')

plt.tight_layout()
plt.show()

# Variational Autoencoder (VAE)
class Sampling(layers.Layer):
    def call(self, inputs):
        z_mean, z_log_var = inputs
        batch = tf.shape(z_mean)[0]
        dim = tf.shape(z_mean)[1]
        epsilon = tf.random.normal(shape=(batch, dim))
        return z_mean + tf.exp(0.5 * z_log_var) * epsilon

# VAE Encoder
latent_dim = 2
vae_encoder_input = keras.Input(shape=(input_dim,))
x = layers.Dense(32, activation='relu')(vae_encoder_input)
x = layers.Dense(16, activation='relu')(x)
z_mean = layers.Dense(latent_dim, name='z_mean')(x)
z_log_var = layers.Dense(latent_dim, name='z_log_var')(x)
z = Sampling()([z_mean, z_log_var])

vae_encoder = keras.Model(vae_encoder_input, [z_mean, z_log_var, z], name='encoder')

# VAE Decoder
latent_inputs = keras.Input(shape=(latent_dim,))
x = layers.Dense(16, activation='relu')(latent_inputs)
x = layers.Dense(32, activation='relu')(x)
decoder_outputs = layers.Dense(input_dim, activation='sigmoid')(x)

vae_decoder = keras.Model(latent_inputs, decoder_outputs, name='decoder')

# VAE Model
class VAE(keras.Model):
    def __init__(self, encoder, decoder, **kwargs):
        super().__init__(**kwargs)
        self.encoder = encoder
        self.decoder = decoder
        
    def call(self, inputs):
        z_mean, z_log_var, z = self.encoder(inputs)
        reconstructed = self.decoder(z)
        
        # KL divergence
        kl_loss = -0.5 * tf.reduce_mean(
            z_log_var - tf.square(z_mean) - tf.exp(z_log_var) + 1
        )
        self.add_loss(kl_loss)
        return reconstructed

vae = VAE(vae_encoder, vae_decoder)
vae.compile(optimizer='adam', loss='mse')
vae.fit(X_train, X_train, epochs=100, batch_size=32, verbose=0)

print("VAE training complete!")
````

---

## 3. ASSOCIATION RULE LEARNING

### 3.1 Apriori Algorithm (Intermediate)

**What?** Discovers frequent itemsets and association rules in transactional data.

**Why?** Market basket analysis, recommendation systems.

**Key Metrics:**
- **Support:** How frequently itemset appears
- **Confidence:** How often rule is true
- **Lift:** Ratio of observed support to expected support

````python
import pandas as pd
from mlxtend.frequent_patterns import apriori, association_rules
from mlxtend.preprocessing import TransactionEncoder

# Sample transaction data
transactions = [
    ['milk', 'bread', 'butter'],
    ['bread', 'butter'],
    ['milk', 'bread'],
    ['milk', 'bread', 'butter', 'eggs'],
    ['bread', 'eggs'],
    ['milk', 'bread', 'eggs'],
    ['milk', 'butter'],
    ['bread', 'butter', 'eggs'],
    ['milk', 'bread', 'butter', 'eggs'],
    ['milk', 'eggs']
]

# One-hot encode
te = TransactionEncoder()
te_array = te.fit_transform(transactions)
df = pd.DataFrame(te_array, columns=te.columns_)

print("Transaction Matrix:")
print(df)

# Find frequent itemsets
frequent_itemsets = apriori(df, min_support=0.3, use_colnames=True)
print(f"\nFrequent Itemsets (min_support=0.3):")
print(frequent_itemsets)

# Generate association rules
rules = association_rules(frequent_itemsets, metric='confidence', min_threshold=0.6)
print(f"\nAssociation Rules (min_confidence=0.6):")
print(rules[['antecedents', 'consequents', 'support', 'confidence', 'lift']])

# Filter interesting rules
interesting_rules = rules[(rules['lift'] > 1) & (rules['confidence'] > 0.7)]
print(f"\nInteresting Rules (lift>1, confidence>0.7):")
print(interesting_rules[['antecedents', 'consequents', 'support', 'confidence', 'lift']])
````

---

### 3.2 FP-Growth (Advanced)

**What?** Faster alternative to Apriori using FP-tree data structure.

**Why?** More efficient — doesn't generate candidate itemsets.

````python
import pandas as pd
from mlxtend.frequent_patterns import fpgrowth, association_rules
from mlxtend.preprocessing import TransactionEncoder
import time

# Larger dataset
import numpy as np
np.random.seed(42)

items = ['milk', 'bread', 'butter', 'eggs', 'cheese', 'yogurt', 'juice', 'cereal']
n_transactions = 1000

transactions = []
for _ in range(n_transactions):
    n_items = np.random.randint(2, 6)
    transaction = list(np.random.choice(items, size=n_items, replace=False))
    transactions.append(transaction)

# Encode
te = TransactionEncoder()
te_array = te.fit_transform(transactions)
df = pd.DataFrame(te_array, columns=te.columns_)

# Compare Apriori vs FP-Growth
from mlxtend.frequent_patterns import apriori

start = time.time()
apriori_result = apriori(df, min_support=0.1, use_colnames=True)
apriori_time = time.time() - start

start = time.time()
fpgrowth_result = fpgrowth(df, min_support=0.1, use_colnames=True)
fpgrowth_time = time.time() - start

print(f"Apriori time: {apriori_time:.4f}s, found {len(apriori_result)} itemsets")
print(f"FP-Growth time: {fpgrowth_time:.4f}s, found {len(fpgrowth_result)} itemsets")

# Rules from FP-Growth
rules = association_rules(fpgrowth_result, metric='lift', min_threshold=1.0)
print(f"\nTop 10 rules by lift:")
print(rules.nlargest(10, 'lift')[['antecedents', 'consequents', 'support', 'confidence', 'lift']])
````

---

## 4. ANOMALY DETECTION

### 4.1 Isolation Forest (Intermediate)

**What?** Tree-based algorithm that isolates anomalies by random partitioning.

**Why?** Anomalies are isolated in fewer steps — efficient for high-dimensional data.

````python
import numpy as np
from sklearn.ensemble import IsolationForest
from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt

# Generate data with outliers
np.random.seed(42)
X_normal, _ = make_blobs(n_samples=300, centers=1, cluster_std=0.5, random_state=42)
X_outliers = np.random.uniform(low=-4, high=4, size=(20, 2))
X = np.vstack([X_normal, X_outliers])

# Isolation Forest
iso_forest = IsolationForest(n_estimators=100, contamination=0.1, random_state=42)
predictions = iso_forest.fit_predict(X)
scores = iso_forest.decision_function(X)

# -1 = anomaly, 1 = normal
anomalies = X[predictions == -1]
normal = X[predictions == 1]

# Visualize
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
plt.scatter(normal[:, 0], normal[:, 1], c='blue', label='Normal', alpha=0.6)
plt.scatter(anomalies[:, 0], anomalies[:, 1], c='red', label='Anomaly', marker='x', s=100)
plt.legend()
plt.title('Isolation Forest Anomaly Detection')

plt.subplot(1, 2, 2)
plt.scatter(X[:, 0], X[:, 1], c=scores, cmap='RdYlGn')
plt.colorbar(label='Anomaly Score')
plt.title('Anomaly Scores')

plt.tight_layout()
plt.show()

print(f"Detected {len(anomalies)} anomalies out of {len(X)} points")
````

---

### 4.2 Local Outlier Factor (LOF) (Intermediate)

**What?** Density-based anomaly detection comparing local density of a point to neighbors.

**Why?** Can detect local anomalies that have different density than neighbors.

````python
import numpy as np
from sklearn.neighbors import LocalOutlierFactor
import matplotlib.pyplot as plt

# Generate data with varying densities
np.random.seed(42)
X1 = np.random.randn(100, 2) * 0.3 + [0, 0]
X2 = np.random.randn(100, 2) * 1.5 + [4, 4]
X_outliers = np.array([[2, 2], [-2, 3], [5, 0]])
X = np.vstack([X1, X2, X_outliers])

# LOF
lof = LocalOutlierFactor(n_neighbors=20, contamination=0.05)
predictions = lof.fit_predict(X)
scores = -lof.negative_outlier_factor_  # Higher = more anomalous

# Visualize
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
colors = ['red' if p == -1 else 'blue' for p in predictions]
plt.scatter(X[:, 0], X[:, 1], c=colors, alpha=0.6)
plt.title('LOF Anomaly Detection')

plt.subplot(1, 2, 2)
plt.scatter(X[:, 0], X[:, 1], c=scores, cmap='Reds')
plt.colorbar(label='LOF Score')
plt.title('LOF Scores (Higher = More Anomalous)')

plt.tight_layout()
plt.show()
````

---

### 4.3 One-Class SVM (Advanced)

**What?** SVM trained only on normal data to find decision boundary.

**Why?** Good when you only have examples of normal behavior.

````python
import numpy as np
from sklearn.svm import OneClassSVM
import matplotlib.pyplot as plt

# Generate normal training data
np.random.seed(42)
X_train = np.random.randn(200, 2) * 0.5

# Test data with anomalies
X_test_normal = np.random.randn(50, 2) * 0.5
X_test_anomaly = np.random.uniform(low=-3, high=3, size=(10, 2))
X_test = np.vstack([X_test_normal, X_test_anomaly])
y_test = np.array([1] * 50 + [-1] * 10)

# One-Class SVM
oc_svm = OneClassSVM(kernel='rbf', gamma='auto', nu=0.1)
oc_svm.fit(X_train)

predictions = oc_svm.predict(X_test)

# Visualize decision boundary
xx, yy = np.meshgrid(np.linspace(-4, 4, 200), np.linspace(-4, 4, 200))
Z = oc_svm.decision_function(np.c_[xx.ravel(), yy.ravel()])
Z = Z.reshape(xx.shape)

plt.figure(figsize=(10, 8))
plt.contourf(xx, yy, Z, levels=np.linspace(Z.min(), 0, 10), cmap='Blues_r', alpha=0.5)
plt.contour(xx, yy, Z, levels=[0], linewidths=2, colors='red')
plt.scatter(X_train[:, 0], X_train[:, 1], c='blue', label='Training (normal)', alpha=0.5)
plt.scatter(X_test_normal[:, 0], X_test_normal[:, 1], c='green', marker='s', label='Test (normal)')
plt.scatter(X_test_anomaly[:, 0], X_test_anomaly[:, 1], c='red', marker='x', s=100, label='Test (anomaly)')
plt.legend()
plt.title('One-Class SVM Anomaly Detection')
plt.show()

# Evaluate
from sklearn.metrics import classification_report
print(classification_report(y_test, predictions, target_names=['Anomaly', 'Normal']))
````

---

## 5. SELF-SUPERVISED LEARNING (Advanced)

### 5.1 Contrastive Learning

**What?** Learn representations by contrasting positive pairs against negative pairs.

**Why?** Learn useful representations without labels.

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Simple contrastive learning example (SimCLR-style)
class ContrastiveModel(keras.Model):
    def __init__(self, encoder, projection_dim=64, temperature=0.1):
        super().__init__()
        self.encoder = encoder
        self.projector = keras.Sequential([
            layers.Dense(128, activation='relu'),
            layers.Dense(projection_dim)
        ])
        self.temperature = temperature
        
    def contrastive_loss(self, z1, z2):
        # Normalize
        z1 = tf.nn.l2_normalize(z1, axis=1)
        z2 = tf.nn.l2_normalize(z2, axis=1)
        
        batch_size = tf.shape(z1)[0]
        
        # Similarity matrix
        similarity = tf.matmul(z1, z2, transpose_b=True) / self.temperature
        
        # Labels: positive pairs are on diagonal
        labels = tf.range(batch_size)
        
        # Cross entropy loss
        loss = tf.nn.sparse_softmax_cross_entropy_with_logits(labels, similarity)
        return tf.reduce_mean(loss)
    
    def call(self, inputs):
        x1, x2 = inputs  # Two augmented views
        h1 = self.encoder(x1)
        h2 = self.encoder(x2)
        z1 = self.projector(h1)
        z2 = self.projector(h2)
        return z1, z2

# Example encoder
encoder = keras.Sequential([
    layers.Flatten(),
    layers.Dense(256, activation='relu'),
    layers.Dense(128, activation='relu'),
])

print("Contrastive learning model created!")
print("In practice, this is used with data augmentation for self-supervised pretraining.")
````

---

## 6. EVALUATION METRICS FOR UNSUPERVISED LEARNING

````python
import numpy as np
from sklearn.metrics import (
    silhouette_score,
    calinski_harabasz_score,
    davies_bouldin_score,
    adjusted_rand_score,
    normalized_mutual_info_score
)
from sklearn.cluster import KMeans
from sklearn.datasets import make_blobs

# Generate data
X, y_true = make_blobs(n_samples=500, n_features=2, centers=4, random_state=42)

# Cluster
kmeans = KMeans(n_clusters=4, random_state=42)
y_pred = kmeans.fit_predict(X)

# Internal metrics (no ground truth needed)
print("=== Internal Metrics ===")
print(f"Silhouette Score: {silhouette_score(X, y_pred):.3f}")  # Higher is better [-1, 1]
print(f"Calinski-Harabasz Index: {calinski_harabasz_score(X, y_pred):.3f}")  # Higher is better
print(f"Davies-Bouldin Index: {davies_bouldin_score(X, y_pred):.3f}")  # Lower is better

# External metrics (require ground truth)
print("\n=== External Metrics ===")
print(f"Adjusted Rand Index: {adjusted_rand_score(y_true, y_pred):.3f}")  # [-1, 1], 1 is perfect
print(f"Normalized Mutual Information: {normalized_mutual_info_score(y_true, y_pred):.3f}")  # [0, 1]

# Silhouette analysis for choosing K
from sklearn.metrics import silhouette_samples
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
K_range = [2, 3, 4, 5]

for ax, k in zip(axes.flat, K_range):
    km = KMeans(n_clusters=k, random_state=42)
    labels = km.fit_predict(X)
    
    silhouette_avg = silhouette_score(X, labels)
    sample_silhouette_values = silhouette_samples(X, labels)
    
    y_lower = 10
    for i in range(k):
        cluster_silhouette_values = sample_silhouette_values[labels == i]
        cluster_silhouette_values.sort()
        
        cluster_size = cluster_silhouette_values.shape[0]
        y_upper = y_lower + cluster_size
        
        ax.fill_betweenx(np.arange(y_lower, y_upper),
                         0, cluster_silhouette_values,
                         alpha=0.7)
        y_lower = y_upper + 10
    
    ax.axvline(x=silhouette_avg, color='red', linestyle='--')
    ax.set_xlabel('Silhouette Coefficient')
    ax.set_ylabel('Cluster')
    ax.set_title(f'K={k}, Avg Silhouette={silhouette_avg:.3f}')

plt.tight_layout()
plt.show()
````

---

## 7. COMPARISON TABLE

| Algorithm | Type | Pros | Cons | Use When |
|-----------|------|------|------|----------|
| **K-Means** | Clustering | Fast, simple | Needs K, spherical clusters | Clear spherical clusters |
| **DBSCAN** | Clustering | Arbitrary shapes, finds outliers | eps/min_samples sensitive | Unknown cluster count, noise |
| **GMM** | Clustering | Soft clustering, elliptical | Needs components count | Overlapping clusters |
| **Hierarchical** | Clustering | Dendrogram, no K needed | Slow for large data | Small data, need hierarchy |
| **PCA** | Dim. Reduction | Fast, linear | Only linear relationships | Feature reduction, speed |
| **t-SNE** | Dim. Reduction | Great visualization | Slow, no new point transform | 2D/3D visualization only |
| **UMAP** | Dim. Reduction | Fast, preserves structure | Parameters matter | Visualization + reduction |
| **Isolation Forest** | Anomaly | Fast, high-dim | Contamination parameter | Large-scale anomaly detection |
| **Apriori** | Association | Interpretable rules | Slow for large itemsets | Market basket analysis |

---

## 8. BEST PRACTICES

1. **Always scale/normalize data** before clustering or dimensionality reduction
2. **Use multiple metrics** to evaluate clustering quality
3. **Visualize results** — even in 2D projections
4. **Try multiple algorithms** — no single best approach
5. **Tune hyperparameters** using validation metrics
6. **Consider computational cost** for large datasets
7. **Domain knowledge matters** — understand what patterns make sense

---

This comprehensive guide covers all major unsupervised learning techniques from beginner to advanced levels. Would you like me to dive deeper into any specific topic?