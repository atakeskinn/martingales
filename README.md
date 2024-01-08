## Abstract
In the scope of this project, we present a formalization of martingales in arbitrary Banach spaces.

The current formalization of conditional expectation in the Isabelle library is limited to real-valued functions. To overcome this limitation, we extend the construction of conditional expectation to general Banach spaces, employing an approach similar to the one described in "Analysis in Banach Spaces Volume I" by Hytönen et al. We use measure theoretic arguments to construct the conditional expectation using suitable limits of simple functions.

Subsequently, we define stochastic processes and introduce the concepts of adapted, progressively measurable and predictable processes using suitable locale definitions. We show the relation
$$\text{adapted} \supseteq \text{progressive} \supseteq \text{predictable}$$
Furthermore, we show that progressive measurability and adaptedness are equivalent when the indexing set is discrete. We pay special attention to predictable processes in discrete-time, showing that $(X_n)_{n \in \mathbb{N}}$ is predictable if and only if $(X _{n + 1}) _{n \in \mathbb{N}}$ is adapted.

Moving forward, we rigorously define martingales, submartingales, and supermartingales, presenting their first consequences and corollaries. Discrete-time martingales are given special attention in the formalization. In every step of our formalization, we make extensive use of the powerful locale system of Isabelle.

The formalization further contributes by generalizing concepts in Bochner integration by extending their application from the real numbers to arbitrary Banach spaces equipped with a second-countable topology. Induction schemes for integrable simple functions on Banach spaces are introduced, accommodating various scenarios with or without a real vector ordering. Specifically, we formalize a powerful result called the "Averaging Theorem" (Real and Functional Analysis, Serge Lang) which allows us to show that densities are unique in Banach spaces.

In depth information on the formalization and the proofs of the individual theorems can be found in the thesis linked below.

#### [View this entry on the Archive of Formal Proofs](https://www.isa-afp.org/entries/Martingales.html)

## Related publications
- Lang, S. (1993). Real and Functional Analysis. In Graduate Texts in Mathematics. Springer New York. https://doi.org/10.1007/978-1-4612-0897-6
- Hytönen, T., van Neerven, J., Veraar, M., & Weis, L. (2016). Analysis in Banach Spaces. Springer International Publishing. https://doi.org/10.1007/978-3-319-48520-1
- Keskin, A. (2023). A Formalization of Martingales in Isabelle/HOL (Version 1). arXiv. https://doi.org/10.48550/ARXIV.2311.06188
