---
slug: deriv-edge-credence-dynamics
type: derivation
status: conditional
depends:
  - schema-strategy-persistence
  - hyp-edge-update-via-gain
  - deriv-sector-condition
  - scope-and-or
stage: draft
---

# Derivation: Sector Condition Verification for Edge-Credence Dynamics

Complete verification that specific strategy update dynamics satisfy the sector condition from #deriv-sector-condition, backing the schema proposed in #schema-strategy-persistence. Seven propositions are proved across distinct topologies. **B.1 (single edge):** sector condition holds globally with $\alpha_\Sigma = 1/(n+1)$, tight. **B.2 (two-edge AND chain, observable intermediate):** weakest-link result with $\alpha_\Sigma = \min(1/(n_1+1), \theta_1/(n_2+1))$ — the evidence-starvation effect on the downstream edge attenuates by the upstream success probability. **B.3 (two-edge AND chain, unobservable intermediate):** per-edge sector condition *fails* (the marginal point estimate is biased), but plan-level tracking recovers persistence with $\alpha_{\Sigma,\text{plan}} = 1/(n_\Phi+1)$ at the cost of per-edge diagnostic resolution. **B.4 (two-arm OR, $\varepsilon$-greedy):** *exploration-gated* weakest-link — pure greedy *fails* the sector condition; minimum exploration is required (the sufficient-exploration condition from #schema-strategy-persistence).

