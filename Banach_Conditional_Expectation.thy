theory Banach_Conditional_Expectation                                                                                  
  imports Main "HOL-Probability.Conditional_Expectation" "HOL-Analysis.Analysis" "HOL-Analysis.Bochner_Integration" Misc
begin                                           

abbreviation "sb_integrable \<equiv> Bochner_Integration.simple_bochner_integrable"
abbreviation "sb_integral \<equiv> Bochner_Integration.simple_bochner_integral"

lemma banach_density_unique:
  fixes f f'::"_ \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes M[measurable]: "integrable M f" "integrable M f'"
  assumes density_eq: "\<And>A. A \<in> sets M \<Longrightarrow> (\<integral>x \<in> A. f x \<partial>M) = (\<integral>x \<in> A. f' x \<partial>M)"
  shows "AE x in M. f x = f' x"
  sorry

lemma set_integrableI:
  fixes f :: "'a \<Rightarrow> 'b::{banach, second_countable_topology}"
  assumes "A \<in> sets M"
      and "integrable M f"
    shows "set_integrable M A f"
  unfolding set_integrable_def using assms by (rule integrable_mult_indicator)

definition has_cond_exp :: "'a measure \<Rightarrow> 'a measure \<Rightarrow> ('a \<Rightarrow> 'b) \<Rightarrow> ('a \<Rightarrow> 'b::{real_normed_vector, second_countable_topology}) \<Rightarrow> bool" where 
  "has_cond_exp M F f g = ((\<forall>A \<in> sets F. (\<integral> x \<in> A. f x \<partial>M) = (\<integral> x \<in> A. g x \<partial>M))
                        \<and> integrable M f 
                        \<and> integrable M g 
                        \<and> g \<in> borel_measurable F)"

lemma has_cond_expI[intro]:
  assumes "\<And>A. A \<in> sets F \<Longrightarrow> (\<integral> x \<in> A. f x \<partial>M) = (\<integral> x \<in> A. g x \<partial>M)"
          "integrable M f"
          "integrable M g"
          "g \<in> borel_measurable F"
  shows "has_cond_exp M F f g"
  using assms unfolding has_cond_exp_def by simp

lemma has_cond_expD:
  assumes "has_cond_exp M F f g"
  shows "\<And>A. A \<in> sets F \<Longrightarrow> (\<integral> x \<in> A. f x \<partial>M) = (\<integral> x \<in> A. g x \<partial>M)"
        "integrable M f"
        "integrable M g"
        "g \<in> borel_measurable F"
  using assms unfolding has_cond_exp_def by simp+

lemma has_cond_exp_nested_subalg:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "subalgebra M G" "subalgebra G F" "integrable M f" "has_cond_exp M F f h" "has_cond_exp M G f h'"
  shows "has_cond_exp M F h' h"
proof -
  show ?thesis
  proof (standard, goal_cases)
    case (1 A)
    show ?case by (metis 1 assms(2,4,5) has_cond_expD(1) in_mono subalgebra_def)
  next
    case 2
    then show ?case using has_cond_expD(3)[OF assms(5)] by blast
  next
    case 3
    then show ?case using has_cond_expD(3)[OF assms(4)] .
  next
    case 4
    then show ?case using has_cond_expD(4)[OF assms(4)] .
  qed
qed

definition cond_exp :: "'a measure \<Rightarrow> 'a measure \<Rightarrow> ('a \<Rightarrow> 'b) \<Rightarrow> ('a \<Rightarrow> 'b::{real_normed_vector, second_countable_topology})" where
  "cond_exp M F f = (if \<exists>g. has_cond_exp M F f g then (SOME g. has_cond_exp M F f g) else (\<lambda>_. 0))"

lemma borel_measurable_cond_exp[measurable]: "cond_exp M F f \<in> borel_measurable F" 
  by (metis cond_exp_def someI has_cond_exp_def borel_measurable_const)

lemma integrable_cond_exp[intro]: "integrable M (cond_exp M F f)" 
  by (metis cond_exp_def has_cond_expD(3) integrable_zero someI)

context sigma_finite_subalgebra
begin

lemma borel_measurable_cond_exp'[measurable]: "cond_exp M F f \<in> borel_measurable M"
  by (metis cond_exp_def someI has_cond_exp_def borel_measurable_const subalg measurable_from_subalg)

lemma cond_exp_null: 
  assumes "\<nexists>g. has_cond_exp M F f g" 
  shows "cond_exp M F f = (\<lambda>_. 0)"
  unfolding cond_exp_def using assms by argo

