![](_page_0_Picture_1.jpeg)

![](_page_0_Picture_2.jpeg)

![](_page_0_Picture_3.jpeg)

### Scopes as Types

HENDRIK VAN ANTWERPEN, Delft University of Technology, Netherlands CASPER BACH POULSEN, Delft University of Technology, Netherlands ARJEN ROUVOET, Delft University of Technology, Netherlands EELCO VISSER, Delft University of Technology, Netherlands

Scope graphs are a promising generic framework to model the binding structures of programming languages, bridging formalization and implementation, supporting the definition of type checkers and the automation of type safety proofs. However, previous work on scope graphs has been limited to simple, nominal type systems. In this paper, we show that viewing scopes as types enables us to model the internal structure of types in a range of non-simple type systems (including structural records and generic classes) using the generic representation of scopes. Further, we show that relations between such types can be expressed in terms of generalized scope graph queries. We extend scope graphs with scoped relations and queries. We introduce Statix, a new domain-specific meta-language for the specification of static semantics, based on scope graphs and constraints. We evaluate the scopes as types approach and the Statix design in case studies of the simply-typed lambda calculus with records, System F, and Featherweight Generic Java.

CCS Concepts: • Software and its engineering → Semantics; Domain specific languages;

Additional Key Words and Phrases: static semantics, type system, type checker, name resolution, scope graphs, domain-specific language

#### ACM Reference Format:

