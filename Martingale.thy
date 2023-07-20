theory Martingale                 
  imports Stochastic_Process Conditional_Expectation_Banach
begin           

subsection \<open>Martingale\<close>

unbundle lattice_syntax

locale martingale = adapted_process +
  assumes integrable: "\<And>i. integrable M (X i)"
      and martingale_property: "\<And>i j. i \<le> j \<Longrightarrow> AE \<xi> in M. X i \<xi> = cond_exp M (F i) (X j) \<xi>"

lemma (in filtered_sigma_finite_measure) martingale_const[intro]:  
  assumes "integrable M f" "f \<in> borel_measurable (F \<bottom>)"
  shows "martingale M F (\<lambda>_. f)"
  using assms cond_exp_F_meas[OF assms(1), THEN AE_symmetric]
  by (unfold_locales)
     (simp add: borel_measurable_integrable,
      metis bot.extremum measurable_from_subalg sets_F_mono space_F subalgebra_def, blast,
      metis (mono_tags, lifting) borel_measurable_subalgebra bot_least filtration.sets_F_mono filtration_axioms space_F) 

lemma (in filtered_sigma_finite_measure) martingale_cond_exp[intro]:  
  assumes "integrable M f"
  shows "martingale M F (\<lambda>i. cond_exp M (F i) f)"
  by (unfold_locales,
      auto simp add: subalgebra borel_measurable_cond_exp borel_measurable_cond_exp' intro!: cond_exp_nested_subalg[OF assms],
      simp add: sets_F_mono space_F subalgebra_def)

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

locale martingale_order = martingale M F X for M F and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {linorder_topology, ordered_real_vector}"
begin

lemma is_submartingale: "submartingale M F X" using martingale_property by (unfold_locales) (force simp add: integrable)+

lemma is_supermartingale: "supermartingale M F X" using martingale_property by (unfold_locales) (force simp add: integrable)+

end

sublocale martingale_order \<subseteq> martingale_is_submartingale: submartingale by (rule is_submartingale)

sublocale martingale_order \<subseteq> martingale_is_supermartingale: supermartingale by (rule is_supermartingale)

locale submartingale_lattice = submartingale M F X for M F and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {linorder_topology, lattice, ordered_real_vector}"

locale supermartingale_lattice = supermartingale M F X for M F and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {linorder_topology, lattice, ordered_real_vector}"

locale martingale_lattice = martingale M F X for M F and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {linorder_topology, lattice, ordered_real_vector}"
begin

lemma is_submartingale: "submartingale_lattice M F X" using martingale_property by (unfold_locales) (force simp add: integrable)+

lemma is_supermartingale: "supermartingale_lattice M F X" using martingale_property by (unfold_locales) (force simp add: integrable)+

end

sublocale martingale_lattice \<subseteq> martingale_is_submartingale: submartingale_lattice by (rule is_submartingale)

sublocale martingale_lattice \<subseteq> martingale_is_supermartingale: supermartingale_lattice by (rule is_supermartingale)

context martingale
begin

lemma set_integral_eq:
  assumes "A \<in> F i" "i \<le> j"
  shows "set_lebesgue_integral M A (X i) = set_lebesgue_integral M A (X j)"
proof -
  have "\<integral>x \<in> A. X i x \<partial>M = \<integral>x \<in> A. cond_exp M (F i) (X j) x \<partial>M" using martingale_property[OF assms(2)] borel_measurable_cond_exp' assms(1) subalgebra subalgebra_def by (intro set_lebesgue_integral_cong_AE[OF _ random_variable]) fastforce+
  also have "... = \<integral>x \<in> A. X j x \<partial>M" using assms(1) by (auto simp: integrable intro: cond_exp_set_integral[symmetric])
  finally show ?thesis .