lemma has_cond_exp_charact:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "has_cond_exp M F f g"
  shows "has_cond_exp M F f (cond_exp M F f)"
        "AE x in M. cond_exp M F f x = g x"
proof -
  show cond_exp: "has_cond_exp M F f (cond_exp M F f)" using assms someI cond_exp_def by metis
  let ?MF = "restr_to_subalg M F"
  {
    fix A assume "A \<in> sets ?MF"
    then have [measurable]: "A \<in> sets F" using sets_restr_to_subalg[OF subalg] by simp
    have "(\<integral>x \<in> A. g x \<partial>?MF) = (\<integral>x \<in> A. g x \<partial>M)" using assms subalg by (auto simp add: integral_subalgebra2 set_lebesgue_integral_def dest!: has_cond_expD)
    also have "... = (\<integral>x \<in> A. cond_exp M F f x \<partial>M)" using assms cond_exp by (simp add: has_cond_exp_def)
    also have "... = (\<integral>x \<in> A. cond_exp M F f x \<partial>?MF)" using subalg by (auto simp add: integral_subalgebra2 set_lebesgue_integral_def)
    finally have "(\<integral>x \<in> A. g x \<partial>?MF) = (\<integral>x \<in> A. cond_exp M F f x \<partial>?MF)" by simp
  }
  hence "AE x in ?MF. cond_exp M F f x = g x" using cond_exp assms subalg by (intro banach_density_unique, auto dest: has_cond_expD intro!: integrable_in_subalg )
  then show "AE x in M. cond_exp M F f x = g x" using AE_restr_to_subalg[OF subalg] by simp
qed

lemma cond_exp_F_meas[intro, simp]:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "integrable M f"
          "f \<in> borel_measurable F"
    shows "AE x in M. cond_exp M F f x = f x"
  by (rule has_cond_exp_charact(2), auto intro: assms)

text \<open>Congruence\<close>

lemma has_cond_exp_cong:
  assumes "integrable M f" "\<And>x. x \<in> space M \<Longrightarrow> f x = g x" "has_cond_exp M F g h"
  shows "has_cond_exp M F f h"
proof (intro has_cond_expI[OF _ assms(1)], goal_cases)
  case (1 A)
  hence "set_lebesgue_integral M A f = set_lebesgue_integral M A g" by (intro set_lebesgue_integral_cong) (meson assms(2) subalg in_mono subalgebra_def sets.sets_into_space subalgebra_def subsetD)+
  then show ?case using 1 assms(3) by (simp add: has_cond_exp_def)
qed (auto simp add: has_cond_expD[OF assms(3)])

lemma cond_exp_cong:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "integrable M f" "integrable M g" "\<And>x. x \<in> space M \<Longrightarrow> f x = g x"
  shows "AE x in M. cond_exp M F f x = cond_exp M F g x"
proof (cases "\<exists>h. has_cond_exp M F f h")
  case True
  then obtain h where h: "has_cond_exp M F f h" "has_cond_exp M F g h" using has_cond_exp_cong assms by metis 
  show ?thesis using h[THEN has_cond_exp_charact(2)] by fastforce
next
  case False
  moreover have "\<nexists>h. has_cond_exp M F g h" using False has_cond_exp_cong assms by auto
  ultimately show ?thesis unfolding cond_exp_def by auto
qed

lemma has_cond_exp_cong_AE:
  assumes "integrable M f" "AE x in M. f x = g x" "has_cond_exp M F g h"
  shows "has_cond_exp M F f h"
  using assms(1,2) subalg subalgebra_def subset_iff 
  by (intro has_cond_expI, subst set_lebesgue_integral_cong_AE[OF _ assms(1)[THEN borel_measurable_integrable] borel_measurable_integrable(1)[OF has_cond_expD(2)[OF assms(3)]]]) 
     (fast intro: has_cond_expD[OF assms(3)] integrable_cong_AE_imp[OF _ _ AE_symmetric])+

lemma has_cond_exp_cong_AE':
  assumes "h \<in> borel_measurable F" "AE x in M. h x = h' x" "has_cond_exp M F f h'"
  shows "has_cond_exp M F f h"
  using assms(1, 2) subalg subalgebra_def subset_iff
  using AE_restr_to_subalg2[OF subalg assms(2)] measurable_from_subalg
  by (intro has_cond_expI , subst set_lebesgue_integral_cong_AE[OF _ measurable_from_subalg(1,1)[OF subalg], OF _ assms(1) has_cond_expD(4)[OF assms(3)]])
     (fast intro: has_cond_expD[OF assms(3)] integrable_cong_AE_imp[OF _ _ AE_symmetric])+

