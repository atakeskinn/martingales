theory Cond_Exp
  imports Complex_Main "HOL-Probability.Conditional_Expectation" "Lp.Lp"
begin

subsection \<open>Radon-Nikodym Property\<close>

locale conditional_expectation = prob_space M for M +
  fixes cond_exp :: "'a measure \<Rightarrow> ('a \<Rightarrow> 'b :: {second_countable_topology,real_normed_vector}) \<Rightarrow> 'a \<Rightarrow> 'b"
  assumes set_integral: "\<And>F f A. subalgebra M F \<Longrightarrow> integrable M f \<Longrightarrow> A \<in> sets F \<Longrightarrow> (\<integral> x \<in> A. f x \<partial>M) = (\<integral> x \<in> A. cond_exp F f x \<partial>M)"
  assumes characterization: "\<And>F f g. subalgebra M F \<Longrightarrow> \<lbrakk>\<And>A. A \<in> sets F \<Longrightarrow> (\<integral> x \<in> A. f x \<partial>M) = (\<integral> x \<in> A. g x \<partial>M); integrable M f; integrable M g; g \<in> borel_measurable F\<rbrakk> \<Longrightarrow> AE x in M. cond_exp F f x = g x"
  assumes measurable: "\<And>F f. subalgebra M F \<Longrightarrow> integrable M f \<Longrightarrow> cond_exp F f \<in> borel_measurable M"
  assumes measurable': "\<And>F f. subalgebra M F \<Longrightarrow> integrable M f \<Longrightarrow> cond_exp F f \<in> borel_measurable F"
  assumes integrable: "\<And>F f. subalgebra M F \<Longrightarrow> integrable M f \<Longrightarrow> integrable M (cond_exp F f)"

sublocale prob_space \<subseteq> conditional_expectation M "real_cond_exp M"
proof -
  have s: "sigma_finite_subalgebra M F" if "subalgebra M F" for F
    using finite_measure_subalgebra_is_sigma_finite
    unfolding finite_measure_subalgebra_def finite_measure_subalgebra_axioms_def 
    using local.finite_measure that by blast
  show "conditional_expectation M (real_cond_exp M)"
    apply (unfold_locales)
    using sigma_finite_subalgebra.real_cond_exp_intA[OF s] apply blast
    using sigma_finite_subalgebra.real_cond_exp_charact[OF s] apply blast
    using borel_measurable_cond_exp apply simp
    using borel_measurable_cond_exp2 apply simp
    using sigma_finite_subalgebra.real_cond_exp_int[OF s] apply simp
    done
qed

(* Delete this later *)
definition cond_exp :: "'a measure \<Rightarrow> 'a measure \<Rightarrow> ('a \<Rightarrow> 'b :: {second_countable_topology,real_normed_vector}) \<Rightarrow> 'a \<Rightarrow> 'b" where
  "cond_exp = undefined"
sublocale prob_space \<subseteq> cond_exp: conditional_expectation M "cond_exp M" sorry


end