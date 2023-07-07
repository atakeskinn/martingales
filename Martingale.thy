theory Martingale                 
  imports Stochastic_Process Banach_Conditional_Expectation
begin           


subsection \<open>Martingale\<close>

locale martingale = adapted_process +
  assumes integrable: "\<And>i. integrable M (X i)"
      and martingale_property: "\<And>i j. i \<le> j \<Longrightarrow> AE \<xi> in M. X i \<xi> = cond_exp M (F i) (X j) \<xi>"

lemma (in filtered_sigma_finite_measure) martingale_const[intro]:  
  assumes "integrable M f" "f \<in> borel_measurable (F bot)"
  shows "martingale M F (\<lambda>_. f)"
  using assms cond_exp_F_meas[OF assms(1), THEN AE_symmetric]
  by (unfold_locales, 
      simp add: borel_measurable_integrable,
      metis bot.extremum measurable_from_subalg sets_F_mono space_F subalgebra_def, blast,
      metis (mono_tags, lifting) borel_measurable_subalgebra bot_least filtration.sets_F_mono filtration_axioms space_F) 

lemma (in filtered_sigma_finite_measure) martingale_cond_exp[intro]:  
  assumes "integrable M f"
  shows "martingale M F (\<lambda>i. cond_exp M (F i) f)"
  by (unfold_locales,
      auto simp add: subalgebra borel_measurable_cond_exp borel_measurable_cond_exp' intro!: cond_exp_nested_subalg[OF assms],
      simp add: sets_F_mono space_F subalgebra_def)

lemma (in martingale) martingale_set_integral:
  assumes "A \<in> F i" "i \<le> j"
  shows "set_lebesgue_integral M A (X i) = set_lebesgue_integral M A (X j)"
proof -
  have "\<integral>x \<in> A. X i x \<partial>M = \<integral>x \<in> A. cond_exp M (F i) (X j) x \<partial>M" using martingale_property[OF assms(2)] borel_measurable_cond_exp' assms(1) subalgebra subalgebra_def by (intro set_lebesgue_integral_cong_AE[OF _ random_variable]) fastforce+
  also have "... = \<integral>x \<in> A. X j x \<partial>M" using assms(1) by (auto simp: integrable intro: cond_exp_set_integral[symmetric])
  finally show ?thesis .
qed

subsection \<open>Submartingale\<close>

locale submartingale = adapted_process_order +
  assumes integrable: "\<And>i. integrable M (X i)"
      and submartingale_property: "\<And>i j. i \<le> j \<Longrightarrow> AE \<xi> in M. X i \<xi> \<le> cond_exp M (F i) (X j) \<xi>"

subsection \<open>Supermartingale\<close>

locale supermartingale = adapted_process_order +
  assumes integrable: "\<And>i. integrable M (X i)"
      and supermartingale_property: "\<And>i j. i \<le> j \<Longrightarrow> AE \<xi> in M. X i \<xi> \<ge> cond_exp M (F i) (X j) \<xi>"

subsection \<open>Martingale Stuff\<close>

(* Locale of martingale with order *)

locale martingale_order = martingale M F X for M F and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {ordered_euclidean_space}"
begin

lemma is_submartingale: "submartingale M F X" using martingale_property by (unfold_locales) (force simp add: integrable)+

lemma is_supermartingale: "supermartingale M F X" using martingale_property by (unfold_locales) (force simp add: integrable)+

end

sublocale martingale_order \<subseteq> martingale_is_submartingale: submartingale by (rule is_submartingale)

sublocale martingale_order \<subseteq> martingale_is_supermartingale: supermartingale by (rule is_supermartingale)

context martingale
begin

lemma scaleR_const[intro]:
  shows "martingale M F (\<lambda>i x. c *\<^sub>R X i x)"
proof -
  {
    fix i j :: 'b assume "i \<le> j"
    hence "AE x in M. c *\<^sub>R X i x = cond_exp M (F i) (\<lambda>x. c *\<^sub>R X j x) x" 
      using cond_exp_scaleR_right[OF integrable, of i c, THEN AE_symmetric] martingale_property by force
  }
  thus ?thesis by (unfold_locales) (auto simp add: borel_measurable_const_scaleR adapted random_variable integrable)
qed

lemma uminus[intro]:
  shows "martingale M F (- X)" 
  using scaleR_const[of "-1"] by (force intro: back_subst[of "martingale M F"])

lemma add[intro]:
  assumes "martingale M F Y"
  shows "martingale M F (\<lambda>i \<xi>. X i \<xi> + Y i \<xi>)"
proof -
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> + Y i \<xi> = cond_exp M (F i) (\<lambda>x. X j x + Y j x) \<xi>" 
      using cond_exp_add[OF integrable martingale.integrable[OF assms], of i j j, THEN AE_symmetric] 
            martingale_property[OF asm] martingale.martingale_property[OF assms asm] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_add random_variable adapted integrable martingale.adapted martingale.random_variable martingale.integrable)