lemma cond_exp_cong_AE:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "integrable M f" "integrable M g" "AE x in M. f x = g x"
  shows "AE x in M. cond_exp M F f x = cond_exp M F g x"
proof (cases "\<exists>h. has_cond_exp M F f h")
  case True
  then obtain h where h: "has_cond_exp M F f h" "has_cond_exp M F g h" using has_cond_exp_cong_AE assms by (metis (mono_tags, lifting) eventually_mono)
  show ?thesis using h[THEN has_cond_exp_charact(2)] by fastforce
next
  case False
  moreover have "\<nexists>h. has_cond_exp M F g h" using False has_cond_exp_cong_AE assms by auto
  ultimately show ?thesis unfolding cond_exp_def by auto
qed
  
lemma has_cond_exp_real[intro]:
  fixes f :: "'a \<Rightarrow> real"
  assumes "integrable M f"
  shows "has_cond_exp M F f (real_cond_exp M F f)"
  by (standard, auto intro!: real_cond_exp_intA assms)

lemma cond_exp_real[intro]:
  fixes f :: "'a \<Rightarrow> real"
  assumes "integrable M f"
  shows "AE x in M. cond_exp M F f x = real_cond_exp M F f x" 
  using has_cond_exp_charact assms by blast

text \<open>Indicator functions\<close>

lemma has_cond_exp_indicator:
  assumes "A \<in> sets M" "emeasure M A < \<infinity>"
  shows "has_cond_exp M F (\<lambda>x. indicat_real A x *\<^sub>R y) (\<lambda>x. real_cond_exp M F (indicator A) x *\<^sub>R y)"
proof (intro has_cond_expI, goal_cases)
  case (1 B)
  have "\<integral>x\<in>B. (indicat_real A x *\<^sub>R y) \<partial>M  = (\<integral>x\<in>B. indicat_real A x \<partial>M) *\<^sub>R y" using assms by (intro set_integral_scaleR_left, meson 1 in_mono subalg subalgebra_def, blast)
  also have "... = (\<integral>x\<in>B. real_cond_exp M F (indicator A) x \<partial>M) *\<^sub>R y" using 1 assms by (subst real_cond_exp_intA, auto)
  also have "... = \<integral>x\<in>B. (real_cond_exp M F (indicator A) x *\<^sub>R y) \<partial>M" using assms by (intro set_integral_scaleR_left[symmetric], meson 1 in_mono subalg subalgebra_def, blast)
  finally show ?case .
next
  case 2
  then show ?case using integrable_scaleR_left integrable_real_indicator assms by blast
next
  case 3
  show ?case using assms by (intro integrable_scaleR_left, intro real_cond_exp_int, blast+)
next
  case 4
  then show ?case by (intro borel_measurable_scaleR, intro Conditional_Expectation.borel_measurable_cond_exp, simp)
qed

lemma cond_exp_indicator[intro]:
  fixes y :: "'b::{second_countable_topology,banach}"
  assumes [measurable]: "A \<in> sets M" "emeasure M A < \<infinity>"
  shows "AE x in M. cond_exp M F (\<lambda>x. indicat_real A x *\<^sub>R y) x = cond_exp M F (indicator A) x *\<^sub>R y"
proof -
  have "AE x in M. cond_exp M F (\<lambda>x. indicat_real A x *\<^sub>R y) x = real_cond_exp M F (indicator A) x *\<^sub>R y" using has_cond_exp_indicator[OF assms] has_cond_exp_charact by blast
  thus ?thesis using cond_exp_real[OF integrable_real_indicator, OF assms] by fastforce
qed

text \<open>Addition\<close>

lemma has_cond_exp_add:
  fixes f g :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "has_cond_exp M F f f'" "has_cond_exp M F g g'"
  shows "has_cond_exp M F (\<lambda>x. f x + g x) (\<lambda>x. f' x + g' x)"
proof (intro has_cond_expI, goal_cases)
  case (1 A)
  have "\<integral>x\<in>A. (f x + g x)\<partial>M = (\<integral>x\<in>A. f x \<partial>M) + (\<integral>x\<in>A. g x \<partial>M)" using assms[THEN has_cond_expD(2)] subalg 1 by (intro set_integral_add(2), auto simp add: subalgebra_def intro!: set_integrableI)
  also have "... = (\<integral>x\<in>A. f' x \<partial>M) + (\<integral>x\<in>A. g' x \<partial>M)" using assms[THEN has_cond_expD(1)[OF _ 1]] by argo
  also have "... = \<integral>x\<in>A. (f' x + g' x)\<partial>M" using assms[THEN has_cond_expD(3)] subalg 1 by (intro set_integral_add(2)[symmetric], auto simp add: subalgebra_def intro!: set_integrableI)
  finally show ?case .
