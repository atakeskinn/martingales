theory Stochastic_Process
imports Filtered_Measure "HOL-Analysis.Analysis" Complex_Main
begin      

section "Stochastic Process"

text \<open>A stochastic process is a collection of random variables, indexed by a type \<^typ>\<open>'b\<close>.\<close>

locale stochastic_process =
  fixes M and X :: "'b :: {second_countable_topology, order_bot, linorder_topology} \<Rightarrow> 'a \<Rightarrow> 'c :: {second_countable_topology, banach}"
  assumes random_variable[measurable]: "\<And>i. X i \<in> borel_measurable M"
begin

definition left_continuous where "left_continuous = (AE \<xi> in M. \<forall>i. continuous (at_left i) (\<lambda>i. X i \<xi>))"
definition right_continuous where "right_continuous = (AE \<xi> in M. \<forall>i. continuous (at_right i) (\<lambda>i. X i \<xi>))"

lemma compose:
  assumes "\<And>i. f i \<in> borel_measurable borel"
  shows "stochastic_process M (\<lambda>i \<xi>. (f i) (X i \<xi>))"
  by (unfold_locales, intro measurable_compose[OF random_variable assms]) 

lemma norm: "stochastic_process M (\<lambda>i \<xi>. norm (X i \<xi>))" by (auto intro: compose borel_measurable_norm)

lemma scaleR_right:
  assumes "stochastic_process M Y"
  shows "stochastic_process M (\<lambda>i \<xi>. (Y i \<xi>) *\<^sub>R (X i \<xi>))"
  by (unfold_locales) (simp add: borel_measurable_scaleR random_variable assms stochastic_process.random_variable)

lemma scaleR_const_right: 
  assumes "f \<in> borel_measurable M" 
  shows "stochastic_process M (\<lambda>i \<xi>. f \<xi> *\<^sub>R (X i \<xi>))"
  by (unfold_locales, intro borel_measurable_scaleR assms random_variable)

lemma scaleR_const: "stochastic_process M (\<lambda>i \<xi>. c *\<^sub>R (X i \<xi>))" by (auto intro: scaleR_const_right borel_measurable_const)

lemma add:
  assumes "stochastic_process M Y"
  shows "stochastic_process M (\<lambda>i \<xi>. X i \<xi> + Y i \<xi>)"
  by (unfold_locales) (simp add: borel_measurable_add random_variable assms stochastic_process.random_variable)

lemma diff:
  assumes "stochastic_process M Y"
  shows "stochastic_process M (\<lambda>i \<xi>. X i \<xi> - Y i \<xi>)"
  by (unfold_locales) (simp add: borel_measurable_diff random_variable assms stochastic_process.random_variable)

lemma uminus: "stochastic_process M (-X)" using scaleR_const[of "-1"] by (simp add: fun_Compl_def)

lemma partial_sum: "stochastic_process M (\<lambda>n \<xi>. \<Sum>i<n. X i \<xi>)" by (unfold_locales, simp)

lemma partial_sum': "stochastic_process M (\<lambda>n \<xi>. \<Sum>i\<le>n. X i \<xi>)" by (unfold_locales, simp)

end

lemma stochastic_process_const:
  assumes "f \<in> borel_measurable M"
  shows "stochastic_process M (\<lambda>_. f)"
  using assms by (unfold_locales)

lemma stochastic_process_sum:
  assumes "\<And>i. i \<in> I \<Longrightarrow> stochastic_process M (X i)"
  shows "stochastic_process M (\<lambda>k \<xi>. \<Sum>i \<in> I. X i k \<xi>)" using assms[THEN stochastic_process.random_variable] by (unfold_locales, auto)

subsection "Adapted Process"

text \<open>We call a stochastic process \<^term>\<open>X\<close> adapted if \<^term>\<open>X i\<close> is \<^term>\<open>F i\<close>-borel-measurable for all indices \<^term>\<open>i :: 't\<close>.\<close>

locale adapted_process = filtered_measure M F for M and F :: "_ :: {second_countable_topology, linorder_topology, order_bot} \<Rightarrow> _" and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {second_countable_topology, banach}" +
  assumes adapted[measurable]: "\<And>i. X i \<in> borel_measurable (F i)"