qed

lemma diff[intro]:
  assumes "martingale M F Y"
  shows "martingale M F (\<lambda>i x. X i x - Y i x)"
proof -
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> - Y i \<xi> = cond_exp M (F i) (\<lambda>x. X j x - Y j x) \<xi>" 
      using cond_exp_diff[OF integrable martingale.integrable[OF assms], of i j j, THEN AE_symmetric, unfolded fun_diff_def] 
            martingale_property[OF asm] martingale.martingale_property[OF assms asm] by fastforce
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_diff random_variable adapted integrable martingale.random_variable martingale.adapted martingale.integrable)  
qed

end

locale\<^marker>\<open>tag unimportant\<close> martingale_iff = submartingale M F X + supermartingale M F X for M F and X :: "_ \<Rightarrow> _ \<Rightarrow> _::{second_countable_topology, order, banach}"
begin
 
lemma martingale_iff: "martingale M F X" using integrable submartingale_property supermartingale_property by (unfold_locales) (fast intro: antisym)+

end

lemmas martingale_iff = martingale_iff.martingale_iff[OF martingale_iff.intro]

subsection \<open>Submartingale Stuff\<close>

context submartingale
begin

lemma set_integral_le:
  assumes "A \<in> F i" "i \<le> j"
  shows "set_lebesgue_integral M A (X i) \<le> set_lebesgue_integral M A (X j)" 
  unfolding cond_exp_set_integral[OF integrable assms(1), of j]  
  using submartingale_property[OF assms(2)]
  by (simp only: set_lebesgue_integral_def, intro integral_mono_AE_ordered_real_vector, metis assms(1) in_mono integrable integrable_mult_indicator subalgebra subalgebra_def, metis assms(1) in_mono integrable_mult_indicator subalgebra subalgebra_def integrable_cond_exp) 
     (auto intro: scaleR_left_mono)

lemma cond_exp_diff_nonneg: 
  assumes "i \<le> j"
  shows "AE x in M. 0 \<le> cond_exp M (F i) (X j - X i) x"
  using submartingale_property[OF assms] cond_exp_diff[OF integrable(1,1), of i j i] cond_exp_F_meas[OF integrable adapted, of i] by fastforce

lemma add[intro]:
  assumes "submartingale M F Y"
  shows "submartingale M F (\<lambda>i \<xi>. X i \<xi> + Y i \<xi>)"
proof -
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> + Y i \<xi> \<le> cond_exp M (F i) (\<lambda>x. X j x + Y j x) \<xi>" 
      using cond_exp_add[OF integrable submartingale.integrable[OF assms], of i j j] 
            submartingale_property[OF asm] submartingale.submartingale_property[OF assms asm] add_mono[of "X i _" _ "Y i _"] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_add random_variable adapted integrable submartingale.random_variable submartingale.adapted submartingale.integrable)  
qed

lemma diff[intro]:
  assumes "supermartingale M F Y"
  shows "submartingale M F (\<lambda>i \<xi>. X i \<xi> - Y i \<xi>)"
proof -
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> - Y i \<xi> \<le> cond_exp M (F i) (\<lambda>x. X j x - Y j x) \<xi>" 
      using cond_exp_diff[OF integrable supermartingale.integrable[OF assms], of i j j, unfolded fun_diff_def] 
            submartingale_property[OF asm] supermartingale.supermartingale_property[OF assms asm] diff_mono[of "X i _" _ _ "Y i _"] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_diff random_variable adapted integrable supermartingale.random_variable supermartingale.adapted supermartingale.integrable)  
qed

lemma scaleR_nonneg: 
  assumes "c \<ge> 0"
  shows "submartingale M F (\<lambda>i \<xi>. c *\<^sub>R X i \<xi>)"
proof
  {
    fix i j :: 'b assume asm: "i \<le> j"
    show "AE \<xi> in M. c *\<^sub>R X i \<xi> \<le> cond_exp M (F i) (\<lambda>\<xi>. c *\<^sub>R X j \<xi>) \<xi>"  
      using cond_exp_scaleR_right[OF integrable, of i "c" j] submartingale_property[OF asm] by (auto intro!: scaleR_left_mono[OF _ assms])
  }
qed (auto simp add: borel_measurable_integrable borel_measurable_scaleR integrable random_variable adapted borel_measurable_const_scaleR)

lemma scaleR_nonpos: 
  assumes "c \<le> 0"
  shows "supermartingale M F (\<lambda>i \<xi>. c *\<^sub>R X i \<xi>)"