next
  case 2
  then show ?case by (metis Bochner_Integration.integrable_add assms has_cond_expD(2))
next
  case 3
  then show ?case by (metis Bochner_Integration.integrable_add assms has_cond_expD(3))
next
  case 4
  then show ?case using assms borel_measurable_add has_cond_expD(4) by blast
qed

lemma cond_exp_add':
  fixes f g :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "has_cond_exp M F f f'" "has_cond_exp M F g g'"
  shows "AE x in M. cond_exp M F (\<lambda>a. f a + g a) x = cond_exp M F f x + cond_exp M F g x"
  using assms by (fast intro!: has_cond_exp_add has_cond_exp_charact)

lemma has_cond_exp_scaleR_right:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "has_cond_exp M F f f'"
  shows "has_cond_exp M F (\<lambda>x. c *\<^sub>R f x) (\<lambda>x. c *\<^sub>R f' x)"
  using has_cond_expD[OF assms] by (intro has_cond_expI, auto)

lemma cond_exp_scaleR_right:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "integrable M f"
  shows "AE x in M. cond_exp M F (\<lambda>x. c *\<^sub>R f x) x = c *\<^sub>R cond_exp M F f x"
proof (cases "\<exists>f'. has_cond_exp M F f f'")
  case True
  then show ?thesis using assms has_cond_exp_charact has_cond_exp_scaleR_right by metis
next
  case False
  show ?thesis
  proof (cases "c = 0")
    case True
    then show ?thesis by simp
  next
    case c_nonzero: False
    have "\<nexists>f'. has_cond_exp M F (\<lambda>x. c *\<^sub>R f x) f'"
    proof (standard, goal_cases)
      case 1
      then obtain f' where f': "has_cond_exp M F (\<lambda>x. c *\<^sub>R f x) f'" by blast
      have "has_cond_exp M F f (\<lambda>x. inverse c *\<^sub>R f' x)" using has_cond_expD[OF f'] divideR_right[OF c_nonzero] assms by (intro has_cond_expI, auto)
      then show ?case using False by blast
    qed
    then show ?thesis using cond_exp_null[OF False] cond_exp_null by force
  qed 
qed

lemma cond_exp_diff':
  fixes f g :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "has_cond_exp M F f f'" "has_cond_exp M F g g'"
  shows "AE x in M. cond_exp M F (\<lambda>x. f x - g x) x = cond_exp M F f x - cond_exp M F g x"
  using cond_exp_add'[OF assms(1) has_cond_exp_scaleR_right[OF assms(2), of "-1"]] cond_exp_scaleR_right[OF assms(2)[THEN has_cond_expD(2)], of "-1"] by force

lemma has_cond_exp_simple:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "simple_function M f" "emeasure M {y \<in> space M. f y \<noteq> 0} \<noteq> \<infinity>"
  shows "has_cond_exp M F f (cond_exp M F f)"
  using assms
proof (induction rule: simple_integrable_function_induct)
  case (cong f g)
  then show ?case using has_cond_exp_cong by (metis (no_types, opaque_lifting) Bochner_Integration.integrable_cong has_cond_expD(2) has_cond_exp_charact(1))
next
  case (indicator A y)
  then show ?case using has_cond_exp_charact[OF has_cond_exp_indicator] by fast
next
  case (add u v)
  then show ?case using has_cond_exp_add has_cond_exp_charact(1) by blast
qed

lemma cond_exp_norm_le_real:
  fixes f :: "'a \<Rightarrow> real"
  assumes "integrable M f"
  shows "AE x in M. norm (cond_exp M F f x) \<le> cond_exp M F (\<lambda>x. norm (f x)) x"
proof-
  have "AE x in M. 0 \<le> real_cond_exp M F (\<lambda>x. norm (cond_exp M F f x)) x" by (standard, simp+)
  hence "AE x in M. real_cond_exp M F (\<lambda>x. norm (cond_exp M F f x)) x = abs (real_cond_exp M F (\<lambda>x. norm (cond_exp M F f x)) x)" by force
  hence "AE x in M. norm (cond_exp M F f x) = abs (real_cond_exp M F (\<lambda>x. norm (cond_exp M F f x)) x)" using assms has_cond_exp_simple 
    apply (subst AE_trans, subst real_cond_exp_F_meas[THEN AE_symmetric]) sorry
  moreover have "AE x in M. abs (real_cond_exp M F (\<lambda>x. norm (cond_exp M F f x)) x) \<le> real_cond_exp M F (\<lambda>x. norm (cond_exp M F f x)) x"
    sorry
  thus ?thesis sorry
qed

lemma simple_cond_exp_norm_le:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology, banach}"
  assumes "simple_function M f" "emeasure M {y \<in> space M. f y \<noteq> 0} \<noteq> \<infinity>"
  shows "AE x in M. norm (cond_exp M F f x) \<le> cond_exp M F (\<lambda>x. norm (f x)) x"
  using assms
