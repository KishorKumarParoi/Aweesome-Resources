# Precision vs Recall - ML Engineer Perspective

Let me break this down with real-world examples.

---

## **Core Definitions**

### **Precision** 
**"Of the cases I predicted as POSITIVE, how many were actually correct?"**

```
Precision = TP / (TP + FP)
           = True Positives / All Predicted Positives
```

**In plain English:** How accurate are my positive predictions?

### **Recall**
**"Of all actual POSITIVE cases, how many did I catch?"**

```
Recall = TP / (TP + FN)
        = True Positives / All Actual Positives
```

**In plain English:** How complete is my detection?

---

## **Example 1: Cancer Prediction 🏥**

Imagine we're building a model to detect cancer from medical scans.

### **Scenario: 1000 patients, 100 actually have cancer**

**Our Model Predicts:**
- 150 patients have cancer
- Of those 150:
  - 90 actually have cancer (True Positives - TP)
  - 60 don't have cancer (False Positives - FP)

- 850 patients don't have cancer
- Of those 850:
  - 10 actually have cancer (False Negatives - FN) ⚠️ MISSED!
  - 840 don't have cancer (True Negatives - TN)

**Confusion Matrix:**
```
                Predicted Cancer    Predicted No Cancer
Actual Cancer        90 (TP)              10 (FN)
Actual No Cancer     60 (FP)             840 (TN)
```

### **Calculate Metrics**

**Precision:**
```
Precision = TP / (TP + FP)
          = 90 / (90 + 60)
          = 90 / 150
          = 0.60 or 60%
```

**Meaning:** Of the 150 patients we predicted as having cancer, only 60% actually have it. 40% are false alarms.

**Recall:**
```
Recall = TP / (TP + FN)
       = 90 / (90 + 10)
       = 90 / 100
       = 0.90 or 90%
```

**Meaning:** Of the 100 patients who actually have cancer, we caught 90 of them (missed 10).

---

## **Example 2: Spam Call Detection 📱**

Building a model to detect spam calls from 10,000 incoming calls.

### **Actual Data:**
- 2,000 calls are actually spam
- 8,000 calls are legitimate

### **Our Model Predicts:**
- Flags 2,500 calls as spam
- Of those 2,500:
  - 1,900 are actually spam (True Positives - TP)
  - 600 are legitimate (False Positives - FP) ⚠️ Users miss important calls!

- 7,500 calls as legitimate
- Of those 7,500:
  - 100 are actually spam (False Negatives - FN) ⚠️ Spam gets through!
  - 7,400 are legitimate (True Negatives - TN)

**Confusion Matrix:**
```
                Predicted Spam    Predicted Legitimate
Actual Spam       1,900 (TP)          100 (FN)
Actual Legit        600 (FP)        7,400 (TN)
```

### **Calculate Metrics**

**Precision:**
```
Precision = TP / (TP + FP)
          = 1,900 / (1,900 + 600)
          = 1,900 / 2,500
          = 0.76 or 76%
```

**Meaning:** When we flag something as spam, it's actually spam 76% of the time. But 24% of the time we're wrong and block legitimate calls!

**Recall:**
```
Recall = TP / (TP + FN)
       = 1,900 / (1,900 + 100)
       = 1,900 / 2,000
       = 0.95 or 95%
```

**Meaning:** We catch 95% of all spam calls. Only 5% of spam gets through to the user.

---

## **Precision vs Recall Trade-off**

When you increase one, the other typically decreases.

### **Visual Comparison**

```
High Precision, Low Recall         High Recall, Low Precision
(Conservative)                     (Aggressive)
├─ Flag only obvious spam          ├─ Flag everything suspicious
├─ Miss some spam (FN high)        ├─ Block many legit calls (FP high)
└─ Legit calls rarely blocked      └─ Almost no spam gets through
```

---

## **Which Metric Matters? 🎯**

### **Cancer Prediction - Recall is Critical!**