proof
  {
    fix i j :: 'b assume asm: "i \<le> j"
    show "AE \<xi> in M. c *\<^sub>R X i \<xi> \<ge> cond_exp M (F i) (\<lambda>\<xi>. c *\<^sub>R X j \<xi>) \<xi>" 
      using cond_exp_scaleR_right[OF integrable, of i "c" j] submartingale_property[OF asm] by (auto intro!: scaleR_left_mono_neg[OF _ assms])
  }
qed (auto simp add: borel_measurable_integrable borel_measurable_scaleR integrable random_variable adapted borel_measurable_const_scaleR)

lemma uminus[intro]:
  shows "supermartingale M F (- X)"
  unfolding fun_Compl_def using scaleR_nonpos[of "-1"] by simp

end 

lemma (in adapted_process_order) submartingale_of_cond_exp_diff_nonneg:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and diff_nonneg: "\<And>i j. i \<le> j \<Longrightarrow> AE x in M. 0 \<le> cond_exp M (F i) (X j - X i) x"
    shows "submartingale M F X"
proof (unfold_locales)
  {
    fix i j :: 't assume asm: "i \<le> j"
    show "AE \<xi> in M. X i \<xi> \<le> cond_exp M (F i) (X j) \<xi>" 
      using diff_nonneg[OF asm] cond_exp_diff[OF integrable(1,1), of i j i] cond_exp_F_meas[OF integrable adapted, of i] by fastforce
  }
qed (intro integrable)

lemma (in adapted_process_order) submartingale_of_set_integral_le:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>A i j. i \<le> j \<Longrightarrow> A \<in> F i \<Longrightarrow> set_lebesgue_integral M A (X i) \<le> set_lebesgue_integral M A (X j)"
    shows "submartingale M F X"
proof (unfold_locales)
  {
    fix i j :: 't assume asm: "i \<le> j"
    {
      fix A assume "A \<in> F i"
      hence "LINT \<xi>|M. indicat_real A \<xi> *\<^sub>R (X j \<xi> - X i \<xi>) \<ge> 0" using assms(2)[OF asm] sorry
    }
    thus "AE \<xi> in M. X i \<xi> \<le> cond_exp M (F i) (X j) \<xi>" sorry
  }
qed (intro integrable)


subsection \<open>Supermartingale Stuff\<close>

context supermartingale
begin

lemma set_integral_ge:
  assumes "A \<in> F i" "i \<le> j"
  shows "set_lebesgue_integral M A (X i) \<ge> set_lebesgue_integral M A (X j)"
  unfolding cond_exp_set_integral[OF integrable assms(1), of j]
  using supermartingale_property[OF assms(2)] 
  by (simp only: set_lebesgue_integral_def, intro integral_mono_AE_ordered_real_vector, metis assms(1) in_mono integrable_mult_indicator subalgebra subalgebra_def integrable_cond_exp, metis assms(1) in_mono integrable integrable_mult_indicator subalgebra subalgebra_def)
     (auto intro: scaleR_left_mono)

lemma cond_exp_diff_nonneg:
  assumes "i \<le> j"
  shows "AE x in M. 0 \<le> cond_exp M (F i) (X i - X j) x"
  using supermartingale_property[OF assms] cond_exp_diff[OF integrable(1,1), of i i j] cond_exp_F_meas[OF integrable adapted, of i] by fastforce

lemma add[intro]:
  assumes "supermartingale M F Y"
  shows "supermartingale M F (\<lambda>i \<xi>. X i \<xi> + Y i \<xi>)"
proof -
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> + Y i \<xi> \<ge> cond_exp M (F i) (\<lambda>x. X j x + Y j x) \<xi>" 
      using cond_exp_add[OF integrable supermartingale.integrable[OF assms], of i j j] 
            supermartingale_property[OF asm] supermartingale.supermartingale_property[OF assms asm] add_mono[of _ "X i _" _ "Y i _"] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_add random_variable adapted integrable supermartingale.random_variable supermartingale.adapted supermartingale.integrable)  
qed

lemma diff[intro]:
  assumes "submartingale M F Y"
  shows "supermartingale M F (\<lambda>i \<xi>. X i \<xi> - Y i \<xi>)"
proof -
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> - Y i \<xi> \<ge> cond_exp M (F i) (\<lambda>x. X j x - Y j x) \<xi>" 
      using cond_exp_diff[OF integrable submartingale.integrable[OF assms], of i j j, unfolded fun_diff_def] 
            supermartingale_property[OF asm] submartingale.submartingale_property[OF assms asm] diff_mono[of _ "X i _" "Y i _"] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_diff random_variable adapted integrable submartingale.random_variable submartingale.adapted submartingale.integrable)  
qed

lemma scaleR_nonneg: 
  assumes "c \<ge> 0"
  shows "supermartingale M F (\<lambda>i \<xi>. c *\<^sub>R X i \<xi>)"