proof (induction rule: simple_integrable_function_induct)
  case (cong f g)
  hence ae: "AE x in M. f x = g x" by blast
  hence "AE x in M. cond_exp M F f x = cond_exp M F g x" using cong has_cond_exp_simple by (subst cond_exp_cong_AE) (auto intro!: has_cond_expD(2))
  hence "AE x in M. norm (cond_exp M F f x) = norm (cond_exp M F g x)" by force
  moreover have "AE x in M. cond_exp M F (\<lambda>x. norm (f x)) x = cond_exp M F (\<lambda>x. norm (g x)) x"  using ae cong has_cond_exp_simple by (subst cond_exp_cong_AE) (auto dest: has_cond_expD)
  ultimately show ?case using cong(6) by fastforce
next
  case (indicator A y)
  hence "AE x in M. cond_exp M F (\<lambda>a. indicator A a *\<^sub>R y) x = cond_exp M F (indicator A) x *\<^sub>R y" by blast
  hence *: "AE x in M. norm (cond_exp M F (\<lambda>a. indicat_real A a *\<^sub>R y) x) \<le> norm y * cond_exp M F (\<lambda>x. norm (indicat_real A x)) x" using cond_exp_norm_le_real[OF integrable_real_indicator, OF indicator] by fastforce

  have "AE x in M. norm y * cond_exp M F (\<lambda>x. norm (indicat_real A x)) x = norm y * real_cond_exp M F (\<lambda>x. norm (indicat_real A x)) x" using cond_exp_real[OF integrable_real_indicator, OF indicator] by fastforce
  moreover have "AE x in M. cond_exp M F (\<lambda>x. norm y * norm (indicat_real A x)) x = real_cond_exp M F (\<lambda>x. norm y * norm (indicat_real A x)) x" using indicator by (intro cond_exp_real, auto)
  ultimately have "AE x in M. norm y * cond_exp M F (\<lambda>x. norm (indicat_real A x)) x = cond_exp M F (\<lambda>x. norm y * norm (indicat_real A x)) x" using real_cond_exp_cmult[of "\<lambda>x. norm (indicat_real A x)" "norm y"] indicator by fastforce
  moreover have "(\<lambda>x. norm y * norm (indicat_real A x)) = (\<lambda>x. norm (indicat_real A x *\<^sub>R y))" by force
  ultimately show ?case using * by force
next
  case (add u v)
  have "AE x in M. norm (cond_exp M F (\<lambda>a. u a + v a) x) = norm (cond_exp M F u x + cond_exp M F v x)" using cond_exp_add'[OF has_cond_exp_simple(1,1), OF add(1,2,3,4)] by fastforce
  moreover have "AE x in M. norm (cond_exp M F u x + cond_exp M F v x) \<le> norm (cond_exp M F u x) + norm (cond_exp M F v x)" using norm_triangle_ineq by blast
  moreover have "AE x in M. norm (cond_exp M F u x) + norm (cond_exp M F v x) \<le> cond_exp M F (\<lambda>x. norm (u x)) x + cond_exp M F (\<lambda>x. norm (v x)) x" using add(6,7) by fastforce
  moreover have "AE x in M. cond_exp M F (\<lambda>x. norm (u x)) x + cond_exp M F (\<lambda>x. norm (v x)) x = cond_exp M F (\<lambda>x. norm (u x) + norm (v x)) x" using integrable_simple_function[OF add(1,2)] integrable_simple_function[OF add(3,4)] by (intro cond_exp_add'[THEN AE_symmetric], auto)
  moreover have "AE x in M. cond_exp M F (\<lambda>x. norm (u x) + norm (v x)) x = cond_exp M F (\<lambda>x. norm (u x + v x)) x" using add(5) integrable_simple_function[OF add(1,2)] integrable_simple_function[OF add(3,4)] by (intro cond_exp_cong, auto)
  ultimately show ?case by force
qed

lemma has_cond_exp_lim:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology, banach}"
  assumes "integrable M f"
      and "\<And>i. simple_function M (s i)"
      and "\<And>i. emeasure M {y \<in> space M. s i y \<noteq> 0} \<noteq> \<infinity>"
      and "\<And>x. x \<in> space M \<Longrightarrow> (\<lambda>i. s i x) \<longlonglongrightarrow> f x"
      and "\<And>x i. x \<in> space M \<Longrightarrow> norm (s i x) \<le> 2 * norm (f x)"
  obtains r where "has_cond_exp M F f (\<lambda>x. lim (\<lambda>i. cond_exp M F (s i) x))"