**B.5 (sector transfer to plan-confidence error):** the sector condition transfers from per-edge credence space to *strategy-plan-confidence error* via the Jacobian — and the transfer is *credit-assignment-free*, requiring only status propagation. **B.6 (L1 augmented DAG, strict-prerequisite common cause):** persistence transfers with three-way gating (condition-testing rate, evidence-starvation factor, exploration-gating factor) — the formal extension to causally-insufficient DAGs handled by augmentation. **B.7 (L1' mixture form, soft-facilitator common cause):** persistence holds under *observable* common cause via five-way gating, and is *refuted* under unobservable common cause by the Cramér-Rao floor (the second formal instance of `#disc-identifiability-floor`).

The overall result: strategic persistence has a complete verified instance set for the canonical topologies. AND-chains exhibit depth-gated (geometric) attenuation; OR-nodes exhibit exploration-gated allocation; L1-augmented DAGs combine condition-testing, evidence-starvation, and exploration-gating. The chapter's claim that strategic persistence is structurally identical to epistemic persistence at the sector-template level is *verified* by these instantiations.

## Motivation

#schema-strategy-persistence proposes that the sector-condition mathematics (Props A.1, A.1S, A.2 in #deriv-sector-condition) extends from epistemic to strategic mismatch. The schema identifies three structural conditions (SA1, SA2', SA3) and conjectures the persistence form $\alpha_\Sigma \gt \rho_\Sigma / R_\Sigma$. This appendix instantiates the schema for concrete Beta-Bernoulli edge dynamics, verifying the conditions case by case. Each proposition establishes the sector parameter $\alpha_\Sigma$ for a specific DAG topology; the persistence condition then follows by direct substitution into Proposition A.1 of #deriv-sector-condition.


## Common Setup

Throughout, edge credences follow Beta-Bernoulli dynamics: edge $k$ has true success probability $\theta_k \in (0,1)$, agent belief $p_k \sim \text{Beta}(\alpha_k, \beta_k)$ with point estimate $\hat p_k = \alpha_k / n_k$ where $n_k = \alpha_k + \beta_k$, and conjugate update on observing $y_k \in \{0,1\}$:

*[Definition (Beta-Bernoulli edge dynamics)]*

$$\Delta \hat p_k = \frac{y_k - \hat p_k}{n_k + 1}, \qquad \eta_k = \frac{1}{n_k + 1}$$

The single-step update matches the gain-based form from #hyp-edge-update-via-gain with $\eta_{\text{edge}} = 1/(n_k + 1)$.

**Parameterization note.** Propositions B.1–B.7 below are stated in the *moment-parameter* (probability-space) coordinate $\hat p_k \in [0, 1]$, consistent with the Beta-Bernoulli conjugate presentation. The log-odds coordinate $\lambda_k = \log(\hat p_k / (1 - \hat p_k)) \in \mathbb{R}$ is the unique additive-evidence presentation forced by the evidential-additivity axiom ( #deriv-edge-update-natural-parameter); the sector-parameter content of each proposition is Fisher-equivalent in either coordinate, so the derivations are retained in moment-parameter form for algebraic tightness ($\eta_k = 1/(n_k + 1)$ is exact in probability space). The log-odds coordinate becomes load-bearing in #disc-credit-assignment-boundary for the continuous-gradient signal function, where the probability-space presentation would exhibit a mechanical domain break.

Strategic mismatch per edge is $\delta_k = \hat p_k - \theta_k$. The sector-condition framework ( #form-sector-condition) requires: (SA1) $F(\mathbf{0}) = \mathbf{0}$, (SA2') $\boldsymbol{\delta}^T \mathbf{F}(\boldsymbol{\delta}) \geq \alpha_\Sigma \lVert\boldsymbol{\delta}\rVert^2$ within a region $\mathcal B_R$.

### Regime-adjustment convention

The propositions below state sector parameters $\alpha_\Sigma$ for the **canonical Regime-A case**, in which every edge's evidence is fully interventional and attributable (identifiability coefficient $\iota_{ij} = 1$ per #scope-edge-update-causal-validity). For edges with $\iota_{ij} \lt 1$ (Regime B or C), each sector parameter carries an implicit $\iota_{ij}$ factor:

$$\alpha_\Sigma^{\text{eff}} = \iota_{ij} \cdot \alpha_\Sigma^{\text{stated}}$$

This commutes through every diagonal sector product in Props B.1–B.4 and B.6 because each edge's contribution to $\boldsymbol\delta_\Sigma^T \mathbf{F}$ is scaled by $\iota_{ij}$ independently: Regime-C edges ($\iota \approx 0$) contribute essentially nothing to the weakest-link minimum, and Regime-A edges ($\iota \approx 1$) recover the stated formulas exactly. The persistence condition $\alpha_\Sigma \gt \rho_\Sigma/R_\Sigma$ becomes $\iota_{ij} \cdot \alpha_\Sigma^{\text{stated}} \gt \rho_{\Sigma,ij}/R_{\Sigma,ij}$ per edge. The propositions below state everything in Regime-A form for clarity; the $\iota$-adjustment is uniform across cases and does not alter the structural results (evidence starvation, exploration gating, three-way gating) — only their quantitative thresholds per edge.

For Prop B.3 (unobservable intermediate), the regime adjustment does not change the A1 violation result: the bias is structural to the marginal Bayesian update, not to the identifiability quality. The plan-level fallback still recovers the sector condition with an $\iota$-adjusted $\alpha_{\Sigma,\text{plan}}$ governed by the aggregate's identifiability.


## Proposition B.1: Single Edge ($A \to G$)

**Setup.** One action $A$, one goal $G$, one edge with credence $\hat p$ and true probability $\theta$. Mismatch: $\delta_\Sigma = \hat p - \theta$ (scalar).

**Statement.** Under Beta-Bernoulli updating, the expected correction function satisfies the sector condition globally (all $\lvert\delta_\Sigma\rvert \leq 1$) with:

*[Derived (Conditional on Beta-Bernoulli model)]*

$$\alpha_\Sigma = \frac{1}{n+1}$$

The bound is tight.

**Proof.**

The expected correction. Since $y \sim \text{Bernoulli}(\theta)$:

*[Derived (Proof Step)]*

$$\mathbb{E}[\Delta \hat p] = \frac{\theta - \hat p}{n+1} = -\frac{\delta_\Sigma}{n+1}$$

Identifying $F_\Sigma(\delta_\Sigma) = -\mathbb{E}[\Delta\delta_\Sigma] = \delta_\Sigma/(n+1)$:

*[Derived (Proof Step)]*

$$\delta_\Sigma \cdot F_\Sigma(\delta_\Sigma) = \frac{\delta_\Sigma^2}{n+1} = \frac{1}{n+1}\lVert\delta_\Sigma\rVert^2$$

So $\alpha_\Sigma = 1/(n+1)$. The correction is exactly linear, so the sector bound is tight (not merely a lower bound).

**Verification of (SA1).** At $\delta_\Sigma = 0$: $F_\Sigma(0) = 0$. Satisfied.

**Stochastic ultimate bound.** Decomposing $\delta_{\Sigma,t+1} = \delta_\Sigma \cdot n/(n+1) + (y - \theta)/(n+1)$ and computing $\mathbb{E}[\delta_{\Sigma,t+1}^2]$:

*[Derived (stochastic ultimate bound, single edge)]*

$$\mathbb{E}[\delta_{\Sigma,t+1}^2] = \delta_\Sigma^2 \cdot \frac{n^2}{(n+1)^2} + \frac{\theta(1-\theta)}{(n+1)^2}$$

The expected Lyapunov derivative $\mathbb{E}[\Delta V] \lt 0$ whenever:

$$\lvert\delta_\Sigma\rvert \gt \sqrt{\frac{\theta(1-\theta)}{2n+1}}$$

The stochastic noise floor decreases as $O(1/\sqrt{n})$ --- the standard Bayesian posterior concentration rate. $\square$


## Proposition B.2: Two-Edge AND-Chain, Observable Intermediate ($A \to B \to G$, $B$ observed)

**Setup.** Action $A$ leads to intermediate $B$, then to goal $G$. Both $y_B$ and $y_G$ are observed. Edge credences $\hat p_1, \hat p_2$ with true probabilities $\theta_1, \theta_2$. Plan confidence: $\hat P_\Sigma = \hat p_1 \hat p_2$ (AND propagation from #scope-and-or). Mismatch vector: $\boldsymbol{\delta}_\Sigma = (\delta_1, \delta_2)^T$.

The generative model:

$$y_B \sim \text{Bernoulli}(\theta_1), \qquad y_G \mid y_B = 1 \sim \text{Bernoulli}(\theta_2), \qquad y_G \mid y_B = 0 = 0$$

**Statement.** Under Beta-Bernoulli updating with observable intermediate, the expected correction function is diagonal and satisfies the sector condition globally with:

*[Derived (Conditional on Beta-Bernoulli model, observable intermediate)]*

$$\alpha_\Sigma = \min\!\left(\frac{1}{n_1+1},\; \frac{\theta_1}{n_2+1}\right)$$

**Proof.**

Edge 1 is tested every trial: $\Delta \hat p_1 = (y_B - \hat p_1)/(n_1+1)$, giving $\mathbb{E}[\Delta \hat p_1] = -\delta_1/(n_1+1)$.

Edge 2 is tested only when $y_B = 1$ (probability $\theta_1$). When $y_B = 0$, edge 2 receives no information:

*[Derived (Proof Step)]*

$$\mathbb{E}[\Delta \hat p_2] = \theta_1 \cdot \frac{\theta_2 - \hat p_2}{n_2+1} + (1 - \theta_1) \cdot 0 = -\frac{\theta_1 \delta_2}{n_2+1}$$

The expected correction function is diagonal:

$$\mathbf{F}(\boldsymbol{\delta}_\Sigma) = \begin{pmatrix} \delta_1/(n_1+1) \\ \theta_1 \delta_2/(n_2+1) \end{pmatrix}$$

**Verification of (SA1).** At $\boldsymbol{\delta}_\Sigma = \mathbf{0}$: $\mathbf{F}(\mathbf{0}) = \mathbf{0}$. Satisfied.

The sector product:

*[Derived (Proof Step)]*

$$\boldsymbol{\delta}_\Sigma^T \mathbf{F}(\boldsymbol{\delta}_\Sigma) = \frac{\delta_1^2}{n_1+1} + \frac{\theta_1 \delta_2^2}{n_2+1} \geq \min\!\left(\frac{1}{n_1+1}, \frac{\theta_1}{n_2+1}\right)(\delta_1^2 + \delta_2^2)$$

The minimum is achieved by whichever edge has the lower effective correction rate. $\square$

**The evidence-starvation effect.** Edge 2's effective correction rate $\theta_1/(n_2+1)$ is attenuated by the upstream success probability $\theta_1$. When $\theta_1$ is small, edge 2 is starved of evidence --- it is tested rarely, learns slowly, and becomes the weakest link. This gives a precise mechanism for #der-chain-confidence-decay: downstream edges in AND-chains are harder to calibrate, with correction rate proportional to the product of all upstream success probabilities.

**Generalization to depth $d$.** For a chain of depth $d$ with all intermediates observable, edge $k$'s effective correction rate is $\alpha_k = \prod_{j=1}^{k-1}\theta_j / (n_k + 1)$, giving:

*[Derived (depth-$d$ chain sector parameter)]*

$$\alpha_\Sigma = \min_{k=1}^{d}\; \frac{\prod_{j=1}^{k-1}\theta_j}{n_k+1}$$


## Proposition B.3: Two-Edge AND-Chain, Unobservable Intermediate ($A \to B \to G$, $B$ not observed)

**Setup.** Same DAG as Proposition B.2, but only $y_G \in \{0,1\}$ is observed. The agent cannot distinguish "$A \to B$ failed" from "$B \to G$ failed" when $y_G = 0$.

**Statement.** (a) The per-edge sector condition fails: the marginal Bayesian update violates (SA1) with systematic bias $O(1/n)$. (b) Plan-level tracking (treating $\hat\Phi = \hat p_1 \hat p_2$ as a single Beta over the composite probability $\Phi = \theta_1\theta_2$) recovers the sector condition with:

*[Derived (Conditional on Beta-Bernoulli model, unobservable intermediate)]*

$$\alpha_{\Sigma,\text{plan}} = \frac{1}{n_\Phi + 1}$$

**Proof of (a): Per-edge (SA1) violation.**

The joint posterior after success ($y_G = 1$) factors cleanly: $\alpha_k \to \alpha_k + 1$ for both edges. The joint posterior after failure ($y_G = 0$) includes the factor $(1 - \theta_1\theta_2)$, which does not decompose into separate functions of $\theta_1$ and $\theta_2$. Failure introduces posterior correlation.

The exact marginal Bayesian update for edge 1 on failure is:

*[Derived (Proof Step)]*

$$\Delta \hat p_1^{(\text{fail})} = -\frac{\hat p_1 \, q_1}{n_1 + 1}$$

where $q_1 = (1 - \hat p_1)/(1 - \hat p_1 \hat p_2)$ is the posterior probability that edge 1 caused the failure (the proportional-blame weight). The expected update, combining success (probability $\theta_1\theta_2$) and failure (probability $1 - \theta_1\theta_2$):

*[Derived (Proof Step)]*

$$\mathbb{E}[\Delta \hat p_1] = \theta_1\theta_2 \cdot \frac{1 - \hat p_1}{n_1+1} - (1-\theta_1\theta_2)\cdot\frac{\hat p_1\,q_1}{n_1+1}$$

Evaluating at truth ($\hat p_k = \theta_k$):

*[Derived (SA1 violation magnitude)]*

$$\mathbb{E}[\Delta \hat p_1]\big\rvert_{\hat p = \theta} = -\frac{\theta_1(1-\theta_1)(1-\theta_2)}{n_1+1} \neq 0$$

The bias is negative (pushes credence below truth), of magnitude $O(1/n)$, and arises because success always increments $\alpha_1$ by a full unit while failure increments $\beta_1$ by the fractional weight $q_1 \lt 1$. The success case over-credits edge 1 because the agent cannot separate edge 1's contribution from edge 2's. By symmetry, $\hat p_2$ is also biased downward. $\square$

**Proof of (b): Plan-level recovery.**

If the agent tracks $\hat\Phi$ directly as a Beta posterior over $\Phi = \theta_1\theta_2$ using $y_G \sim \text{Bernoulli}(\Phi)$, the setup reduces to a single-edge problem (Proposition B.1) with mismatch $\delta_\Phi = \hat\Phi - \Phi$ and sector parameter $\alpha_{\Sigma,\text{plan}} = 1/(n_\Phi + 1)$. All single-edge results apply. $\square$

**Tradeoff.** Per-edge tracking provides diagnostic resolution (which edge is failing?) but yields biased, non-sector-conforming updates when the intermediate is unobservable. Plan-level tracking sacrifices diagnostic resolution but provides clean sector-condition satisfaction. This is a concrete instance of #der-observability-dominance: unobservable nodes freeze per-edge learning, making the aggregate the correct unit of analysis.

**Non-identifiability.** From $y_G$ observations alone, only $\Phi = \theta_1\theta_2$ is identifiable. The per-edge decomposition $(\theta_1, \theta_2)$ is underdetermined --- any pair with the same product produces identical observations. Per-edge identification requires per-edge observability (or structural constraints that break the symmetry).


## Proposition B.4: Two-Arm OR-Node ($A_1, A_2 \to G$, $\varepsilon$-greedy)

**Setup.** Goal $G$ reachable via two alternative actions $A_1, A_2$ (an OR-node from #scope-and-or). True probabilities $\theta_1, \theta_2$. Agent selects one action per trial: with probability $1 - \varepsilon$ the greedy choice (higher $\hat p_k$), with probability $\varepsilon$ the other. Mismatch vector: $\boldsymbol{\delta}_\Sigma = (\delta_1, \delta_2)^T$.

**Statement.** (a) Under a greedy policy ($\varepsilon = 0$), the sector condition fails for the full mismatch vector. (b) Under $\varepsilon$-greedy action selection with $\varepsilon \gt 0$, the sector condition is satisfied with:

*[Derived (Conditional on Beta-Bernoulli model, $\varepsilon$-greedy OR-node)]*

$$\alpha_\Sigma = \min\!\left(\frac{1-\varepsilon}{n_1+1},\; \frac{\varepsilon}{n_2+1}\right)$$

where arm 1 is the greedy choice.

**Proof of (a): Greedy failure.**

Under greedy selection, only the chosen arm updates. Assuming $\hat p_1 \gt \hat p_2$ (arm 1 is greedy):

$$\mathbf{F}(\boldsymbol{\delta}_\Sigma) = \begin{pmatrix}\delta_1/(n_1+1) \\ 0\end{pmatrix}$$

The sector product $\boldsymbol{\delta}_\Sigma^T \mathbf{F} = \delta_1^2/(n_1+1)$. For the sector condition to hold, we need $\delta_1^2/(n_1+1) \geq \alpha_\Sigma(\delta_1^2 + \delta_2^2)$. Setting $\delta_1 = 0$: the LHS is zero but $\alpha_\Sigma \delta_2^2 \gt 0$ for $\delta_2 \neq 0$. No $\alpha_\Sigma \gt 0$ works. $\square$

**Proof of (b): $\varepsilon$-greedy recovery.**

The expected correction (arm 1 greedy):

*[Derived (Proof Step)]*

$$\mathbb{E}[\mathbf{F}(\boldsymbol{\delta}_\Sigma)] = \begin{pmatrix}(1-\varepsilon)\,\delta_1/(n_1+1) \\ \varepsilon\,\delta_2/(n_2+1)\end{pmatrix}$$

The sector product:

*[Derived (Proof Step)]*

$$\boldsymbol{\delta}_\Sigma^T \mathbf{F} = \frac{(1-\varepsilon)\,\delta_1^2}{n_1+1} + \frac{\varepsilon\,\delta_2^2}{n_2+1} \geq \min\!\left(\frac{1-\varepsilon}{n_1+1},\;\frac{\varepsilon}{n_2+1}\right)\!(\delta_1^2 + \delta_2^2)$$

**Verification of (SA1).** At $\boldsymbol{\delta}_\Sigma = \mathbf{0}$: $\mathbf{F}(\mathbf{0}) = \mathbf{0}$. Satisfied. $\square$

**Optimal exploration rate.** Maximizing $\alpha_\Sigma$ over $\varepsilon$ by equalizing the two terms:

*[Derived (optimal exploration rate)]*

$$\varepsilon^\ast = \frac{n_2+1}{n_1+n_2+2}, \qquad \alpha_\Sigma^\ast = \frac{1}{n_1+n_2+2}$$

For equal experience ($n_1 = n_2$): $\varepsilon^\ast = 1/2$ (equal allocation). For unequal experience, $\varepsilon^\ast$ allocates more trials to the arm with higher $n$ (lower gain) to equalize correction rates.

**The $k$-arm generalization.** For $k$ OR-alternatives with $\varepsilon$-uniform exploration (probability $\varepsilon/(k-1)$ per non-greedy arm):

*[Derived ($k$-arm OR-node sector parameter)]*

$$\alpha_\Sigma = \min\!\left(\frac{1-\varepsilon}{n_{\text{greedy}}+1},\;\min_{j \neq \text{greedy}}\frac{\varepsilon/(k-1)}{n_j+1}\right)$$

With optimal equal-rate exploration and equal experience: $\alpha_\Sigma = 1/(k(n+1))$. The sector parameter scales as $1/k$ --- each additional alternative dilutes correction capacity.

**Condition (SA3).** For the sector condition to be satisfiable at all, the exploration rate must satisfy:

*[Derived (minimum exploration rate for persistence)]*

$$\varepsilon \gt \frac{\rho_\Sigma(n_{\max}+1)}{R_\Sigma}$$

A purely greedy agent ($\varepsilon = 0$) violates the sector condition because the unchosen alternative's mismatch grows without correction. This is the structural justification for (SA3) in #schema-strategy-persistence: OR-nodes require deliberate exploration to maintain strategic persistence.


## Persistence Conditions

Substituting each proposition's $\alpha_\Sigma$ into the persistence threshold $\alpha_\Sigma \gt \rho_\Sigma / R_\Sigma$ from Proposition A.1 of #deriv-sector-condition:

**Single edge (B.1):**