Hendrik van Antwerpen, Casper Bach Poulsen, Arjen Rouvoet, and Eelco Visser. 2018. Scopes as Types. Proc. ACM Program. Lang. 2, OOPSLA, Article 114 (November 2018), [30](#page-29-0) pages. <https://doi.org/10.1145/3276484>

#### 1 INTRODUCTION

The goal of our work is to support high-level specification of type systems that can be used for multiple purposes, including reasoning (about type safety among other things) and the implementation of type checkers [\[Visser et al.](#page-28-0) [2014\]](#page-28-0). Traditional approaches to type system specification do not reflect the commonality underlying the name binding mechanisms for different languages. Furthermore, operationalizing name binding in a type checker requires carefully staging the traversals of the abstract syntax tree in order to collect information before it is needed. In this paper, we introduce an approach to the declarative specification of type systems that is close in abstraction to traditional type system specifications, but can be directly interpreted as type checking rules. The approach is based on scope graphs for name resolution, and constraints to separate traversal order from solving order.

Authors' addresses: Hendrik van Antwerpen, Delft University of Technology, Delft, Netherlands, H.vanAntwerpen@tudelft. nl; Casper Bach Poulsen, Delft University of Technology, Delft, Netherlands, C.B.Poulsen@tudelft.nl; Arjen Rouvoet, Delft University of Technology, Delft, Netherlands, A.J.Rouvoet@tudelft.nl; Eelco Visser, Delft University of Technology, Delft, Netherlands, E.Visser@tudelft.nl.

![](_page_0_Picture_14.jpeg)

contact the owner/author(s). This work is licensed under a Creative Commons Attribution 4.0 International License.

© 2018 Copyright held by the owner/author(s).

2475-1421/2018/11-ART114

<https://doi.org/10.1145/3276484>

Modeling Names in Programming Languages. Formal definitions of type systems and their implementation as type checkers feature a variety of techniques to model and implement name binding and name resolution for different languages. For example, if we consider [Pierce'](#page-28-1)s [\[2002\]](#page-28-1) book we encounter the following representations for the treatment of names: sequences of name-type associations to represent type environments for the simply-typed lambda calculus; tuples of labeltype associations to represent record and variant types; class tables with functions for field and method lookup to represent the nominal class types of Featherweight Java; types with quantifiers to represent parameterized types in System F; and pairs of type variables and types to represent existential types. These are all fine mathematical representations, but they have been optimized for the particular language they model. These optimizations obscure the understanding of the common underlying concepts of name binding. Furthermore, the variation in representations is not a good basis for the construction of reusable tools for language design. Would it be possible to standardize the treatment of names in programming languages?

Modeling Name Resolution with Scope Graphs. Scope graphs were introduced by [Néron et al.](#page-28-2) [\[2015\]](#page-28-2) as a general model for name resolution in programming languages that is suitable for formalization as well as implementation. A scope graph captures the binding structure of a program. A scope is a region in a program that behaves uniformly with respect to name resolution. Declarations of names and references are associated with scopes. Visibility is modeled by edges between scopes. A generic, language-independent resolution algorithm interprets a scope graph to resolve references to declarations by finding the most specific well-formed path in a scope graph. To express the binding rules of a programming language, one defines a mapping from abstract syntax trees to scope graphs. Scope graphs cover a wide range of binding structures, including lexical bindings[1](#page-1-0) such as let bindings, function parameters, and local variables in blocks; and non-lexical bindings such as (potentially cyclic) module imports and class inheritance. The framework enables languageindependent definitions of alpha equivalence and safe variable renaming.

The scope graph framework has already been used succesfully in several applications. [Van](#page-28-3) [Antwerpen et al.](#page-28-3) [\[2016\]](#page-28-3) use scope graphs to model name binding in a constraint language for the definition of type checkers. [Poulsen et al.](#page-28-4) [\[2016\]](#page-28-4) define a framework in which scopes describe frames, providing a language-independent model for run-time memory in dynamic semantics. [Poulsen et al.](#page-28-5) [\[2018\]](#page-28-5) show that this model can be used to realize type safety by construction in intrinsically-typed definitional interpreters for imperative languages.

Thus, scope graphs are the basis for a promising approach to the definition of the static semantics of programming languages that serves the implementation of tools such as type checkers, as well as the verification of language properties such as type safety. However, the adoption of scope graphs is inhibited by its limitation to simple type systems. As a model that ties information to names, scope graphs appear to be limited in expressiveness. The works cited above cover languages with simple, nominal type systems in which types are identified by name, and their future work calls for extension to more sophisticated type systems. In particular, it is not clear how scope graphs can be used to describe structural types, in which types are not identified by name, and generic types, in which types are parameterized by types.

Scopes as Types. In this paper, we demonstrate how scope graphs can be used to model type systems with more sophisticated forms of type representation and compatibility checking, such as structural record types and parameterized types in both nominal and structural type systems, by using scopes as types. Scope graph scopes can model a variety of structured types such as records

<span id="page-1-0"></span><sup>1</sup> Lexical bindings are those in which the name binding construct dominates the abstract tree that corresponds to the scope of the construct. Non-lexical bindings define names that are reachable outside the dominated tree.

and classes. Visibility edges between scopes can be used to model subtyping. The instantiation of a parameterized type can be modeled by means of a new scope that refines the binding of a parameter. To realize scopes-as-types we generalize scope graphs with scoped relations, formalizing scoped information including typed declarations, and we simplify scope graphs by using the scopes-as-types approach to model imports, which were previously built into the framework.

We demonstrate how the approach can be applied in the definition of type systems for the simply-typed lambda calculus with records (featuring structural sub-typing) [\[Pierce 2002\]](#page-28-1), System F (featuring parametric types) [\[Girard 1972;](#page-27-0) [Reynolds 1974\]](#page-28-6), and Featherweight Generic Java (featuring generic class types) [\[Igarashi et al. 2001\]](#page-27-1).

Staging Name Resolution and Type Checking. Scope graphs provide a uniform model for the representation and resolution of binding information in programs, but they do not, by themselves, address another issue with realizing declarative definition of type checkers: the staging of name resolution and type checking. It is common practice to use constraints in type checkers in order to separate the collection of type compatibility requirements, and checking that these are satisfied. However, name resolution is typically performed during the traversal of the abstract syntax tree that generates constraints. This requires a careful staging of the traversal in order to collect information (names and their types) before it will be needed. For example, checking a recursive let expression requires processing the declared variables before checking the initializing expressions. Similarly, checking modules or classes requires collecting signature information before checking their contents. This approach is further complicated when considering type-dependent name resolution in which the resolution of names depends on the resolution of types.

In this paper, we introduce Statix, a constraint-based declarative language for the specification of type systems that combines type constraints with name resolution constraints based on scope graphs. That is, Statix rules define the static semantics of language constructs in terms of constraints over type terms and constraints that define and query a scope graph. Definition of type checkers using this approach is more declarative since the order of evaluation of constraints is not tied to the order of the traversal of the abstract syntax tree. In particular, this relieves the language designer from ensuring that information is collected before it is used. Statix generalizes the constraint language of [Van Antwerpen et al.](#page-28-3) [\[2016\]](#page-28-3) by introducing user-defined constraints, required to define type compatibility predicates, and by generalizing name resolution to scope graph queries to retrieve (visible) scoped information.

Contributions. The paper makes the following technical contributions:

- We show that viewing scopes as types enables modeling the internal structure of types in a range of interesting type systems, including structural records and generic classes, using the generic representation of scopes.
- We extend the scope graph framework of [Néron et al.](#page-28-2) [\[2015\]](#page-28-2) and [Van Antwerpen et al.](#page-28-3) [\[2016\]](#page-28-3) with scoped relations to model the association of types with declarations and the representation of explicit substitutions in the instantiation of parameterized types. We generalize name resolution from resolution of references to general queries for scoped relations. Furthermore, visibility policies, which were global (per language), can be defined per query, enabling namespace-specific visibility policies. We simplify the framework by not including imports as a primitive, since these can be encoded using the scopes-as-types approach.
- We extend the visual notation of scope graph diagrams with scoped relations, which provides a useful language to explain patterns of names and types in programming languages.
- We introduce Statix, a declarative language to specify type systems. The language provides simple guarded rules for the definition of user-defined constraints with unification, scope

graph construction, and name resolution as built-in theories. We provide a formal definition of the declarative semantics of Statix.

- We discuss the execution model of Statix and how it guarantees soundness of resolution in incomplete graphs.
- We evaluate the scopes-as-types approach and the Statix language in three case studies: the simply-typed lambda calculus with records (featuring structural sub-typing) [\[Pierce](#page-28-1) [2002\]](#page-28-1) (STLC-REC), System F (featuring parametric types) [\[Girard 1972;](#page-27-0) [Reynolds 1974\]](#page-28-6), and Featherweight Generic Java (featuring generic class types) [\[Igarashi et al. 2001\]](#page-27-1).

Outline. In Section [2](#page-3-0) we present the revised scope graph framework and the corresponding resolution calculus. We demonstrate how this formalism supports the specification of type systems, including ones with structural and parametric types. In Section [3](#page-17-0) we introduce the Statix language and its declarative semantics. We show the specification in Statix of typical patterns in programming languages with structural and parametric type systems. In Section [4](#page-19-0) we discuss the execution model of the solver for the Statix language. In particular, we discuss resolution in incomplete scope graphs. In Section [5](#page-23-0) we discuss the evaluation of Statix by means of an implementation in the Spoofax language workbench and several critical case studies. In Section [6](#page-24-0) we discuss how the approach compares to other approaches. We conclude in Section [7.](#page-26-0)

#### <span id="page-3-0"></span>2 SCOPES AS TYPES

Typing is deeply dependent on name resolution: a program phrase is typically typed by resolving names that occur in it to names in its surrounding context. In many interesting languages, types can also bind names; this is the case with record types, object or class types, and dependent types. In this section we observe and illustrate how types that bind names (records, objects, etc.) can be described by scopes in a scope graph, and we present a revised definition of the scope graph framework of [Néron et al.](#page-28-2) [\[2015\]](#page-28-2) and [Van Antwerpen et al.](#page-28-3) [\[2016\]](#page-28-3) and show how it can be applied to the definition of type systems.

#### <span id="page-3-1"></span>2.1 Scope Graphs and the Resolution Calculus

In the scope graph approach, a program is reduced to a graph that represents its binding information. The first part of Fig. [1](#page-4-0) defines the structure of scope graphs. A scope graph consists of scopes, connected by edges, containing data. A labeled edge s<sup>1</sup> s<sup>2</sup> between scopes s<sup>1</sup> and s<sup>2</sup> determines that the declarations in scope s<sup>2</sup> are reachable from scope s1. The label can be used to regulate visibility. A scoped datum s r d associates a data term d with a scope s under relation r. For example, we will use s (x,T ), to represent a declaration of name x in the scope s with type T , and use x : T to denote the pair. There may be multiple data items associated with a scope under the same relation.

Given this structure, we can now precisely characterize name resolution for a reference as finding a path from its scope to a scope with a matching declaration. This intuition is formally captured by the resolution calculus in the third part of Fig. [1,](#page-4-0) which is parameterized by well-formedness and visibility parameters defined in the second part of Fig. [1.](#page-4-0) We discuss the judgments of the calculus.

The judgment G ⊢ p : s<sup>1</sup> ↠ s<sup>2</sup> states that there is a path p from scope s<sup>1</sup> to scope s2, if there is a sequence of labeled scope edges starting at s<sup>1</sup> and leading to s2. Cyclic paths are not admitted: the s<sup>1</sup> < scopes(p) premise of (NR-Cons) asserts that scope s<sup>1</sup> does not occur in path p. The path p records the scopes and edge labels that it passes through.

The judgment WFD, WFL, G ⊢ p : s r d states that data term (declaration) d is reachable through path p from scope s under relation r with data term predicate WFD and label well-formedness predicate WFL. Label well-formedness tests that the path has a 'good shape' as defined by a regular

```
Syntax Parameters
          data terms d ∈ D a set of data terms
              labels l ∈ L a set of edge labels
           relations r ∈ R a set of relation names
Syntax Definitions
          scopes s ∈ S := some countable set
           paths p ∈ P ::= s | s·l·p
           edges Edges ::= s
                                    s
         datums Data ::= s
                                 r
                                    d
     scope graphs G ∈ Graphs ::= ⟨scopes ⊆ S, edges ⊆ Edges, data ⊆ Data⟩
   extended labels ˆ
                  l ∈ Lˆ := L ∪ {$} where $ indicates the end of a path
Visibility Parameters
   data term well-formedness WFD ⊆ D
       label well-formedness WFL ⊆ L∗
                                         defined as a regular expression
                data order ≤d ⊆ D × D partial order
                label order <l ⊆ L ×ˆ Lˆ strict partial order
Path Well-formedness WFL ⊢ p ok
                               (l1 . . . ln) ∈ WFL
                          WFL ⊢ (s1·l1· . . . · sn·ln·sn+1) ok
Visibility Order <l ⊢ p <p p
     <l ⊢ p1 <p p2
   <l ⊢ s·l·p1 <p s·l·p2
                           $ <l
                               l
                       <l ⊢ s <p s·l·p
                                           l <l $
                                        <l ⊢ s·l·p <p s
                                                              l1 <l
                                                                  l2
                                                        <l ⊢ s·l1·p1 <p s·l2·p2
Paths G ⊢ p : s ↠ s
(NR-Refl)
       s ∈ scopes(G)
       G ⊢ s : s ↠ s
                      (NR-Cons)
                              s1
                                   s2 ∈ edges(G) G ⊢ p : s2 ↠ s3 s1 < scopes(p)
                                             G ⊢ s1·l·p : s1 ↠ s3
Reachability WFD, WFL, G ⊢ p : s
                                                                         r
                                                                          d
         (NR-Rel)
               G ⊢ p : s ↠ s
                          ′
                             s
                              ′ r
                                  d ∈ data(G) WFL ⊢ p ok d ∈ WFD
                              WFD, WFL, G ⊢ p : s
                                                r
                                                  d
Visibility WFD, WFL, ≤d , <l
                                                                , G ⊢ p : s
                                                                         r
                                                                          d
        (NR-Vis)
                              WFD, WFL, G ⊢ p : s
                                                r
                                                  d
              ∄ p
                 ′d
                  ′
                   .
                     WFD, WFL, G ⊢ p
                                   ′
                                    : s
                                       r
                                         d
                                          ′

                                            ∧

                                               <l ⊢ p
                                                   ′ <p p

                                                         ∧ (d
                                                             ′ ≤d d)

                            WFD, WFL, ≤d , <l
                                          , G ⊢ p : s
                                                   r
                                                    d
```

Fig. 1. Formal definition of scope graphs with syntax, visibility predicates, and resolution calculus

expression. This is used to model policies such as transitive vs. non-transitive imports or the unreachability of lexical parents of imported modules [\[Van Antwerpen et al.](#page-28-3) [2016\]](#page-28-3). Data term well-formedness tests whether we have found the datum we were looking for. For example, to resolve a reference x we use a well-formedness predicate that matches all declaration-type pairs y: T where  $x \simeq y$ , that is, the reference has the same name as the declaration (but a different position in the program).

Finally, the judgment *WFD*, *WFL*,  $\leq_d$ ,  $<_l$ ,  $G \vdash p : s \stackrel{r}{\vdash} d$  states that data term d is *visible* through path p from scope s under relation r with the well-formedness predicates WFD, WFL, and the orders  $\leq_d$  and  $<_l$ . The parameterization is chosen such that algorithmic resolution remains feasible (see Section 4.2). The *visibility order*  $p_1 <_p p_2$  (' $p_1$  shadows  $p_2$ ') is defined as a prefix order over the labels of a path, in terms of a label order  $<_l$ . A special label \$ indicates the end of a path, and is used to order paths of different lengths. The prefix order only orders paths that have a common prefix. That is,  $s_1 \cdot l_1 \cdot s_2 \not<_p s_1' \cdot l_1' \cdot s_2' \cdot l_2' \cdot s_3'$  when  $s_1 \neq s_1'$  or  $l_1 \neq l_1'$ . The *data order*  $d \leq_d d$  decides which declarations shadow each other, if multiple declarations are reachable via shadowing paths. This is used to specify all visible declarations, where a declaration only shadows a declaration that is reached via a shadowed path, if it has the same name. Using the visibility order and data order, the rule (NR-Vis) defines that a data term d is visible through path p when there does not exist a data term d' reachable through p' such that d' shadows d and such that p' is strictly preferred over p. We will illustrate below how this captures the notion of shadowing in name resolution.

In the rest of this section we show how scope graphs can be used in the definition of type systems for languages with a variety of binding systems, including bindings in types. We discuss how our approach compares to representations of binding in traditional definitions of type systems.

#### <span id="page-5-1"></span>2.2 Simply-Typed Lambda Calculus

First we consider the syntax and typing rules for the simply-typed lambda calculus with arithmetic expressions (STLC) in Fig. 3. The language consists of number constants, addition, function literals, variables, function application, and let bindings.

Name binding for STLC is typically modeled using type environments, which are ordered lists of pairs associating a name with a type. Scoping is modeled by extension of an environment with a new pair, which shadows any earlier declarations of the same name (either by removing a matching pair or through definition of the lookup function). The extended environment is only used for those sub-expressions where the binding is in scope. Scope graphs make the shadowing rules explicit by separating the construction of the binding structure and the definition of resolution.

The typing rules in Fig. 3 use scope graphs and the resolution calculus instead of type environments to model binding in STLC. The judgment  $\mathcal{G}$ ,  $s \vdash e : t$  states that in the context of scope graph  $\mathcal{G}$  and scope s, expression e has type t. The rules are implicitly parameterized by a scope graph  $\mathcal{G}$ , and use  $s_1 \xrightarrow{l} s_2$  as a shorthand for  $s_1 \xrightarrow{l} s_2 \in \text{edges}(\mathcal{G})$ , and  $s \xrightarrow{r} d$  for  $s \xrightarrow{r} d \in \text{data}(\mathcal{G})$ . The notation  $\nabla s$  is used to assert that a scope s is distinct in a scope graph. For example, the  $\nabla s_2$  premise in the (STLC-Fun) rule asserts that the scope  $s_2$  is distinct from  $s_1$  in the scope graph.

Scope Graph Structure. In addition to defining the *types* of expression forms, the typing rules define the scoping structure of expressions by relating the scope of an expression to the scope(s) of its sub-expressions. Numbers, addition, and function application are non-binding, non-scoping constructs. Thus, rules (STLC-Num), (STLC-Plus), and (STLC-App) state that the scope of the sub-expressions (if any) of these operators is the same as the scope of the parent. Rules (STLC-Fun) and (STLC-Let) introduce a distinct scope  $s_2$  and associate a declaration  $x_i$ : t for the binding occurrence with that scope. A scope edge  $s_2 \xrightarrow{P} s_1$  makes the declarations reachable from  $s_1$ , also reachable from the scope  $s_2$ , which is used as the scope for the sub-expression in which the binding occurrence is in scope: the bodies of the function and let expression. Note that in (STLC-Let), scope

<span id="page-5-0"></span><sup>&</sup>lt;sup>2</sup>We can think of  $\nabla s$  as a claim to "ownership" of scope s. Each scope in the scope graph can have exactly one "owner". In Section 4 we give a declarative semantics of Statix where this notion is formally defined.

```
Syntax
           integers z \in \mathbb{Z} := {...,-1,0,1,...}
      identifiers x \in Id := some countable set
   expressions e \in Expr := z \mid e + e \mid fun(x : t) \{ e \} \mid x \mid e e \mid let x = e in e
                types t \in Type ::= num \mid t \rightarrow t
Resolution Syntax Parameters
                                            labels l \in \mathcal{L} ::= P
                                      relations r \in \mathcal{R} ::= :
                                  data terms d \in \mathcal{D} ::= x_i : t
                                                                                                                                       d \in DECL(x_i) || \hat{l} <_l \hat{l}
Matching Declarations, Label Order and Data Order
                                                    \frac{\mathsf{x}_i \simeq \mathsf{x}_j}{(\mathsf{x}_j : \mathsf{t}) \in DECL(\mathsf{x}_i)} \qquad \$ <_l P \qquad t_1 \leq_\top t_2
Typing Rules
                                                                                                                                                                                 G, s \vdash e : t
                                  (STLC-Num)\frac{s \vdash e_1 : num}{s \vdash z : num} \qquad (STLC-Plus)\frac{s \vdash e_1 : num}{s \vdash e_1 + e_2 : num}
                                        (STLC-Fun) \frac{\nabla s_2 \quad s_2 \xrightarrow{P} s_1 \quad s_2 \stackrel{:}{\longrightarrow} x_i : t_1 \quad s_2 \vdash e : t_2}{s_1 \vdash \mathbf{fun} \quad (x_i : t_1) \quad \{e\} : t_1 \rightarrow t_2}
        (STLC-Id) \frac{DECL(\mathsf{x}_i), \mathsf{P}^*, \leq_\mathsf{T}, <_l \vdash p : s \stackrel{:}{\mapsto} \mathsf{x}_j : \mathsf{t}}{s \vdash \mathsf{x}_i : \mathsf{t}} \qquad (STLC-App) \frac{s \vdash \mathsf{e}_1 : \mathsf{t}_1 \rightarrow \mathsf{t}_2 \quad s \vdash \mathsf{e}_2 : \mathsf{t}_1}{s \vdash \mathsf{e}_1 : \mathsf{e}_2 : \mathsf{t}_2}
                 \frac{s_1 \vdash e_1 : t_1 \quad \nabla s_2 \quad s_2 \stackrel{P}{\longrightarrow} s_1 \quad s_2 \stackrel{:}{\longrightarrow} x_i : t_1 \quad s_2 \vdash e_2 : t_2}{s_1 \vdash \text{let } x_i = e_1 \text{ in } e_2 : t_2}
Fig. 3. Syntax and typing rules for a simply-typed lambda calculus using scope graphs
```

 $s_1$  is used for the initialization expression, reflecting that the variable introduced is not in scope in that expression.

Before we consider the rule (SLTC-Id) and name resolution, it can be helpful to visualize scope graphs using scope graph diagrams. To distinguish different occurrences of the same name in a program we subscript names in programs by a position index. For example, the program fun  $(x : num) \{ x \}$  is written fun  $(x_1 : num) \{ x_2 \}$ . Fig. 2 shows an example program and its scope graph diagram. Scopes are depicted by circles labeled with a number, and edges between scopes are depicted as labeled edges  $\stackrel{l}{\longrightarrow}$ . Scope #0 in the scope graph in Fig. 2 is the scope of the context of the outer let. Scopes #1 and #2 are the scopes of the first and second let, respectively. Scope #3 is the scope of the function literal. The scopes are connected via P-labeled edges to their lexical parent scope (thus P is for parent). Declarations are depicted as boxes associated with scopes via an — edge going from a scope to a declaration. Lastly, references are depicted as boxes connected to scopes by edges

<span id="page-6-1"></span>![](_page_6_Figure_5.jpeg)

Fig. 2. A program with nested lets

going from the reference to the scope. References are not formally part of the structure of scope

graphs (Fig. [1\)](#page-4-0), but we include them in scope graph diagrams to indicate which scope each reference is resolved relative to.

Reachability and Visibility. Now we can consider how variables in STLC are resolved in rule (STLC-Id). The premise of the rule states that x<sup>i</sup> has type t if x<sup>i</sup> can be resolved in scope s through path p leading to a declaration x<sup>j</sup> : t, such that there is no other declaration with a matching name that shadows x<sup>j</sup> : t. The data well-formedness and label order used as parameters to resolve x<sup>i</sup> in (STLC-Id) are defined in Fig. [3.](#page-6-0) The declaration well-formedness predicate DECL(xi) is parameterized by an identifier x<sup>i</sup> with position subscript i as input, and identifies the set of all declarations with the same name as, but at positions different from, x<sup>i</sup> . The label well-formedness predicate for STLC is P ∗ , which reflects that a variable can be resolved in any scope reachable through a sequence of parent edges. Declarations are not ordered in STLC, and the ≤<sup>⊤</sup> order passed as parameter to the visibility judgment in (STLC-Id) is the order where all declarations are equal. The definition \$ <<sup>l</sup> P of the visibility ordering for STLC specifies that shorter paths are preferred over longer paths. Thus, declaration in a scope that has a path with fewer P edges is preferred, which formalizes the usual notion of shadowing based on on lexical proximity. For example, the reference x<sup>4</sup> in the program in Fig. [2](#page-6-1) reaches x<sup>1</sup> and x<sup>3</sup> since DECL(x4), P ∗ ⊢ s3·P·s2·P·s<sup>1</sup> : s<sup>3</sup> x<sup>1</sup> : **num** and DECL(x4), P ∗ ⊢ s<sup>3</sup> : s<sup>3</sup> x<sup>3</sup> : **num**. However, because s<sup>3</sup> <<sup>p</sup> s3·P·s2, we have that x<sup>4</sup> resolves to x3.

#### <span id="page-7-0"></span>2.3 Records and Structural Subtyping

Next we consider an extension of STLC with structural records. The language defined in Fig. [4](#page-8-0) extends STLC with record literals, field access, record extension, and a Pascal/JavaScript-like **with** expression. Record types are structural, that is, record types are not identified by name, but by a set of field-type pairs. The type system features subtyping between record types: a function expecting a record as parameter can be provided any extension of the expected record type. We discuss how to identify, represent, compose, access, and compare record types.

Identifying Record Types. In nominal type systems, types are identified by name. Information about the type is associated with that name. For example, with scope graphs we can state s td (Point,rPoint), which associates with the type name Point some representation rPoint of the record type. A record type can then be represented as REC(Point) referring to the declaration of the type by its name. Such a representation is efficient since copying the type entails copying a reference to its representation. Furthermore, a type is directly related to its origin in a program. The disadvantage of nominal types is that each variation of a type must be given a name and that comparisons must be organized through relations between names. In structural type systems, types are identified by their structure [\[Cardelli 1988\]](#page-27-2). This means that new types can be created 'on the fly', that is, not all types have to be defined by name. In previous work, [Van Antwerpen et al.](#page-28-3) [\[2016\]](#page-28-3) show how to represent nominal record types with scope graphs, but not how to express structural comparisons and composition of such types. Here we show how to do that using scopes as types and scope graph queries.

Representing Record Types. The representation of record types requires a mapping from field names to types. [Pierce](#page-28-1) [\[2002\]](#page-28-1) uses association lists to represent record types. With scope graphs, we do not need a new representation: scopes provide a natural representation for record types. For example, the x coordinate of a Point type is represented as a declaration in the scope:sPoint x : num. Such a scope could be associated with a type name to realize a nominal type system, as discussed above. To realize a structural type system, we use the scope reference itself as a type, and represent a record type as REC(s<sup>r</sup> ). A difference with the traditional representation of structural types as association lists is that scopes have identity. Thus, copying types entails copying of references.

```
Syntax
  expressions e ∈ Expr ::= . . . | { (x = e)
                                            ∗
                                            } | e.x | e extends e | with e do e
syntactic types t ∈ TypeExpr ::= num | t -> t | { (x : t)
                                                   ∗
                                                    }
semantic types T,U ∈ Type ::= NUM | T → T | REC(s)
Resolution Syntax Parameters
      labels l ∈ L ::= . . . | R | E and otherwise like STLC
Syntactic to Semantic Typing G ⊢ JtK ⇛ T
          (T-Num)