begin

lemma adaptedE[elim]:
  assumes "\<lbrakk>\<And>j i. j \<le> i \<Longrightarrow> X j \<in> borel_measurable (F i)\<rbrakk> \<Longrightarrow> P"
  shows P
  using assms using adapted by (metis borel_measurable_subalgebra sets_F_mono space_F)

end

text \<open>An adapted process is necessarily a stochastic process.\<close>

sublocale adapted_process \<subseteq> stochastic_process using measurable_from_subalg subalgebra adapted by (unfold_locales) blast

lemma (in filtered_measure) adapted_process_const:
  assumes "f \<in> borel_measurable (F \<bottom>)"
  shows "adapted_process M F (\<lambda>_. f)"
  using assms by (unfold_locales) (blast intro: measurable_from_subalg subalgebra, metis borel_measurable_subalgebra bot.extremum sets_F_mono space_F)

context adapted_process
begin

lemma compose:
  assumes "\<And>i. f i \<in> borel_measurable borel"
  shows "adapted_process M F (\<lambda>i \<xi>. (f i) (X i \<xi>))"
  by (unfold_locales) (intro measurable_compose[OF adapted assms])

lemma norm: "adapted_process M F (\<lambda>i \<xi>. norm (X i \<xi>))" by (auto intro: compose borel_measurable_norm)

lemma scaleR_right:
  assumes "adapted_process M F R"
  shows "adapted_process M F (\<lambda>i \<xi>. (R i \<xi>) *\<^sub>R (X i \<xi>))"
proof -
  interpret R: adapted_process M F R by (rule assms)
  show ?thesis by (unfold_locales) (auto simp add: borel_measurable_scaleR adapted assms R.adapted)
qed
  
lemma scaleR_const_right: 
  assumes "f \<in> borel_measurable (F \<bottom>)" 
  shows "adapted_process M F (\<lambda>i \<xi>. f \<xi> *\<^sub>R (X i \<xi>))"
  using assms by (fast intro: scaleR_right adapted_process_const)

lemma scaleR_const: "adapted_process M F (\<lambda>i \<xi>. c *\<^sub>R (X i \<xi>))" by (auto intro: scaleR_const_right borel_measurable_const)

lemma add:
  assumes "adapted_process M F Y"
  shows "adapted_process M F (\<lambda>i \<xi>. X i \<xi> + Y i \<xi>)"
proof -
  interpret Y: adapted_process M F Y by (rule assms)
  show ?thesis by (unfold_locales) (auto simp add: borel_measurable_add adapted Y.adapted)
qed

lemma diff:
  assumes "adapted_process M F Y"
  shows "adapted_process M F (\<lambda>i \<xi>. X i \<xi> - Y i \<xi>)"
proof -
  interpret Y: adapted_process M F Y by (rule assms)
  show ?thesis by (unfold_locales) (auto simp add: borel_measurable_diff adapted Y.adapted)
qed

lemma uminus: "adapted_process M F (-X)" using scaleR_const[of "-1"] by (simp add: fun_Compl_def)

lemma partial_sum: "adapted_process M F (\<lambda>n \<xi>. \<Sum>i<n. X i \<xi>)" 
proof (unfold_locales)
  fix i :: 'b
  have "X j \<in> borel_measurable (F i)" if "j \<le> i" for j using that adaptedE by meson
  thus "(\<lambda>\<xi>. \<Sum>i<i. X i \<xi>) \<in> borel_measurable (F i)" by auto
qed

lemma partial_sum': "adapted_process M F (\<lambda>n \<xi>. \<Sum>i\<le>n. X i \<xi>)" 
proof (unfold_locales)
  fix i :: 'b
  have "X j \<in> borel_measurable (F i)" if "j \<le> i" for j using that adaptedE by meson
  thus "(\<lambda>\<xi>. \<Sum>i\<le>i. X i \<xi>) \<in> borel_measurable (F i)" by auto
qed

end