qed

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
  interpret Y: martingale M F Y by (rule assms)
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> + Y i \<xi> = cond_exp M (F i) (\<lambda>x. X j x + Y j x) \<xi>" 
      using cond_exp_add[OF integrable martingale.integrable[OF assms], of i j j, THEN AE_symmetric] 
            martingale_property[OF asm] martingale.martingale_property[OF assms asm] by force
  }
  thus ?thesis using assms
  by (unfold_locales) (auto simp add: borel_measurable_add random_variable adapted integrable Y.adapted Y.random_variable martingale.integrable)
qed

lemma diff[intro]:
  assumes "martingale M F Y"
  shows "martingale M F (\<lambda>i x. X i x - Y i x)"
proof -
  interpret Y: martingale M F Y by (rule assms)
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> - Y i \<xi> = cond_exp M (F i) (\<lambda>x. X j x - Y j x) \<xi>" 
      using cond_exp_diff[OF integrable martingale.integrable[OF assms], of i j j, THEN AE_symmetric, unfolded fun_diff_def] 
            martingale_property[OF asm] martingale.martingale_property[OF assms asm] by fastforce
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_diff random_variable adapted integrable Y.random_variable Y.adapted martingale.integrable)  
qed

end

lemma (in adapted_process) martingale_of_set_integral_eq:
  assumes integrable: "\<And>i. integrable M (X i)"
      and "\<And>A i j. i \<le> j \<Longrightarrow> A \<in> F i \<Longrightarrow> set_lebesgue_integral M A (X i) = set_lebesgue_integral M A (X j)" 
    shows "martingale M F X"
proof (unfold_locales)
  fix i j :: 't assume asm: "i \<le> j"
  interpret sigma_finite_measure "restr_to_subalg M (F i)" by (simp add: sigma_fin_subalg)
  {
    fix A assume "A \<in> restr_to_subalg M (F i)"
    hence *: "A \<in> F i" using sets_restr_to_subalg subalgebra by blast
    have "set_lebesgue_integral (restr_to_subalg M (F i)) A (X i) = set_lebesgue_integral M A (X i)" using * subalg by (auto simp: set_lebesgue_integral_def intro: integral_subalgebra2 borel_measurable_scaleR adapted borel_measurable_indicator) 
    also have "... = set_lebesgue_integral M A (cond_exp M (F i) (X j))" using * assms(2)[OF asm] cond_exp_set_integral[OF integrable] by auto
    finally have "set_lebesgue_integral (restr_to_subalg M (F i)) A (X i) = set_lebesgue_integral (restr_to_subalg M (F i)) A (cond_exp M (F i) (X j))" using * subalg by (auto simp: set_lebesgue_integral_def intro!: integral_subalgebra2[symmetric] borel_measurable_scaleR borel_measurable_cond_exp borel_measurable_indicator)
  }
  hence "AE \<xi> in restr_to_subalg M (F i). X i \<xi> = cond_exp M (F i) (X j) \<xi>" by (intro density_unique, auto intro: integrable_in_subalg subalg borel_measurable_cond_exp integrable)
  thus "AE \<xi> in M. X i \<xi> = cond_exp M (F i) (X j) \<xi>" using AE_restr_to_subalg[OF subalg] by blast
qed (simp add: integrable)
  
lemma martingale_orderI:
  assumes "submartingale M F X" "supermartingale M F X"
  shows "martingale_order M F X" 
proof -
  interpret submartingale M F X by (rule assms)
  interpret supermartingale M F X by (rule assms)
  show ?thesis using integrable submartingale_property supermartingale_property by (unfold_locales) (fast intro: antisym)+
qed

lemma martingale_iff: "martingale M F X \<longleftrightarrow> submartingale M F X \<and> supermartingale M F X"
  using martingale_orderI martingale_order.is_submartingale martingale_order.is_supermartingale martingale_order_def by blast

subsection \<open>Submartingale Stuff\<close>

context submartingale
begin

