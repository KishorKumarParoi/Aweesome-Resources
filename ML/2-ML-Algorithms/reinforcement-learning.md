# Reinforcement Learning: Complete Guide (Beginner to Advanced)

I'll teach you Reinforcement Learning comprehensively with the **Why, How, What** framework.

---

## 1. What is Reinforcement Learning?

### The Core Idea

**What?** Reinforcement Learning (RL) is a paradigm where an **agent** learns to make sequential decisions by interacting with an **environment** to maximize cumulative **rewards**.

**Why?** Unlike supervised learning (needs labels) or unsupervised learning (finds patterns), RL solves problems where:
- Decisions have **long-term consequences**
- You learn from **trial and error**
- No explicit "correct answer" exists—only rewards

**How?** Through a feedback loop:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    ┌─────────┐         Action (a)          ┌───────────┐   │
│    │         │ ──────────────────────────► │           │   │
│    │  Agent  │                             │Environment│   │
│    │         │ ◄────────────────────────── │           │   │
│    └─────────┘    State (s), Reward (r)    └───────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### When to Use RL vs Other ML?

| Problem Type | Traditional ML | Reinforcement Learning |
|--------------|----------------|------------------------|
| Image classification | ✅ Best | ❌ Overkill |
| Sequential decisions | ❌ Limited | ✅ Best |
| Game playing | ❌ Limited | ✅ Best |
| Robot control | ❌ Limited | ✅ Best |
| No labeled data | ❌ Needs labels | ✅ Learns from rewards |

### Real-World Applications

- **Games**: AlphaGo, OpenAI Five, Atari games
- **Robotics**: Manipulation, walking robots
- **Autonomous vehicles**: Self-driving cars
- **Finance**: Trading, portfolio optimization
- **Healthcare**: Treatment optimization
- **LLMs**: RLHF (ChatGPT uses PPO!)

---

## 2. Key Concepts & Terminology

### The Building Blocks

| Component | What | Why | Notation |
|-----------|------|-----|----------|
| **Agent** | The learner/decision maker | Makes choices | - |
| **Environment** | The world agent interacts with | Provides feedback | - |
| **State (s)** | Current situation | Agent needs context | S |
| **Action (a)** | What agent can do | Agent affects environment | A |
| **Reward (r)** | Scalar feedback signal | Guides learning | R |
| **Policy (π)** | Strategy for choosing actions | Defines behavior | π(a\|s) |
| **Value Function (V)** | Expected cumulative reward from state | Evaluates states | V(s) |
| **Q-Function (Q)** | Expected cumulative reward from state-action | Evaluates actions | Q(s,a) |

````python
# Conceptual representation of RL components

import numpy as np

class RLAgent:
    """
    Basic structure of an RL Agent
    """
    def __init__(self):
        self.policy = None      # How to choose actions: π(a|s)
        self.value_fn = None    # How good is a state: V(s)
        self.q_fn = None        # How good is action in state: Q(s,a)
    
    def observe(self, state):
        """Receive current state from environment"""
        self.current_state = state
    
    def act(self, state):
        """Choose action based on policy"""
        return self.policy(state)
    
    def learn(self, state, action, reward, next_state, done):
        """Update policy/value based on experience"""
        pass
````

### Markov Decision Process (MDP)

**What?** The mathematical framework for RL problems.

**Why?** Formalizes the environment so we can develop algorithms.

**How?** Defined by tuple **(S, A, P, R, γ)**:

| Symbol | Name | Meaning |
|--------|------|---------|
| S | States | All possible situations |
| A | Actions | All possible choices |
| P(s'\|s,a) | Transition | Probability of next state |
| R(s,a,s') | Reward | Immediate feedback |
| γ | Discount | How much to value future (0-1) |

**The Markov Property**: Future depends only on present, not past.
$$P(S_{t+1} | S_t, A_t) = P(S_{t+1} | S_0, A_0, S_1, A_1, ..., S_t, A_t)$$

````python
import numpy as np

class GridWorldMDP:
    """
    Simple 4x4 Grid World MDP
    
    Why this example?
    - Simple enough to understand
    - Complex enough to demonstrate concepts
    - Classic RL benchmark
    """
    
    def __init__(self, grid_size=4):
        self.grid_size = grid_size
        self.n_states = grid_size * grid_size  # 16 states
        self.n_actions = 4  # up, down, left, right
        self.gamma = 0.99  # Discount factor
        
        # Goal at bottom-right
        self.goal_state = self.n_states - 1
        
        # Action effects: (row_change, col_change)
        self.actions = {
            0: (-1, 0),  # up
            1: (1, 0),   # down
            2: (0, -1),  # left
            3: (0, 1)    # right
        }
    
    def state_to_pos(self, state):
        """Convert state index to (row, col)"""
        return state // self.grid_size, state % self.grid_size
    
    def pos_to_state(self, row, col):
        """Convert (row, col) to state index"""
        return row * self.grid_size + col
    
    def step(self, state, action):
        """
        Execute action in state
        
        Returns: (next_state, reward, done)
        
        This is the TRANSITION FUNCTION P(s'|s,a) and REWARD R(s,a,s')
        """
        if state == self.goal_state:
            return state, 0, True  # Already at goal
        
        row, col = self.state_to_pos(state)
        d_row, d_col = self.actions[action]
        
        # Apply action (with boundary checking)
        new_row = max(0, min(self.grid_size - 1, row + d_row))
        new_col = max(0, min(self.grid_size - 1, col + d_col))
        
        next_state = self.pos_to_state(new_row, new_col)
        
        # Reward structure
        if next_state == self.goal_state:
            reward = 10.0   # Big reward for goal
        else:
            reward = -0.1   # Small penalty per step (encourages efficiency)
        
        done = (next_state == self.goal_state)
        return next_state, reward, done
    
    def reset(self):
        """Start at top-left corner"""
        return 0

# Example usage
env = GridWorldMDP()
state = env.reset()
print(f"Starting state: {state}")

# Take some actions
for action in [1, 1, 3, 3]:  # down, down, right, right
    next_state, reward, done = env.step(state, action)
    print(f"Action {action}: State {state} → {next_state}, Reward: {reward}")
    state = next_state
````

### Value Functions: The Heart of RL

**Why Value Functions?**
The reward at each step isn't enough—we need to know **long-term value**.

**State Value V(s)**:
$$V^\pi(s) = \mathbb{E}_\pi\left[\sum_{t=0}^{\infty} \gamma^t R_{t+1} \mid S_0 = s\right]$$

**Translation**: "If I'm in state s and follow policy π, what's my expected total future reward?"

**Action Value Q(s,a)**:
$$Q^\pi(s,a) = \mathbb{E}_\pi\left[\sum_{t=0}^{\infty} \gamma^t R_{t+1} \mid S_0 = s, A_0 = a\right]$$

**Translation**: "If I'm in state s, take action a, then follow policy π, what's my expected total future reward?"

**The Relationship**:
$$V^\pi(s) = \sum_a \pi(a|s) \cdot Q^\pi(s,a)$$

### Bellman Equations: The Magic Formula

**Why Bellman?**
Breaks down a complex problem into **recursive** subproblems.

**Bellman Expectation Equation (for a policy π)**:
$$V^\pi(s) = \sum_a \pi(a|s) \sum_{s'} P(s'|s,a)[R(s,a,s') + \gamma V^\pi(s')]$$

**Bellman Optimality Equation (for optimal policy)**:
$$V^*(s) = \max_a \sum_{s'} P(s'|s,a)[R(s,a,s') + \gamma V^*(s')]$$

````python
import numpy as np

def bellman_expectation_v(V, policy, env, state):
    """
    Bellman Expectation Equation for V(s)
    
    V(s) = Σ π(a|s) * [R(s,a) + γ * V(s')]
    
    Why: Tells us the value of a state under a specific policy
    How: Weighted sum over actions of immediate reward + discounted future value
    """
    value = 0
    for action in range(env.n_actions):
        action_prob = policy[state, action]  # π(a|s)
        next_state, reward, _ = env.step(state, action)
        value += action_prob * (reward + env.gamma * V[next_state])
    return value

def bellman_optimality_q(Q, env, state, action):
    """
    Bellman Optimality Equation for Q(s,a)
    
    Q*(s,a) = R(s,a) + γ * max_a' Q*(s',a')
    
    Why: Tells us the value of taking an action optimally
    How: Immediate reward + best possible future value
    """
    next_state, reward, _ = env.step(state, action)
    return reward + env.gamma * np.max(Q[next_state])
````

### Exploration vs Exploitation: The Dilemma

**What?** The fundamental tradeoff in RL.

**Why it matters?**
- **Exploit**: Use known good actions → might miss better options
- **Explore**: Try new actions → might waste time on bad options

**How to balance?**

| Strategy | How it Works | When to Use |
|----------|--------------|-------------|
| ε-greedy | Random with probability ε | Simple, works well |
| ε-decay | ε decreases over time | Start exploring, end exploiting |
| Boltzmann | Softmax over Q-values | Smooth exploration |
| UCB | Optimism under uncertainty | Theoretical guarantees |

````python
import numpy as np

class ExplorationStrategies:
    """Different ways to balance exploration vs exploitation"""
    
    @staticmethod
    def epsilon_greedy(Q, state, epsilon=0.1):
        """
        WHY: Simple and effective
        HOW: Random action with probability ε, best action otherwise
        """
        if np.random.random() < epsilon:
            return np.random.randint(len(Q[state]))  # Explore
        return np.argmax(Q[state])  # Exploit
    
    @staticmethod
    def epsilon_decay(episode, start=1.0, end=0.01, decay=0.995):
        """
        WHY: Explore more early, exploit more later
        HOW: Exponentially decay ε
        """
        return max(end, start * (decay ** episode))
    
    @staticmethod
    def boltzmann(Q, state, temperature=1.0):
        """
        WHY: Smooth exploration based on action values
        HOW: Softmax over Q-values (higher temp = more random)
        
        High temperature → uniform random
        Low temperature → greedy
        """
        q_values = Q[state]
        # Subtract max for numerical stability
        exp_q = np.exp((q_values - np.max(q_values)) / temperature)
        probs = exp_q / np.sum(exp_q)
        return np.random.choice(len(q_values), p=probs)
    
    @staticmethod
    def ucb(Q, state, action_counts, c=2.0, t=1):
        """
        WHY: Mathematically optimal exploration
        HOW: Add exploration bonus for uncertain actions
        
        UCB = Q(s,a) + c * sqrt(ln(t) / N(s,a))
        """
        exploration_bonus = c * np.sqrt(np.log(t) / (action_counts[state] + 1e-8))
        ucb_values = Q[state] + exploration_bonus
        return np.argmax(ucb_values)
````

---

## 3. Types of RL Algorithms

### The Complete Taxonomy

```
Reinforcement Learning
│
├── Model-Based (learns/uses environment model)
│   ├── Dynamic Programming (known model)
│   │   ├── Policy Iteration
│   │   └── Value Iteration
│   └── Model Learning (learns model)
│       ├── Dyna-Q
│       └── World Models
│
└── Model-Free (learns directly from experience)
    │
    ├── Value-Based (learn V or Q, derive policy)
    │   ├── Tabular
    │   │   ├── Monte Carlo
    │   │   ├── TD(0), TD(λ)
    │   │   ├── SARSA
    │   │   └── Q-Learning
    │   └── Deep
    │       ├── DQN
    │       ├── Double DQN
    │       ├── Dueling DQN
    │       └── Rainbow
    │
    ├── Policy-Based (learn policy directly)
    │   ├── REINFORCE
    │   ├── TRPO
    │   └── PPO
    │
    └── Actor-Critic (learn both)
        ├── A2C / A3C
        ├── DDPG
        ├── TD3
        └── SAC
```

### Quick Comparison

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **Value-Based** | Sample efficient, stable | Discrete actions only | Games, discrete control |
| **Policy-Based** | Continuous actions, stochastic policies | High variance | Robotics, continuous |
| **Actor-Critic** | Best of both | More complex | General purpose |
| **Model-Based** | Very sample efficient | Model errors compound | Known/simple dynamics |

---

## 4. Model-Based Methods

### Why Model-Based?

**What?** Agent learns or uses a model of environment dynamics.

**Why?**
- **Sample efficient**: Plan without real interaction
- **Can look ahead**: Simulate future scenarios
- **Transfer**: Model transfers to new tasks

**Drawbacks:**
- Model errors compound
- Hard to learn accurate models
- Computationally expensive

### Dynamic Programming (Known Model)

**When?** You know P(s'|s,a) and R(s,a,s') exactly.

#### Policy Iteration

**What?** Alternate between:
1. **Policy Evaluation**: Calculate V for current policy
2. **Policy Improvement**: Make policy greedy w.r.t. V

````python
import numpy as np

def policy_evaluation(policy, env, V, theta=1e-6):
    """
    WHAT: Calculate V(s) for all states under policy π
    
    WHY: Need to know how good current policy is before improving
    
    HOW: Iterate Bellman expectation until convergence
         V(s) ← Σ π(a|s) * [R(s,a) + γ * V(s')]
    """
    while True:
        delta = 0
        for s in range(env.n_states):
            v = V[s]
            # Bellman update
            new_v = 0
            for a in range(env.n_actions):
                next_s, reward, _ = env.step(s, a)
                new_v += policy[s, a] * (reward + env.gamma * V[next_s])
            V[s] = new_v
            delta = max(delta, abs(v - V[s]))
        
        if delta < theta:  # Converged!
            break
    return V

def policy_improvement(env, V):
    """
    WHAT: Create greedy policy w.r.t. value function
    
    WHY: Greedy improvement theorem guarantees this is better or equal
    
    HOW: π(s) = argmax_a [R(s,a) + γ * V(s')]
    """
    policy = np.zeros((env.n_states, env.n_actions))
    
    for s in range(env.n_states):
        q_values = np.zeros(env.n_actions)
        for a in range(env.n_actions):
            next_s, reward, _ = env.step(s, a)
            q_values[a] = reward + env.gamma * V[next_s]
        
        best_action = np.argmax(q_values)
        policy[s, best_action] = 1.0  # Deterministic greedy policy
    
    return policy

def policy_iteration(env, theta=1e-6):
    """
    Complete Policy Iteration Algorithm
    
    WHY: Guaranteed to find optimal policy in finite iterations
    """
    # Start with uniform random policy
    policy = np.ones((env.n_states, env.n_actions)) / env.n_actions
    V = np.zeros(env.n_states)
    
    iteration = 0
    while True:
        # Step 1: Evaluate current policy
        V = policy_evaluation(policy, env, V, theta)
        
        # Step 2: Improve policy
        new_policy = policy_improvement(env, V)
        
        # Check if policy changed
        if np.array_equal(policy, new_policy):
            print(f"Converged after {iteration} iterations")
            break
        
        policy = new_policy
        iteration += 1
    
    return policy, V
````

#### Value Iteration

**What?** Combine evaluation and improvement into one step.

**Why faster?** Don't need full policy evaluation each iteration.

````python
import numpy as np

def value_iteration(env, theta=1e-6):
    """
    Value Iteration Algorithm
    
    WHAT: Find optimal V* directly, then extract optimal policy
    
    WHY: More efficient than policy iteration (one sweep per iteration)
    
    HOW: V(s) ← max_a [R(s,a) + γ * V(s')]
         (combines evaluation + improvement)
    """
    V = np.zeros(env.n_states)
    
    iteration = 0
    while True:
        delta = 0
        for s in range(env.n_states):
            v = V[s]
            
            # Find best action value
            q_values = np.zeros(env.n_actions)
            for a in range(env.n_actions):
                next_s, reward, _ = env.step(s, a)
                q_values[a] = reward + env.gamma * V[next_s]
            
            V[s] = np.max(q_values)  # Take max (greedy)
            delta = max(delta, abs(v - V[s]))
        
        iteration += 1
        if delta < theta:
            print(f"Converged after {iteration} iterations")
            break
    
    # Extract optimal policy from V*
    policy = np.zeros((env.n_states, env.n_actions))
    for s in range(env.n_states):
        q_values = np.zeros(env.n_actions)
        for a in range(env.n_actions):
            next_s, reward, _ = env.step(s, a)
            q_values[a] = reward + env.gamma * V[next_s]
        policy[s, np.argmax(q_values)] = 1.0
    
    return policy, V
````

### Dyna-Q (Learn Model + Planning)

**What?** Learn model from experience, use it for planning.

**Why?** Get model-based sample efficiency with model-free flexibility.

````python
import numpy as np

class DynaQ:
    """
    Dyna-Q: Integrates learning, planning, and acting
    
    WHAT: 
    - Learn Q-values from real experience
    - Learn a model from real experience  
    - Use model for simulated experience (planning)
    
    WHY:
    - More sample efficient than pure model-free
    - More robust than pure model-based
    
    HOW:
    1. Act in real environment
    2. Learn Q from real experience
    3. Update model with real experience
    4. Do n planning steps using model
    """
    
    def __init__(self, n_states, n_actions, alpha=0.1, gamma=0.99, 
                 epsilon=0.1, n_planning_steps=5):
        self.n_states = n_states
        self.n_actions = n_actions
        self.alpha = alpha          # Learning rate
        self.gamma = gamma          # Discount factor
        self.epsilon = epsilon      # Exploration rate
        self.n_planning_steps = n_planning_steps
        
        # Q-table
        self.Q = np.zeros((n_states, n_actions))
        
        # Model: stores (next_state, reward, done) for each (state, action)
        self.model = {}
        
        # Track which state-action pairs we've seen
        self.visited = []
    
    def select_action(self, state):
        """ε-greedy action selection"""
        if np.random.random() < self.epsilon:
            return np.random.randint(self.n_actions)
        return np.argmax(self.Q[state])
    
    def learn(self, state, action, reward, next_state, done):
        """
        The Dyna-Q learning loop
        """
        # 1. DIRECT RL: Learn from real experience
        target = reward + (0 if done else self.gamma * np.max(self.Q[next_state]))
        self.Q[state, action] += self.alpha * (target - self.Q[state, action])
        
        # 2. MODEL LEARNING: Update model
        self.model[(state, action)] = (next_state, reward, done)
        if (state, action) not in self.visited:
            self.visited.append((state, action))
        
        # 3. PLANNING: Learn from simulated experience
        for _ in range(self.n_planning_steps):
            # Pick random previously seen state-action
            s, a = self.visited[np.random.randint(len(self.visited))]
            ns, r, d = self.model[(s, a)]
            
            # Q-learning update on simulated experience
            target = r + (0 if d else self.gamma * np.max(self.Q[ns]))
            self.Q[s, a] += self.alpha * (target - self.Q[s, a])
    
    def train(self, env, n_episodes=500):
        rewards_history = []
        
        for episode in range(n_episodes):
            state = env.reset()
            total_reward = 0
            done = False
            
            while not done:
                action = self.select_action(state)
                next_state, reward, done = env.step(state, action)
                self.learn(state, action, reward, next_state, done)
                
                total_reward += reward
                state = next_state
            
            rewards_history.append(total_reward)
            
            if (episode + 1) % 100 == 0:
                avg = np.mean(rewards_history[-100:])
                print(f"Episode {episode + 1}, Avg Reward: {avg:.2f}")
        
        return rewards_history
````

---

## 5. Value-Based Methods (Model-Free)

### Monte Carlo Methods

**What?** Learn from complete episodes by averaging returns.

**Why?**
- Simple to understand
- Unbiased estimates
- No bootstrapping needed

**Limitation:** Must wait for episode to end.

````python
import numpy as np
from collections import defaultdict

class MonteCarlo:
    """
    First-Visit Monte Carlo Control
    
    WHAT: Learn Q(s,a) by averaging actual returns
    
    WHY: 
    - No model needed
    - Unbiased estimates
    - Simple to implement
    
    HOW:
    1. Generate complete episode using policy
    2. For each (s,a) pair visited:
       - Calculate return G from that point
       - Average all returns for that (s,a)
    """
    
    def __init__(self, n_actions, gamma=0.99, epsilon=0.1):
        self.n_actions = n_actions
        self.gamma = gamma
        self.epsilon = epsilon
        
        # Q-values (using defaultdict for any state)
        self.Q = defaultdict(lambda: np.zeros(n_actions))
        
        # Store all returns for averaging
        self.returns = defaultdict(list)
    
    def select_action(self, state):
        """ε-greedy policy"""
        if np.random.random() < self.epsilon:
            return np.random.randint(self.n_actions)
        return np.argmax(self.Q[state])
    
    def generate_episode(self, env):
        """Generate one episode following current policy"""
        episode = []
        state = env.reset()
        done = False
        
        while not done:
            action = self.select_action(state)
            next_state, reward, done = env.step(state, action)
            episode.append((state, action, reward))
            state = next_state
        
        return episode
    
    def learn_from_episode(self, episode):
        """
        First-Visit MC: Only use first occurrence of (s,a)
        
        WHY first-visit? Simpler, works well in practice
        """
        visited = set()
        
        # Calculate returns backwards
        G = 0
        for t in range(len(episode) - 1, -1, -1):
            state, action, reward = episode[t]
            G = self.gamma * G + reward  # Accumulate discounted return
            
            # First-visit check
            if (state, action) not in visited:
                visited.add((state, action))
                self.returns[(state, action)].append(G)
                # Q = average of all returns
                self.Q[state][action] = np.mean(self.returns[(state, action)])
    
    def train(self, env, n_episodes=1000):
        rewards_history = []
        
        for ep in range(n_episodes):
            episode = self.generate_episode(env)
            self.learn_from_episode(episode)
            
            total_reward = sum(r for _, _, r in episode)
            rewards_history.append(total_reward)
            
            # Decay exploration
            self.epsilon = max(0.01, self.epsilon * 0.999)
        
        return rewards_history
````

### Temporal Difference (TD) Learning

**What?** Learn from incomplete episodes using bootstrapping.

**Why better than MC?**
- Learn online (every step)
- Works for continuing tasks
- Lower variance

**Key Insight**: Update toward estimated value, not actual return.

#### TD(0) - One-Step TD

````python
import numpy as np

class TD0:
    """
    TD(0): One-step Temporal Difference
    
    WHAT: Update V toward one-step estimated return
    
    WHY:
    - Can learn online (every step)
    - Works for non-episodic tasks
    - Lower variance than MC
    
    HOW: V(s) ← V(s) + α[R + γV(s') - V(s)]
    
    The term [R + γV(s') - V(s)] is called TD ERROR (δ)
    """
    
    def __init__(self, n_states, alpha=0.1, gamma=0.99):
        self.V = np.zeros(n_states)
        self.alpha = alpha  # Learning rate
        self.gamma = gamma  # Discount factor
    
    def update(self, state, reward, next_state, done):
        """
        One TD update
        
        TD Target: R + γV(s')
        TD Error: Target - V(s)
        """
        # Target: what we think V(s) should be
        target = reward + (0 if done else self.gamma * self.V[next_state])
        
        # TD Error: how wrong we were
        td_error = target - self.V[state]
        
        # Update toward target
        self.V[state] += self.alpha * td_error
        
        return td_error


class TDLambda:
    """
    TD(λ): Bridge between TD(0) and Monte Carlo
    
    WHAT: Use eligibility traces to blend TD and MC
    
    WHY:
    - λ=0: TD(0) (one-step)
    - λ=1: Monte Carlo (full episode)
    - Between: best of both worlds
    
    HOW: Eligibility traces remember which states led to current reward
    """
    
    def __init__(self, n_states, alpha=0.1, gamma=0.99, lambda_=0.9):
        self.V = np.zeros(n_states)
        self.alpha = alpha
        self.gamma = gamma
        self.lambda_ = lambda_
        self.eligibility = np.zeros(n_states)
    
    def reset_eligibility(self):
        """Reset traces at start of episode"""
        self.eligibility = np.zeros_like(self.eligibility)
    
    def update(self, state, reward, next_state, done):
        """
        Update with eligibility traces
        
        Traces decay by γλ each step
        Current state gets trace boost
        All states update proportional to their trace
        """
        # TD error
        target = reward + (0 if done else self.gamma * self.V[next_state])
        td_error = target - self.V[state]
        
        # Boost eligibility for current state
        self.eligibility[state] += 1
        
        # Update ALL states proportional to eligibility
        self.V += self.alpha * td_error * self.eligibility
        
        # Decay eligibility traces
        self.eligibility *= self.gamma * self.lambda_
        
        return td_error
````

### SARSA (On-Policy TD Control)

**What?** TD learning for Q-values, following the same policy.

**Why "on-policy"?** Updates Q using the actual next action taken (not best action).

**Name:** **S**tate-**A**ction-**R**eward-**S**tate-**A**ction

````python
import numpy as np

class SARSA:
    """
    SARSA: On-Policy TD Control
    
    WHAT: Learn Q(s,a) using TD, but follow the learned policy
    
    WHY:
    - Learns value of policy being followed (including exploration)
    - Safer in dangerous environments (considers exploration risk)
    
    HOW: Q(s,a) ← Q(s,a) + α[R + γQ(s',a') - Q(s,a)]
    
    KEY DIFFERENCE from Q-Learning:
    - Uses Q(s', a') where a' is the action actually taken
    - Not max_a' Q(s', a')
    """
    
    def __init__(self, n_states, n_actions, alpha=0.1, gamma=0.99, epsilon=0.1):
        self.Q = np.zeros((n_states, n_actions))
        self.alpha = alpha
        self.gamma = gamma
        self.epsilon = epsilon
        self.n_actions = n_actions
    
    def select_action(self, state):
        """ε-greedy action selection"""
        if np.random.random() < self.epsilon:
            return np.random.randint(self.n_actions)
        return np.argmax(self.Q[state])
    
    def update(self, state, action, reward, next_state, next_action, done):
        """
        SARSA update
        
        Uses ACTUAL next action (a') not best action
        This makes it on-policy
        """
        target = reward + (0 if done else self.gamma * self.Q[next_state, next_action])
        td_error = target - self.Q[state, action]
        self.Q[state, action] += self.alpha * td_error
        return td_error
    
    def train(self, env, n_episodes=1000):
        rewards_history = []
        
        for episode in range(n_episodes):
            state = env.reset()
            action = self.select_action(state)  # Choose first action
            total_reward = 0
            done = False
            
            while not done:
                # Take action, observe result
                next_state, reward, done = env.step(state, action)
                
                # Choose next action (needed for SARSA update)
                next_action = self.select_action(next_state)
                
                # Update Q
                self.update(state, action, reward, next_state, next_action, done)
                
                total_reward += reward
                state = next_state
                action = next_action  # This is what makes it SARSA
            
            rewards_history.append(total_reward)
            self.epsilon = max(0.01, self.epsilon * 0.999)
        
        return rewards_history
````

### Q-Learning (Off-Policy TD Control)

**What?** TD learning for Q-values, but learns optimal policy regardless of exploration.

**Why "off-policy"?** Updates Q using max Q(s', a'), not the action actually taken.

**Why this matters?** Can explore freely while still learning the optimal policy.

````python
import numpy as np

class QLearning:
    """
    Q-Learning: Off-Policy TD Control
    
    WHAT: Learn optimal Q* regardless of policy followed
    
    WHY:
    - Can explore with any policy
    - Still learns optimal policy
    - More sample efficient than on-policy
    
    HOW: Q(s,a) ← Q(s,a) + α[R + γ max_a' Q(s',a') - Q(s,a)]
    
    KEY INSIGHT: Uses max Q(s',a') - the BEST possible action
    This is what makes it off-policy
    """
    
    def __init__(self, n_states, n_actions, alpha=0.1, gamma=0.99, epsilon=0.1):
        self.Q = np.zeros((n_states, n_actions))
        self.alpha = alpha
        self.gamma = gamma
        self.epsilon = epsilon
        self.n_actions = n_actions
    
    def select_action(self, state):
        """ε-greedy (behavior policy)"""
        if np.random.random() < self.epsilon:
            return np.random.randint(self.n_actions)
        return np.argmax(self.Q[state])
    
    def update(self, state, action, reward, next_state, done):
        """
        Q-Learning update
        
        Uses MAX Q(s',a') - this is the key difference from SARSA
        """
        # Target uses BEST action, not actual action
        target = reward + (0 if done else self.gamma * np.max(self.Q[next_state]))
        td_error = target - self.Q[state, action]
        self.Q[state, action] += self.alpha * td_error
        return td_error
    
    def train(self, env, n_episodes=1000):
        rewards_history = []
        
        for episode in range(n_episodes):
            state = env.reset()
            total_reward = 0
            done = False
            
            while not done:
                action = self.select_action(state)
                next_state, reward, done = env.step(state, action)
                
                # Note: we don't need next_action (unlike SARSA)
                self.update(state, action, reward, next_state, done)
                
                total_reward += reward
                state = next_state
            
            rewards_history.append(total_reward)
            self.epsilon = max(0.01, self.epsilon * 0.999)
        
        return rewards_history


class DoubleQLearning:
    """
    Double Q-Learning: Fixes overestimation bias
    
    WHAT: Use two Q-functions to decouple action selection and evaluation
    
    WHY: Regular Q-learning overestimates Q-values because:
         max_a Q(s,a) >= Q(s, argmax_a Q(s,a)) on average
    
    HOW: 
    - Q1 selects the action
    - Q2 evaluates it (or vice versa)
    - Randomly choose which to update
    """
    
    def __init__(self, n_states, n_actions, alpha=0.1, gamma=0.99, epsilon=0.1):
        self.Q1 = np.zeros((n_states, n_actions))
        self.Q2 = np.zeros((n_states, n_actions))
        self.alpha = alpha
        self.gamma = gamma
        self.epsilon = epsilon
        self.n_actions = n_actions
    
    def select_action(self, state):
        """Use sum of both Q-functions for action selection"""
        if np.random.random() < self.epsilon:
            return np.random.randint(self.n_actions)
        return np.argmax(self.Q1[state] + self.Q2[state])
    
    def update(self, state, action, reward, next_state, done):
        """
        Randomly update Q1 or Q2
        Use other network for action selection
        """
        if np.random.random() < 0.5:
            # Update Q1, use Q1 to select action, Q2 to evaluate
            best_action = np.argmax(self.Q1[next_state])
            target = reward + (0 if done else self.gamma * self.Q2[next_state, best_action])
            self.Q1[state, action] += self.alpha * (target - self.Q1[state, action])
        else:
            # Update Q2, use Q2 to select action, Q1 to evaluate
            best_action = np.argmax(self.Q2[next_state])
            target = reward + (0 if done else self.gamma * self.Q1[next_state, best_action])
            self.Q2[state, action] += self.alpha * (target - self.Q2[state, action])
````

### SARSA vs Q-Learning: The Key Difference

```
SARSA (On-Policy):
  Q(s,a) ← Q(s,a) + α[R + γQ(s',a') - Q(s,a)]
                           ↑
                    actual action taken

Q-Learning (Off-Policy):  
  Q(s,a) ← Q(s,a) + α[R + γ max_a' Q(s',a') - Q(s,a)]
                           ↑
                    best possible action
```

**Practical Difference:**
- **SARSA**: Safer, learns to avoid cliffs even with exploration
- **Q-Learning**: May be riskier, but learns optimal path faster

---

### Deep Q-Network (DQN)

**What?** Use neural networks to approximate Q-function.

**Why?**
- Handles high-dimensional states (images!)
- Generalizes across similar states
- Breakthrough in game-playing AI (Atari)

**Key Innovations:**
1. **Experience Replay**: Store and sample past experiences
2. **Target Network**: Stabilize learning with delayed updates

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from collections import deque
import random

class ReplayBuffer:
    """
    Experience Replay Buffer
    
    WHAT: Store past experiences for random sampling
    
    WHY:
    - Breaks correlation between consecutive samples
    - Reuses experiences multiple times
    - More stable learning
    """
    
    def __init__(self, capacity=100000):
        self.buffer = deque(maxlen=capacity)
    
    def push(self, state, action, reward, next_state, done):
        self.buffer.append((state, action, reward, next_state, done))
    
    def sample(self, batch_size):
        batch = random.sample(self.buffer, batch_size)
        states, actions, rewards, next_states, dones = zip(*batch)
        return (np.array(states), np.array(actions), np.array(rewards),
                np.array(next_states), np.array(dones))
    
    def __len__(self):
        return len(self.buffer)


class DQN:
    """
    Deep Q-Network
    
    WHAT: Q-Learning with neural network function approximation
    
    WHY:
    - Handle large/continuous state spaces
    - Generalization across states
    - Works with raw pixels
    
    HOW:
    1. Use neural net to approximate Q(s,a)
    2. Experience replay for stable learning
    3. Target network for stable targets
    """
    
    def __init__(self, state_dim, n_actions, hidden_dims=[64, 64],
                 lr=0.001, gamma=0.99, epsilon=1.0, epsilon_min=0.01,
                 epsilon_decay=0.995, buffer_size=100000, batch_size=64,
                 target_update_freq=100):
        
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.gamma = gamma
        self.epsilon = epsilon
        self.epsilon_min = epsilon_min
        self.epsilon_decay = epsilon_decay
        self.batch_size = batch_size
        self.target_update_freq = target_update_freq
        self.learn_step = 0
        
        # Two networks: online and target
        self.q_network = self._build_network(hidden_dims)
        self.target_network = self._build_network(hidden_dims)
        self.update_target_network()  # Copy weights initially
        
        self.optimizer = keras.optimizers.Adam(learning_rate=lr)
        self.buffer = ReplayBuffer(buffer_size)
    
    def _build_network(self, hidden_dims):
        """Build Q-network"""
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        
        model.add(layers.Dense(self.n_actions, activation='linear'))
        return model
    
    def update_target_network(self):
        """
        Copy weights from online to target network
        
        WHY: Stabilizes learning by having fixed targets
        """
        self.target_network.set_weights(self.q_network.get_weights())
    
    def select_action(self, state):
        """ε-greedy action selection"""
        if np.random.random() < self.epsilon:
            return np.random.randint(self.n_actions)
        
        state = np.array(state).reshape(1, -1)
        q_values = self.q_network(state, training=False)
        return np.argmax(q_values[0])
    
    def store_transition(self, state, action, reward, next_state, done):
        self.buffer.push(state, action, reward, next_state, done)
    
    def learn(self):
        """
        One learning step
        """
        if len(self.buffer) < self.batch_size:
            return 0
        
        # Sample random batch
        states, actions, rewards, next_states, dones = self.buffer.sample(self.batch_size)
        
        # Compute targets using TARGET network (not online)
        next_q_values = self.target_network(next_states, training=False)
        max_next_q = np.max(next_q_values, axis=1)
        targets = rewards + (1 - dones) * self.gamma * max_next_q
        
        # Train online network
        with tf.GradientTape() as tape:
            q_values = self.q_network(states, training=True)
            # Get Q-values for actions taken
            action_masks = tf.one_hot(actions, self.n_actions)
            q_values_taken = tf.reduce_sum(q_values * action_masks, axis=1)
            
            loss = tf.reduce_mean(tf.square(targets - q_values_taken))
        
        gradients = tape.gradient(loss, self.q_network.trainable_variables)
        self.optimizer.apply_gradients(zip(gradients, self.q_network.trainable_variables))
        
        # Update target network periodically
        self.learn_step += 1
        if self.learn_step % self.target_update_freq == 0:
            self.update_target_network()
        
        # Decay exploration
        self.epsilon = max(self.epsilon_min, self.epsilon * self.epsilon_decay)
        
        return loss.numpy()
````

### DQN Improvements

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class DoubleDQN(DQN):
    """
    Double DQN: Fix overestimation bias
    
    WHAT: Use online network for action selection, target for evaluation
    
    WHY: Regular DQN overestimates Q-values
    
    HOW: 
    - a* = argmax_a Q_online(s', a)  # Online selects action
    - target = R + γ Q_target(s', a*)  # Target evaluates
    """
    
    def learn(self):
        if len(self.buffer) < self.batch_size:
            return 0
        
        states, actions, rewards, next_states, dones = self.buffer.sample(self.batch_size)
        
        # DOUBLE DQN: Online network selects best action
        next_q_online = self.q_network(next_states, training=False)
        best_actions = np.argmax(next_q_online, axis=1)
        
        # Target network evaluates that action
        next_q_target = self.target_network(next_states, training=False)
        max_next_q = next_q_target.numpy()[np.arange(self.batch_size), best_actions]
        
        targets = rewards + (1 - dones) * self.gamma * max_next_q
        
        with tf.GradientTape() as tape:
            q_values = self.q_network(states, training=True)
            action_masks = tf.one_hot(actions, self.n_actions)
            q_values_taken = tf.reduce_sum(q_values * action_masks, axis=1)
            loss = tf.reduce_mean(tf.square(targets - q_values_taken))
        
        gradients = tape.gradient(loss, self.q_network.trainable_variables)
        self.optimizer.apply_gradients(zip(gradients, self.q_network.trainable_variables))
        
        self.learn_step += 1
        if self.learn_step % self.target_update_freq == 0:
            self.update_target_network()
        
        self.epsilon = max(self.epsilon_min, self.epsilon * self.epsilon_decay)
        return loss.numpy()


class DuelingDQN(DQN):
    """
    Dueling DQN: Separate value and advantage
    
    WHAT: Q(s,a) = V(s) + A(s,a) - mean(A)
    
    WHY: 
    - Some states are bad/good regardless of action
    - Separating V and A helps learn this
    
    HOW:
    - V(s): How good is this state?
    - A(s,a): How much better is action a than average?
    """
    
    def _build_network(self, hidden_dims):
        inputs = layers.Input(shape=(self.state_dim,))
        
        # Shared layers
        x = inputs
        for dim in hidden_dims[:-1]:
            x = layers.Dense(dim, activation='relu')(x)
        
        # VALUE stream: single output
        value = layers.Dense(hidden_dims[-1], activation='relu')(x)
        value = layers.Dense(1)(value)  # V(s)
        
        # ADVANTAGE stream: one output per action
        advantage = layers.Dense(hidden_dims[-1], activation='relu')(x)
        advantage = layers.Dense(self.n_actions)(advantage)  # A(s,a)
        
        # Combine: Q = V + (A - mean(A))
        # Subtracting mean makes A identifiable
        q_values = value + (advantage - tf.reduce_mean(advantage, axis=1, keepdims=True))
        
        return keras.Model(inputs, q_values)


class PrioritizedReplayBuffer:
    """
    Prioritized Experience Replay
    
    WHAT: Sample important transitions more often
    
    WHY: Not all experiences are equally useful
    
    HOW: 
    - Priority = |TD error| (how surprising was this transition?)
    - Sample with probability proportional to priority
    - Use importance sampling weights to correct bias
    """
    
    def __init__(self, capacity=100000, alpha=0.6, beta=0.4, beta_increment=0.001):
        self.capacity = capacity
        self.alpha = alpha      # Priority exponent (0 = uniform, 1 = full prioritization)
        self.beta = beta        # Importance sampling exponent
        self.beta_increment = beta_increment
        
        self.buffer = []
        self.priorities = []
        self.position = 0
    
    def push(self, state, action, reward, next_state, done):
        max_priority = max(self.priorities) if self.priorities else 1.0
        
        if len(self.buffer) < self.capacity:
            self.buffer.append((state, action, reward, next_state, done))
            self.priorities.append(max_priority)
        else:
            self.buffer[self.position] = (state, action, reward, next_state, done)
            self.priorities[self.position] = max_priority
        
        self.position = (self.position + 1) % self.capacity
    
    def sample(self, batch_size):
        # Calculate sampling probabilities
        priorities = np.array(self.priorities)
        probabilities = priorities ** self.alpha
        probabilities /= probabilities.sum()
        
        # Sample based on priorities
        indices = np.random.choice(len(self.buffer), batch_size, p=probabilities)
        
        # Importance sampling weights (correct for non-uniform sampling)
        weights = (len(self.buffer) * probabilities[indices]) ** (-self.beta)
        weights /= weights.max()  # Normalize
        
        # Increase beta toward 1
        self.beta = min(1.0, self.beta + self.beta_increment)
        
        batch = [self.buffer[i] for i in indices]
        states, actions, rewards, next_states, dones = zip(*batch)
        
        return (np.array(states), np.array(actions), np.array(rewards),
                np.array(next_states), np.array(dones), indices, weights)
    
    def update_priorities(self, indices, td_errors):
        """Update priorities based on TD errors"""
        for idx, td_error in zip(indices, td_errors):
            self.priorities[idx] = abs(td_error) + 1e-6  # Small constant to avoid 0
    
    def __len__(self):
        return len(self.buffer)
````

---

## 6. Policy-Based Methods

### Why Policy-Based?

| Value-Based | Policy-Based |
|-------------|--------------|
| Learn Q, derive π | Learn π directly |
| Discrete actions only | Works with continuous actions |
| Deterministic policies | Can learn stochastic policies |
| Can oscillate | Smoother optimization |

### REINFORCE (Monte Carlo Policy Gradient)

**What?** Directly optimize policy using gradient ascent on expected return.

**The Policy Gradient Theorem:**
$$\nabla J(\theta) = \mathbb{E}_\pi[\nabla \log \pi(a|s;\theta) \cdot G_t]$$

**Translation**: Increase probability of actions that led to high returns.

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class REINFORCE:
    """
    REINFORCE: Monte Carlo Policy Gradient
    
    WHAT: Learn policy directly by gradient ascent on expected return
    
    WHY:
    - Can learn stochastic policies
    - Works with continuous actions
    - Directly optimizes what we care about
    
    HOW: ∇J(θ) ≈ Σ_t ∇log π(a_t|s_t;θ) * G_t
    
    INTUITION: 
    - If action led to high return → increase its probability
    - If action led to low return → decrease its probability
    """
    
    def __init__(self, state_dim, n_actions, hidden_dims=[64, 64],
                 lr=0.001, gamma=0.99):
        
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.gamma = gamma
        
        # Policy network: outputs action probabilities
        self.policy_network = self._build_network(hidden_dims)
        self.optimizer = keras.optimizers.Adam(learning_rate=lr)
        
        # Episode storage
        self.states = []
        self.actions = []
        self.rewards = []
    
    def _build_network(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        
        # Output: probabilities over actions
        model.add(layers.Dense(self.n_actions, activation='softmax'))
        return model
    
    def select_action(self, state):
        """Sample action from policy distribution"""
        state = np.array(state).reshape(1, -1)
        probs = self.policy_network(state, training=False)[0].numpy()
        action = np.random.choice(self.n_actions, p=probs)
        return action
    
    def store_transition(self, state, action, reward):
        self.states.append(state)
        self.actions.append(action)
        self.rewards.append(reward)
    
    def compute_returns(self):
        """
        Calculate discounted returns for each timestep
        G_t = R_t + γR_{t+1} + γ²R_{t+2} + ...
        """
        returns = []
        G = 0
        for reward in reversed(self.rewards):
            G = reward + self.gamma * G
            returns.insert(0, G)
        
        # Normalize returns (crucial for stable learning!)
        returns = np.array(returns)
        returns = (returns - returns.mean()) / (returns.std() + 1e-8)
        return returns
    
    def learn(self):
        """
        Policy gradient update at end of episode
        
        Loss = -Σ log(π(a|s)) * G  (negative because we maximize)
        """
        returns = self.compute_returns()
        states = np.array(self.states)
        actions = np.array(self.actions)
        
        with tf.GradientTape() as tape:
            probs = self.policy_network(states, training=True)
            action_masks = tf.one_hot(actions, self.n_actions)
            
            # Log probabilities of taken actions
            log_probs = tf.math.log(tf.reduce_sum(probs * action_masks, axis=1) + 1e-8)
            
            # Policy gradient loss: -log(π) * G
            loss = -tf.reduce_mean(log_probs * returns)
        
        gradients = tape.gradient(loss, self.policy_network.trainable_variables)
        self.optimizer.apply_gradients(zip(gradients, self.policy_network.trainable_variables))
        
        # Clear episode storage
        self.states = []
        self.actions = []
        self.rewards = []
        
        return loss.numpy()


class REINFORCEBaseline:
    """
    REINFORCE with Baseline: Reduce variance
    
    WHAT: Subtract baseline from returns
    
    WHY: 
    - Raw returns have high variance
    - Baseline reduces variance without adding bias
    - Much faster learning!
    
    HOW: Use V(s) as baseline
         Advantage = G - V(s)
    """
    
    def __init__(self, state_dim, n_actions, hidden_dims=[64, 64],
                 lr_policy=0.001, lr_value=0.001, gamma=0.99):
        
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.gamma = gamma
        
        # Policy network (actor)
        self.policy_network = self._build_policy_network(hidden_dims)
        self.policy_optimizer = keras.optimizers.Adam(learning_rate=lr_policy)
        
        # Value network (baseline/critic)
        self.value_network = self._build_value_network(hidden_dims)
        self.value_optimizer = keras.optimizers.Adam(learning_rate=lr_value)
        
        self.states = []
        self.actions = []
        self.rewards = []
    
    def _build_policy_network(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(self.n_actions, activation='softmax'))
        return model
    
    def _build_value_network(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(1))  # Single value output
        return model
    
    def learn(self):
        returns = self.compute_returns()
        states = np.array(self.states)
        actions = np.array(self.actions)
        
        # Update value network (baseline)
        with tf.GradientTape() as tape:
            values = self.value_network(states, training=True)
            value_loss = tf.reduce_mean(tf.square(returns - tf.squeeze(values)))
        
        value_grads = tape.gradient(value_loss, self.value_network.trainable_variables)
        self.value_optimizer.apply_gradients(
            zip(value_grads, self.value_network.trainable_variables))
        
        # Compute advantages: A = G - V(s)
        values = self.value_network(states, training=False).numpy().flatten()
        advantages = returns - values
        advantages = (advantages - advantages.mean()) / (advantages.std() + 1e-8)
        
        # Update policy network using advantages
        with tf.GradientTape() as tape:
            probs = self.policy_network(states, training=True)
            action_masks = tf.one_hot(actions, self.n_actions)
            log_probs = tf.math.log(tf.reduce_sum(probs * action_masks, axis=1) + 1e-8)
            policy_loss = -tf.reduce_mean(log_probs * advantages)  # Use advantages!
        
        policy_grads = tape.gradient(policy_loss, self.policy_network.trainable_variables)
        self.policy_optimizer.apply_gradients(
            zip(policy_grads, self.policy_network.trainable_variables))
        # filepath: /Users/kishorkumarparoi/Awesome-Resources/ML/2-ML-Algorithms/reinforce.py
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class REINFORCE:
    """
    REINFORCE: Monte Carlo Policy Gradient
    
    WHAT: Learn policy directly by gradient ascent on expected return
    
    WHY:
    - Can learn stochastic policies
    - Works with continuous actions
    - Directly optimizes what we care about
    
    HOW: ∇J(θ) ≈ Σ_t ∇log π(a_t|s_t;θ) * G_t
    
    INTUITION: 
    - If action led to high return → increase its probability
    - If action led to low return → decrease its probability
    """
    
    def __init__(self, state_dim, n_actions, hidden_dims=[64, 64],
                 lr=0.001, gamma=0.99):
        
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.gamma = gamma
        
        # Policy network: outputs action probabilities
        self.policy_network = self._build_network(hidden_dims)
        self.optimizer = keras.optimizers.Adam(learning_rate=lr)
        
        # Episode storage
        self.states = []
        self.actions = []
        self.rewards = []
    
    def _build_network(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        
        # Output: probabilities over actions
        model.add(layers.Dense(self.n_actions, activation='softmax'))
        return model
    
    def select_action(self, state):
        """Sample action from policy distribution"""
        state = np.array(state).reshape(1, -1)
        probs = self.policy_network(state, training=False)[0].numpy()
        action = np.random.choice(self.n_actions, p=probs)
        return action
    
    def store_transition(self, state, action, reward):
        self.states.append(state)
        self.actions.append(action)
        self.rewards.append(reward)
    
    def compute_returns(self):
        """
        Calculate discounted returns for each timestep
        G_t = R_t + γR_{t+1} + γ²R_{t+2} + ...
        """
        returns = []
        G = 0
        for reward in reversed(self.rewards):
            G = reward + self.gamma * G
            returns.insert(0, G)
        
        # Normalize returns (crucial for stable learning!)
        returns = np.array(returns)
        returns = (returns - returns.mean()) / (returns.std() + 1e-8)
        return returns
    
    def learn(self):
        """
        Policy gradient update at end of episode
        
        Loss = -Σ log(π(a|s)) * G  (negative because we maximize)
        """
        returns = self.compute_returns()
        states = np.array(self.states)
        actions = np.array(self.actions)
        
        with tf.GradientTape() as tape:
            probs = self.policy_network(states, training=True)
            action_masks = tf.one_hot(actions, self.n_actions)
            
            # Log probabilities of taken actions
            log_probs = tf.math.log(tf.reduce_sum(probs * action_masks, axis=1) + 1e-8)
            
            # Policy gradient loss: -log(π) * G
            loss = -tf.reduce_mean(log_probs * returns)
        
        gradients = tape.gradient(loss, self.policy_network.trainable_variables)
        self.optimizer.apply_gradients(zip(gradients, self.policy_network.trainable_variables))
        
        # Clear episode storage
        self.states = []
        self.actions = []
        self.rewards = []
        
        return loss.numpy()


class REINFORCEBaseline:
    """
    REINFORCE with Baseline: Reduce variance
    
    WHAT: Subtract baseline from returns
    
    WHY: 
    - Raw returns have high variance
    - Baseline reduces variance without adding bias
    - Much faster learning!
    
    HOW: Use V(s) as baseline
         Advantage = G - V(s)
    """
    
    def __init__(self, state_dim, n_actions, hidden_dims=[64, 64],
                 lr_policy=0.001, lr_value=0.001, gamma=0.99):
        
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.gamma = gamma
        
        # Policy network (actor)
        self.policy_network = self._build_policy_network(hidden_dims)
        self.policy_optimizer = keras.optimizers.Adam(learning_rate=lr_policy)
        
        # Value network (baseline/critic)
        self.value_network = self._build_value_network(hidden_dims)
        self.value_optimizer = keras.optimizers.Adam(learning_rate=lr_value)
        
        self.states = []
        self.actions = []
        self.rewards = []
    
    def _build_policy_network(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(self.n_actions, activation='softmax'))
        return model
    
    def _build_value_network(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(1))  # Single value output
        return model
    
    def learn(self):
        returns = self.compute_returns()
        states = np.array(self.states)
        actions = np.array(self.actions)
        
        # Update value network (baseline)
        with tf.GradientTape() as tape:
            values = self.value_network(states, training=True)
            value_loss = tf.reduce_mean(tf.square(returns - tf.squeeze(values)))
        
        value_grads = tape.gradient(value_loss, self.value_network.trainable_variables)
        self.value_optimizer.apply_gradients(
            zip(value_grads, self.value_network.trainable_variables))
        
        # Compute advantages: A = G - V(s)
        values = self.value_network(states, training=False).numpy().flatten()
        advantages = returns - values
        advantages = (advantages - advantages.mean()) / (advantages.std() + 1e-8)
        
        # Update policy network using advantages
        with tf.GradientTape() as tape:
            probs = self.policy_network(states, training=True)
            action_masks = tf.one_hot(actions, self.n_actions)
            log_probs = tf.math.log(tf.reduce_sum(probs * action_masks, axis=1) + 1e-8)
            policy_loss = -tf.reduce_mean(log_probs * advantages)  # Use advantages!
        
        policy_grads = tape.gradient(policy_loss, self.policy_network.trainable_variables)
        self.policy_optimizer.apply_gradients(
            zip(policy_grads, self.policy_network.trainable_variables))
    
    def compute_returns(self):
        """Calculate discounted returns"""
        returns = []
        G = 0
        for reward in reversed(self.rewards):
            G = reward + self.gamma * G
            returns.insert(0, G)
        return np.array(returns)

---

## 7. Actor-Critic Methods

### Why Actor-Critic?

**What?** Combine policy-based (actor) and value-based (critic) approaches.

**Why?**
- **Actor**: Learns policy π(a|s) - decides what to do
- **Critic**: Learns value V(s) or Q(s,a) - evaluates how good actions are
- **Best of both**: Lower variance than REINFORCE, works with continuous actions

```
┌─────────────────────────────────────────────────────────────┐
│                     ACTOR-CRITIC                            │
│                                                             │
│   ┌─────────┐                          ┌─────────┐         │
│   │  ACTOR  │ ───── selects action ──► │   ENV   │         │
│   │   π(a|s)│                          │         │         │
│   └────▲────┘                          └────┬────┘         │
│        │                                    │              │
│        │ policy gradient                    │ reward, s'   │
│        │ using advantage                    │              │
│        │                                    ▼              │
│   ┌────┴────┐                          ┌─────────┐         │
│   │ CRITIC  │ ◄─── TD error ────────── │  TD(0)  │         │
│   │  V(s)   │                          │ update  │         │
│   └─────────┘                          └─────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Advantage Actor-Critic (A2C)

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class A2C:
    """
    Advantage Actor-Critic (A2C)
    
    WHAT: Actor-Critic with advantage function for variance reduction
    
    WHY:
    - Lower variance than REINFORCE (uses TD instead of MC)
    - More stable than pure policy gradient
    - Can learn online (every step)
    
    HOW:
    - Actor: π(a|s;θ) - policy network
    - Critic: V(s;w) - value network
    - Advantage: A(s,a) = R + γV(s') - V(s) = TD error
    - Update actor using: ∇log π(a|s) * A(s,a)
    """
    
    def __init__(self, state_dim, n_actions, hidden_dims=[64, 64],
                 lr_actor=0.001, lr_critic=0.001, gamma=0.99,
                 entropy_coef=0.01):
        
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.gamma = gamma
        self.entropy_coef = entropy_coef  # Encourages exploration
        
        # Build networks
        self.actor = self._build_actor(hidden_dims)
        self.critic = self._build_critic(hidden_dims)
        
        self.actor_optimizer = keras.optimizers.Adam(learning_rate=lr_actor)
        self.critic_optimizer = keras.optimizers.Adam(learning_rate=lr_critic)
    
    def _build_actor(self, hidden_dims):
        """Policy network: state → action probabilities"""
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(self.n_actions, activation='softmax'))
        return model
    
    def _build_critic(self, hidden_dims):
        """Value network: state → value"""
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(1))
        return model
    
    def select_action(self, state):
        """Sample action from policy"""
        state = np.array(state).reshape(1, -1)
        probs = self.actor(state, training=False)[0].numpy()
        action = np.random.choice(self.n_actions, p=probs)
        return action
    
    def learn(self, state, action, reward, next_state, done):
        """
        One-step Actor-Critic update
        
        KEY INSIGHT: Update every step, not every episode!
        This is what makes it TD-based and lower variance.
        """
        state = np.array(state).reshape(1, -1)
        next_state = np.array(next_state).reshape(1, -1)
        
        # Compute TD target and advantage
        value = self.critic(state, training=False)[0, 0]
        next_value = self.critic(next_state, training=False)[0, 0]
        
        # TD target: R + γV(s')
        td_target = reward + (0 if done else self.gamma * next_value)
        
        # Advantage: TD error = R + γV(s') - V(s)
        advantage = td_target - value
        
        # Update Critic (minimize TD error)
        with tf.GradientTape() as tape:
            value_pred = self.critic(state, training=True)[0, 0]
            critic_loss = tf.square(td_target - value_pred)
        
        critic_grads = tape.gradient(critic_loss, self.critic.trainable_variables)
        self.critic_optimizer.apply_gradients(
            zip(critic_grads, self.critic.trainable_variables))
        
        # Update Actor (policy gradient with advantage)
        with tf.GradientTape() as tape:
            probs = self.actor(state, training=True)[0]
            action_prob = probs[action]
            log_prob = tf.math.log(action_prob + 1e-8)
            
            # Entropy bonus for exploration
            entropy = -tf.reduce_sum(probs * tf.math.log(probs + 1e-8))
            
            # Actor loss: -log(π) * A - entropy_bonus
            actor_loss = -log_prob * advantage - self.entropy_coef * entropy
        
        actor_grads = tape.gradient(actor_loss, self.actor.trainable_variables)
        self.actor_optimizer.apply_gradients(
            zip(actor_grads, self.actor.trainable_variables))
        
        return float(actor_loss), float(critic_loss)
    
    def train(self, env, n_episodes=1000):
        rewards_history = []
        
        for episode in range(n_episodes):
            state = env.reset()
            total_reward = 0
            done = False
            
            while not done:
                action = self.select_action(state)
                next_state, reward, done = env.step(state, action)
                
                # Learn every step!
                self.learn(state, action, reward, next_state, done)
                
                total_reward += reward
                state = next_state
            
            rewards_history.append(total_reward)
            
            if (episode + 1) % 100 == 0:
                avg = np.mean(rewards_history[-100:])
                print(f"Episode {episode + 1}, Avg Reward: {avg:.2f}")
        
        return rewards_history
````

### A3C (Asynchronous Advantage Actor-Critic)

**What?** Multiple parallel actors learning simultaneously.

**Why?**
- Faster training through parallelization
- More diverse experience (decorrelates samples)
- No replay buffer needed

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
import threading
import multiprocessing

class A3C:
    """
    Asynchronous Advantage Actor-Critic (A3C)
    
    WHAT: Multiple workers learning in parallel, updating shared network
    
    WHY:
    - Parallelization = faster training
    - Different workers explore different parts of state space
    - Naturally decorrelates samples (no replay buffer needed!)
    
    HOW:
    1. Global network (shared parameters)
    2. Each worker has local copy
    3. Workers collect experience and compute gradients
    4. Gradients applied to global network asynchronously
    """
    
    def __init__(self, state_dim, n_actions, n_workers=4):
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.n_workers = n_workers
        self.gamma = 0.99
        
        # Global networks (shared across workers)
        self.global_actor = self._build_actor()
        self.global_critic = self._build_critic()
        
        self.actor_optimizer = keras.optimizers.Adam(learning_rate=0.001)
        self.critic_optimizer = keras.optimizers.Adam(learning_rate=0.001)
        
        # Lock for thread-safe updates
        self.lock = threading.Lock()
    
    def _build_actor(self):
        model = keras.Sequential([
            keras.layers.Input(shape=(self.state_dim,)),
            keras.layers.Dense(64, activation='relu'),
            keras.layers.Dense(64, activation='relu'),
            keras.layers.Dense(self.n_actions, activation='softmax')
        ])
        return model
    
    def _build_critic(self):
        model = keras.Sequential([
            keras.layers.Input(shape=(self.state_dim,)),
            keras.layers.Dense(64, activation='relu'),
            keras.layers.Dense(64, activation='relu'),
            keras.layers.Dense(1)
        ])
        return model
    
    def worker(self, worker_id, env_fn, n_steps=5):
        """
        Worker thread that collects experience and updates global network
        
        n_steps: number of steps before updating (n-step returns)
        """
        # Create local copy of environment
        env = env_fn()
        
        # Local networks (copy of global)
        local_actor = self._build_actor()
        local_critic = self._build_critic()
        
        while True:  # Run forever (or until stopped)
            # Sync local networks with global
            local_actor.set_weights(self.global_actor.get_weights())
            local_critic.set_weights(self.global_critic.get_weights())
            
            # Collect n-step experience
            states, actions, rewards, dones = [], [], [], []
            state = env.reset()
            
            for _ in range(n_steps):
                probs = local_actor(np.array([state]), training=False)[0].numpy()
                action = np.random.choice(self.n_actions, p=probs)
                
                next_state, reward, done = env.step(state, action)
                
                states.append(state)
                actions.append(action)
                rewards.append(reward)
                dones.append(done)
                
                state = next_state
                if done:
                    state = env.reset()
            
            # Compute n-step returns and advantages
            returns = self._compute_returns(rewards, dones, 
                                           local_critic(np.array([state]))[0, 0])
            
            # Compute gradients
            states = np.array(states)
            
            with tf.GradientTape() as actor_tape, tf.GradientTape() as critic_tape:
                values = local_critic(states, training=True)[:, 0]
                advantages = returns - values
                
                # Actor loss
                probs = local_actor(states, training=True)
                action_masks = tf.one_hot(actions, self.n_actions)
                log_probs = tf.math.log(tf.reduce_sum(probs * action_masks, axis=1) + 1e-8)
                actor_loss = -tf.reduce_mean(log_probs * tf.stop_gradient(advantages))
                
                # Critic loss
                critic_loss = tf.reduce_mean(tf.square(returns - values))
            
            actor_grads = actor_tape.gradient(actor_loss, local_actor.trainable_variables)
            critic_grads = critic_tape.gradient(critic_loss, local_critic.trainable_variables)
            
            # Apply gradients to global network (thread-safe)
            with self.lock:
                self.actor_optimizer.apply_gradients(
                    zip(actor_grads, self.global_actor.trainable_variables))
                self.critic_optimizer.apply_gradients(
                    zip(critic_grads, self.global_critic.trainable_variables))
    
    def _compute_returns(self, rewards, dones, bootstrap_value):
        """Compute n-step returns"""
        returns = []
        R = bootstrap_value
        for reward, done in zip(reversed(rewards), reversed(dones)):
            R = reward + (0 if done else self.gamma * R)
            returns.insert(0, R)
        return np.array(returns, dtype=np.float32)
````

---

## 8. Advanced Policy Gradient Methods

### Trust Region Policy Optimization (TRPO)

**What?** Constrain policy updates to prevent catastrophic changes.

**Why?**
- Policy gradient can make huge destructive updates
- TRPO limits how much policy can change
- More stable learning

**Key Idea**: Update policy while keeping KL divergence small.

$$\max_\theta \mathbb{E}\left[\frac{\pi_\theta(a|s)}{\pi_{\theta_{old}}(a|s)} A(s,a)\right]$$
$$\text{subject to } D_{KL}(\pi_{\theta_{old}} || \pi_\theta) \leq \delta$$

### Proximal Policy Optimization (PPO)

**What?** Simpler alternative to TRPO using clipped objective.

**Why PPO is so popular:**
- Simple to implement
- Good performance
- Stable training
- **Used in ChatGPT's RLHF!**

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class PPO:
    """
    Proximal Policy Optimization (PPO)
    
    WHAT: Policy gradient with clipped surrogate objective
    
    WHY:
    - Simple implementation (no second-order optimization like TRPO)
    - Very stable training
    - State-of-the-art performance
    - Used in ChatGPT, robotics, games
    
    HOW:
    1. Collect batch of trajectories with current policy
    2. Compute advantages
    3. Update policy multiple times with clipped objective
    4. Repeat
    
    KEY INNOVATION: Clipped surrogate objective
    L_CLIP = min(r(θ)A, clip(r(θ), 1-ε, 1+ε)A)
    
    where r(θ) = π_new(a|s) / π_old(a|s)
    """
    
    def __init__(self, state_dim, n_actions, hidden_dims=[64, 64],
                 lr_actor=0.0003, lr_critic=0.001, gamma=0.99,
                 gae_lambda=0.95, clip_epsilon=0.2, 
                 entropy_coef=0.01, n_epochs=10, batch_size=64):
        
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.gamma = gamma
        self.gae_lambda = gae_lambda      # For GAE advantage estimation
        self.clip_epsilon = clip_epsilon   # PPO clip range
        self.entropy_coef = entropy_coef
        self.n_epochs = n_epochs           # PPO epochs per update
        self.batch_size = batch_size
        
        # Actor (policy) network
        self.actor = self._build_actor(hidden_dims)
        self.actor_optimizer = keras.optimizers.Adam(learning_rate=lr_actor)
        
        # Critic (value) network
        self.critic = self._build_critic(hidden_dims)
        self.critic_optimizer = keras.optimizers.Adam(learning_rate=lr_critic)
        
        # Storage for batch
        self.states = []
        self.actions = []
        self.rewards = []
        self.dones = []
        self.log_probs = []
        self.values = []
    
    def _build_actor(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(self.n_actions, activation='softmax'))
        return model
    
    def _build_critic(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(1))
        return model
    
    def select_action(self, state):
        """Select action and store log probability"""
        state = np.array(state).reshape(1, -1)
        probs = self.actor(state, training=False)[0].numpy()
        value = self.critic(state, training=False)[0, 0].numpy()
        
        action = np.random.choice(self.n_actions, p=probs)
        log_prob = np.log(probs[action] + 1e-8)
        
        return action, log_prob, value
    
    def store_transition(self, state, action, reward, done, log_prob, value):
        """Store transition for batch learning"""
        self.states.append(state)
        self.actions.append(action)
        self.rewards.append(reward)
        self.dones.append(done)
        self.log_probs.append(log_prob)
        self.values.append(value)
    
    def compute_gae(self, last_value):
        """
        Generalized Advantage Estimation (GAE)
        
        WHY: Balances bias vs variance in advantage estimation
        
        A_t = δ_t + (γλ)δ_{t+1} + (γλ)²δ_{t+2} + ...
        where δ_t = r_t + γV(s_{t+1}) - V(s_t)
        
        λ=0: A = δ (TD, low variance, high bias)
        λ=1: A = G - V (MC, high variance, low bias)
        """
        advantages = []
        gae = 0
        
        values = self.values + [last_value]
        
        for t in reversed(range(len(self.rewards))):
            delta = self.rewards[t] + self.gamma * values[t+1] * (1 - self.dones[t]) - values[t]
            gae = delta + self.gamma * self.gae_lambda * (1 - self.dones[t]) * gae
            advantages.insert(0, gae)
        
        advantages = np.array(advantages, dtype=np.float32)
        returns = advantages + np.array(self.values, dtype=np.float32)
        
        # Normalize advantages
        advantages = (advantages - advantages.mean()) / (advantages.std() + 1e-8)
        
        return advantages, returns
    
    def learn(self, last_value):
        """
        PPO update: multiple epochs on collected batch
        """
        advantages, returns = self.compute_gae(last_value)
        
        # Convert to arrays
        states = np.array(self.states, dtype=np.float32)
        actions = np.array(self.actions)
        old_log_probs = np.array(self.log_probs, dtype=np.float32)
        
        # Multiple epochs of updates
        for epoch in range(self.n_epochs):
            # Create random mini-batches
            indices = np.random.permutation(len(states))
            
            for start in range(0, len(states), self.batch_size):
                end = start + self.batch_size
                batch_idx = indices[start:end]
                
                batch_states = states[batch_idx]
                batch_actions = actions[batch_idx]
                batch_old_log_probs = old_log_probs[batch_idx]
                batch_advantages = advantages[batch_idx]
                batch_returns = returns[batch_idx]
                
                # Update actor
                with tf.GradientTape() as tape:
                    probs = self.actor(batch_states, training=True)
                    action_masks = tf.one_hot(batch_actions, self.n_actions)
                    new_probs = tf.reduce_sum(probs * action_masks, axis=1)
                    new_log_probs = tf.math.log(new_probs + 1e-8)
                    
                    # Probability ratio: π_new / π_old
                    ratio = tf.exp(new_log_probs - batch_old_log_probs)
                    
                    # Clipped surrogate objective
                    surr1 = ratio * batch_advantages
                    surr2 = tf.clip_by_value(ratio, 
                                            1 - self.clip_epsilon, 
                                            1 + self.clip_epsilon) * batch_advantages
                    
                    # PPO loss: take minimum (pessimistic bound)
                    actor_loss = -tf.reduce_mean(tf.minimum(surr1, surr2))
                    
                    # Entropy bonus for exploration
                    entropy = -tf.reduce_mean(tf.reduce_sum(probs * tf.math.log(probs + 1e-8), axis=1))
                    actor_loss -= self.entropy_coef * entropy
                
                actor_grads = tape.gradient(actor_loss, self.actor.trainable_variables)
                self.actor_optimizer.apply_gradients(
                    zip(actor_grads, self.actor.trainable_variables))
                
                # Update critic
                with tf.GradientTape() as tape:
                    values = self.critic(batch_states, training=True)[:, 0]
                    critic_loss = tf.reduce_mean(tf.square(batch_returns - values))
                
                critic_grads = tape.gradient(critic_loss, self.critic.trainable_variables)
                self.critic_optimizer.apply_gradients(
                    zip(critic_grads, self.critic.trainable_variables))
        
        # Clear storage
        self.states = []
        self.actions = []
        self.rewards = []
        self.dones = []
        self.log_probs = []
        self.values = []
        
        return float(actor_loss), float(critic_loss)
    
    def train(self, env, n_episodes=1000, update_interval=2048):
        """Train PPO agent"""
        rewards_history = []
        timestep = 0
        
        for episode in range(n_episodes):
            state = env.reset()
            total_reward = 0
            done = False
            
            while not done:
                action, log_prob, value = self.select_action(state)
                next_state, reward, done = env.step(state, action)
                
                self.store_transition(state, action, reward, done, log_prob, value)
                
                total_reward += reward
                state = next_state
                timestep += 1
                
                # Update when enough samples collected
                if timestep % update_interval == 0:
                    last_value = self.critic(np.array([state]))[0, 0].numpy()
                    self.learn(last_value)
            
            rewards_history.append(total_reward)
            
            if (episode + 1) % 100 == 0:
                avg = np.mean(rewards_history[-100:])
                print(f"Episode {episode + 1}, Avg Reward: {avg:.2f}")
        
        return rewards_history
````

---

## 9. Continuous Action Space Methods

### Why Different Methods for Continuous Actions?

| Discrete Actions | Continuous Actions |
|-----------------|-------------------|
| Output: probabilities over N actions | Output: parameters of distribution (μ, σ) |
| Sample: categorical | Sample: Gaussian |
| DQN, vanilla policy gradient | DDPG, TD3, SAC |

### Deep Deterministic Policy Gradient (DDPG)

**What?** DQN-style algorithm for continuous actions.

**Why?**
- Can't do max over continuous actions
- Learn deterministic policy μ(s) directly
- Use separate critic Q(s,a) for evaluation

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from collections import deque
import random

class OUNoise:
    """
    Ornstein-Uhlenbeck Noise for exploration
    
    WHY: Better exploration for continuous control than Gaussian
    HOW: Correlated noise that provides smoother exploration
    """
    def __init__(self, action_dim, mu=0, theta=0.15, sigma=0.2):
        self.action_dim = action_dim
        self.mu = mu
        self.theta = theta
        self.sigma = sigma
        self.state = np.ones(action_dim) * mu
    
    def reset(self):
        self.state = np.ones(self.action_dim) * self.mu
    
    def sample(self):
        dx = self.theta * (self.mu - self.state) + self.sigma * np.random.randn(self.action_dim)
        self.state += dx
        return self.state


class DDPG:
    """
    Deep Deterministic Policy Gradient (DDPG)
    
    WHAT: Actor-Critic for continuous actions with deterministic policy
    
    WHY:
    - Can't enumerate all continuous actions for max
    - Deterministic policy is easier to learn than stochastic
    
    HOW:
    - Actor μ(s): outputs continuous action directly
    - Critic Q(s,a): evaluates state-action pairs
    - Target networks for stability
    - Experience replay
    
    Update rules:
    - Critic: minimize (Q(s,a) - (r + γQ'(s', μ'(s'))))²
    - Actor: maximize Q(s, μ(s)) via gradient ascent
    """
    
    def __init__(self, state_dim, action_dim, action_high,
                 hidden_dims=[400, 300], lr_actor=0.0001, lr_critic=0.001,
                 gamma=0.99, tau=0.005, buffer_size=1000000, batch_size=64):
        
        self.state_dim = state_dim
        self.action_dim = action_dim
        self.action_high = action_high  # Max action value
        self.gamma = gamma
        self.tau = tau  # Soft update parameter
        self.batch_size = batch_size
        
        # Actor networks (policy)
        self.actor = self._build_actor(hidden_dims)
        self.actor_target = self._build_actor(hidden_dims)
        self.actor_target.set_weights(self.actor.get_weights())
        self.actor_optimizer = keras.optimizers.Adam(learning_rate=lr_actor)
        
        # Critic networks (Q-function)
        self.critic = self._build_critic(hidden_dims)
        self.critic_target = self._build_critic(hidden_dims)
        self.critic_target.set_weights(self.critic.get_weights())
        self.critic_optimizer = keras.optimizers.Adam(learning_rate=lr_critic)
        
        # Replay buffer
        self.buffer = deque(maxlen=buffer_size)
        
        # Exploration noise
        self.noise = OUNoise(action_dim)
    
    def _build_actor(self, hidden_dims):
        """Actor: state → action"""
        inputs = layers.Input(shape=(self.state_dim,))
        x = inputs
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        # Output: action scaled to action space
        outputs = layers.Dense(self.action_dim, activation='tanh')(x)
        outputs = outputs * self.action_high  # Scale to action range
        return keras.Model(inputs, outputs)
    
    def _build_critic(self, hidden_dims):
        """Critic: (state, action) → Q-value"""
        state_input = layers.Input(shape=(self.state_dim,))
        action_input = layers.Input(shape=(self.action_dim,))
        
        # Concatenate state and action
        x = layers.Concatenate()([state_input, action_input])
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        outputs = layers.Dense(1)(x)
        
        return keras.Model([state_input, action_input], outputs)
    
    def select_action(self, state, add_noise=True):
        """Select action with optional exploration noise"""
        state = np.array(state).reshape(1, -1)
        action = self.actor(state, training=False)[0].numpy()
        
        if add_noise:
            action += self.noise.sample()
        
        return np.clip(action, -self.action_high, self.action_high)
    
    def store_transition(self, state, action, reward, next_state, done):
        self.buffer.append((state, action, reward, next_state, done))
    
    def soft_update(self, target, source):
        """Soft update: target = τ*source + (1-τ)*target"""
        for target_var, source_var in zip(target.trainable_variables, 
                                          source.trainable_variables):
            target_var.assign(self.tau * source_var + (1 - self.tau) * target_var)
    
    def learn(self):
        if len(self.buffer) < self.batch_size:
            return 0, 0
        
        # Sample batch
        batch = random.sample(self.buffer, self.batch_size)
        states, actions, rewards, next_states, dones = zip(*batch)
        
        states = np.array(states, dtype=np.float32)
        actions = np.array(actions, dtype=np.float32)
        rewards = np.array(rewards, dtype=np.float32)
        next_states = np.array(next_states, dtype=np.float32)
        dones = np.array(dones, dtype=np.float32)
        
        # Update Critic
        with tf.GradientTape() as tape:
            # Target Q: r + γ * Q'(s', μ'(s'))
            next_actions = self.actor_target(next_states, training=False)
            target_q = self.critic_target([next_states, next_actions], training=False)[:, 0]
            target_q = rewards + (1 - dones) * self.gamma * target_q
            
            # Current Q
            current_q = self.critic([states, actions], training=True)[:, 0]
            
            critic_loss = tf.reduce_mean(tf.square(target_q - current_q))
        
        critic_grads = tape.gradient(critic_loss, self.critic.trainable_variables)
        self.critic_optimizer.apply_gradients(
            zip(critic_grads, self.critic.trainable_variables))
        
        # Update Actor
        with tf.GradientTape() as tape:
            # Actor loss: -Q(s, μ(s)) (maximize Q by gradient ascent)
            actor_actions = self.actor(states, training=True)
            actor_loss = -tf.reduce_mean(
                self.critic([states, actor_actions], training=False))
        
        actor_grads = tape.gradient(actor_loss, self.actor.trainable_variables)
        self.actor_optimizer.apply_gradients(
            zip(actor_grads, self.actor.trainable_variables))
        
        # Soft update target networks
        self.soft_update(self.actor_target, self.actor)
        self.soft_update(self.critic_target, self.critic)
        
        return float(actor_loss), float(critic_loss)
````

### Twin Delayed DDPG (TD3)

**What?** DDPG with three key improvements.

**Why?** DDPG suffers from:
1. **Overestimation bias** → Twin critics (take min)
2. **High variance actor updates** → Delayed policy updates
3. **Error accumulation** → Target policy smoothing

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from collections import deque
import random

class TD3:
    """
    Twin Delayed Deep Deterministic Policy Gradient (TD3)
    
    WHAT: DDPG with three improvements
    
    WHY: Fix DDPG's issues:
    1. Overestimation → Twin critics (take minimum)
    2. High variance → Delayed policy updates
    3. Error accumulation → Target policy smoothing (add noise to target actions)
    
    HOW:
    - Two Q-networks (twins)
    - Update actor less frequently than critic
    - Add noise to target actions
    """
    
    def __init__(self, state_dim, action_dim, action_high,
                 hidden_dims=[400, 300], lr_actor=0.0001, lr_critic=0.001,
                 gamma=0.99, tau=0.005, policy_noise=0.2, noise_clip=0.5,
                 policy_delay=2, buffer_size=1000000, batch_size=100):
        
        self.state_dim = state_dim
        self.action_dim = action_dim
        self.action_high = action_high
        self.gamma = gamma
        self.tau = tau
        self.policy_noise = policy_noise
        self.noise_clip = noise_clip
        self.policy_delay = policy_delay
        self.batch_size = batch_size
        self.learn_step = 0
        
        # Actor networks
        self.actor = self._build_actor(hidden_dims)
        self.actor_target = self._build_actor(hidden_dims)
        self.actor_target.set_weights(self.actor.get_weights())
        self.actor_optimizer = keras.optimizers.Adam(learning_rate=lr_actor)
        
        # Twin Critic networks (KEY INNOVATION 1)
        self.critic1 = self._build_critic(hidden_dims)
        self.critic2 = self._build_critic(hidden_dims)
        self.critic1_target = self._build_critic(hidden_dims)
        self.critic2_target = self._build_critic(hidden_dims)
        self.critic1_target.set_weights(self.critic1.get_weights())
        self.critic2_target.set_weights(self.critic2.get_weights())
        self.critic_optimizer = keras.optimizers.Adam(learning_rate=lr_critic)
        
        self.buffer = deque(maxlen=buffer_size)
    
    def _build_actor(self, hidden_dims):
        inputs = layers.Input(shape=(self.state_dim,))
        x = inputs
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        outputs = layers.Dense(self.action_dim, activation='tanh')(x)
        outputs = outputs * self.action_high
        return keras.Model(inputs, outputs)
    
    def _build_critic(self, hidden_dims):
        state_input = layers.Input(shape=(self.state_dim,))
        action_input = layers.Input(shape=(self.action_dim,))
        x = layers.Concatenate()([state_input, action_input])
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        outputs = layers.Dense(1)(x)
        return keras.Model([state_input, action_input], outputs)
    
    def select_action(self, state, add_noise=True):
        state = np.array(state).reshape(1, -1)
        action = self.actor(state, training=False)[0].numpy()
        
        if add_noise:
            noise = np.random.normal(0, self.action_high * 0.1, size=self.action_dim)
            action += noise
        
        return np.clip(action, -self.action_high, self.action_high)
    
    def store_transition(self, state, action, reward, next_state, done):
        self.buffer.append((state, action, reward, next_state, done))
    
    def soft_update(self, target, source):
        for target_var, source_var in zip(target.trainable_variables, 
                                          source.trainable_variables):
            target_var.assign(self.tau * source_var + (1 - self.tau) * target_var)
    
    def learn(self):
        if len(self.buffer) < self.batch_size:
            return 0, 0
        
        self.learn_step += 1
        
        batch = random.sample(self.buffer, self.batch_size)
        states, actions, rewards, next_states, dones = zip(*batch)
        
        states = np.array(states, dtype=np.float32)
        actions = np.array(actions, dtype=np.float32)
        rewards = np.array(rewards, dtype=np.float32)
        next_states = np.array(next_states, dtype=np.float32)
        dones = np.array(dones, dtype=np.float32)
        
        # KEY INNOVATION 3: Target policy smoothing
        # Add clipped noise to target actions
        noise = np.clip(
            np.random.normal(0, self.policy_noise, actions.shape),
            -self.noise_clip, self.noise_clip
        )
        next_actions = self.actor_target(next_states, training=False) + noise
        next_actions = np.clip(next_actions, -self.action_high, self.action_high)
        
        # KEY INNOVATION 1: Twin critics - take minimum
        target_q1 = self.critic1_target([next_states, next_actions], training=False)[:, 0]
        target_q2 = self.critic2_target([next_states, next_actions], training=False)[:, 0]
        target_q = tf.minimum(target_q1, target_q2)  # Take minimum!
        target_q = rewards + (1 - dones) * self.gamma * target_q
        
        # Update critics
        with tf.GradientTape() as tape:
            current_q1 = self.critic1([states, actions], training=True)[:, 0]
            current_q2 = self.critic2([states, actions], training=True)[:, 0]
            
            critic_loss = tf.reduce_mean(tf.square(target_q - current_q1)) + \
                         tf.reduce_mean(tf.square(target_q - current_q2))
        
        critic_vars = self.critic1.trainable_variables + self.critic2.trainable_variables
        critic_grads = tape.gradient(critic_loss, critic_vars)
        self.critic_optimizer.apply_gradients(zip(critic_grads, critic_vars))
        
        actor_loss = 0
        
        # KEY INNOVATION 2: Delayed policy updates
        if self.learn_step % self.policy_delay == 0:
            with tf.GradientTape() as tape:
                actor_actions = self.actor(states, training=True)
                actor_loss = -tf.reduce_mean(
                    self.critic1([states, actor_actions], training=False))
            
            actor_grads = tape.gradient(actor_loss, self.actor.trainable_variables)
            self.actor_optimizer.apply_gradients(
                zip(actor_grads, self.actor.trainable_variables))
            
            # Soft update all targets
            self.soft_update(self.actor_target, self.actor)
            self.soft_update(self.critic1_target, self.critic1)
            self.soft_update(self.critic2_target, self.critic2)
        
        return float(actor_loss), float(critic_loss)
````

### Soft Actor-Critic (SAC)

**What?** Maximum entropy RL for continuous actions.

**Why?**
- More exploration through entropy maximization
- More robust policies
- State-of-the-art sample efficiency

**Key Idea**: Maximize reward AND entropy.
$$J(\pi) = \sum_t \mathbb{E}[r_t + \alpha \mathcal{H}(\pi(\cdot|s_t))]$$

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from collections import deque
import random

class SAC:
    """
    Soft Actor-Critic (SAC)
    
    WHAT: Maximum entropy RL with automatic temperature tuning
    
    WHY:
    - Better exploration (entropy bonus)
    - More robust policies (stochastic, handles uncertainty)
    - State-of-the-art sample efficiency
    
    HOW:
    - Maximize: reward + α * entropy
    - Stochastic policy: output μ and σ, sample from Gaussian
    - Twin critics (like TD3)
    - Automatic α tuning
    
    Objective: J(π) = Σ E[r + α * H(π(·|s))]
    
    α (temperature): controls exploration-exploitation tradeoff
    - High α: more random (exploration)
    - Low α: more deterministic (exploitation)
    """
    
    def __init__(self, state_dim, action_dim, action_high,
                 hidden_dims=[256, 256], lr=0.0003, gamma=0.99, tau=0.005,
                 alpha=0.2, auto_alpha=True, buffer_size=1000000, batch_size=256):
        
        self.state_dim = state_dim
        self.action_dim = action_dim
        self.action_high = action_high
        self.gamma = gamma
        self.tau = tau
        self.batch_size = batch_size
        
        # Temperature parameter
        self.alpha = alpha
        self.auto_alpha = auto_alpha
        if auto_alpha:
            self.target_entropy = -action_dim  # Heuristic
            self.log_alpha = tf.Variable(0.0, trainable=True)
            self.alpha_optimizer = keras.optimizers.Adam(learning_rate=lr)
        
        # Actor (stochastic policy)
        self.actor = self._build_actor(hidden_dims)
        self.actor_optimizer = keras.optimizers.Adam(learning_rate=lr)
        
        # Twin Critics
        self.critic1 = self._build_critic(hidden_dims)
        self.critic2 = self._build_critic(hidden_dims)
        self.critic1_target = self._build_critic(hidden_dims)
        self.critic2_target = self._build_critic(hidden_dims)
        self.critic1_target.set_weights(self.critic1.get_weights())
        self.critic2_target.set_weights(self.critic2.get_weights())
        self.critic_optimizer = keras.optimizers.Adam(learning_rate=lr)
        
        self.buffer = deque(maxlen=buffer_size)
    
    def _build_actor(self, hidden_dims):
        """
        Stochastic actor: outputs mean and log_std
        
        WHY log_std instead of std?
        - Can be any real number (std must be positive)
        - More numerically stable
        """
        inputs = layers.Input(shape=(self.state_dim,))
        x = inputs
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        
        # Output mean and log_std
        mean = layers.Dense(self.action_dim)(x)
        log_std = layers.Dense(self.action_dim)(x)
        log_std = tf.clip_by_value(log_std, -20, 2)  # Prevent extreme values
        
        return keras.Model(inputs, [mean, log_std])
    
    def _build_critic(self, hidden_dims):
        state_input = layers.Input(shape=(self.state_dim,))
        action_input = layers.Input(shape=(self.action_dim,))
        x = layers.Concatenate()([state_input, action_input])
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        outputs = layers.Dense(1)(x)
        return keras.Model([state_input, action_input], outputs)
    
    def sample_action(self, state, deterministic=False):
        """
        Sample action using reparameterization trick
        
        a = tanh(μ + σ * ε), where ε ~ N(0,1)
        """
        state = np.array(state).reshape(1, -1)
        mean, log_std = self.actor(state, training=False)
        std = tf.exp(log_std)
        
        if deterministic:
            action = tf.tanh(mean)
        else:
            # Reparameterization trick
            noise = tf.random.normal(tf.shape(mean))
            action = tf.tanh(mean + std * noise)
        
        return action[0].numpy() * self.action_high
    
    def _get_action_and_log_prob(self, states, training=True):
        """
        Get action and log probability for policy update
        
        Uses reparameterization for differentiable sampling
        """
        mean, log_std = self.actor(states, training=training)
        std = tf.exp(log_std)
        
        # Sample with reparameterization
        noise = tf.random.normal(tf.shape(mean))
        x = mean + std * noise
        action = tf.tanh(x)
        
        # Compute log probability (accounting for tanh squashing)
        # log π(a|s) = log N(x; μ, σ) - Σ log(1 - tanh²(x))
        log_prob = -0.5 * (tf.square((x - mean) / (std + 1e-8)) + 
                          2 * log_std + tf.math.log(2 * np.pi))
        log_prob = tf.reduce_sum(log_prob, axis=1)
        
        # Correction for tanh squashing
        log_prob -= tf.reduce_sum(tf.math.log(1 - tf.square(action) + 1e-6), axis=1)
        
        return action * self.action_high, log_prob
    
    def store_transition(self, state, action, reward, next_state, done):
        self.buffer.append((state, action, reward, next_state, done))
    
    def soft_update(self, target, source):
        for target_var, source_var in zip(target.trainable_variables, 
                                          source.trainable_variables):
            target_var.assign(self.tau * source_var + (1 - self.tau) * target_var)
    
    def learn(self):
        if len(self.buffer) < self.batch_size:
            return {}
        
        batch = random.sample(self.buffer, self.batch_size)
        states, actions, rewards, next_states, dones = zip(*batch)
        
        states = np.array(states, dtype=np.float32)
        actions = np.array(actions, dtype=np.float32)
        rewards = np.array(rewards, dtype=np.float32)
        next_states = np.array(next_states, dtype=np.float32)
        dones = np.array(dones, dtype=np.float32)
        
        # Get current alpha
        if self.auto_alpha:
            alpha = tf.exp(self.log_alpha)
        else:
            alpha = self.alpha
        
        # Sample next actions and their log probs
        next_actions, next_log_probs = self._get_action_and_log_prob(next_states)
        
        # Compute targets with entropy
        target_q1 = self.critic1_target([next_states, next_actions], training=False)[:, 0]
        target_q2 = self.critic2_target([next_states, next_actions], training=False)[:, 0]
        target_q = tf.minimum(target_q1, target_q2)
        target_q = target_q - alpha * next_log_probs  # Entropy regularization!
        target_q = rewards + (1 - dones) * self.gamma * target_q
        
        # Update critics
        with tf.GradientTape() as tape:
            current_q1 = self.critic1([states, actions], training=True)[:, 0]
            current_q2 = self.critic2([states, actions], training=True)[:, 0]
            critic_loss = tf.reduce_mean(tf.square(target_q - current_q1)) + \
                         tf.reduce_mean(tf.square(target_q - current_q2))
        
        critic_vars = self.critic1.trainable_variables + self.critic2.trainable_variables
        critic_grads = tape.gradient(critic_loss, critic_vars)
        self.critic_optimizer.apply_gradients(zip(critic_grads, critic_vars))
        
        # Update actor
        with tf.GradientTape() as tape:
            new_actions, log_probs = self._get_action_and_log_prob(states)
            q1 = self.critic1([states, new_actions], training=False)[:, 0]
            q2 = self.critic2([states, new_actions], training=False)[:, 0]
            q = tf.minimum(q1, q2)
            
            # Actor loss: minimize α*log_prob - Q (maximize Q - α*log_prob)
            actor_loss = tf.reduce_mean(alpha * log_probs - q)
        
        actor_grads = tape.gradient(actor_loss, self.actor.trainable_variables)
        self.actor_optimizer.apply_gradients(
            zip(actor_grads, self.actor.trainable_variables))
        
        # Update alpha (automatic temperature tuning)
        alpha_loss = 0
        if self.auto_alpha:
            with tf.GradientTape() as tape:
                _, log_probs = self._get_action_and_log_prob(states, training=False)
                alpha_loss = -tf.reduce_mean(
                    tf.exp(self.log_alpha) * (log_probs + self.target_entropy))
            
            alpha_grads = tape.gradient(alpha_loss, [self.log_alpha])
            self.alpha_optimizer.apply_gradients(zip(alpha_grads, [self.log_alpha]))
        
        # Soft update targets
        self.soft_update(self.critic1_target, self.critic1)
        self.soft_update(self.critic2_target, self.critic2)
        
        return {
            'critic_loss': float(critic_loss),
            'actor_loss': float(actor_loss),
            'alpha': float(alpha),
            'alpha_loss': float(alpha_loss)
        }
````

---

## 10. RLHF: Reinforcement Learning from Human Feedback

### What is RLHF?

**What?** Train AI models using human preferences instead of explicit rewards.

**Why?**
- Hard to specify reward functions for complex tasks
- Human preferences capture nuanced goals
- Powers ChatGPT, Claude, and modern LLMs!

**How?**

```
┌───────────────────────────────────────────────────────────────┐
│                        RLHF Pipeline                          │
│                                                               │
│  Step 1: Supervised Fine-Tuning (SFT)                        │
│  ┌─────────────┐    fine-tune    ┌─────────────┐             │
│  │ Base LLM    │ ──────────────► │  SFT Model  │             │
│  │ (pretrained)│    on demos     │             │             │
│  └─────────────┘                 └─────────────┘             │
│                                                               │
│  Step 2: Train Reward Model                                   │
│  ┌─────────────┐                 ┌─────────────┐             │
│  │   Human     │  preferences    │   Reward    │             │
│  │ comparisons │ ──────────────► │   Model     │             │
│  │  (A > B)    │                 │   r(x,y)    │             │
│  └─────────────┘                 └─────────────┘             │
│                                                               │
│  Step 3: RL Fine-Tuning (PPO)                                │
│  ┌─────────────┐    optimize     ┌─────────────┐             │
│  │  SFT Model  │ ──────────────► │ RLHF Model  │             │
│  │             │   with reward   │  (aligned)  │             │
│  └─────────────┘                 └─────────────┘             │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Step 1: Supervised Fine-Tuning

````python
# Conceptual SFT - fine-tune on demonstration data
# In practice: use Hugging Face Trainer with instruction data

from transformers import AutoModelForCausalLM, Trainer, TrainingArguments

def supervised_fine_tuning(base_model_name, train_dataset):
    """
    Step 1: Fine-tune base LLM on demonstration data
    
    WHY: Give model initial capability for the task
    HOW: Standard language model fine-tuning on (prompt, response) pairs
    """
    model = AutoModelForCausalLM.from_pretrained(base_model_name)
    
    training_args = TrainingArguments(
        output_dir="./sft_model",
        num_train_epochs=3,
        per_device_train_batch_size=4,
        learning_rate=2e-5,
    )
    
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
    )
    
    trainer.train()
    return model
````

### Step 2: Reward Model

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class RewardModel:
    """
    Reward Model for RLHF
    
    WHAT: Learn to predict human preferences
    
    WHY: 
    - Can't get reward for every response
    - Train on comparisons, generalize to new responses
    
    HOW:
    - Input: (prompt, response)
    - Output: scalar reward
    - Train with Bradley-Terry model on pairwise comparisons
    
    Loss: -log(σ(r(x,y_w) - r(x,y_l)))
    
    where y_w = preferred response, y_l = rejected response
    """
    
    def __init__(self, input_dim, hidden_dims=[256, 128]):
        self.model = self._build_model(input_dim, hidden_dims)
        self.optimizer = keras.optimizers.Adam(learning_rate=1e-5)
    
    def _build_model(self, input_dim, hidden_dims):
        """Simple reward model (in practice: fine-tuned LLM)"""
        model = keras.Sequential()
        model.add(layers.Input(shape=(input_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
            model.add(layers.Dropout(0.1))
        model.add(layers.Dense(1))  # Single scalar reward
        return model
    
    def get_reward(self, state):
        """Get reward for a (prompt, response) embedding"""
        return self.model(state, training=False)[0, 0].numpy()
    
    def train_on_comparisons(self, preferred, rejected):
        """
        Train on preference pairs
        
        preferred: embeddings of preferred responses
        rejected: embeddings of rejected responses
        
        Bradley-Terry loss: -log σ(r_w - r_l)
        """
        with tf.GradientTape() as tape:
            r_preferred = self.model(preferred, training=True)
            r_rejected = self.model(rejected, training=True)
            
            # Bradley-Terry loss
            # Higher reward for preferred → positive difference → high σ → low loss
            loss = -tf.reduce_mean(
                tf.math.log(tf.sigmoid(r_preferred - r_rejected) + 1e-8)
            )
        
        grads = tape.gradient(loss, self.model.trainable_variables)
        self.optimizer.apply_gradients(zip(grads, self.model.trainable_variables))
        
        return float(loss)


# Example comparison data format
class PreferenceDataset:
    """
    Dataset of human preferences
    
    Format: (prompt, response_A, response_B, preferred)
    where preferred ∈ {A, B}
    """
    
    def __init__(self):
        self.comparisons = []
    
    def add_comparison(self, prompt, response_a, response_b, preferred):
        """
        Add a human preference comparison
        
        preferred: 'A' or 'B' indicating which response human preferred
        """
        self.comparisons.append({
            'prompt': prompt,
            'response_a': response_a,
            'response_b': response_b,
            'preferred': preferred
        })
    
    def get_training_pairs(self):
        """Convert to (preferred, rejected) pairs"""
        preferred_responses = []
        rejected_responses = []
        
        for comp in self.comparisons:
            if comp['preferred'] == 'A':
                preferred_responses.append(comp['response_a'])
                rejected_responses.append(comp['response_b'])
            else:
                preferred_responses.append(comp['response_b'])
                rejected_responses.append(comp['response_a'])
        
        return preferred_responses, rejected_responses
````

### Step 3: PPO for Language Models

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras

class RLHF_PPO:
    """
    PPO for RLHF (Language Model Alignment)
    
    WHAT: Fine-tune LLM with PPO using reward model
    
    WHY: 
    - Align model with human preferences
    - PPO is stable and works well for LLMs
    
    HOW:
    - Policy: Language model π(token|context)
    - Reward: From reward model + KL penalty
    - Update: PPO with clipped objective
    
    KEY ADDITION: KL penalty to stay close to reference model
    reward_total = r(x,y) - β * KL(π || π_ref)
    
    WHY KL penalty?
    - Prevent policy from deviating too much
    - Maintain linguistic quality from pretraining
    - Avoid reward hacking
    """
    
    def __init__(self, policy_model, ref_model, reward_model,
                 lr=1e-6, clip_epsilon=0.2, kl_coef=0.1,
                 value_coef=0.5, entropy_coef=0.01):
        
        self.policy = policy_model      # Model being trained
        self.ref_model = ref_model      # Frozen reference model
        self.reward_model = reward_model
        
        self.clip_epsilon = clip_epsilon
        self.kl_coef = kl_coef          # KL penalty coefficient (β)
        self.value_coef = value_coef
        self.entropy_coef = entropy_coef
        
        self.optimizer = keras.optimizers.Adam(learning_rate=lr)
    
    def compute_rewards(self, prompts, responses):
        """
        Compute rewards with KL penalty
        
        r_total = r_reward_model(x,y) - β * KL(π || π_ref)
        """
        rewards = []
        
        for prompt, response in zip(prompts, responses):
            # Reward from reward model
            reward_score = self.reward_model.get_reward(
                self._encode(prompt, response))
            
            # KL divergence penalty
            policy_logprobs = self._get_logprobs(self.policy, prompt, response)
            ref_logprobs = self._get_logprobs(self.ref_model, prompt, response)
            kl_div = policy_logprobs - ref_logprobs  # Approximate KL
            
            # Total reward
            total_reward = reward_score - self.kl_coef * kl_div.mean()
            rewards.append(total_reward)
        
        return np.array(rewards)
    
    def _encode(self, prompt, response):
        """Encode prompt+response for reward model (placeholder)"""
        # In practice: use tokenizer and model embeddings
        return np.zeros((1, 256), dtype=np.float32)
    
    def _get_logprobs(self, model, prompt, response):
        """Get log probabilities of response tokens (placeholder)"""
        # In practice: forward pass through LLM
        return np.zeros(10, dtype=np.float32)
    
    def ppo_update(self, experiences):
        """
        PPimport numpy as np
import tensorflow as tf
from tensorflow import keras

class RLHF_PPO:
    """
    PPO for RLHF (Language Model Alignment)
    
    WHAT: Fine-tune LLM with PPO using reward model
    
    WHY: 
    - Align model with human preferences
    - PPO is stable and works well for LLMs
    
    HOW:
    - Policy: Language model π(token|context)
    - Reward: From reward model + KL penalty
    - Update: PPO with clipped objective
    
    KEY ADDITION: KL penalty to stay close to reference model
    reward_total = r(x,y) - β * KL(π || π_ref)
    
    WHY KL penalty?
    - Prevent policy from deviating too much
    - Maintain linguistic quality from pretraining
    - Avoid reward hacking
    """
    
    def __init__(self, policy_model, ref_model, reward_model,
                 lr=1e-6, clip_epsilon=0.2, kl_coef=0.1,
                 value_coef=0.5, entropy_coef=0.01):
        
        self.policy = policy_model      # Model being trained
        self.ref_model = ref_model      # Frozen reference model
        self.reward_model = reward_model
        
        self.clip_epsilon = clip_epsilon
        self.kl_coef = kl_coef          # KL penalty coefficient (β)
        self.value_coef = value_coef
        self.entropy_coef = entropy_coef
        
        self.optimizer = keras.optimizers.Adam(learning_rate=lr)
    
    def compute_rewards(self, prompts, responses):
        """
        Compute rewards with KL penalty
        
        r_total = r_reward_model(x,y) - β * KL(π || π_ref)
        """
        rewards = []
        
        for prompt, response in zip(prompts, responses):
            # Reward from reward model
            reward_score = self.reward_model.get_reward(
                self._encode(prompt, response))
            
            # KL divergence penalty
            policy_logprobs = self._get_logprobs(self.policy, prompt, response)
            ref_logprobs = self._get_logprobs(self.ref_model, prompt, response)
            kl_div = policy_logprobs - ref_logprobs  # Approximate KL
            
            # Total reward
            total_reward = reward_score - self.kl_coef * kl_div.mean()
            rewards.append(total_reward)
        
        return np.array(rewards)
    
    def _encode(self, prompt, response):
        """Encode prompt+response for reward model (placeholder)"""
        # In practice: use tokenizer and model embeddings
        return np.zeros((1, 256), dtype=np.float32)
    
    def _get_logprobs(self, model, prompt, response):
        """Get log probabilities of response tokens (placeholder)"""
        # In practice: forward pass through LLM
        return np.zeros(10, dtype=np.float32)

    def ppo_update(self, experiences):
        """
        PPO update for language model
        
        experiences: list of (prompt, response, old_log_prob, advantage, return)
        """
        prompts, responses, old_log_probs, advantages, returns = zip(*experiences)
        
        # Multiple epochs of PPO updates
        for epoch in range(4):
            with tf.GradientTape() as tape:
                # Get new log probs
                new_log_probs = []
                for prompt, response in zip(prompts, responses):
                    lp = self._get_logprobs(self.policy, prompt, response)
                    new_log_probs.append(lp.mean())
                
                new_log_probs = tf.constant(new_log_probs, dtype=tf.float32)
                old_log_probs_t = tf.constant(old_log_probs, dtype=tf.float32)
                advantages_t = tf.constant(advantages, dtype=tf.float32)
                
                # PPO ratio
                ratio = tf.exp(new_log_probs - old_log_probs_t)
                
                # Clipped objective
                surr1 = ratio * advantages_t
                surr2 = tf.clip_by_value(ratio, 
                                        1 - self.clip_epsilon,
                                        1 + self.clip_epsilon) * advantages_t
                
                policy_loss = -tf.reduce_mean(tf.minimum(surr1, surr2))
            
            grads = tape.gradient(policy_loss, self.policy.trainable_variables)
            self.optimizer.apply_gradients(
                zip(grads, self.policy.trainable_variables))
        
        return float(policy_loss)


class DPO:
    """
    Direct Preference Optimization (DPO)
    
    WHAT: Skip reward model, directly optimize on preferences
    
    WHY:
    - Simpler than full RLHF pipeline
    - No need for separate reward model
    - No RL instabilities
    - Same theoretical objective as RLHF
    
    HOW:
    Loss = -log σ(β * (log π(y_w|x)/π_ref(y_w|x) - log π(y_l|x)/π_ref(y_l|x)))
    
    where y_w = preferred, y_l = rejected
    
    INTUITION:
    - Increase prob of preferred response relative to reference
    - Decrease prob of rejected response relative to reference
    """
    
    def __init__(self, policy_model, ref_model, beta=0.1, lr=1e-6):
        self.policy = policy_model
        self.ref_model = ref_model  # Frozen
        self.beta = beta
        self.optimizer = keras.optimizers.Adam(learning_rate=lr)
    
    def compute_loss(self, prompts, preferred, rejected):
        """
        DPO loss on preference pairs
        """
        with tf.GradientTape() as tape:
            losses = []
            
            for prompt, y_w, y_l in zip(prompts, preferred, rejected):
                # Log probs under policy
                log_pi_yw = self._get_logprobs(self.policy, prompt, y_w).sum()
                log_pi_yl = self._get_logprobs(self.policy, prompt, y_l).sum()
                
                # Log probs under reference (no gradient)
                log_ref_yw = self._get_logprobs(self.ref_model, prompt, y_w).sum()
                log_ref_yl = self._get_logprobs(self.ref_model, prompt, y_l).sum()
                
                # DPO loss
                # Implicit reward: r(x,y) = β * log(π(y|x) / π_ref(y|x))
                log_ratio_w = log_pi_yw - log_ref_yw
                log_ratio_l = log_pi_yl - log_ref_yl
                
                loss = -tf.math.log(
                    tf.sigmoid(self.beta * (log_ratio_w - log_ratio_l)) + 1e-8
                )
                losses.append(loss)
            
            total_loss = tf.reduce_mean(losses)
        
        grads = tape.gradient(total_loss, self.policy.trainable_variables)
        self.optimizer.apply_gradients(zip(grads, self.policy.trainable_variables))
        
        return float(total_loss)
    
    def _get_logprobs(self, model, prompt, response):
        """Get log probabilities (placeholder)"""
        return tf.zeros(10, dtype=tf.float32)
````

---

## 11. Multi-Agent Reinforcement Learning (MARL)

### What is MARL?

**What?** Multiple agents learning and interacting in shared environment.

**Why?**
- Real world has multiple actors
- Games, traffic, robotics
- Emergent behaviors

**Challenges:**
- Non-stationary environment (other agents learning)
- Credit assignment (who contributed to reward?)
- Coordination vs competition

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class IndependentQLearning:
    """
    Independent Q-Learning (IQL)
    
    WHAT: Each agent learns independently, treating others as environment
    
    WHY: Simple baseline, scales well
    
    PROBLEM: Environment appears non-stationary (other agents changing)
    """
    
    def __init__(self, n_agents, state_dim, n_actions):
        self.n_agents = n_agents
        self.agents = [
            QLearningAgent(state_dim, n_actions) 
            for _ in range(n_agents)
        ]
    
    def select_actions(self, states):
        """Each agent selects action independently"""
        return [agent.select_action(states[i]) 
                for i, agent in enumerate(self.agents)]
    
    def learn(self, states, actions, rewards, next_states, dones):
        """Each agent learns from its own experience"""
        for i, agent in enumerate(self.agents):
            agent.update(states[i], actions[i], rewards[i], 
                        next_states[i], dones[i])


class MADDPG:
    """
    Multi-Agent Deep Deterministic Policy Gradient (MADDPG)
    
    WHAT: Centralized training, decentralized execution
    
    WHY:
    - Actors only see own observation
    - Critics see all observations and actions
    - Handles non-stationarity
    
    HOW:
    - Train: Critic Q(s, a_1, ..., a_n) sees everything
    - Execute: Actor μ(o_i) only sees own observation
    """
    
    def __init__(self, n_agents, obs_dims, action_dims, 
                 hidden_dims=[64, 64], lr=0.01, gamma=0.99, tau=0.01):
        
        self.n_agents = n_agents
        self.gamma = gamma
        self.tau = tau
        
        # Total dimensions for centralized critic
        total_obs_dim = sum(obs_dims)
        total_action_dim = sum(action_dims)
        
        # Each agent has its own actor and critic
        self.actors = []
        self.critics = []
        self.actor_targets = []
        self.critic_targets = []
        self.actor_optimizers = []
        self.critic_optimizers = []
        
        for i in range(n_agents):
            # Decentralized actor: own observation → own action
            actor = self._build_actor(obs_dims[i], action_dims[i], hidden_dims)
            actor_target = self._build_actor(obs_dims[i], action_dims[i], hidden_dims)
            actor_target.set_weights(actor.get_weights())
            
            # Centralized critic: all observations + all actions → Q
            critic = self._build_critic(total_obs_dim, total_action_dim, hidden_dims)
            critic_target = self._build_critic(total_obs_dim, total_action_dim, hidden_dims)
            critic_target.set_weights(critic.get_weights())
            
            self.actors.append(actor)
            self.critics.append(critic)
            self.actor_targets.append(actor_target)
            self.critic_targets.append(critic_target)
            self.actor_optimizers.append(keras.optimizers.Adam(learning_rate=lr))
            self.critic_optimizers.append(keras.optimizers.Adam(learning_rate=lr))
    
    def _build_actor(self, obs_dim, action_dim, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(obs_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(action_dim, activation='tanh'))
        return model
    
    def _build_critic(self, obs_dim, action_dim, hidden_dims):
        obs_input = layers.Input(shape=(obs_dim,))
        action_input = layers.Input(shape=(action_dim,))
        x = layers.Concatenate()([obs_input, action_input])
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')
        output = layers.Dense(1)(x)
        return keras.Model([obs_input, action_input], output)
    
    def select_actions(self, observations, add_noise=True):
        """Decentralized execution: each actor uses own observation"""
        actions = []
        for i, (actor, obs) in enumerate(zip(self.actors, observations)):
            action = actor(np.array([obs]), training=False)[0].numpy()
            if add_noise:
                action += np.random.normal(0, 0.1, size=action.shape)
            actions.append(np.clip(action, -1, 1))
        return actions
    
    def update(self, batch):
        """
        Centralized training
        
        Each agent's critic sees all observations and actions
        """
        obs_batch, action_batch, reward_batch, next_obs_batch, done_batch = batch
        
        # Get all agents' target actions for next state
        next_actions = []
        for i, actor_target in enumerate(self.actor_targets):
            next_action = actor_target(next_obs_batch[i], training=False)
            next_actions.append(next_action)
        
        # Concatenate all observations and actions
        all_obs = tf.concat(obs_batch, axis=1)
        all_next_obs = tf.concat(next_obs_batch, axis=1)
        all_actions = tf.concat(action_batch, axis=1)
        all_next_actions = tf.concat(next_actions, axis=1)
        
        # Update each agent
        for i in range(self.n_agents):
            # Update critic
            with tf.GradientTape() as tape:
                target_q = self.critic_targets[i](
                    [all_next_obs, all_next_actions], training=False)[:, 0]
                target_q = reward_batch[i] + (1 - done_batch[i]) * self.gamma * target_q
                
                current_q = self.critics[i](
                    [all_obs, all_actions], training=True)[:, 0]
                critic_loss = tf.reduce_mean(tf.square(target_q - current_q))
            
            critic_grads = tape.gradient(
                critic_loss, self.critics[i].trainable_variables)
            self.critic_optimizers[i].apply_gradients(
                zip(critic_grads, self.critics[i].trainable_variables))
            
            # Update actor
            with tf.GradientTape() as tape:
                # Get this agent's action from actor
                agent_action = self.actors[i](obs_batch[i], training=True)
                
                # Replace this agent's action in all_actions
                actions_for_grad = []
                for j in range(self.n_agents):
                    if j == i:
                        actions_for_grad.append(agent_action)
                    else:
                        actions_for_grad.append(action_batch[j])
                all_actions_new = tf.concat(actions_for_grad, axis=1)
                
                actor_loss = -tf.reduce_mean(
                    self.critics[i]([all_obs, all_actions_new], training=False))
            
            actor_grads = tape.gradient(
                actor_loss, self.actors[i].trainable_variables)
            self.actor_optimizers[i].apply_gradients(
                zip(actor_grads, self.actors[i].trainable_variables))
        
        # Soft update targets
        for i in range(self.n_agents):
            self._soft_update(self.actor_targets[i], self.actors[i])
            self._soft_update(self.critic_targets[i], self.critics[i])
    
    def _soft_update(self, target, source):
        for t, s in zip(target.trainable_variables, source.trainable_variables):
            t.assign(self.tau * s + (1 - self.tau) * t)
````

---

## 12. Inverse Reinforcement Learning (IRL)

### What is IRL?

**What?** Learn reward function from expert demonstrations.

**Why?**
- Hard to specify reward functions
- Expert behavior encodes implicit rewards
- Transfer to new scenarios

**How?** Given expert trajectories, find R such that expert is optimal.

````python
import numpy as np
from scipy.optimize import minimize

class MaxEntIRL:
    """
    Maximum Entropy Inverse Reinforcement Learning
    
    WHAT: Find reward function that makes expert behavior most likely
    
    WHY:
    - Classic IRL is ill-posed (many rewards explain same behavior)
    - Max entropy adds regularization: prefer simpler rewards
    
    HOW:
    - Reward is linear in features: r(s) = θᵀφ(s)
    - Maximize: Σ log P(τ|θ) where τ are expert trajectories
    - P(τ|θ) ∝ exp(Σ r(s_t))
    """
    
    def __init__(self, n_states, n_features, gamma=0.99):
        self.n_states = n_states
        self.n_features = n_features
        self.gamma = gamma
        self.theta = np.zeros(n_features)  # Reward weights
    
    def get_reward(self, state_features):
        """Linear reward: r = θᵀφ"""
        return np.dot(self.theta, state_features)
    
    def compute_feature_expectations(self, trajectories, feature_fn):
        """
        Compute empirical feature expectations from expert trajectories
        
        μ_E = (1/N) Σ Σ γᵗ φ(s_t)
        """
        feature_exp = np.zeros(self.n_features)
        
        for trajectory in trajectories:
            discount = 1.0
            for state in trajectory:
                feature_exp += discount * feature_fn(state)
                discount *= self.gamma
        
        return feature_exp / len(trajectories)
    
    def compute_policy_feature_exp(self, policy, env, feature_fn, n_episodes=100):
        """
        Compute feature expectations under current policy
        """
        feature_exp = np.zeros(self.n_features)
        
        for _ in range(n_episodes):
            state = env.reset()
            discount = 1.0
            done = False
            
            while not done:
                feature_exp += discount * feature_fn(state)
                action = policy(state)
                state, _, done = env.step(state, action)
                discount *= self.gamma
        
        return feature_exp / n_episodes
    
    def train(self, expert_trajectories, env, feature_fn, n_iterations=100):
        """
        Max Entropy IRL training
        
        Goal: Match feature expectations between expert and learned policy
        """
        # Expert feature expectations
        expert_features = self.compute_feature_expectations(
            expert_trajectories, feature_fn)
        
        for iteration in range(n_iterations):
            # 1. Solve forward RL with current reward
            policy = self._solve_rl(env, feature_fn)
            
            # 2. Compute policy feature expectations
            policy_features = self.compute_policy_feature_exp(
                policy, env, feature_fn)
            
            # 3. Update reward weights (gradient ascent)
            # Gradient: μ_E - μ_π
            gradient = expert_features - policy_features
            self.theta += 0.1 * gradient  # Learning rate
            
            if iteration % 10 == 0:
                diff = np.linalg.norm(gradient)
                print(f"Iteration {iteration}, Gradient norm: {diff:.4f}")
        
        return self.theta
    
    def _solve_rl(self, env, feature_fn):
        """Solve RL with current reward (simplified)"""
        # In practice: run Q-learning or policy gradient
        def policy(state):
            # Greedy w.r.t. learned reward
            best_action = 0
            best_value = -float('inf')
            for action in range(env.n_actions):
                next_state, _, _ = env.step(state, action)
                value = self.get_reward(feature_fn(next_state))
                if value > best_value:
                    best_value = value
                    best_action = action
            return best_action
        return policy


class GAIL:
    """
    Generative Adversarial Imitation Learning (GAIL)
    
    WHAT: Learn policy that matches expert distribution
    
    WHY:
    - Avoids explicit reward learning
    - Scales better than IRL
    - State-of-the-art imitation learning
    
    HOW:
    - Discriminator: distinguish expert vs policy trajectories
    - Policy: fool discriminator (appear like expert)
    - Similar to GAN, but for policies
    
    Training:
    - D: max E_expert[log D(s,a)] + E_policy[log(1-D(s,a))]
    - π: maximize E_policy[-log(1-D(s,a))] (use as reward)
    """
    
    def __init__(self, state_dim, action_dim, hidden_dims=[64, 64]):
        self.state_dim = state_dim
        self.action_dim = action_dim
        
        # Discriminator: (s,a) → probability of being expert
        self.discriminator = self._build_discriminator(hidden_dims)
        self.disc_optimizer = keras.optimizers.Adam(learning_rate=0.0003)
        
        # Policy (can use any policy gradient method)
        self.policy = self._build_policy(hidden_dims)
        self.policy_optimizer = keras.optimizers.Adam(learning_rate=0.0003)
    
    def _build_discriminator(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim + self.action_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='tanh'))
        model.add(layers.Dense(1, activation='sigmoid'))
        return model
    
    def _build_policy(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='tanh'))
        model.add(layers.Dense(self.action_dim, activation='softmax'))
        return model
    
    def get_reward(self, state, action):
        """
        GAIL reward: -log(1 - D(s,a))
        
        Higher D → more expert-like → higher reward
        """
        sa = np.concatenate([state, action]).reshape(1, -1)
        d = self.discriminator(sa, training=False)[0, 0].numpy()
        return -np.log(1 - d + 1e-8)
    
    def update_discriminator(self, expert_states, expert_actions,
                            policy_states, policy_actions):
        """
        Train discriminator to distinguish expert from policy
        """
        expert_sa = np.concatenate([expert_states, expert_actions], axis=1)
        policy_sa = np.concatenate([policy_states, policy_actions], axis=1)
        
        with tf.GradientTape() as tape:
            expert_probs = self.discriminator(expert_sa, training=True)
            policy_probs = self.discriminator(policy_sa, training=True)
            
            # Binary cross-entropy
            expert_loss = -tf.reduce_mean(tf.math.log(expert_probs + 1e-8))
            policy_loss = -tf.reduce_mean(tf.math.log(1 - policy_probs + 1e-8))
            disc_loss = expert_loss + policy_loss
        
        grads = tape.gradient(disc_loss, self.discriminator.trainable_variables)
        self.disc_optimizer.apply_gradients(
            zip(grads, self.discriminator.trainable_variables))
        
        return float(disc_loss)
    
    def update_policy(self, states, actions, advantages):
        """
        Update policy using discriminator reward
        (Standard policy gradient with GAIL reward)
        """
        with tf.GradientTape() as tape:
            probs = self.policy(states, training=True)
            action_masks = tf.one_hot(actions, self.action_dim)
            log_probs = tf.math.log(
                tf.reduce_sum(probs * action_masks, axis=1) + 1e-8)
            policy_loss = -tf.reduce_mean(log_probs * advantages)
        
        grads = tape.gradient(policy_loss, self.policy.trainable_variables)
        self.policy_optimizer.apply_gradients(
            zip(grads, self.policy.trainable_variables))
        
        return float(policy_loss)
````

---

## 13. Hierarchical Reinforcement Learning

### What is Hierarchical RL?

**What?** Decompose complex tasks into hierarchy of subtasks.

**Why?**
- Long-horizon tasks are hard to solve directly
- Temporal abstraction helps exploration
- Reusable skills for transfer

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class OptionCriticFramework:
    """
    Option-Critic Architecture
    
    WHAT: Learn options (temporally extended actions) and their termination
    
    WHY:
    - Primitive actions may be too fine-grained
    - Options provide temporal abstraction
    - End-to-end learning of both options and terminations
    
    COMPONENTS:
    - Options: macro-actions that last multiple steps
    - Intra-option policy: π(a|s,ω) - what to do within option ω
    - Termination: β(s,ω) - when to stop option ω
    - Policy over options: π(ω|s) - which option to choose
    """
    
    def __init__(self, state_dim, n_actions, n_options=4, 
                 hidden_dims=[64, 64], gamma=0.99):
        
        self.state_dim = state_dim
        self.n_actions = n_actions
        self.n_options = n_options
        self.gamma = gamma
        
        # Policy over options: π(ω|s)
        self.option_policy = self._build_option_policy(hidden_dims)
        
        # Intra-option policies: π(a|s,ω) for each option
        self.intra_policies = [
            self._build_intra_policy(hidden_dims) 
            for _ in range(n_options)
        ]
        
        # Termination functions: β(s,ω)
        self.terminations = [
            self._build_termination(hidden_dims)
            for _ in range(n_options)
        ]
        
        # Option-value function: Q(s,ω)
        self.option_critic = self._build_option_critic(hidden_dims)
        
        self.optimizer = keras.optimizers.Adam(learning_rate=0.001)
    
    def _build_option_policy(self, hidden_dims):
        """Which option to execute"""
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(self.n_options, activation='softmax'))
        return model
    
    def _build_intra_policy(self, hidden_dims):
        """What action to take within option"""
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(self.n_actions, activation='softmax'))
        return model
    
    def _build_termination(self, hidden_dims):
        """When to terminate option"""
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(1, activation='sigmoid'))
        return model
    
    def _build_option_critic(self, hidden_dims):
        """Q(s,ω) for each option"""
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(self.n_options))
        return model
    
    def select_option(self, state):
        """Select option using option policy"""
        state = np.array(state).reshape(1, -1)
        probs = self.option_policy(state, training=False)[0].numpy()
        return np.random.choice(self.n_options, p=probs)
    
    def select_action(self, state, option):
        """Select primitive action using intra-option policy"""
        state = np.array(state).reshape(1, -1)
        probs = self.intra_policies[option](state, training=False)[0].numpy()
        return np.random.choice(self.n_actions, p=probs)
    
    def should_terminate(self, state, option):
        """Check if option should terminate"""
        state = np.array(state).reshape(1, -1)
        term_prob = self.terminations[option](state, training=False)[0, 0].numpy()
        return np.random.random() < term_prob
    
    def train_episode(self, env):
        """One episode of option-critic training"""
        state = env.reset()
        option = self.select_option(state)
        total_reward = 0
        done = False
        
        while not done:
            action = self.select_action(state, option)
            next_state, reward, done = env.step(state, action)
            total_reward += reward
            
            # Update (simplified - full version is more complex)
            self._update(state, option, action, reward, next_state, done)
            
            # Check termination
            if self.should_terminate(next_state, option) or done:
                option = self.select_option(next_state)
            
            state = next_state
        
        return total_reward
    
    def _update(self, state, option, action, reward, next_state, done):
        """Option-critic update (simplified)"""
        state = np.array(state).reshape(1, -1)
        next_state = np.array(next_state).reshape(1, -1)
        
        # Get option values
        q_values = self.option_critic(state, training=False)[0].numpy()
        next_q_values = self.option_critic(next_state, training=False)[0].numpy()
        
        # TD target
        if done:
            target = reward
        else:
            # Value upon continuation
            term_prob = self.terminations[option](
                next_state, training=False)[0, 0].numpy()
            continue_value = next_q_values[option]
            switch_value = np.max(next_q_values)
            next_value = (1 - term_prob) * continue_value + term_prob * switch_value
            target = reward + self.gamma * next_value
        
        # Update critic, intra-policy, and termination
        # (Full implementation would have separate losses)


class HierarchicalActorCritic:
    """
    Hierarchical Actor-Critic (HAC)
    
    WHAT: Multi-level hierarchy with goal-conditioned policies
    
    WHY:
    - Tackles sparse reward problems
    - Each level operates at different time scale
    - Goals provide intrinsic motivation
    
    HOW:
    - Higher levels set goals for lower levels
    - Lower levels try to achieve those goals
    - Hindsight allows learning from failures
    """
    
    def __init__(self, state_dim, action_dim, goal_dim, n_levels=2):
        self.n_levels = n_levels
        self.state_dim = state_dim
        self.action_dim = action_dim
        self.goal_dim = goal_dim
        
        # Policies at each level
        # Level 0: primitive actions
        # Level 1+: subgoals for level below
        self.policies = []
        self.critics = []
        
        for level in range(n_levels):
            if level == 0:
                # Lowest level: outputs primitive actions
                output_dim = action_dim
            else:
                # Higher levels: output subgoals
                output_dim = goal_dim
            
            policy = self._build_policy(state_dim + goal_dim, output_dim)
            critic = self._build_critic(state_dim + goal_dim, output_dim)
            
            self.policies.append(policy)
            self.critics.append(critic)
    
    def _build_policy(self, input_dim, output_dim):
        model = keras.Sequential([
            layers.Input(shape=(input_dim,)),
            layers.Dense(64, activation='relu'),
            layers.Dense(64, activation='relu'),
            layers.Dense(output_dim, activation='tanh')
        ])
        return model
    
    def _build_critic(self, state_dim, action_dim):
        state_input = layers.Input(shape=(state_dim,))
        action_input = layers.Input(shape=(action_dim,))
        x = layers.Concatenate()([state_input, action_input])
        x = layers.Dense(64, activation='relu')(x)
        x = layers.Dense(64, activation='relu')(x)
        output = layers.Dense(1)(x)
        return keras.Model([state_input, action_input], output)
    
    def get_action(self, state, goal, level=0):
        """Get action at specified level given state and goal"""
        state_goal = np.concatenate([state, goal]).reshape(1, -1)
        action = self.policies[level](state_goal, training=False)[0].numpy()
        return action
    
    def run_level(self, env, state, goal, level, max_steps=10):
        """
        Run one level of hierarchy
        
        Higher levels set goals, lower levels execute
        """
        if level == 0:
            # Primitive execution
            action = self.get_action(state, goal, level=0)
            next_state, reward, done = env.step(state, action)
            return next_state, reward, done, 1
        else:
            # Higher level sets subgoals
            total_reward = 0
            steps = 0
            
            for _ in range(max_steps):
                # Get subgoal from this level
                subgoal = self.get_action(state, goal, level=level)
                
                # Execute subgoal at lower level
                next_state, reward, done, sub_steps = self.run_level(
                    env, state, subgoal, level - 1)
                
                total_reward += reward
                steps += sub_steps
                state = next_state
                
                # Check if subgoal achieved or episode done
                if done or self._goal_achieved(state, subgoal):
                    break
            
            return state, total_reward, done, steps
    
    def _goal_achieved(self, state, goal, threshold=0.1):
        """Check if goal is achieved"""
        return np.linalg.norm(state[:self.goal_dim] - goal) < threshold
````

---

## 14. Offline Reinforcement Learning

### What is Offline RL?

**What?** Learn from fixed dataset without environment interaction.

**Why?**
- Real-world interaction is expensive/dangerous
- Can leverage existing data
- Important for healthcare, robotics, etc.

**Challenge:** Distribution shift - policy may visit states not in data.

````python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

class BCQ:
    """
    Batch-Constrained Q-Learning (BCQ)
    
    WHAT: Only consider actions similar to those in dataset
    
    WHY:
    - Standard Q-learning overestimates OOD actions
    - Constraining to data distribution prevents this
    
    HOW:
    - Train VAE to model behavior policy
    - Only select actions that VAE would generate
    - Q-learning on constrained action space
    """
    
    def __init__(self, state_dim, action_dim, latent_dim=64,
                 hidden_dims=[400, 300], threshold=0.75):
        
        self.state_dim = state_dim
        self.action_dim = action_dim
        self.latent_dim = latent_dim
        self.threshold = threshold  # Action similarity threshold
        
        # VAE for generative model of behavior policy
        self.vae = self._build_vae(hidden_dims)
        
        # Q-networks (twin)
        self.q1 = self._build_q(hidden_dims)
        self.q2 = self._build_q(hidden_dims)
        
        # Perturbation network (fine-tune generated actions)
        self.perturbation = self._build_perturbation(hidden_dims)
        
        self.vae_optimizer = keras.optimizers.Adam(learning_rate=0.001)
        self.q_optimizer = keras.optimizers.Adam(learning_rate=0.001)
        self.perturb_optimizer = keras.optimizers.Adam(learning_rate=0.001)
    
    def _build_vae(self, hidden_dims):
        """VAE to model behavior policy"""
        # Encoder
        encoder_input = layers.Input(shape=(self.state_dim + self.action_dim,))
        x = encoder_input
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        z_mean = layers.Dense(self.latent_dim)(x)
        z_log_var = layers.Dense(self.latent_dim)(x)
        encoder = keras.Model(encoder_input, [z_mean, z_log_var])
        
        # Decoder
        decoder_input = layers.Input(shape=(self.state_dim + self.latent_dim,))
        x = decoder_input
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        decoded = layers.Dense(self.action_dim, activation='tanh')(x)
        decoder = keras.Model(decoder_input, decoded)
        
        return {'encoder': encoder, 'decoder': decoder}
    
    def _build_q(self, hidden_dims):
        state_input = layers.Input(shape=(self.state_dim,))
        action_input = layers.Input(shape=(self.action_dim,))
        x = layers.Concatenate()([state_input, action_input])
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        output = layers.Dense(1)(x)
        return keras.Model([state_input, action_input], output)
    
    def _build_perturbation(self, hidden_dims):
        """Small perturbation to generated actions"""
        state_input = layers.Input(shape=(self.state_dim,))
        action_input = layers.Input(shape=(self.action_dim,))
        x = layers.Concatenate()([state_input, action_input])
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        # Small perturbation range
        output = layers.Dense(self.action_dim, activation='tanh')(x)
        output = output * 0.05  # Scale down
        return keras.Model([state_input, action_input], output)
    
    def train_vae(self, states, actions):
        """Train VAE on dataset to model behavior policy"""
        with tf.GradientTape() as tape:
            # Encode
            sa = tf.concat([states, actions], axis=1)
            z_mean, z_log_var = self.vae['encoder'](sa, training=True)
            
            # Reparameterization
            epsilon = tf.random.normal(tf.shape(z_mean))
            z = z_mean + tf.exp(0.5 * z_log_var) * epsilon
            
            # Decode
            sz = tf.concat([states, z], axis=1)
            recon_actions = self.vae['decoder'](sz, training=True)
            
            # VAE loss: reconstruction + KL
            recon_loss = tf.reduce_mean(tf.square(actions - recon_actions))
            kl_loss = -0.5 * tf.reduce_mean(
                1 + z_log_var - tf.square(z_mean) - tf.exp(z_log_var))
            vae_loss = recon_loss + 0.5 * kl_loss
        
        all_vars = (self.vae['encoder'].trainable_variables + 
                   self.vae['decoder'].trainable_variables)
        grads = tape.gradient(vae_loss, all_vars)
        self.vae_optimizer.apply_gradients(zip(grads, all_vars))
        
        return float(vae_loss)
    
    def select_action(self, state, n_samples=10):
        """
        Select action by:
        1. Sample multiple actions from VAE
        2. Perturb each
        3. Select highest Q-value
        """
        state = np.array(state).reshape(1, -1)
        states = np.repeat(state, n_samples, axis=0)
        
        # Sample from VAE
        z = np.random.normal(size=(n_samples, self.latent_dim))
        sz = np.concatenate([states, z], axis=1)
        actions = self.vae['decoder'](sz, training=False).numpy()
        
        # Perturb actions
        perturbations = self.perturbation([states, actions], training=False).numpy()
        actions = np.clip(actions + perturbations, -1, 1)
        
        # Select action with highest Q
        q1_values = self.q1([states, actions], training=False).numpy()
        q2_values = self.q2([states, actions], training=False).numpy()
        q_values = np.minimum(q1_values, q2_values)
        
        best_idx = np.argmax(q_values)
        return actions[best_idx]


class CQL:
    """
    Conservative Q-Learning (CQL)
    
    WHAT: Learn conservative Q-values that lower-bound true values
    
    WHY:
    - Prevents overestimation of OOD actions
    - Theoretically grounded
    - Works well in practice
    
    HOW:
    - Regularize Q to be low on OOD actions
    - Regularize Q to be high on in-distribution actions
    
    Loss = Standard TD loss + α * (E_random[Q] - E_data[Q])
    """
    
    def __init__(self, state_dim, action_dim, hidden_dims=[256, 256],
                 lr=0.0003, gamma=0.99, alpha=1.0, n_random_actions=10):
        
        self.state_dim = state_dim
        self.action_dim = action_dim
        self.gamma = gamma
        self.alpha = alpha  # CQL regularization weight
        self.n_random = n_random_actions
        
        # Twin Q-networks
        self.q1 = self._build_q(hidden_dims)
        self.q2 = self._build_q(hidden_dims)
        self.q1_target = self._build_q(hidden_dims)
        self.q2_target = self._build_q(hidden_dims)
        self.q1_target.set_weights(self.q1.get_weights())
        self.q2_target.set_weights(self.q2.get_weights())
        
        # Policy network
        self.policy = self._build_policy(hidden_dims)
        
        self.q_optimizer = keras.optimizers.Adam(learning_rate=lr)
        self.policy_optimizer = keras.optimizers.Adam(learning_rate=lr)
    
    def _build_q(self, hidden_dims):
        state_input = layers.Input(shape=(self.state_dim,))
        action_input = layers.Input(shape=(self.action_dim,))
        x = layers.Concatenate()([state_input, action_input])
        for dim in hidden_dims:
            x = layers.Dense(dim, activation='relu')(x)
        output = layers.Dense(1)(x)
        return keras.Model([state_input, action_input], output)
    
    def _build_policy(self, hidden_dims):
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.state_dim,)))
        for dim in hidden_dims:
            model.add(layers.Dense(dim, activation='relu'))
        model.add(layers.Dense(self.action_dim, activation='tanh'))
        return model
    
    def update(self, states, actions, rewards, next_states, dones):
        """CQL update with conservative regularization"""
        batch_size = len(states)
        
        # Compute TD target
        next_actions = self.policy(next_states, training=False)
        target_q1 = self.q1_target([next_states, next_actions], training=False)
        target_q2 = self.q2_target([next_states, next_actions], training=False)
        target_q = tf.minimum(target_q1, target_q2)[:, 0]
        target_q = rewards + (1 - dones) * self.gamma * target_q
        
        # Generate random actions for CQL regularization
        random_actions = tf.random.uniform(
            (batch_size * self.n_random, self.action_dim), -1, 1)
        random_states = tf.repeat(states, self.n_random, axis=0)
        
        # Current policy actions
        curr_actions = self.policy(states, training=False)
        
        with tf.GradientTape() as tape:
            # Standard TD loss
            q1 = self.q1([states, actions], training=True)[:, 0]
            q2 = self.q2([states, actions], training=True)[:, 0]
            td_loss = tf.reduce_mean(tf.square(target_q - q1)) + \
                     tf.reduce_mean(tf.square(target_q - q2))
            
            # CQL regularization: push down Q on random actions
            q1_random = self.q1([random_states, random_actions], training=True)
            q2_random = self.q2([random_states, random_actions], training=True)
            
            # Push up Q on data actions
            q1_data = self.q1([states, actions], training=True)
            q2_data = self.q2([states, actions], training=True)
            
            # CQL penalty: log-sum-exp of random - data
            cql_loss = (
                tf.reduce_mean(tf.math.reduce_logsumexp(
                    tf.reshape(q1_random, (batch_size, self.n_random)), axis=1)) -
                tf.reduce_mean(q1_data) +
                tf.reduce_mean(tf.math.reduce_logsumexp(
                    tf.reshape(q2_random, (batch_size, self.n_random)), axis=1)) -
                tf.reduce_mean(q2_data)
            )
            
            total_loss = td_loss + self.alpha * cql_loss
        
        q_vars = self.q1.trainable_variables + self.q2.trainable_variables
        grads = tape.gradient(total_loss, q_vars)
        self.q_optimizer.apply_gradients(zip(grads, q_vars))
        
        return float(td_loss), float(cql_loss)
````

---

## 15. Summary & Algorithm Selection Guide

### When to Use What?

```
Decision Tree for RL Algorithm Selection:

START
  │
  ├── Do you have a model of the environment?
  │     │
  │     ├── YES → Dynamic Programming (Value/Policy Iteration)
  │     │
  │     └── NO → Continue
  │
  ├── Is your action space discrete or continuous?
  │     │
  │     ├── DISCRETE
  │     │     │
  │     │     ├── Small state space? → Q-Learning, SARSA
  │     │     │
  │     │     └── Large state space? → DQN, Rainbow
  │     │
  │     └── CONTINUOUS
  │           │
  │           ├── Need sample efficiency? → SAC, TD3
  │           │
  │           └── Need stability? → PPO
  │
  ├── Do you need to learn from demonstrations?
  │     │
  │     ├── YES
  │     │     │
  │     │     ├── Have reward labels? → Offline RL (CQL, BCQ)
  │     │     │
  │     │     └── Only demonstrations? → Imitation (BC, GAIL, IRL)
  │     │
  │     └── NO → Continue
  │
  ├── Is it a multi-agent problem?
  │     │
  │     ├── YES → MADDPG, QMIX
  │     │
  │     └── NO → Continue
  │
  └── Is it a long-horizon task?
        │
        ├── YES → Hierarchical RL (Options, HAC)
        │
        └── NO → Standard methods
```

### Algorithm Comparison Table

| Algorithm | Action Space | Sample Efficiency | Stability | Best Use Case |
|-----------|-------------|-------------------|-----------|---------------|
| Q-Learning | Discrete | Low | High | Simple tabular |
| DQN | Discrete | Medium | Medium | Atari games |
| Double DQN | Discrete | Medium | High | When DQN overestimates |
| Dueling DQN | Discrete | Medium | High | State values matter |
| Rainbow | Discrete | High | High | Best discrete performance |
| REINFORCE | Both | Low | Low | Simple continuous |
| A2C/A3C | Both | Medium | Medium | Parallel training |
| PPO | Both | Medium | **High** | **General purpose** |
| TRPO | Both | Medium | High | When stability critical |
| DDPG | Continuous | Medium | Low | Continuous control |
| TD3 | Continuous | Medium | Medium | Better than DDPG |
| SAC | Continuous | **High** | High | **Best continuous** |

### Key Takeaways

1. **Start Simple**: Try Q-learning or DQN before complex methods
2. **PPO is Your Friend**: Works well almost everywhere, stable
3. **SAC for Continuous**: State-of-the-art for continuous control
4. **Reward Engineering Matters**: Good rewards > complex algorithms
5. **Hyperparameters**: Learning rate, discount factor, exploration are crucial
6. **Sample Efficiency vs Stability**: Usually a tradeoff

### Further Reading

| Topic | Resource |
|-------|----------|
| Fundamentals | Sutton & Barto "RL: An Introduction" |
| Deep RL | OpenAI Spinning Up |
| Theory | Silver's UCL Course |
| Implementation | Stable-Baselines3, CleanRL |
| Research | DeepMind, OpenAI papers |

---

## 16. Practice Problems & Exercises

### Beginner Level

1. **GridWorld**: Implement Q-learning for 4x4 grid navigation
2. **CartPole**: Solve with DQN using OpenAI Gym
3. **FrozenLake**: Compare SARSA vs Q-learning

### Intermediate Level

4. **Atari Breakout**: Implement DQN with experience replay
5. **MountainCar-v0**: Solve with PPO
6. **LunarLander**: Compare PPO, A2C, and DQN

### Advanced Level

7. **MuJoCo Walker**: Implement SAC for walking robot
8. **Custom Environment**: Design reward function for your problem
9. **Multi-Agent**: Implement MADDPG for cooperative task

---

**Congratulations!** You now have a comprehensive understanding of Reinforcement Learning from fundamentals to advanced topics. The key to mastery is practice—implement these algorithms and experiment with different environments!
````

This completes your comprehensive Reinforcement Learning guide covering all major topics from beginner to advanced, including RLHF, Multi-Agent RL, Inverse RL, Hierarchical RL, and Offline RL with the Why, How, What framework throughout.This completes your comprehensive Reinforcement Learning guide covering all major topics from beginner to advanced, including RLHF, Multi-Agent RL, Inverse RL, Hierarchical RL, and Offline RL with the Why, How, What framework throughout.