proof -
  let ?u = "\<lambda>i x. cond_exp M F (s i) x"
  have "AE x in M. (\<lambda>i. ?u i x) \<longlonglongrightarrow> lim (\<lambda>i. ?u i x)"
  proof-
    have "AE x in M. Cauchy (\<lambda>i. s i x)" using assms(4) by (meson AE_I2 LIMSEQ_imp_Cauchy)
    hence "AE x in M. \<forall>e > 0. \<exists>N. \<forall>i\<ge>N. \<forall>j\<ge>N. norm (s i x - s j x) < e" using CauchyD by fast
    moreover have "AE x in M. \<forall>i j. norm (?u i x - ?u j x) \<le> norm (s i x - s j x)"
    proof -
      fix i j
      have "AE x in M. ?u i x - ?u j x = cond_exp M F (\<lambda>x. s i x - s j x) x" using cond_exp_diff'[THEN AE_symmetric, OF has_cond_exp_simple(1,1)[OF assms(2,3)]] by presburger
      hence "AE x in M. norm (?u i x - ?u j x) = norm (cond_exp M F (\<lambda>x. s i x - s j x) x)" by fastforce
      have "AE x in M. norm (cond_exp M F (\<lambda>x. s i x - s j x) x) \<le> cond_exp M F (\<lambda>x. norm (s i x - s j x)) x" using assms(2,3) apply (intro simple_cond_exp_norm_le, simp) sorry
      
      thus ?thesis sorry
    qed
    ultimately have "AE x in M. \<forall>e > 0. \<exists>N. \<forall>i\<ge>N. \<forall>j\<ge>N. norm (?u i x - ?u j x) < e" by (subst AE_mp[OF _ AE_impI', of "\<lambda>x. (\<forall>e > 0. \<exists>N. \<forall>i\<ge>N. \<forall>j\<ge>N. norm (s i x - s j x) < e) \<and> (\<forall>i j. norm (?u i x - ?u j x) \<le> norm (s i x - s j x))"], fast, meson order.strict_trans1, blast)
    hence "AE x in M. Cauchy (\<lambda>i. ?u i x)" using CauchyI by fast
    thus ?thesis using convergent_eq_Cauchy limI by fast
  qed

  have integrableM0: "integrable M (\<lambda>x. u i x - s i x)" for i by (metis Bochner_Integration.integrable_diff assms(6) has_cond_expD(2) has_cond_expD(3))

  have "(\<lambda>i. integral\<^sup>L M (u i)) = (\<lambda>i. integral\<^sup>L M (s i))" sorry
  have "(\<lambda>i. integral\<^sup>L M (s i)) \<longlonglongrightarrow> integral\<^sup>L M f" sorry
  have "lim (\<lambda>i. integral\<^sup>L M (u i)) = integral\<^sup>L M f" sorry

  have "(\<lambda>i. integral\<^sup>L M (u i)) \<longlonglongrightarrow> integral\<^sup>L M f" sorry


  have "AE x in M. u i x = s i x" for i sorry
  hence "AE x in M. u i x - s i x = 0" for i by simp
  hence "emeasure M {x \<in> space M. u i x - s i x \<noteq> 0} = 0" for i using AE_iff_measurable emeasure_neq_0_sets by fast
  hence "LINT x|M. norm (u i x - s i x) = 0" for i using integral_norm_eq_0_iff[OF integrableM0] by blast
  then obtain r where r_seq: "strict_mono r" "AE x in M. (\<lambda>n. u (r n) x - s (r n) x) \<longlonglongrightarrow> 0" 
    using integrableM0 tendsto_L1_AE_subseq[of M "\<lambda>i x. u i x - s i x"] by auto

  have "has_cond_exp M F f (\<lambda>x. lim (\<lambda>i. u (r i) x))"
  proof (rule has_cond_expI)
  
    have "AE x in M. (\<lambda>i. s i x) \<longlonglongrightarrow> f x" using assms(4) by simp
    hence "AE x in M. (\<lambda>i. s (r i) x) \<longlonglongrightarrow> f x" using r_seq(1) filterlim_compose filterlim_subseq by fast
    hence "AE x in M. (\<lambda>i. u (r i) x) \<longlonglongrightarrow> f x" using r_seq(2) Lim_transform by fast
    hence "AE x in M. lim (\<lambda>i. u (r i) x) = f x" using limI by fastforce
    hence ae_eq: "AE x in M. indicator A x *\<^sub>R lim (\<lambda>i. u (r i) x) = indicator A x *\<^sub>R f x" for A by fastforce
  
    show "(\<lambda>x. lim (\<lambda>i. u (r i) x)) \<in> borel_measurable F" using has_cond_expD(4)[OF assms(6), THEN borel_measurable_lim_metric] .
    hence "(\<lambda>x. indicator A x *\<^sub>R lim (\<lambda>i. u (r i) x)) \<in> borel_measurable F" if "A \<in> sets F" for A using borel_measurable_indicator borel_measurable_scaleR that by blast
    hence measurable0: "(\<lambda>x. indicator A x *\<^sub>R lim (\<lambda>i. u (r i) x)) \<in> borel_measurable M" if "A \<in> sets F" for A using measurable_from_subalg subalg that by blast
  
    have measurable1: "(\<lambda>x. indicator A x *\<^sub>R f x) \<in> borel_measurable M" if "A \<in> sets F" for A 
      using borel_measurable_scaleR assms(1) borel_measurable_indicator borel_measurable_integrable measurable_from_subalg
      subalg that by fast
  
  
    show intA: "set_lebesgue_integral M A f = \<integral>x\<in>A. lim (\<lambda>i. u (r i) x) \<partial>M" if "A \<in> sets F" for A
      using integral_cong_AE[OF measurable0[OF that] measurable1[OF that] ae_eq]
      unfolding set_lebesgue_integral_def by argo

    have "space M \<in> sets F" using sets.top subalg subalgebra_def by metis
    moreover have "AE x in M. indicat_real (space M) x *\<^sub>R lim (\<lambda>i. u (r i) x) = lim (\<lambda>i. u (r i) x)" by auto
    ultimately show "integrable M (\<lambda>x. lim (\<lambda>i. u (r i) x))" by (metis (full_types) \<open>AE x in M. lim (\<lambda>i. u (r i) x) = f x\<close> assms(1) assms(6) borel_measurable_lim_metric has_cond_expD(3) integrable_cong_AE integrable_iff_bounded)
  qed (simp add: assms(1))
  thus thesis using that sorry
qed

lemma has_cond_exp_cond_exp:
  fixes f :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "integrable M f"
  shows "has_cond_exp M F f (cond_exp M F f)"
  using assms
proof (induction rule: integrable_induct')
  case (base A c)
  show ?case using has_cond_exp_indicator[OF base(1,2)] has_cond_exp_charact(1) by blast
next
  case (add u v)
  show ?case using has_cond_exp_add[OF add(3,4)] has_cond_exp_charact(1) by blast
next
  case (lim f s)
  show ?case using has_cond_exp_lim[OF lim(1,3,4,5,6,7)] has_cond_exp_charact(1) by meson
qed

lemma cond_exp_cong:
  fixes f g :: "'a \<Rightarrow> 'b::{second_countable_topology,banach}"
  assumes "AE x in M. f x = g x"
      and [measurable]: "f \<in> borel_measurable M" "g \<in> borel_measurable M"
    shows "AE x in M. cond_exp M F f x = cond_exp M F g x"
  sorry
  

lemma cond_exp_intA:
    fixes f :: "'a \<Rightarrow>'b :: {second_countable_topology,real_normed_vector}"
  assumes [measurable]: "integrable M f" "A \<in> sets F"
  shows "has_cond_exp M F f \<cc>\<^sub>f" "integrable F \<cc>\<^sub>f"
          "(\<integral> x \<in> A. f x \<partial>F) = (\<integral> x \<in> A. \<cc>\<^sub>f x \<partial>F)"
  sorry


lemma cond_exp_int [intro]:
  assumes "integrable M f"
  obtains \<cc>\<^sub>f 
    where "has_cond_exp M F f \<cc>\<^sub>f" "integrable M \<cc>\<^sub>f" 
          "(\<integral>x. \<cc>\<^sub>f x \<partial>M) = (\<integral>x. f x \<partial>M)"
  sorry

lemma cond_exp_charact:
  assumes "\<And>A. A \<in> sets F \<Longrightarrow> (\<integral> x \<in> A. f x \<partial>M) = (\<integral> x \<in> A. g x \<partial>M)"
      and [measurable]: "integrable M f" "integrable M g"
          "g \<in> borel_measurable F"
  shows "AE x in M. cond_exp M F f x = g x"
  sorry



lemma cond_exp_F_meas [intro, simp]:
  assumes "integrable M f"
          "f \<in> borel_measurable F"
  shows "AE x in M. cond_exp M F f x = f x"
  sorry

lemma cond_exp_mult:
  assumes [measurable]:"f \<in> borel_measurable F" "g \<in> borel_measurable M" "integrable M (\<lambda>x. f x * g x)"
  shows "AE x in M. cond_exp M F (\<lambda>x. f x * g x) x = f x * cond_exp M F g x"
  sorry



lemma cond_exp_cmult [intro, simp]:
  fixes c::real
  assumes "integrable M f"
  shows "AE x in M. cond_exp M F (\<lambda>x. c * f x) x = c * cond_exp M F f x"
  sorry

lemma cond_exp_cdiv [intro, simp]:
  fixes c::real
  assumes "integrable M f"
  shows "AE x in M. cond_exp M F (\<lambda>x. f x / c) x = cond_exp M F f x / c"
  sorry

lemma cond_exp_diff [intro, simp]:
  assumes [measurable]: "integrable M f" "integrable M g"
  shows "AE x in M. cond_exp M F (\<lambda>x. f x - g x) x = cond_exp M F f x - cond_exp M F g x"
  sorry

lemma cond_exp_pos [intro]:
  assumes "AE x in M. f x \<ge> 0" and [measurable]: "f \<in> borel_measurable M"
  shows "AE x in M. cond_exp M F f x \<ge> 0"
  sorry

lemma cond_exp_mono:
  assumes "AE x in M. f x \<le> g x" and [measurable]: "integrable M f" "integrable M g"
  shows "AE x in M. cond_exp M F f x \<le> cond_exp M F g x"
  sorry

lemma cond_exp_gr_c:
  assumes [measurable]: "integrable M f"
      and AE: "AE x in M. f x > c"
  shows "AE x in M. cond_exp M F f x > c"
  sorry

lemma cond_exp_less_c:
  assumes [measurable]: "integrable M f"
      and "AE x in M. f x < c"
  shows "AE x in M. cond_exp M F f x < c"
  sorry

lemma cond_exp_ge_c:
  assumes [measurable]: "integrable M f"
      and "AE x in M. f x \<ge> c"
  shows "AE x in M. cond_exp M F f x \<ge> c"
  sorry

lemma cond_exp_le_c:
  assumes [measurable]: "integrable M f"
      and "AE x in M. f x \<le> c"
  shows "AE x in M. cond_exp M F f x \<le> c"
  sorry

lemma cond_exp_mono_strict:
  assumes "AE x in M. f x < g x" and [measurable]: "integrable M f" "integrable M g"
  shows "AE x in M. cond_exp M F f x < cond_exp M F g x"
  sorry

lemma cond_exp_nested_subalg [intro, simp]:
  assumes "subalgebra M G" "subalgebra G F"
      and [measurable]: "integrable M f"
  shows "AE x in M. cond_exp M F (cond_exp M G f) x = cond_exp M F f x"
  sorry

lemma cond_exp_sum [intro, simp]:
  fixes f::"'b \<Rightarrow> 'a \<Rightarrow> real"
  assumes [measurable]: "\<And>i. integrable M (f i)"
  shows "AE x in M. cond_exp M F (\<lambda>x. \<Sum>i\<in>I. f i x) x = (\<Sum>i\<in>I. cond_exp M F (f i) x)"
  sorry

theorem cond_exp_jensens_inequality:
  fixes q :: "real \<Rightarrow> real"
  assumes X: "integrable M X" "AE x in M. X x \<in> I"
  assumes I: "I = {a <..< b} \<or> I = {a <..} \<or> I = {..< b} \<or> I = UNIV"
  assumes q: "integrable M (\<lambda>x. q (X x))" "convex_on I q" "q \<in> borel_measurable borel"
  shows "AE x in M. cond_exp M F X x \<in> I"
        "AE x in M. q (cond_exp M F X x) \<le> cond_exp M F (\<lambda>x. q (X x)) x"
  sorry


lemma integrable_convex_cond_exp:
  fixes q :: "real \<Rightarrow> real"
  assumes X: "integrable M X" "AE x in M. X x \<in> I"
  assumes I: "I = {a <..< b} \<or> I = {a <..} \<or> I = {..< b} \<or> I = UNIV"
  assumes q: "integrable M (\<lambda>x. q (X x))" "convex_on I q" "q \<in> borel_measurable borel"
  assumes H: "emeasure M (space M) = \<infinity> \<Longrightarrow> 0 \<in> I"
  shows "integrable M (\<lambda>x. q (real_cond_exp M F X x))"
  sorry

end

end