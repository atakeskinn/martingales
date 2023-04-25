theory Sigma_Utils
  imports "HOL-Analysis.Measure_Space"
begin

definition sigma_gen :: "'a set \<Rightarrow> 'b measure \<Rightarrow> ('a \<Rightarrow> 'b) set \<Rightarrow> 'a measure" where
  "sigma_gen \<Omega> N S \<equiv> sigma \<Omega> (\<Union>f \<in> S. {f -` A \<inter> \<Omega> | A. A \<in> N})"

lemma [simp]:
  shows sets_sigma_gen: "sets (sigma_gen \<Omega> N S) = sigma_sets \<Omega> (\<Union>f \<in> S. {f -` A \<inter> \<Omega> | A. A \<in> N})" 
    and space_sigma_gen: "space (sigma_gen \<Omega> N S) = \<Omega>"
  by (auto simp add: sigma_gen_def sets_measure_of_conv space_measure_of_conv)

lemma measurable_sigma_gen[measurable]:
  assumes "f \<in> S" "f \<in> \<Omega> \<rightarrow> space N"
  shows "f \<in> sigma_gen \<Omega> N S \<rightarrow>\<^sub>M N"
  using assms by (intro measurableI, auto)

lemma measurable_sigma_gen_singleton[measurable]:
  assumes "f \<in> \<Omega> \<rightarrow> space N"
  shows "f \<in> sigma_gen \<Omega> N {f}\<rightarrow>\<^sub>M N"
  using assms measurable_sigma_gen by blast

lemma measurable_iff_contains_sigma_gen:
  shows "(f \<in> M \<rightarrow>\<^sub>M N) \<longleftrightarrow> f \<in> space M \<rightarrow> space N \<and> sigma_gen (space M) N {f} \<subseteq> M"
proof (standard, goal_cases)
  case 1
  hence "f \<in> space M \<rightarrow> space N" using measurable_space by fast
  thus ?case unfolding sets_sigma_gen by (simp, intro sigma_algebra.sigma_sets_subset, (blast intro: sets.sigma_algebra_axioms measurable_sets[OF 1])+) 
next
  case 2
  thus ?case using measurable_mono[OF _ refl _ space_sigma_gen] measurable_sigma_gen_singleton by fast
qed

lemma measurable_iff_contains_sigma_gen':
  shows "(S \<subseteq> M \<rightarrow>\<^sub>M N) \<longleftrightarrow> S \<subseteq> space M \<rightarrow> space N \<and> sigma_gen (space M) N S \<subseteq> M"
proof (standard, goal_cases)
  case 1
  hence subset: "S \<subseteq> space M \<rightarrow> space N" using measurable_space by fast
  have "{f -` A \<inter> space M |A. A \<in> N} \<subseteq> M" if "f \<in> S" for f using measurable_iff_contains_sigma_gen[unfolded sets_sigma_gen, of f] 1 subset that by blast
  then show ?case unfolding sets_sigma_gen using sets.sigma_algebra_axioms by (simp add: subset, intro sigma_algebra.sigma_sets_subset, blast+)
next
  case 2
  hence subset: "S \<subseteq> space M \<rightarrow> space N" by simp
  show ?case
  proof (standard, goal_cases)
    case (1 x)
    have "sigma_gen (space M) N {x} \<subseteq> M" by (metis (no_types, lifting) 1 2 sets_sigma_gen SUP_le_iff sigma_sets_le_sets_iff singletonD)
    thus ?case using measurable_iff_contains_sigma_gen subset[THEN subsetD, OF 1] by fast 
  qed
qed

end