lemma set_integral_le:
  assumes "A \<in> F i" "i \<le> j"
  shows "set_lebesgue_integral M A (X i) \<le> set_lebesgue_integral M A (X j)" 
  unfolding cond_exp_set_integral[OF integrable assms(1), of j]  
  using submartingale_property[OF assms(2)]
  by (simp only: set_lebesgue_integral_def, intro integral_mono_AE_banach, metis assms(1) in_mono integrable integrable_mult_indicator subalgebra subalgebra_def, metis assms(1) in_mono integrable_mult_indicator subalgebra subalgebra_def integrable_cond_exp) 
     (auto intro: scaleR_left_mono)

lemma cond_exp_diff_nonneg: 
  assumes "i \<le> j"
  shows "AE x in M. 0 \<le> cond_exp M (F i) (\<lambda>\<xi>. X j \<xi> - X i \<xi>) x"
  using submartingale_property[OF assms] cond_exp_diff[OF integrable(1,1), of i j i] cond_exp_F_meas[OF integrable adapted, of i] by fastforce

lemma add[intro]:
  assumes "submartingale M F Y"
  shows "submartingale M F (\<lambda>i \<xi>. X i \<xi> + Y i \<xi>)"
proof -
  interpret Y: submartingale M F Y by (rule assms)
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> + Y i \<xi> \<le> cond_exp M (F i) (\<lambda>x. X j x + Y j x) \<xi>" 
      using cond_exp_add[OF integrable submartingale.integrable[OF assms], of i j j] 
            submartingale_property[OF asm] submartingale.submartingale_property[OF assms asm] add_mono[of "X i _" _ "Y i _"] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_add random_variable adapted integrable Y.random_variable Y.adapted submartingale.integrable)  
qed

lemma diff[intro]:
  assumes "supermartingale M F Y"
  shows "submartingale M F (\<lambda>i \<xi>. X i \<xi> - Y i \<xi>)"
proof -
  interpret Y: supermartingale M F Y by (rule assms)
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> - Y i \<xi> \<le> cond_exp M (F i) (\<lambda>x. X j x - Y j x) \<xi>" 
      using cond_exp_diff[OF integrable supermartingale.integrable[OF assms], of i j j, unfolded fun_diff_def] 
            submartingale_property[OF asm] supermartingale.supermartingale_property[OF assms asm] diff_mono[of "X i _" _ _ "Y i _"] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_diff random_variable adapted integrable Y.random_variable Y.adapted supermartingale.integrable)  
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

lemma max:
  assumes "submartingale M F Y"
  shows "submartingale M F (\<lambda>i \<xi>. max (X i \<xi>) (Y i \<xi>))"
proof (unfold_locales)
  interpret Y: submartingale M F Y by (rule assms)
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. max (X i \<xi>) (Y i \<xi>) \<le> max (cond_exp M (F i) (X j) \<xi>) (cond_exp M (F i) (Y j) \<xi>)" using submartingale_property Y.submartingale_property asm unfolding max_def by fastforce
    thus "AE \<xi> in M. max (X i \<xi>) (Y i \<xi>) \<le> cond_exp M (F i) (\<lambda>\<xi>. max (X j \<xi>) (Y j \<xi>)) \<xi>" using cond_exp_max[OF integrable Y.integrable, of i j j] order.trans by fast
  }
  show "\<And>i. (\<lambda>\<xi>. max (X i \<xi>) (Y i \<xi>)) \<in> borel_measurable M" "\<And>i. (\<lambda>\<xi>. max (X i \<xi>) (Y i \<xi>)) \<in> borel_measurable (F i)" "\<And>i. integrable M (\<lambda>\<xi>. max (X i \<xi>) (Y i \<xi>))" by (force intro: Y.integrable integrable assms)+
qed

lemma max_0:
  shows "submartingale M F (\<lambda>i \<xi>. max 0 (X i \<xi>))"
proof -
  interpret zero: submartingale M F "\<lambda>_ _. 0" by (intro martingale_order.is_submartingale, unfold_locales, auto)
  show ?thesis by (intro zero.max submartingale_axioms)