lemma (in filtered_measure) adapted_process_sum:
  assumes "\<And>i. i \<in> I \<Longrightarrow> adapted_process M F (X i)"
  shows "adapted_process M F (\<lambda>k \<xi>. \<Sum>i \<in> I. X i k \<xi>)" 
proof -
  {
    fix i k assume "i \<in> I"
    then interpret adapted_process M F "X i" using assms by simp
    have "X i k \<in> borel_measurable M" "X i k \<in> borel_measurable (F k)" by auto
  }
  thus ?thesis by (unfold_locales, auto)
qed

text \<open>A stochastic process is always adapted to the natural filtration it generates.\<close>

sublocale stochastic_process \<subseteq> adapted_process_natural_filtration: adapted_process M "natural_filtration M borel X" X by (unfold_locales, simp, intro measurableI) auto
 
subsection "Predictable Process"

locale predictable_process = filtered_measure M F for M and F :: "_ :: {second_countable_topology, linorder_topology, order_bot} \<Rightarrow> _" and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {second_countable_topology, banach}" +
  assumes "case_prod X \<in> borel_measurable (sigma (UNIV \<times> space M) ({{s<..t} \<times> A | A s t. A \<in> F s \<and> s < t} \<union> {{bot} \<times> A | A. A \<in> F bot}))"
begin

text \<open>We introduce the constant \<^term>\<open>\<Sigma>\<^sub>P\<close> to denote the predictable sigma algebra.\<close>

definition predictable_sigma: "\<Sigma>\<^sub>P \<equiv> sigma (UNIV \<times> space M) ({{s<..t} \<times> A | A s t. A \<in> F s \<and> s < t} \<union> {{bot} \<times> A | A. A \<in> F bot})"

lemma predictable: "case_prod X \<in> borel_measurable \<Sigma>\<^sub>P" unfolding predictable_sigma using predictable_process_axioms predictable_process_axioms_def predictable_process_def by blast

lemma space_predictable_sigma[simp]: "space \<Sigma>\<^sub>P = (UNIV \<times> space M)" unfolding predictable_sigma space_measure_of_conv by blast

lemma sets_predictable_sigma[simp]: "sets \<Sigma>\<^sub>P = sigma_sets (UNIV \<times> space M) ({{s<..t} \<times> A | A s t. A \<in> F s \<and> s < t} \<union> {{bot} \<times> A | A. A \<in> F bot})" 
  unfolding predictable_sigma sets_measure_of_conv 
  using space_F sets.sets_into_space
  by (fastforce intro!: if_P)

lemmas predictableD = measurable_sets[OF predictable, unfolded space_predictable_sigma]

end

text \<open>Every predictable process is also adapted.\<close>

sublocale predictable_process \<subseteq> adapted_process
proof (unfold_locales)
  fix i :: 'b
  {
    fix S assume "S \<in> {{s<..t} \<times> A | A s t. A \<in> F s \<and> s < t} \<union> {{bot} \<times> A | A. A \<in> F bot}"
    hence "Pair i -` S \<inter> space (F i) \<in> F i"
    proof (cases)
      assume "S \<in> {{s<..t} \<times> A |A s t. A \<in> sets (F s) \<and> s < t}"
      then obtain s t A where S_is: "S = {s<..t} \<times> A" "s < t" "A \<in> F s" by blast
      {
        assume asm: "i \<in> {s<..t}"
        hence "Pair i -` S \<inter> space (F i) = A" using S_is space_F sets.sets_into_space by blast
        hence "Pair i -` S \<inter> space (F i) \<in> sets (F i)" using S_is(3) sets_F_mono[OF less_imp_le] asm by auto
      }
      thus "Pair i -` S \<inter> space (F i) \<in> sets (F i)" using S_is by (cases "i \<in> {s<..t}", blast, fastforce)
    qed (auto)
  }
  hence "Pair i \<in> (F i) \<rightarrow>\<^sub>M \<Sigma>\<^sub>P" using space_F sets.sets_into_space by (intro measurable_sigma_sets, simp, fast, blast, meson)
  hence "case_prod X o (Pair i) \<in> borel_measurable (F i)" using predictable by force
  thus "X i \<in> borel_measurable (F i)" by (simp add: comp_def)
