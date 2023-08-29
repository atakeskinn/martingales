theory Filtered_Measure
imports "HOL-Probability.Conditional_Expectation"
begin                                                                                          

subsection \<open>Filtered Measure\<close>

locale filtered_measure = 
  fixes M F and t\<^sub>0 :: "'b :: {second_countable_topology, linorder_topology}"
  assumes subalgebra: "\<And>i. t\<^sub>0 \<le> i \<Longrightarrow> subalgebra M (F i)"
      and sets_F_mono: "\<And>i j. t\<^sub>0 \<le> i \<Longrightarrow> i \<le> j \<Longrightarrow> sets (F i) \<le> sets (F j)"
begin

lemma space_F: 
  assumes "t\<^sub>0 \<le> i"
  shows "space (F i) = space M"
  using subalgebra assms by (simp add: subalgebra_def)

lemma subalgebra_F: 
  assumes "t\<^sub>0 \<le> i" "i \<le> j"
  shows "subalgebra (F j) (F i)"
  unfolding subalgebra_def using assms by (simp add: space_F sets_F_mono)

lemma borel_measurable_mono:
  assumes "t\<^sub>0 \<le> i" "i \<le> j"
  shows "borel_measurable (F i) \<subseteq> borel_measurable (F j)"
  unfolding subset_iff by (metis assms subalgebra_F measurable_from_subalg)

end

subsection \<open>Filtered Sigma Finite Measure\<close>

text \<open>The locale presented here is a generalization of the \<^locale>\<open>sigma_finite_subalgebra\<close> for a particular filtration.\<close>

locale sigma_finite_filtered_measure = filtered_measure +
  assumes sigma_finite: "sigma_finite_subalgebra M (F t\<^sub>0)"

lemma (in sigma_finite_filtered_measure) sigma_finite_subalgebra_F[intro]:
  assumes "t\<^sub>0 \<le> i"
  shows "sigma_finite_subalgebra M (F i)"
  using assms by (metis dual_order.refl sets_F_mono sigma_finite sigma_finite_subalgebra.nested_subalg_is_sigma_finite subalgebra subalgebra_def)

subsubsection \<open>Typed locales\<close>

locale nat_filtered_measure = filtered_measure M F 0 for M and F :: "nat \<Rightarrow> _"
locale real_filtered_measure = filtered_measure M F 0 for M and F :: "real \<Rightarrow> _"

context nat_filtered_measure
begin

lemma space_F: "space (F i) = space M"
  using subalgebra by (simp add: subalgebra_def)

lemma subalgebra_F: 
  assumes "i \<le> j"
  shows "subalgebra (F j) (F i)"
  unfolding subalgebra_def using assms by (simp add: space_F sets_F_mono)

lemma borel_measurable_mono:
  assumes "i \<le> j"
  shows "borel_measurable (F i) \<subseteq> borel_measurable (F j)"
  unfolding subset_iff by (metis assms subalgebra_F measurable_from_subalg)

end

locale nat_sigma_finite_filtered_measure = sigma_finite_filtered_measure M F 0 for M and F :: "nat \<Rightarrow> _"
locale real_sigma_finite_filtered_measure = sigma_finite_filtered_measure M F 0 for M and F :: "real \<Rightarrow> _"

sublocale nat_sigma_finite_filtered_measure \<subseteq> sigma_finite_subalgebra M "F i" by blast

subsubsection "Constant Filtration"

lemma filtered_measure_constant_filtration:
  assumes "subalgebra M F"
  shows "filtered_measure M (\<lambda>_. F) t\<^sub>0"
  using assms by (unfold_locales) (auto simp add: subalgebra_def)

sublocale sigma_finite_subalgebra \<subseteq> constant_filtration: sigma_finite_filtered_measure M "\<lambda>_ :: 't :: {second_countable_topology, linorder_topology}. F" t\<^sub>0
  using subalg by (unfold_locales) (auto simp add: subalgebra_def)

end