qed

end

lemma (in submartingale_lattice) sup:
  assumes "submartingale_lattice M F Y"
  shows "submartingale_lattice M F (\<lambda>i \<xi>. sup (X i \<xi>) (Y i \<xi>))"
  using submartingale_lattice.intro submartingale.max[OF submartingale_axioms assms[THEN submartingale_lattice.axioms]] unfolding sup_max[symmetric] .

lemma (in adapted_process_order) submartingale_of_cond_exp_diff_nonneg:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and diff_nonneg: "\<And>i j. i \<le> j \<Longrightarrow> AE x in M. 0 \<le> cond_exp M (F i) (\<lambda>\<xi>. X j \<xi> - X i \<xi>) x"
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
    interpret sigma_finite_measure "restr_to_subalg M (F i)" by (simp add: sigma_fin_subalg)
    {
      fix A assume "A \<in> restr_to_subalg M (F i)"
      hence *: "A \<in> F i" using sets_restr_to_subalg subalgebra by blast
      have "set_lebesgue_integral (restr_to_subalg M (F i)) A (X i) = set_lebesgue_integral M A (X i)" using * subalg by (auto simp: set_lebesgue_integral_def intro: integral_subalgebra2 borel_measurable_scaleR adapted borel_measurable_indicator) 
      also have "... \<le> set_lebesgue_integral M A (cond_exp M (F i) (X j))" using * assms(2)[OF asm] cond_exp_set_integral[OF integrable] by auto
      also have "... = set_lebesgue_integral (restr_to_subalg M (F i)) A (cond_exp M (F i) (X j))" using * subalg by (auto simp: set_lebesgue_integral_def intro!: integral_subalgebra2[symmetric] borel_measurable_scaleR borel_measurable_cond_exp borel_measurable_indicator)
      finally have "0 \<le> set_lebesgue_integral (restr_to_subalg M (F i)) A (\<lambda>\<xi>. cond_exp M (F i) (X j) \<xi> - X i \<xi>)" using * subalg by (subst set_integral_diff, auto simp add: set_integrable_def sets_restr_to_subalg intro!: integrable adapted integrable_in_subalg borel_measurable_scaleR borel_measurable_indicator borel_measurable_cond_exp integrable_mult_indicator)
    }
    hence "AE \<xi> in restr_to_subalg M (F i). 0 \<le> cond_exp M (F i) (X j) \<xi> - X i \<xi>" by (intro density_nonneg integrable_in_subalg subalg borel_measurable_diff borel_measurable_cond_exp adapted Bochner_Integration.integrable_diff integrable_cond_exp integrable)
    thus "AE \<xi> in M. X i \<xi> \<le> cond_exp M (F i) (X j) \<xi>" using AE_restr_to_subalg[OF subalg] by simp
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
  by (simp only: set_lebesgue_integral_def, intro integral_mono_AE_banach, metis assms(1) in_mono integrable_mult_indicator subalgebra subalgebra_def integrable_cond_exp, metis assms(1) in_mono integrable integrable_mult_indicator subalgebra subalgebra_def)
     (auto intro: scaleR_left_mono)

lemma cond_exp_diff_nonneg:
  assumes "i \<le> j"
  shows "AE x in M. 0 \<le> cond_exp M (F i) (\<lambda>\<xi>. X i \<xi> - X j \<xi>) x"
  using supermartingale_property[OF assms] cond_exp_diff[OF integrable(1,1), of i i j] cond_exp_F_meas[OF integrable adapted, of i] by fastforce

lemma add[intro]:
  assumes "supermartingale M F Y"
  shows "supermartingale M F (\<lambda>i \<xi>. X i \<xi> + Y i \<xi>)"