proof
  {
    fix i j :: 'b assume asm: "i \<le> j"
    show "AE \<xi> in M. c *\<^sub>R X i \<xi> \<ge> cond_exp M (F i) (\<lambda>\<xi>. c *\<^sub>R X j \<xi>) \<xi>" 
      using cond_exp_scaleR_right[OF integrable, of i "c" j] supermartingale_property[OF asm] 
      by (auto intro!: scaleR_left_mono[OF _ assms])
  }
qed (auto simp add: borel_measurable_integrable borel_measurable_scaleR integrable random_variable adapted borel_measurable_const_scaleR)

lemma scaleR_nonpos: 
  assumes "c \<le> 0"
  shows "submartingale M F (\<lambda>i \<xi>. c *\<^sub>R X i \<xi>)"
proof
  {
    fix i j :: 'b assume asm: "i \<le> j"
    show "AE \<xi> in M. c *\<^sub>R X i \<xi> \<le> cond_exp M (F i) (\<lambda>\<xi>. c *\<^sub>R X j \<xi>) \<xi>" 
      using cond_exp_scaleR_right[OF integrable, of i "c" j] supermartingale_property[OF asm] 
      by (auto intro!: scaleR_left_mono_neg[OF _ assms])
  }
qed (auto simp add: borel_measurable_integrable borel_measurable_scaleR integrable random_variable adapted borel_measurable_const_scaleR)

lemma uminus[intro]:
  shows "submartingale M F (- X)"
  unfolding fun_Compl_def using scaleR_nonpos[of "-1"] by simp

end

lemma (in adapted_process_order) supermartingale_of_cond_exp_diff_nonneg: 
  assumes integrable: "\<And>i. integrable M (X i)" 
      and diff_nonneg: "\<And>i j. i \<le> j \<Longrightarrow> AE x in M. 0 \<le> cond_exp M (F i) (X i - X j) x"
    shows "supermartingale M F X"
proof 
  {
    fix i j :: 't assume asm: "i \<le> j"
    show "AE \<xi> in M. X i \<xi> \<ge> cond_exp M (F i) (X j) \<xi>" 
      using diff_nonneg[OF asm] cond_exp_diff[OF integrable(1,1), of i i j] cond_exp_F_meas[OF integrable adapted, of i] by fastforce
  }
qed (intro integrable)

lemma (in adapted_process_order) supermartingale_of_set_integral_ge:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>A i j. i \<le> j \<Longrightarrow> A \<in> F i \<Longrightarrow> set_lebesgue_integral M A (X j) \<le> set_lebesgue_integral M A (X i)" 
    shows "supermartingale M F X"
proof (unfold_locales)
  {
    fix i j :: 't assume asm: "i \<le> j"
    {
      fix A assume "A \<in> F i"
      hence "LINT \<xi>|M. indicat_real A \<xi> *\<^sub>R (X i \<xi> - X j \<xi>) \<ge> 0" using assms(2)[OF asm] sorry
    }
    thus "AE \<xi> in M. cond_exp M (F i) (X j) \<xi> \<le> X i \<xi>" sorry
  }
qed (intro integrable)

section \<open>Discrete Time Martingales\<close>

locale discrete_time_martingale = martingale M F X for M F and X :: "nat \<Rightarrow> _ \<Rightarrow> _"
locale discrete_time_submartingale = submartingale M F X for M F and X :: "nat \<Rightarrow> _ \<Rightarrow> _"
locale discrete_time_supermartingale = supermartingale M F X for M F and X :: "nat \<Rightarrow> _ \<Rightarrow> _"

sublocale discrete_time_martingale \<subseteq> discrete_time_adapted_process by (unfold_locales)
sublocale discrete_time_submartingale \<subseteq> discrete_time_adapted_process by (unfold_locales)
sublocale discrete_time_supermartingale \<subseteq> discrete_time_adapted_process by (unfold_locales)

lemma (in discrete_time_martingale) predictable_eq_bot:
  assumes "predictable X"
  shows "AE \<xi> in M. X i \<xi> = X \<bottom> \<xi>"
proof (induction i)
  case 0
  then show ?case by (simp add: bot_nat_def)
next
  case (Suc i)
  thus ?case 
    using predictable_discrete_time_process[OF assms, of "Suc i"] 
          martingale_property[OF le_SucI, of i]
          cond_exp_F_meas[OF integrable, of "Suc i" i] Suc by fastforce
qed

lemma (in discrete_time_adapted_process) martingale_nat:
  assumes "\<And>i. integrable M (X i)"
      and "\<And>i. AE \<xi> in M. X i \<xi> = cond_exp M (F i) (X (Suc i)) \<xi>"
    shows "discrete_time_martingale M F X"
  sorry



end