qed

subsection "Discrete Time Process"

text \<open>Locales for discrete time processes.\<close>

locale nat_stochastic_process = stochastic_process M X for M and X :: "nat \<Rightarrow> _"
locale nat_adapted_process = adapted_process M F X for M F and X :: "nat \<Rightarrow> _"
locale nat_predictable_process = predictable_process M F X for M F and X :: "nat \<Rightarrow> _"

sublocale nat_predictable_process \<subseteq> nat_adapted_process by (unfold_locales)
sublocale nat_adapted_process \<subseteq> nat_stochastic_process by (unfold_locales)

lemma (in nat_adapted_process) partial_sum_Suc: "nat_adapted_process M F (\<lambda>n \<xi>. \<Sum>i<n. X (Suc i) \<xi>)" 
proof (unfold_locales)
  fix i
  have "X j \<in> borel_measurable (F i)" if "j \<le> i" for j using that adaptedE by meson
  thus "(\<lambda>\<xi>. \<Sum>i<i. X (Suc i) \<xi>) \<in> borel_measurable (F i)" by auto
qed

text \<open>The following lemma characterizes predictability in a discrete-time setting.\<close>

lemma (in nat_predictable_process) sets_in_filtration:
  assumes "(\<Union>i. {i} \<times> A i) \<in> \<Sigma>\<^sub>P"
  shows "A (Suc i) \<in> F i" "A 0 \<in> F 0"
  using assms unfolding sets_predictable_sigma
proof (induction "(\<Union>i. {i} \<times> A i)" arbitrary: A)
  case Basic
  {
    assume "\<exists>S. (\<Union>i. {i} \<times> A i) = {bot} \<times> S"
    then obtain S where S: "(\<Union>i. {i} \<times> A i) = {bot} \<times> S" by blast
    hence "S \<in> F 0" using Basic by (fastforce simp add: times_eq_iff bot_nat_def)
    moreover have "A i = {}" if "i \<noteq> bot" for i using that S by blast
    moreover have "A bot = S" using S by blast
    ultimately have "A (Suc i) \<in> F i" "A 0 \<in> F 0" for i unfolding bot_nat_def by (auto simp add: bot_nat_def)
  }
  note * = this
  {
    assume "\<nexists>S. (\<Union>i. {i} \<times> A i) = {bot} \<times> S"
    then obtain s t B where B: "(\<Union>i. {i} \<times> A i) = {s<..t} \<times> B" "B \<in> sets (F s)" "s < t" using Basic by auto
    hence "A i = B" if "i \<in> {s<..t}" for i using that by fast
    moreover have "A i = {}" if "i \<notin> {s<..t}" for i using B that by fastforce
    ultimately have "A (Suc i) \<in> F i" "A 0 \<in> F 0" for i unfolding bot_nat_def using B sets_F_mono by (auto simp add: bot_nat_def) (metis less_Suc_eq_le sets.empty_sets subset_eq)
  }
  note ** = this
  show "A (Suc i) \<in> sets (F i)" "A 0 \<in> sets (F 0)" using *(1)[of i] *(2) **(1)[of i] **(2) by auto blast+ 
next
  case Empty
  {
    case 1
    then show ?case using Empty by simp
  next
    case 2
    then show ?case using Empty by simp
  }
next
  case (Compl a)
  have a_in: "a \<subseteq> UNIV \<times> space M" using Compl(1) sets.sets_into_space sets_predictable_sigma space_predictable_sigma by metis
  hence A_in: "A i \<subseteq> space M" for i using Compl(4) by blast
  have a: "a = UNIV \<times> space M - (\<Union>i. {i} \<times> A i)" using a_in Compl(4) by blast
  also have "... = (\<Union>j. {j} \<times> (space M - A j))" by blast
  finally have *: "(space M - A (Suc i)) \<in> F i" "(space M - A 0) \<in> F 0" using Compl(2,3) by auto
  {
    case 1
    then show ?case using * A_in by (metis double_diff sets.compl_sets space_F subset_refl)
  next
    case 2
    then show ?case using * A_in by (metis double_diff sets.compl_sets space_F subset_refl)
  }