proof -
  interpret Y: supermartingale M F Y by (rule assms)
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> + Y i \<xi> \<ge> cond_exp M (F i) (\<lambda>x. X j x + Y j x) \<xi>" 
      using cond_exp_add[OF integrable supermartingale.integrable[OF assms], of i j j] 
            supermartingale_property[OF asm] supermartingale.supermartingale_property[OF assms asm] add_mono[of _ "X i _" _ "Y i _"] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_add random_variable adapted integrable Y.random_variable Y.adapted supermartingale.integrable)  
qed

lemma diff[intro]:
  assumes "submartingale M F Y"
  shows "supermartingale M F (\<lambda>i \<xi>. X i \<xi> - Y i \<xi>)"
proof -
  interpret Y: submartingale M F Y by (rule assms)
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. X i \<xi> - Y i \<xi> \<ge> cond_exp M (F i) (\<lambda>x. X j x - Y j x) \<xi>" 
      using cond_exp_diff[OF integrable submartingale.integrable[OF assms], of i j j, unfolded fun_diff_def] 
            supermartingale_property[OF asm] submartingale.submartingale_property[OF assms asm] diff_mono[of _ "X i _" "Y i _"] by force
  }
  thus ?thesis using assms by (unfold_locales) (auto simp add: borel_measurable_diff random_variable adapted integrable Y.random_variable Y.adapted submartingale.integrable)  
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

lemma min:
  assumes "supermartingale M F Y"
  shows "supermartingale M F (\<lambda>i \<xi>. min (X i \<xi>) (Y i \<xi>))"
proof (unfold_locales)
  interpret Y: supermartingale M F Y by (rule assms)
  {
    fix i j :: 'b assume asm: "i \<le> j"
    have "AE \<xi> in M. min (X i \<xi>) (Y i \<xi>) \<ge> min (cond_exp M (F i) (X j) \<xi>) (cond_exp M (F i) (Y j) \<xi>)" using supermartingale_property Y.supermartingale_property asm unfolding min_def by fastforce
    thus "AE \<xi> in M. min (X i \<xi>) (Y i \<xi>) \<ge> cond_exp M (F i) (\<lambda>\<xi>. min (X j \<xi>) (Y j \<xi>)) \<xi>" using cond_exp_min[OF integrable Y.integrable, of i j j] order.trans by fast
  }
  show "\<And>i. (\<lambda>\<xi>. min (X i \<xi>) (Y i \<xi>)) \<in> borel_measurable M" "\<And>i. (\<lambda>\<xi>. min (X i \<xi>) (Y i \<xi>)) \<in> borel_measurable (F i)" "\<And>i. integrable M (\<lambda>\<xi>. min (X i \<xi>) (Y i \<xi>))" by (force intro: Y.integrable integrable assms)+
qed

lemma min_0:
  shows "supermartingale M F (\<lambda>i \<xi>. min 0 (X i \<xi>))"
proof -
  interpret zero: supermartingale M F "\<lambda>_ _. 0" by (intro martingale_order.is_supermartingale, unfold_locales, auto)
  show ?thesis by (intro zero.min supermartingale_axioms)
qed

end

lemma (in supermartingale_lattice) inf:
  assumes "supermartingale_lattice M F Y"
  shows "supermartingale_lattice M F (\<lambda>i \<xi>. inf (X i \<xi>) (Y i \<xi>))"
  using supermartingale_lattice.intro supermartingale.min[OF supermartingale_axioms assms[THEN supermartingale_lattice.axioms]] unfolding inf_min[symmetric] .

lemma (in adapted_process_order) supermartingale_of_cond_exp_diff_nonneg: 
  assumes integrable: "\<And>i. integrable M (X i)" 
      and diff_nonneg: "\<And>i j. i \<le> j \<Longrightarrow> AE x in M. 0 \<le> cond_exp M (F i) (\<lambda>\<xi>. X i \<xi> - X j \<xi>) x"
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
proof -
  interpret uminus_X: adapted_process_order M F "-X" by (intro adapted_process_order.intro uminus)
  note * = set_integral_uminus[unfolded set_integrable_def, OF integrable_mult_indicator[OF _ integrable]]
  have "supermartingale M F (-(- X))" using ord_eq_le_trans[OF * ord_le_eq_trans[OF le_imp_neg_le[OF assms(2)] *[symmetric]]] subalg
    by (intro submartingale.uminus uminus_X.submartingale_of_set_integral_le) (auto simp add: subalgebra_def integrable fun_Compl_def, blast)
  thus ?thesis unfolding fun_Compl_def by simp