```
Why? Missing a cancer patient (high FN) is DANGEROUS
     - False Negative = Patient dies ☠️
     - False Positive = Extra tests (annoying but safe)

Goal: High Recall (catch all cancer patients)
      Acceptable precision loss (more tests for healthy people)

Ideal Model:
✅ Recall = 98% (catch almost all cancers)
⚠️ Precision = 50% (send many for further testing)
```

**Real-world strategy:**
```
If model is uncertain → Recommend further tests
Better safe than sorry!
```

### **Spam Call Detection - Precision is Critical!**

```
Why? False positives (blocking legit calls) hurt user experience
     - False Positive = Miss important call ☠️
     - False Negative = Get annoying spam call (minor annoyance)

Goal: High Precision (block only sure spam)
      Acceptable recall loss (some spam gets through)

Ideal Model:
✅ Precision = 99% (block only definite spam)
⚠️ Recall = 60% (some spam gets through)
```

**Real-world strategy:**
```
If model is uncertain → Let call through
Better to hear spam than miss important call!
```

---

## **The F1-Score: Balance Both**

When you need balance between precision and recall:

```
F1-Score = 2 × (Precision × Recall) / (Precision + Recall)
```

**Example - Cancer:**
```
F1 = 2 × (0.60 × 0.90) / (0.60 + 0.90)
   = 2 × 0.54 / 1.50
   = 0.72
```

---

## **Quick Reference Table**

| Scenario | Priority | Why | Trade-off |
|----------|----------|-----|-----------|
| **Cancer Detection** | High Recall | Miss = death | Accept false alarms |
| **Spam Detection** | High Precision | False block = missed call | Accept some spam |
| **Fraud Detection** | High Recall | Miss fraud = money loss | Accept false alerts |
| **Email Spam** | High Precision | False spam = lost email | Accept some spam |
| **Movie Recommendation** | Balanced (F1) | Neither is critical | Balance both |

---

## **Code Example: Cancer Prediction**

```python
from sklearn.metrics import precision_recall_fscore_support, confusion_matrix

# True labels vs Predicted labels
y_true = [1, 1, 1, 0, 0, 1, 0, 0, 0, 1]  # Actual cancer
y_pred = [1, 1, 0, 0, 0, 1, 1, 0, 0, 1]  # Model prediction

# Calculate metrics
precision, recall, f1, _ = precision_recall_fscore_support(
    y_true, y_pred, average='binary'
)

print(f"Precision: {precision:.2f}")  # 4/5 = 0.80
print(f"Recall: {recall:.2f}")        # 4/5 = 0.80
print(f"F1-Score: {f1:.2f}")          # 0.80

# Confusion Matrix
tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()
print(f"\nTrue Positives: {tp}")   # 4 (correctly predicted cancer)
print(f"False Positives: {fp}")   # 1 (incorrectly said cancer)
print(f"False Negatives: {fn}")   # 1 (missed cancer)
print(f"True Negatives: {tn}")    # 4 (correctly said no cancer)
```

**Output:**
```
Precision: 0.80
Recall: 0.80
F1-Score: 0.80

True Positives: 4
False Positives: 1
False Negatives: 1
True Negatives: 4
```

---

## **Key Takeaways 🎓**

| Concept | Meaning |
|---------|---------|
| **Precision** | "When I say YES, am I right?" |
| **Recall** | "Do I find ALL the YES cases?" |
| **Cancer** | Need high recall (don't miss cancer!) |
| **Spam** | Need high precision (don't block calls!) |
| **Trade-off** | Usually can't maximize both |
| **F1-Score** | Balanced metric for both |

---

## **Real-world Impact**

**Cancer Model with:**
- ✅ 60% Precision, 90% Recall → 10% of real cancers missed (9 deaths per 100 cancer patients)
- ❌ 90% Precision, 60% Recall → 40% of real cancers missed (40 deaths per 100 cancer patients)

**Choice is clear:** Lose precision, save lives! 🏥

This is why domain knowledge matters in ML! Different problems need different optimization strategies.