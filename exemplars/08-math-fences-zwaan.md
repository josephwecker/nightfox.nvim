# Defining Name Accessibility using Scope Graphs (Extended Edition)

Aron Zwaan ⊠ ©

Delft University of Technology, Delft, Netherlands

Casper Bach Poulsen 

□

Delft University of Technology, Delft, Netherlands

#### Abstract

Many programming languages allow programmers to regulate *accessibility*; i.e., annotating a declaration with keywords such as **export** and **private** to indicate where it can be accessed. Despite the importance of name accessibility for, e.g., compilers, editor auto-completion and tooling, and automated refactorings, few existing type systems provide a formal account of name accessibility.

We present a declarative, executable, and language-parametric model for name accessibility, which provides a formal specification of name accessibility in Java,  $C^{\#}$ ,  $C^{++}$ , Rust, and Eiffel. We achieve this by defining name accessibility as a predicate on resolution paths through scope graphs. Since scope graphs are a language-independent model of name resolution, our model provides a uniform approach to defining different accessibility policies for different languages.

Our model is implemented in Statix, a logic language for executable type system specification using scope graphs. We evaluate its correctness on a test suite that compares it with the  $C^{\#}$ , Java, and Rust compilers, and show we can synthesize access modifiers in programs with holes accurately.

**2012 ACM Subject Classification** Software and its engineering  $\rightarrow$  Compilers; Software and its engineering  $\rightarrow$  Language features; Theory of computation  $\rightarrow$  Program constructs

Keywords and phrases access modifier, visibility, scope graph, name resolution

Digital Object Identifier 10.4230/LIPIcs.ECOOP.2024.31

Related Version Published Version: https://doi.org/10.4230/LIPIcs.ECOOP.2024.31 [38]

Supplementary Material Software Artifact

Software (ECOOP'24 AEC Approved Artifact): https://zenodo.org/records/11179594 [39]

**Acknowledgements** We thank Friedrich Steimann for challenging us to specify and formalize access modifiers using scope graphs, and the anonymous reviewers for their helpful comments.

# 1 Introduction

Many programming languages, especially object-oriented ones, support information hiding, i.e., regulating from which positions in a program a declaration can be accessed. Information hiding is used to enforce invariants of particular code units, implement design patterns (e.g. the singleton pattern), improve modularization, limit public APIs to offer guidance to library users and guarantee forward compatibility. Support for information hiding is usually provided using access modifier keywords<sup>1</sup> (access modifiers for short), such as public, protected, internal and private. Each of these corresponds with a particular accessibility policy that is validated by the type checker.

Although recent research has not paid much attention to access modifiers, there are still good reasons to study their semantics. First, understanding access modifiers is required to implement (alternative) compilers and editor services correctly. In particular, disregarding

© Aron Zwaan and Casper Bach Poulsen; licensed under Creative Commons License CC-BY 4.0
38th European Conference on Object-Oriented Programming (ECOOP 2024).
Editors: Jonathan Aldrich and Guido Salvaneschi; Article No. 31; pp. 31:1–31:50
Leibniz International Proceedings in Informatics
LIPICS Schloss Dagstuhl – Leibniz-Zentrum für Informatik, Dagstuhl Publishing, Germany

<sup>&</sup>lt;sup>1</sup> Other common names include 'access specifier' or 'visibility modifier'.

```
package p1;
                              package p;
                                                          package p;
class A {
                              class A {
                                                          class A {
  int x;
                                 protected int x;
                                                            private int x = 0;
                                                            protected int y = 1
                                                          }
package p2;
                               class B extends A {
                                                          class B {
class B extends p1.A { }
                                private int x;
                                                            int x = 3;
                                                            int y = 4;
                                                            class C extends A {
package p1;
class C extends p2.B {
                              class C extends B {
                                                               int z = x + y
  int y = x;
                                 int y = x;
                                                          }
(a) Inheritance through Packages.
                              (b) Inaccessible or Shadowed?
                                                         (c) Accessibility and Shadowing.
```

Figure 1 Examples of intricate Access Modifier semantics. Classes are assumed to be public.

accessibility may result in incorrect name binding, and hence incorrect program behavior. Second, formalizing access modifiers enables reasoning about the meaning of programs. Finally, program transformation tools, such as automated refactorings, must handle the semantics of accessibility correctly. This is especially relevant for research on large-scale automated transformations, aimed at dealing with large (legacy) codebases. It is often infeasible to check transformations performed with such tools manually. Thus, the correctness of these transformations must be guaranteed through other means.

The meaning of access modifiers can be intricate in corner cases. We illustrate that using the examples in Figure 1. In Figure 1a, there is an inheritance chain, where class C extends class B, which itself extends A. Classes A and C reside in package p1, while B is in p2. Class A defines a package-accessible field x, which is accessed in C. The question here is whether that access is actually allowed. One could reason that it is correct, as the access occurs in the same package as the declaration, so a package-level declaration should be visible. On the other hand, one could consider x not inherited by B [13, §8.2], and thus not inherited by C either. In fact, the Java language designers chose the second option, rejecting this program [26, §4.2]. Using ((A) this).x is accepted however.

Something similar happens in Figure 1b. Here, one can consider the reference x in class C to be invalid, as the field in class B is inaccessible. Alternatively, under the assumption that B.x is out of scope, the reference can be valid, pointing to A.x. In this case, Java checks accessibility after shadowing, so this program is again rejected. However, in Figure 1c, accessibility does influence the binding. The reference x binds to the field of the enclosing class B, as the field inherited from class A is inaccessible. However, reference y binds to the field inherited from A. Thus, in this case, the accessibility of the inherited fields determines the resolution of x and y; i.e., accessibility is checked before shadowing. This shows that specifying accessibility is essential to defining the name binding of a language correctly.

Unintuitive semantics of accessibility occurs in non-object-oriented languages as well. For example, the accessibility scheme of Agda seems simple: definitions are either public or module-private, and imported definitions can be re-exported. However, issue #5461<sup>2</sup> reports that re-exports in a private block are still exposed to the outside world. While this intuitively seems wrong to most commenters, an argument is made that this is actually the intended behavior. The discussion stalls shortly after a remark that talking about intended behavior is "meaningless without a specification".

https://github.com/agda/agda/issues/5461

These examples show that the meaning of access modifiers is not always obvious. Hence, language designers should define their semantics unambiguously. Ideally, that is done through specifications containing inference rules. Inference rules allow unambiguous interpretation of the meaning of programming language constructs, including name binding. However, perhaps surprisingly, a general model for defining access modifiers has never been proposed.

Perhaps closest is the work of Steimann and Thies [28] (later incorporated in the JRRT refactoring tool [26]). They propose a constraint-based approach to automating refactorings in Java, by collecting and solving accessibility constraints. These constraints are generated using constraint generation rules, which cover the access rules the Java compiler enforces. By solving these constraints, changes in accessibility implied by the refactoring can be inferred, yielding type- and behavior-preserving refactorings.

Steimann and Thies' work solves the problem of making refactorings in Java sound regarding accessibility. However, it does not yet give a high-level explanation of the meaning of access modifiers. This is partly because the constraint generation rules need several low-level details to catch some intricate corner cases, but also because the function that computes the minimal required accessibility level is not given, as it was "unpleasant to specify" and "of no theoretical interest" [28, §5.2]. Therefore, their work cannot easily be adapted to a different language or a different application (e.g., a type checker).

To advance the state of the art, we pursue the following goals:

- **Explain** the meaning of access modifiers.
- Explain the (subtle) differences between access modifiers in different languages.
- Provide a framework for experimenting with feature combinations that do not (yet) exist in other languages.

To this end, we do not fully formalize one particular language, but rather define a toy language that incorporates and combines a large number of accessibility features. To abstract over low-level name resolution details, we use *scope graphs* [21, 30, 25, 40]. In this paper, we demonstrate this is a natural fit, because accessibility can be expressed as a predicate over paths in a scope graph. The specification is written in the logic language Statix [30, 25], which has a well-defined declarative semantics and also supports generating executable type-checkers automatically.

We compare these executable type checkers with reference compilers of Java, C<sup>#</sup>, and Rust, showing that we accurately captured the semantics of access modifiers in some real-world languages. Moreover, using Statix/scope graphs as a basis for (language-parametric) refactorings is an active topic of research [19, 32, 18, 3]. We envision that this will provide accessibility-aware refactorings similar to Steimann et al., without requiring significant additional effort. This is substantiated by the fact that Statix-based code completion [22] proposes an access modifier if and only if it would not cause accessibility errors elsewhere in the program.

In summary, the contributions of this paper are as follows:

- We provide a systematic classification of accessibility features (Section 2);
- we apply our taxonomy to Java, C<sup>++</sup>, C<sup>#</sup>, Rust, and Eiffel (Section 2):
- we present a specification of (various versions of) accessibility on modules (Section 5), subclasses (Section 6), and their conjunctive and disjunctive combination (Section 7);
- we extend our specification with accessibility-restricting inheritance (Section 8);
- we prove some theorems about our model, showing it is well-behaved (Section 9); and
- we implement our specification in Statix, and compare it with the standard compilers of Java, C#, and Rust. Moreover, we show access modifiers can be synthesized accurately using Statix-based Code Completion [22] (Section 10).

# 2 Access Modifiers in Real-World Languages

In this section, we explore the design space of access modifiers as they occur in real-world languages. We first motivate why languages have access modifiers (Section 2.1). After that, we discuss common accessibility features (Section 2.2), summarizing them in a feature model (Section 2.3).

# 2.1 Why Accessibility?

Most programming languages allow programmers to define entities (variables, functions, types, etc.), and assign a name to them. That name can then be used to refer to the introduced entity from other positions in the program. However, as there is typically a large number of entities within a software project, most languages offer a notion of modularization to group related definitions. Equally named definitions in different modules can be distinguished by qualifying them with the name of the module in which they reside. Unqualified (or partially qualified) names by default resolve within their enclosing module, or imported modules. Details of this scheme differ from language to language, but generally aim to make definitions easy to refer to (e.g., by minimizing the number of required qualifiers), while trying to be unambiguous to the compiler and the programmer.

However, these rules may often be too lenient with respect to the intention of the programmer. A definition may be accessible from scopes where it is not intended to be used. This can have detrimental effects on the quality of a software artifact. For example, exposing all internal definitions of a library makes it (1) less intuitive to its users, (2) prone to forward compatibility issues and technical dept (e.g. strong coupling).

For these reasons, many programming languages provide constructs that give the programmer control over the regions of code where a definition can be accessed. For example, in many object-oriented languages, a class can access fields from its ancestor classes by default (language-controlled). However, if the programmer does not want a field to be accessible from subclasses, they can add a private access modifier. This modifier prevents access from all other classes (programmer-controlled). Although many constructs that provide access control to the programmer can be envisioned, most languages settle on a limited set of keywords that can be attached to a definition. In practice, this relatively simple scheme has proven powerful enough to cover most use cases.

#### 2.2 Accessibility in Practice

Next, we explore how languages typically provide modularization and accessibility features.

**Modules** A common feature that provides modularization is *modules* (also called 'package' or 'namespace'). A module is a syntactic construct that introduces a named collection of definitions. Members of modules can be accessed using the name of the module, for example in a preceding import statement, or as a qualifier to the name of the member that is accessed.

Hiding a definition from other modules is the simplest accessibility restriction that can be applied with respect to modules. For example, Java declarations without an access modifier can only be accessed within the same package. Rust items without a modifier behave similarly, except that declarations can still be accessed from submodules.

Some languages have multiple notions of modularization. For example, C<sup>#</sup> has assemblies, namespaces, and files, where a namespace can comprise multiple files, and/or a file can contain multiple namespaces. The internal keyword in C<sup>#</sup> restricts accessibility to the

```
mod outer {
    mod inner {
        pub x = 42;
        }
        pub use inner::x;
    }
}
fn main() {
        // ERROR: inner is inaccessible:
        // let x = outer::inner::x;
        let x = outer::x;
        println!("{x}")
}
```

Figure 2 Re-exports can change Accessibility

assembly, and the file keyword (introduced in  $C^{\#}$  11 [35]) to the current file. Similarly, Java 9 introduces modules [24], with features to restrict access from external modules.

Some languages give some more control over *which* modules a declaration can be accessed from. For example, Rust has the pub(in *path*) access modifier, where *path* refers to some enclosing module. This enables programmers to expose items to an arbitrary ancestor.

Imports usually do not affect the visibility of a declaration. A notable exception to this rule is re-exporting (e.g., as implemented in Rust), which can actually change the visibility of a declaration, as shown in Figure 2. In this program, the module inner is accessible in outer, but not in its parent (the root scope). Therefore, the function main cannot access its field x. However, outer re-exports inner::x, which gives rise to a new definition outer::x. As outer is accessible in the root scope, so is this definition. Hence, via the re-export, main can access x, although the original declaration was hidden.

From an accessibility point of view, re-exporting can typically be considered as a combination of an import and a declaration, where the declaration always points to the imported member. The re-exported item (inner::x in the example) should be accessible from the location of the re-export. References to the re-export should have access to the location of the re-export, but not necessarily to the location of the original declaration. In fact, for any access path, it does not matter whether the declaration is a re-export or not.

**Classes** A special modularization concept is the notion of *classes*, which represent composite data types with associated operations (methods). Where simple modules only have a static interpretation, an arbitrary number of class instances can exist at runtime.<sup>3</sup> While modules can implicitly be related to each other by their relative position, such a relation does not exist for classes. However, classes can extend other classes, ensuring the subclass inherits the fields of its parent class. This creates an inheritance hierarchy orthogonal to the module hierarchy.

Object-oriented languages usually provide modifiers to control accessibility over the inheritance chain. For example, Java and  $C^{\#}$  have a private keyword, which prevents access outside the defining class. Additionally, the protected keyword allows access from subclasses, but prevents access from any other location.

In Java and C<sup>#</sup>, the accessibility level is inherited with the field. That means, if a field in the superclass is protected, it will be protected in the subclass as well. However, C<sup>++</sup> allows restricting the accessibility of members of the parent class. A private modifier on extends-clauses will make all inherited public/protected members private on instances of the subclass. Similarly, a protected modifier will make all inherited public members protected.

Finally, some languages allow specifying 'friend' classes, which grant the friend access to its members. This enables fine-grained access control, independent from module and class hierarchies. While discouraged in  $C^{++}$ , Eiffel provides only this access control mechanism.

<sup>&</sup>lt;sup>3</sup> At this point, we slightly over-simplify the reality. For example, neither parameterized modules (ML) nor objects (e.g. Scala/Kotlin) fit in this scheme. We made this choice deliberately, to cover the most prevalent cases. We conjecture that the techniques we develop for classes can be applied to parameterized modules (and vice versa for modules and objects) but leave explicating that to future work.

**Interaction** Accessibility restrictions on modules and classes be combined. This is very explicit in C#, which has protected internal and private protected as additional modifiers. The former permits access from within the assembly (similar to internal) and to subclasses (similar to protected), even if they live outside the assembly. Analogously, private protected grants access to subclasses in the same assembly only, which is equivalent to the conjunction of internal and protected.

#### 2.3 Classification

These concepts are organized and related in the feature model in Figure 3. Following the previous discussion, the main features are modules and classes. We have only a single feature for modules, because the different variants are (apart from C#s files and namespaces) typically not mutually nested. The internal keyword can either relate to the containing module (Direct) or an arbitrary parent module (Ancestor). We explore this further in Section 5.

<sup>&</sup>lt;sup>4</sup> Either the most direct enclosing file (file), or most directly enclosing assembly (internal), possibly bypassing some namespaces.

![](_page_5_Figure_5.jpeg)

Figure 3 Feature Model for Access Control.

**Table 1** Languages classified according to the feature model in Figure 3.

|                             | Java         | C#                  | $C^{++}$     | Eiffel       | Rust     |
|-----------------------------|--------------|---------------------|--------------|--------------|----------|
| Modules                     | <b>✓</b>     | <b>✓</b>            | <b>✓</b>     |              | <b>✓</b> |
| Internal                    | Direct       | $\mathrm{Direct}^4$ | Direct       |              | Ancestor |
| Classes                     | $\checkmark$ | $\checkmark$        | $\checkmark$ | $\checkmark$ |          |
| Friends                     |              |                     | $\checkmark$ | $\checkmark$ |          |
| Subclass Acc. Mod.          | $\checkmark$ | $\checkmark$        | $\checkmark$ | $\checkmark$ |          |
| private                     | $\checkmark$ | $\checkmark$        | $\checkmark$ | $\checkmark$ |          |
| protected                   |              | $\checkmark$        | $\checkmark$ |              |          |
| $protected \mid internal$   | $\checkmark$ | $\checkmark$        |              |              |          |
| $protected \ \& \ internal$ |              | $\checkmark$        | $\checkmark$ |              |          |
| Extends Clause Acc. Mod.    |              |                     | $\checkmark$ |              |          |
| private                     |              |                     | $\checkmark$ |              |          |
| protected                   |              |                     | <b>✓</b>     |              |          |

In the Classes category, the three subfeatures denote the three mechanisms for access control: Friends allow access to other classes by name, Subclass Access Modifiers are access modifiers on definitions that determine how it is accessible within the class hierarchy (Sections 6 and 7), and Extends Clause Access Modifiers (Section 8) are access modifiers on extends clauses, as seen in C<sup>++</sup>. The latter two have subfeatures for each concrete keyword associated with the access control mechanism. For that reason, private and protected occur twice: once on definitions and once on extends clauses. Table 1 classifies several languages according to this scheme. In the remainder of this paper, we develop AML (Access Modifier Language), a language that covers all features. To this end, we first introduce scope graphs (Section 3), and a base language for AML (Section 4).

# 3 Using Scope Graphs to Model Name Binding in Programs

In the previous section, we sketched the landscape of access modifiers. This discussion was based largely on prose specifications as well as experiments with compiler implementations. No language specification we are aware of provides a more rigorous model of accessibility (or even non-lexical name binding). In this section, we introduce *scope graphs* [21, 30, 25, 40], and argue that they provide a suitable framework for such a model. Section 4 introduces AML (Access Modifier Language), a toy language with a type system defined using scope graphs. Sections 5–8 will extend this language with all accessibility features from Figure 3.

#### 3.1 Scope Graphs as A Model for Name Binding

From a name binding perspective, classes and modules have some similarities. Each of these constructs can be thought of as introducing a 'scope' (region of code), in which declarations live, and in which names can be resolved. Scopes are related to each other in various ways. First, modules are related according to their relative position in the abstract syntax tree. In addition, imports and extends clauses relate arbitrary modules and classes, respectively. Resolving a reference corresponds to finding a matching declaration in a scope that is reachable from the scope of the reference. For example, a reference may resolve to a declaration if it lives in a lexically enclosing scope, or in a module that is imported in an enclosing scope.

Scope graphs [21, 30, 25, 40] make this more precise. In this model, the name binding structure of a program is represented by a graph. Figure 4 (adapted from Poulsen et al. [23, Fig. 1]) gives an example program and its corresponding scope graph. A scope is represented by a circular node in the graph. For example,  $s_0$  represents the global scope, and  $s_A$ ,  $s_B$  and  $s_C$  represent the bodies of modules A, B, and C, respectively. Scopes are related using labeled, directed edges. For example,  $s_A$  is lexically enclosed by  $s_0$ , and thus the graph contains an edge from  $s_A$  to  $s_0$  with label Lex. Similarly,  $s_B$  imports  $s_A$ , and thus the graph contains an edge  $s_B \xrightarrow{\text{IMP}} s_A$ . Finally, scope graphs contain declarations. For example, a declaration of i in scope  $s_C$  is represented by the  $s_C \xrightarrow{\text{VAR}} i$ : int edge/node pair. Similarly, the modules are declared in the root scope (e.g.,  $s_0 \xrightarrow{\text{MOD}} A \sim s_A$ ). The language specification determines which data is included in the declaration. Similarly, the labels for edges and declarations can be chosen to match the (binding) constructs of the language.

**Reachability** To resolve a reference, a *query* is executed to find a valid path in the scope graph from the scope of the reference to a matching declaration. Queries give specification writers several options to filter paths, to retain only valid paths. First, a unary predicate selects valid declarations. Usually, this predicate matches declarations with the name of the

![](_page_7_Figure_2.jpeg)

Figure 4 Reachability example. The IMP? part in the regular expression prevents traversal over the second IMP edge.

![](_page_7_Figure_4.jpeg)

Figure 5 Shadowing example. The highlighted label order causes the edge to SF to have priority.

reference. Second, a regular expression over labels is used to select valid paths. This regular expression can, for example, be used to prevent transitive imports, or accessing members in a lexical parent of an imported module.

Figure 4 illustrates this with the query for i in module C (dashed blue box). The parameter on the arrow (LEX\*IMP<sup>?</sup>VAR), is a regular expression that defines which paths to declarations are valid. The LEX\* indicates that a path may traverse an arbitrary number of LEX-edges. This corresponds to looking for variables in enclosing scopes. Next, the IMP? part indicates that zero or one IMP-edges can be traversed. Finally, the regular expression ends with VAR to ensure all paths resolve in variable declarations only, excluding e.g. modules. The isVar<sub>i</sub> parameter matches all variable definitions with name i (isVar is defined in the next section). The candidate path (shown as blue edges) does not match this regular expression. Because IMP-labeled edges may only be traversed one time, the step to  $s_A$  cannot be made. In other words: the declaration of i in A is not reachable from C.

**Visibility** Not every declaration that is reachable (i.e., for which a valid access path exists) can actually be referenced, due to shadowing. For example, in most languages, local definitions have higher priority than imported ones. We call reachable declarations that are not shadowed by any other declaration visible.

In scope graphs, visibility can be encoded using a partial order on labels. For example, an order VAR < IMP encodes that (local) variable declarations shadow imported declarations. This is illustrated in Figure 5. The reference x in module F can refer to the declaration in module D as well as the one in module E. Because the label order (third argument) indicates that imports shadow lexically enclosing scopes (IMP < LEX). Thus, the variable resolves to the declaration in  $s_{\rm F}$ . Alternatively, if LEX < IMP, it would resolve to x in  $s_{\rm D}$ . Finally, if neither LEX  $\not <$  IMP nor IMP  $\not <$  LEX, both paths would be included in the query result.

In summary, scope graphs model the name binding structure of a program using nodes for scopes and declarations, and edges for relations between those. Queries can be used to model reference resolution. A query selects a declaration when (1) it matches some predicate, and (2) there exists a path to it of which the labels match a regular expression, and (3) no other paths that traverse labels with higher priority exist. The result of a query is a set of paths that lead to these matching declarations.

**Accessibility** We can model extensibility using plain scope graphs by including accessibility information in the *declaration*. In other words, a declaration of a variable in a scope graph contains not only a name and a type, but also its accessibility level. *After resolution*, we check if the path that the query returns is actually valid according to the accessibility level of the declaration. For example, if a variable is private, but an EXT-edge (for class *extension*) is traversed, an error is emitted. With this pattern, we can model all accessibility features.

**Notation** Figures 4 and 5 introduce the graphical notation of scope graphs. In text, variable s ranges over scopes, and S over sets of scopes. Moreover, we use the following notation for assertions on scope graphs:  $s_1 \stackrel{\mathsf{L}}{\longrightarrow} s_2 \in \mathcal{G}$  means 'scope graph  $\mathcal{G}$  has an  $\mathsf{L}$ -labeled edge from  $s_1$  to  $s_2$ ', and  $s \stackrel{\mathsf{D}}{\longrightarrow} d \in \mathcal{G}$  means that  $\mathcal{G}$  has a declaration with data d under label  $\mathsf{D}$  in scope s. Moreover, we write queries in the following way:

$$\mathbf{query}_{\mathcal{G}} s \stackrel{R}{\longmapsto} \mathcal{P} / \mathcal{O} \mapsto R$$

where  $\mathcal{G}$  is the scope graph in which the query is resolved, s is the scope in which the resolution starts, R is the regular expression that paths must adhere to, and  $\mathcal{P}$  is the predicate that declarations must match.  $\mathcal{O}$  is the strict partial order on labels used for shadowing. It is usually written as  $L_1 < L_2 < \cdots < L_n$ . We omit the label order when there is no shadowing. R is the result set containing tuples of paths and declarations. When we expect a single result, we use  $\{\langle p, d \rangle\}$  to match on the value in the set. Paths are alternating sequences of scopes and labels, written as  $s_1 \stackrel{L_1}{\longrightarrow} s_2 \cdots s_m$ . Paths do not include the declaration it resolved to, but stop at the scope in which the declaration occurs. The functions  $\operatorname{src}(p)$ ,  $\operatorname{tgt}(p)$  refer to the source and target scope of a path, respectively,  $\operatorname{scopes}(p)$  denotes all scopes in a path.

# 4 AML: The Base Language

In the next sections, we show how scope graphs support intuitive formalization of accessibility. We will do so by defining AML (Access Modifier Language). The base syntax (which will be extended later) is given in Figure 6. In AML, a program consists of a list of modules. Each module can define other modules, import other modules, and contain class definitions. A class can optionally extend another class, and contains a list of field declarations. Each field has an access modifier, and is initialized by some expression. Possible expressions include references, integer constants, class instance creation, field access, and binary operations.

At the right-hand side of Figure 6, the scope graph parameters are shown. There are three labels that connect scopes. Lex denotes lexical scoping, IMP denotes imports, and ext class extension. The other three labels are used for declarations. Mod is used for module declarations, cls for classes, and var for variables/fields. Next, we assume that each *module scope* has a thism edge pointing to itself, and similarly, each class has a thisc scope pointing to itself. This will be used to resolve enclosing classes or modules. The sort  $\langle d \rangle$  denotes the data that can be associated with scopes. Modules and classes are characterized by their name and the scope of their body. A field has a name, a type  $\langle T \rangle$ , and an accessibility level  $\langle A \rangle$ .