qed

section \<open>Discrete Time Martingales\<close>

locale discrete_time_martingale = martingale M F X for M F and X :: "nat \<Rightarrow> _ \<Rightarrow> _"
locale discrete_time_submartingale = submartingale M F X for M F and X :: "nat \<Rightarrow> _ \<Rightarrow> _"
locale discrete_time_supermartingale = supermartingale M F X for M F and X :: "nat \<Rightarrow> _ \<Rightarrow> _"

sublocale discrete_time_martingale \<subseteq> discrete_time_adapted_process by (unfold_locales)
sublocale discrete_time_submartingale \<subseteq> discrete_time_adapted_process by (unfold_locales)
sublocale discrete_time_supermartingale \<subseteq> discrete_time_adapted_process by (unfold_locales)

section "Discrete Time Martingales"

lemma (in discrete_time_martingale) predictable_eq_bot:
  assumes "predictable X"
  shows "AE \<xi> in M. X i \<xi> = X \<bottom> \<xi>"
proof (induction i)
  case 0
  then show ?case by (simp add: bot_nat_def)
next
  case (Suc i)
  thus ?case using predictable_discrete_time_process_measurable[OF assms, of "Suc i"] 
                   martingale_property[OF le_SucI, of i]
                   cond_exp_F_meas[OF integrable, of "Suc i" i] Suc by fastforce
qed

lemma (in discrete_time_adapted_process) martingale_of_set_integral_eq_Suc:
  assumes integrable: "\<And>i. integrable M (X i)"
      and "\<And>A i. A \<in> F i \<Longrightarrow> set_lebesgue_integral M A (X i) = set_lebesgue_integral M A (X (Suc i))" 
    shows "discrete_time_martingale M F X"
proof (intro discrete_time_martingale.intro martingale_of_set_integral_eq)
  fix i j A assume asm: "i \<le> j" "A \<in> sets (F i)"
  show "set_lebesgue_integral M A (X i) = set_lebesgue_integral M A (X j)" using asm
  proof (induction "j - i" arbitrary: i j)
    case 0
    then show ?case using asm by simp
  next
    case (Suc n)
    hence *: "n = j - Suc i" by linarith
    have "Suc i \<le> j" using Suc(2,3) by linarith
    thus ?case using sets_F_mono[OF le_SucI] Suc(4) Suc(1)[OF *] by (auto intro: assms(2)[THEN trans])
  qed
qed (simp add: integrable)

lemma (in discrete_time_adapted_process) martingale_nat:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>i. AE \<xi> in M. X i \<xi> = cond_exp M (F i) (X (Suc i)) \<xi>" 
    shows "discrete_time_martingale M F X"
proof (unfold_locales)
  fix i j :: nat assume asm: "i \<le> j"
  show "AE \<xi> in M. X i \<xi> = cond_exp M (F i) (X j) \<xi>" using asm
  proof (induction "j - i" arbitrary: i j)
    case 0
    hence "j = i" by simp
    thus ?case using cond_exp_F_meas[OF integrable adapted, THEN AE_symmetric] by presburger
  next
    case (Suc n)
    have j: "j = Suc (n + i)" using Suc by linarith
    have n: "n = n + i - i" using Suc by linarith
    have *: "AE \<xi> in M. cond_exp M (F (n + i)) (X j) \<xi> = X (n + i) \<xi>" unfolding j using assms(2)[THEN AE_symmetric] by blast
    have "AE \<xi> in M. cond_exp M (F i) (X j) \<xi> = cond_exp M (F i) (cond_exp M (F (n + i)) (X j)) \<xi>" by (intro cond_exp_nested_subalg integrable subalg, simp add: subalgebra_def space_F sets_F_mono)
    hence "AE \<xi> in M. cond_exp M (F i) (X j) \<xi> = cond_exp M (F i) (X (n + i)) \<xi>" using cond_exp_cong_AE[OF integrable_cond_exp integrable *] by force
    thus ?case using Suc(1)[OF n] by fastforce
  qed