next
  case (Union a)
  have a_in: "a i \<subseteq> UNIV \<times> space M" for i using Union(1) sets.sets_into_space sets_predictable_sigma space_predictable_sigma by metis
  hence A_in: "A i \<subseteq> space M" for i using Union(4) by blast
  have "snd x \<in> snd ` (a i \<inter> ({fst x} \<times> space M))" if "x \<in> a i" for i x using that a_in by fastforce
  hence a_i: "a i = (\<Union>j. {j} \<times> (snd ` (a i \<inter> ({j} \<times> space M))))" for i by force
  have A_i: "A i = snd ` (\<Union> (range a) \<inter> ({i} \<times> space M))" for i unfolding Union(4) using A_in by force 
  have *: "snd ` (a j \<inter> ({Suc i} \<times> space M)) \<in> F i" "snd ` (a j \<inter> ({0} \<times> space M)) \<in> F 0" for j using Union(2,3)[OF a_i] by auto
  {
    case 1
    have "(\<Union>j. snd ` (a j \<inter> ({Suc i} \<times> space M))) \<in> F i" using * by fast
    moreover have "(\<Union>j. snd ` (a j \<inter> ({Suc i} \<times> space M))) = snd ` (\<Union> (range a) \<inter> ({Suc i} \<times> space M))" by fast
    ultimately show ?case using A_i by metis
  next
    case 2
    have "(\<Union>j. snd ` (a j \<inter> ({0} \<times> space M))) \<in> F 0" using * by fast
    moreover have "(\<Union>j. snd ` (a j \<inter> ({0} \<times> space M))) = snd ` (\<Union> (range a) \<inter> ({0} \<times> space M))" by fast
    ultimately show ?case using A_i by metis
  }
qed

text \<open>This leads to the following useful fact.\<close>

corollary (in nat_predictable_process) adapted_Suc:
  shows "nat_adapted_process M F (\<lambda>i. X (Suc i))"
proof (unfold_locales, intro borel_measurableI)
  fix S :: "'b set" and i assume open_S: "open S"
  have "{Suc i} = {i<..Suc i}" by fastforce
  hence "{Suc i} \<times> space M \<in> \<Sigma>\<^sub>P" unfolding space_F[symmetric, of i] sets_predictable_sigma by (intro sigma_sets.Basic) blast
  moreover have "case_prod X -` S \<inter> (UNIV \<times> space M) \<in> \<Sigma>\<^sub>P" using open_S by (intro predictableD, simp add: borel_open)
  ultimately have "case_prod X -` S \<inter> ({Suc i} \<times> space M) \<in> \<Sigma>\<^sub>P" unfolding sets_predictable_sigma using space_F sets.sets_into_space
    by (subst Times_Int_distrib1[of "{Suc i}" UNIV "space M", simplified], subst inf.commute, subst Int_assoc[symmetric], subst Int_range_binary) 
       (intro sigma_sets_Inter binary_in_sigma_sets, fast)+
  moreover have "case_prod X -` S \<inter> ({Suc i} \<times> space M) = {Suc i} \<times> (X (Suc i) -` S \<inter> space M)" by (auto simp add: le_Suc_eq)
  moreover have "... = (\<Union>j. {j} \<times> (if j = Suc i then (X (Suc i) -` S \<inter> space M) else {}))" by (auto split: if_splits)
  ultimately have "(\<Union>j. {j} \<times> (if j = Suc i then (X (Suc i) -` S \<inter> space M) else {})) \<in> \<Sigma>\<^sub>P" by argo
  thus "X (Suc i) -` S \<inter> space (F i) \<in> sets (F i)" using sets_in_filtration[of "\<lambda>j. if j = Suc i then (X (Suc i) -` S \<inter> space M) else {}"] space_F by presburger
qed

subsection "Continuous Time Process"

text \<open>Locales for continuous time processes.\<close>