qed (simp add: integrable)

lemma (in discrete_time_adapted_process) martingale_of_cond_exp_diff_Suc_eq_0:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>i. AE \<xi> in M. 0 = cond_exp M (F i) (\<lambda>\<xi>. X (Suc i) \<xi> - X i \<xi>) \<xi>" 
    shows "discrete_time_martingale M F X"
proof (intro martingale_nat integrable) 
  fix i 
  show "AE \<xi> in M. X i \<xi> = cond_exp M (F i) (X (Suc i)) \<xi>" using cond_exp_diff[OF integrable(1,1), of i "Suc i" i] cond_exp_F_meas[OF integrable adapted, of i] assms(2)[of i] by fastforce
qed

section "Discrete Time Submartingales"

lemma (in discrete_time_submartingale) predictable_ge_bot:
  assumes "predictable X"
  shows "AE \<xi> in M. X i \<xi> \<ge> X \<bottom> \<xi>"
proof (induction i)
  case 0
  then show ?case by (simp add: bot_nat_def)
next
  case (Suc i)
  thus ?case using predictable_discrete_time_process_measurable[OF assms, of "Suc i"] 
                   submartingale_property[OF le_SucI, of i]
                   cond_exp_F_meas[OF integrable, of "Suc i" i] Suc by fastforce
qed

lemma (in discrete_time_adapted_process_order) submartingale_of_set_integral_le_Suc:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>A i. A \<in> F i \<Longrightarrow> set_lebesgue_integral M A (X i) \<le> set_lebesgue_integral M A (X (Suc i))" 
    shows "discrete_time_submartingale M F X"
proof (intro discrete_time_submartingale.intro submartingale_of_set_integral_le)
  fix i j A assume asm: "i \<le> j" "A \<in> sets (F i)"
  show "set_lebesgue_integral M A (X i) \<le> set_lebesgue_integral M A (X j)" using asm
  proof (induction "j - i" arbitrary: i j)
    case 0
    then show ?case using asm by simp
  next
    case (Suc n)
    hence *: "n = j - Suc i" by linarith
    have "Suc i \<le> j" using Suc(2,3) by linarith
    thus ?case using sets_F_mono[OF le_SucI] Suc(4) Suc(1)[OF *] by (auto intro: assms(2)[THEN order_trans])
  qed
qed (simp add: integrable)

lemma (in discrete_time_adapted_process_order) submartingale_nat:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>i. AE \<xi> in M. X i \<xi> \<le> cond_exp M (F i) (X (Suc i)) \<xi>" 
    shows "discrete_time_submartingale M F X"
  using subalg integrable assms(2)
  by (intro submartingale_of_set_integral_le_Suc ord_le_eq_trans[OF set_integral_mono_AE_banach cond_exp_set_integral[symmetric]], simp)
         (meson in_mono integrable_mult_indicator set_integrable_def subalgebra_def,
          meson integrable_cond_exp in_mono integrable_mult_indicator set_integrable_def subalgebra_def,
          auto simp add: subalgebra_def, metis (mono_tags, lifting) AE_I2 AE_mp)

lemma (in discrete_time_adapted_process_order) submartingale_of_cond_exp_diff_Suc_nonneg:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>i. AE \<xi> in M. 0 \<le> cond_exp M (F i) (\<lambda>\<xi>. X (Suc i) \<xi> - X i \<xi>) \<xi>" 
    shows "discrete_time_submartingale M F X"
proof (intro submartingale_nat integrable) 
  fix i 
  show "AE \<xi> in M. X i \<xi> \<le> cond_exp M (F i) (X (Suc i)) \<xi>" using cond_exp_diff[OF integrable(1,1), of i "Suc i" i] cond_exp_F_meas[OF integrable adapted, of i] assms(2)[of i] by fastforce
qed

section "Discrete Time Supermartingales"

lemma (in discrete_time_supermartingale) predictable_le_bot:
  assumes "predictable X"
  shows "AE \<xi> in M. X i \<xi> \<le> X \<bottom> \<xi>"
proof (induction i)
  case 0
  then show ?case by (simp add: bot_nat_def)
next
  case (Suc i)
  thus ?case using predictable_discrete_time_process_measurable[OF assms, of "Suc i"] 
                   supermartingale_property[OF le_SucI, of i]
                   cond_exp_F_meas[OF integrable, of "Suc i" i] Suc by fastforce
qed

lemma (in discrete_time_adapted_process_order) supermartingale_of_set_integral_ge_Suc:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>A i. A \<in> F i \<Longrightarrow> set_lebesgue_integral M A (X (Suc i)) \<le> set_lebesgue_integral M A (X i)" 
    shows "discrete_time_supermartingale M F X"
proof -
  interpret uminus_X: discrete_time_adapted_process_order M F "-X" by (intro discrete_time_adapted_process_order.intro adapted_process_order.intro uminus)
  note * = set_integral_uminus[unfolded set_integrable_def, OF integrable_mult_indicator[OF _ integrable]]
  have "discrete_time_supermartingale M F (-(- X))" using ord_eq_le_trans[OF * ord_le_eq_trans[OF le_imp_neg_le[OF assms(2)] *[symmetric]]] subalg
    by (intro discrete_time_supermartingale.intro submartingale.uminus discrete_time_submartingale.axioms uminus_X.submartingale_of_set_integral_le_Suc) (auto simp add: subalgebra_def integrable fun_Compl_def, blast)
  thus ?thesis unfolding fun_Compl_def by simp
qed

lemma (in discrete_time_adapted_process_order) supermartingale_nat:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>i. AE \<xi> in M. X i \<xi> \<ge> cond_exp M (F i) (X (Suc i)) \<xi>" 
    shows "discrete_time_supermartingale M F X"
proof -
  interpret uminus_X: discrete_time_adapted_process_order M F "-X" by (intro discrete_time_adapted_process_order.intro adapted_process_order.intro uminus)
  have "AE \<xi> in M. - X i \<xi> \<le> cond_exp M (F i) (\<lambda>x. - X (Suc i) x) \<xi>" for i using assms(2) cond_exp_uminus[OF integrable, of i "Suc i"] by force
  hence "discrete_time_supermartingale M F (-(- X))" by (intro discrete_time_supermartingale.intro submartingale.uminus discrete_time_submartingale.axioms uminus_X.submartingale_nat) (simp only: fun_Compl_def, intro integrable_minus integrable, auto simp add: fun_Compl_def)
  thus ?thesis unfolding fun_Compl_def by simp
qed

lemma (in discrete_time_adapted_process_order) supermartingale_of_cond_exp_diff_Suc_nonneg:
  assumes integrable: "\<And>i. integrable M (X i)" 
      and "\<And>i. AE \<xi> in M. 0 \<le> cond_exp M (F i) (\<lambda>\<xi>. X i \<xi> - X (Suc i) \<xi>) \<xi>" 
    shows "discrete_time_supermartingale M F X"
proof (intro supermartingale_nat integrable) 
  fix i 
  show "AE \<xi> in M. X i \<xi> \<ge> cond_exp M (F i) (X (Suc i)) \<xi>" using cond_exp_diff[OF integrable(1,1), of i i "Suc i"] cond_exp_F_meas[OF integrable adapted, of i] assms(2)[of i] by fastforce
qed

end