locale ennreal_stochastic_process = stochastic_process M X for M and X :: "ennreal \<Rightarrow> _"
locale ennreal_adapted_process = adapted_process M F X for M F and X :: "ennreal \<Rightarrow> _"
locale ennreal_predictable_process = predictable_process M F X for M F and X :: "ennreal \<Rightarrow> _"

sublocale ennreal_predictable_process \<subseteq> ennreal_adapted_process by (unfold_locales)
sublocale ennreal_adapted_process \<subseteq> ennreal_stochastic_process by (unfold_locales)

subsection "Processes with an Ordering"

text \<open>These locales are useful in the definition of sub- and supermartingales.\<close>

locale stochastic_process_order = stochastic_process M X for M and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {linorder_topology, ordered_real_vector}"
locale adapted_process_order = adapted_process M F X for M F and X :: "_  \<Rightarrow> _ \<Rightarrow> _ :: {linorder_topology, ordered_real_vector}"
locale predictable_process_order = predictable_process M F X for M F and X :: "_ \<Rightarrow> _ \<Rightarrow> _ :: {linorder_topology, ordered_real_vector}"

(* Discrete Time *)

locale nat_stochastic_process_order = stochastic_process_order M X for M and X :: "nat \<Rightarrow> _" 
locale nat_adapted_process_order = adapted_process_order M F X for M F and X :: "nat \<Rightarrow> _"
locale nat_predictable_process_order = predictable_process_order M F X for M F and X :: "nat \<Rightarrow> _" 

(* Continuous Time *)

locale ennreal_stochastic_process_order = stochastic_process_order M X for M F and X :: "ennreal \<Rightarrow> _"
locale ennreal_adapted_process_order = adapted_process_order M F X for M F and X :: "ennreal \<Rightarrow> _"
locale ennreal_predictable_process_order = predictable_process_order M F X for M F and X :: "ennreal \<Rightarrow> _"

subsection "Sigma Finite Process"

text \<open>Locales for processes with a sigma finite filtration.\<close>

locale sigma_finite_adapted_process = adapted_process + filtered_sigma_finite_measure
locale sigma_finite_predictable_process = predictable_process + filtered_sigma_finite_measure

locale sigma_finite_adapted_process_order = adapted_process_order + filtered_sigma_finite_measure
locale sigma_finite_predictable_process_order = predictable_process_order + filtered_sigma_finite_measure

(* Discrete Time *)

locale nat_sigma_finite_adapted_process = sigma_finite_adapted_process M F X for M F and X :: "nat \<Rightarrow> _"
locale nat_sigma_finite_predictable_process = sigma_finite_predictable_process M F X for M F and X :: "nat \<Rightarrow> _"

locale nat_sigma_finite_adapted_process_order = sigma_finite_adapted_process_order M F X for M F and X :: "nat \<Rightarrow> _"
locale nat_sigma_finite_predictable_process_order = sigma_finite_predictable_process_order M F X for M F and X :: "nat \<Rightarrow> _"

(* Continuous Time *)

locale ennreal_sigma_finite_adapted_process = sigma_finite_adapted_process M F X for M F and X :: "ennreal \<Rightarrow> _"
locale ennreal_sigma_finite_predictable_process = sigma_finite_predictable_process M F X for M F and X :: "ennreal \<Rightarrow> _"

locale ennreal_sigma_finite_adapted_process_order = sigma_finite_adapted_process_order M F X for M F and X :: "ennreal \<Rightarrow> _"
locale ennreal_sigma_finite_predictable_process_order = sigma_finite_predictable_process_order M F X for M F and X :: "ennreal \<Rightarrow> _"

text \<open>Thus, right from the outset, we have pretty much every locale we may need.\<close>

subsection "Stopping Times are Adapted Processes"

lemma (in ennreal_filtered_measure)
  assumes "stopping_time F T"
  shows "ennreal_adapted_process M F (\<lambda>i \<xi>. T \<xi> - enn2real i)"
proof (unfold_locales)
  fix i
  show "(\<lambda>\<xi>. T \<xi> - enn2real i) \<in> borel_measurable (F i)" sorry
qed

end