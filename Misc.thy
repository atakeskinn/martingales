theory Misc
  imports "HOL-Analysis.Measure_Space" "HOL-Analysis.Bochner_Integration" "HOL-Analysis.Set_Integral" "HOL-Probability.Conditional_Expectation"
begin

lemma banach_simple_function_indicator_representation:
  fixes f ::"'a \<Rightarrow> 'b :: {second_countable_topology, banach}"
  assumes f: "simple_function M f" and x: "x \<in> space M"
  shows "f x = (\<Sum>y \<in> f ` space M. indicator (f -` {y} \<inter> space M) x *\<^sub>R y)"
  (is "?l = ?r")
proof -
  have "?r = (\<Sum>y \<in> f ` space M.
    (if y = f x then indicator (f -` {y} \<inter> space M) x *\<^sub>R y else 0))" by (auto intro!: sum.cong)
  also have "... =  indicator (f -` {f x} \<inter> space M) x *\<^sub>R f x" using assms by (auto dest: simple_functionD)
  also have "... = f x" using x by (auto simp: indicator_def)
  finally show ?thesis by auto
qed

lemma banach_simple_function_indicator_representation_AE:
  fixes f ::"'a \<Rightarrow> 'b :: {second_countable_topology, banach}"
  assumes f: "simple_function M f"
  shows "AE x in M. f x = (\<Sum>y \<in> f ` space M. indicator (f -` {y} \<inter> space M) x *\<^sub>R y)"  
  by (metis (mono_tags, lifting) AE_I2 banach_simple_function_indicator_representation f)

lemmas simple_function_scaleR[intro] = simple_function_compose2[where h="(*\<^sub>R)"]

lemma integrable_simple_function:
  assumes "simple_function M f" "emeasure M {y \<in> space M. f y \<noteq> 0} \<noteq> \<infinity>"
  shows "integrable M f"
  using assms has_bochner_integral_simple_bochner_integrable integrable.simps simple_bochner_integrable.simps by blast

lemma\<^marker>\<open>tag important\<close> simple_integrable_function_induct[consumes 2, case_names cong indicator add, induct set: simple_function]:
  fixes f :: "'a \<Rightarrow> 'b :: {second_countable_topology, banach}"
  assumes f: "simple_function M f" "emeasure M {y \<in> space M. f y \<noteq> 0} \<noteq> \<infinity>"
  assumes cong: "\<And>f g. simple_function M f \<Longrightarrow> emeasure M {y \<in> space M. f y \<noteq> 0} \<noteq> \<infinity> \<Longrightarrow> simple_function M g \<Longrightarrow> emeasure M {y \<in> space M. g y \<noteq> 0} \<noteq> \<infinity> \<Longrightarrow> (\<And>x. x \<in> space M \<Longrightarrow> f x = g x) \<Longrightarrow> P f \<Longrightarrow> P g"
  assumes indicator: "\<And>A y. A \<in> sets M \<Longrightarrow> emeasure M A < \<infinity> \<Longrightarrow> P (\<lambda>x. indicator A x *\<^sub>R y)"
  assumes add: "\<And>f g. simple_function M f \<Longrightarrow> emeasure M {y \<in> space M. f y \<noteq> 0} \<noteq> \<infinity> \<Longrightarrow> 
                      simple_function M g \<Longrightarrow> emeasure M {y \<in> space M. g y \<noteq> 0} \<noteq> \<infinity> \<Longrightarrow> 
                      \<lbrakk>\<And>z. z \<in> space M \<Longrightarrow> norm (f z + g z) = norm (f z) + norm (g z)\<rbrakk> \<Longrightarrow>
                      P f \<Longrightarrow> P g \<Longrightarrow> P (\<lambda>x. f x + g x)"
  shows "P f"
proof-
  let ?f = "\<lambda>x. (\<Sum>y\<in>f ` space M. indicat_real (f -` {y} \<inter> space M) x *\<^sub>R y)"
  have f_ae_eq: "f x = ?f x" if "x \<in> space M" for x using banach_simple_function_indicator_representation[OF f(1) that] .
  moreover have "emeasure M {y \<in> space M. ?f y \<noteq> 0} \<noteq> \<infinity>" by (metis (no_types, lifting) Collect_cong calculation f(2))
  moreover have "P (\<lambda>x. \<Sum>y\<in>S. indicat_real (f -` {y} \<inter> space M) x *\<^sub>R y)"
                "simple_function M (\<lambda>x. \<Sum>y\<in>S. indicat_real (f -` {y} \<inter> space M) x *\<^sub>R y)"
                "emeasure M {y \<in> space M. (\<Sum>x\<in>S. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x) \<noteq> 0} \<noteq> \<infinity>"
                if "S \<subseteq> f ` space M" for S using simple_functionD(1)[OF assms(1), THEN rev_finite_subset, OF that] that 
  proof (induction rule: finite_induct)
    case empty
    {
      case 1
      then show ?case using indicator[of "{}" 0] by force 
    next
      case 2
      then show ?case by force 
    next
      case 3
      then show ?case by force 
    }
  next
    case (insert x F)
    have "(f -` {x} \<inter> space M) \<subseteq> {y \<in> space M. f y \<noteq> 0}" if "x \<noteq> 0" using that by blast
    moreover have "{y \<in> space M. f y \<noteq> 0} = space M - (f -` {0} \<inter> space M)" by blast
    moreover have "space M - (f -` {0} \<inter> space M) \<in> sets M" using simple_functionD(2)[OF f(1)] by blast
    ultimately have fin_0: "emeasure M (f -` {x} \<inter> space M) < \<infinity>" if "x \<noteq> 0" using that by (metis emeasure_mono f(2) infinity_ennreal_def top.not_eq_extremum top_unique)
    hence fin_1: "emeasure M {y \<in> space M. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x \<noteq> 0} \<noteq> \<infinity>" if "x \<noteq> 0" by (metis (mono_tags, lifting) emeasure_mono f(1) indicator_simps(2) linorder_not_less mem_Collect_eq scaleR_eq_0_iff simple_functionD(2) subsetI that)

    have *: "(\<Sum>y\<in>insert x F. indicat_real (f -` {y} \<inter> space M) xa *\<^sub>R y) = (\<Sum>y\<in>F. indicat_real (f -` {y} \<inter> space M) xa *\<^sub>R y) + indicat_real (f -` {x} \<inter> space M) xa *\<^sub>R x" for xa by (metis (no_types, lifting) Diff_empty Diff_insert0 add.commute insert.hyps(1) insert.hyps(2) sum.insert_remove)
    have **: "{y \<in> space M. (\<Sum>x\<in>insert x F. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x) \<noteq> 0} \<subseteq> {y \<in> space M. (\<Sum>x\<in>F. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x) \<noteq> 0} \<union> {y \<in> space M. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x \<noteq> 0}" unfolding * by fastforce    
    {
      case 1
      hence x: "x \<in> f ` space M" and F: "F \<subseteq> f ` space M" by auto
      show ?case 
      proof (cases "x = 0")
        case True
        then show ?thesis unfolding * using insert(3)[OF F] by simp
      next
        case False
        have norm_argument: "norm ((\<Sum>y\<in>F. indicat_real (f -` {y} \<inter> space M) z *\<^sub>R y) + indicat_real (f -` {x} \<inter> space M) z *\<^sub>R x) = norm (\<Sum>y\<in>F. indicat_real (f -` {y} \<inter> space M) z *\<^sub>R y) + norm (indicat_real (f -` {x} \<inter> space M) z *\<^sub>R x)" if z: "z \<in> space M" for z
        proof (cases "f z = x")
          case True
          have "indicat_real (f -` {y} \<inter> space M) z *\<^sub>R y = 0" if "y \<in> F" for y using True insert(2) z that 1 unfolding indicator_def by force
          hence "(\<Sum>y\<in>F. indicat_real (f -` {y} \<inter> space M) z *\<^sub>R y) = 0" by (meson sum.neutral)
          then show ?thesis by force
        next
          case False
          then show ?thesis by force
        qed
        show ?thesis using False simple_functionD(2)[OF f(1)] insert(3,5)[OF F] simple_function_scaleR fin_0 fin_1 by (subst *, subst add, subst simple_function_sum) (blast intro: norm_argument indicator)+
      qed 
    next
      case 2
      hence x: "x \<in> f ` space M" and F: "F \<subseteq> f ` space M" by auto
      show ?case 
      proof (cases "x = 0")
        case True
        then show ?thesis unfolding * using insert(4)[OF F] by simp
      next
        case False
        then show ?thesis unfolding * using insert(4)[OF F] simple_functionD(2)[OF f(1)] by fast
      qed
    next
      case 3
      hence x: "x \<in> f ` space M" and F: "F \<subseteq> f ` space M" by auto
      show ?case 
      proof (cases "x = 0")
        case True
        then show ?thesis unfolding * using insert(5)[OF F] by simp
      next
        case False
        have "emeasure M {y \<in> space M. (\<Sum>x\<in>insert x F. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x) \<noteq> 0} \<le> emeasure M ({y \<in> space M. (\<Sum>x\<in>F. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x) \<noteq> 0} \<union> {y \<in> space M. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x \<noteq> 0})"
          using ** simple_functionD(2)[OF insert(4)[OF F]] simple_functionD(2)[OF f(1)] by (intro emeasure_mono, force+)
        also have "... \<le> emeasure M {y \<in> space M. (\<Sum>x\<in>F. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x) \<noteq> 0} + emeasure M {y \<in> space M. indicat_real (f -` {x} \<inter> space M) y *\<^sub>R x \<noteq> 0}"
          using simple_functionD(2)[OF insert(4)[OF F]] simple_functionD(2)[OF f(1)] by (intro emeasure_subadditive, force+)
        also have "... < \<infinity>" using insert(5)[OF F] fin_1[OF False] by (simp add: less_top)
        finally show ?thesis by simp
      qed
    }
  qed
  moreover have "simple_function M (\<lambda>x. \<Sum>y\<in>f ` space M. indicat_real (f -` {y} \<inter> space M) x *\<^sub>R y)" using calculation by blast
  moreover have "P (\<lambda>x. \<Sum>y\<in>f ` space M. indicat_real (f -` {y} \<inter> space M) x *\<^sub>R y)" using calculation by blast
  ultimately show ?thesis by (intro cong[OF _ _ f(1,2)], blast, presburger+) 
qed

proposition integrable_induct'[consumes 1, case_names base add lim, induct pred: integrable]:
  fixes f :: "'a \<Rightarrow> 'b::{banach, second_countable_topology}"
  assumes "integrable M f"
  assumes base: "\<And>A c. A \<in> sets M \<Longrightarrow> emeasure M A < \<infinity> \<Longrightarrow> P (\<lambda>x. indicator A x *\<^sub>R c)"
  assumes add: "\<And>f g. integrable M f \<Longrightarrow> P f \<Longrightarrow> integrable M g \<Longrightarrow> P g \<Longrightarrow> P (\<lambda>x. f x + g x)"
  assumes lim: "\<And>f s. integrable M f
                  \<Longrightarrow> (\<And>i. integrable M (s i)) 
                  \<Longrightarrow> (\<And>i. simple_function M (s i)) 
                  \<Longrightarrow> (\<And>i. emeasure M {y\<in>space M. s i y \<noteq> 0} \<noteq> \<infinity>) 
                  \<Longrightarrow> (\<And>x. x \<in> space M \<Longrightarrow> (\<lambda>i. s i x) \<longlonglongrightarrow> f x) 
                  \<Longrightarrow> (\<And>i x. x \<in> space M \<Longrightarrow> norm (s i x) \<le> 2 * norm (f x)) 
                  \<Longrightarrow> (\<And>i. P (s i)) \<Longrightarrow> P f"
  shows "P f"
proof -
  from \<open>integrable M f\<close> have f: "f \<in> borel_measurable M" "(\<integral>\<^sup>+x. norm (f x) \<partial>M) < \<infinity>"
    unfolding integrable_iff_bounded by auto
  from borel_measurable_implies_sequence_metric[OF f(1)]
  obtain s where s: "\<And>i. simple_function M (s i)" "\<And>x. x \<in> space M \<Longrightarrow> (\<lambda>i. s i x) \<longlonglongrightarrow> f x"
    "\<And>i x. x \<in> space M \<Longrightarrow> norm (s i x) \<le> 2 * norm (f x)"
    unfolding norm_conv_dist by metis

  { fix f A
    have [simp]: "P (\<lambda>x. 0)"
      using base[of "{}" undefined] by simp
    have "(\<And>i::'b. i \<in> A \<Longrightarrow> integrable M (f i::'a \<Rightarrow> 'b)) \<Longrightarrow>
    (\<And>i. i \<in> A \<Longrightarrow> P (f i)) \<Longrightarrow> P (\<lambda>x. \<Sum>i\<in>A. f i x)"
    by (induct A rule: infinite_finite_induct) (auto intro!: add) }
  note sum = this

  define s' where [abs_def]: "s' i z = indicator (space M) z *\<^sub>R s i z" for i z
  then have s'_eq_s: "\<And>i x. x \<in> space M \<Longrightarrow> s' i x = s i x"
    by simp

  have sf[measurable]: "\<And>i. simple_function M (s' i)"
    unfolding s'_def using s(1)
    by (intro simple_function_compose2[where h="(*\<^sub>R)"] simple_function_indicator) auto

  { fix i
    have "\<And>z. {y. s' i z = y \<and> y \<in> s' i ` space M \<and> y \<noteq> 0 \<and> z \<in> space M} =
        (if z \<in> space M \<and> s' i z \<noteq> 0 then {s' i z} else {})"
      by (auto simp add: s'_def split: split_indicator)
    then have "\<And>z. s' i = (\<lambda>z. \<Sum>y\<in>s' i`space M - {0}. indicator {x\<in>space M. s' i x = y} z *\<^sub>R y)"
      using sf by (auto simp: fun_eq_iff simple_function_def s'_def) }
  note s'_eq = this

  show "P f"
  proof (rule lim)
    fix i

    have "(\<integral>\<^sup>+x. norm (s' i x) \<partial>M) \<le> (\<integral>\<^sup>+x. ennreal (2 * norm (f x)) \<partial>M)"
      using s by (intro nn_integral_mono) (auto simp: s'_eq_s)
    also have "\<dots> < \<infinity>"
      using f by (simp add: nn_integral_cmult ennreal_mult_less_top ennreal_mult)
    finally have sbi: "Bochner_Integration.simple_bochner_integrable M (s' i)"
      using sf by (intro simple_bochner_integrableI_bounded) auto
    thus "integrable M (s' i)" "simple_function M (s' i)" "emeasure M {y\<in>space M. s' i y \<noteq> 0} \<noteq> \<infinity>" by (auto intro: integrableI_simple_bochner_integrable simple_bochner_integrable.cases)

    { fix x assume"x \<in> space M" "s' i x \<noteq> 0"
      then have "emeasure M {y \<in> space M. s' i y = s' i x} \<le> emeasure M {y \<in> space M. s' i y \<noteq> 0}"
        by (intro emeasure_mono) auto
      also have "\<dots> < \<infinity>"
        using sbi by (auto elim: simple_bochner_integrable.cases simp: less_top)
      finally have "emeasure M {y \<in> space M. s' i y = s' i x} \<noteq> \<infinity>" by simp }
    then show "P (s' i)"
      by (subst s'_eq) (auto intro!: sum base simp: less_top)

    fix x assume "x \<in> space M" with s show "(\<lambda>i. s' i x) \<longlonglongrightarrow> f x"
      by (simp add: s'_eq_s)
    show "norm (s' i x) \<le> 2 * norm (f x)"
      using \<open>x \<in> space M\<close> s by (simp add: s'_eq_s)
  qed fact
qed

lemma set_integral_scaleR_left: 
  assumes "A \<in> sets M" "c \<noteq> 0 \<Longrightarrow> integrable M f"
  shows "LINT t:A|M. f t *\<^sub>R c = (LINT t:A|M. f t) *\<^sub>R c"
  unfolding set_lebesgue_integral_def 
  using integrable_mult_indicator[OF assms]
  by (subst integral_scaleR_left[symmetric], auto)

lemma nn_set_integral_eq_set_integral:
  assumes [measurable]:"integrable M f" 
      and "AE x \<in> A in M. 0 \<le> f x" "A \<in> sets M"
    shows "(\<integral>\<^sup>+x\<in>A. f x \<partial>M) = (\<integral> x \<in> A. f x \<partial>M)"
proof-
  have "(\<integral>\<^sup>+x. indicator A x *\<^sub>R f x \<partial>M) = (\<integral> x \<in> A. f x \<partial>M)"
  unfolding set_lebesgue_integral_def using assms(2) by (intro nn_integral_eq_integral[of _ "\<lambda>x. indicat_real A x *\<^sub>R f x"], blast intro: assms integrable_mult_indicator, fastforce)
  moreover have "(\<integral>\<^sup>+x. indicator A x *\<^sub>R f x \<partial>M) = (\<integral>\<^sup>+x\<in>A. f x \<partial>M)"  by (metis ennreal_0 indicator_simps(1) indicator_simps(2) mult.commute mult_1 mult_zero_left real_scaleR_def)
  ultimately show ?thesis by argo
qed

lemma AE_impI':
  assumes "\<And>x. x \<in> space M \<Longrightarrow> P x \<Longrightarrow> Q x" 
  shows "AE x in M. P x \<longrightarrow> Q x"
  using assms by fast

lemma AE_trans:
  assumes "AE x in M. P x = Q x" and "AE x in M. Q x = R x"
  shows "AE x in M. P x = R x"
  using assms by fastforce

lemma finite_nn_integral_imp_ae_finite:
  assumes "f \<in> borel_measurable M" "(\<integral>\<^sup>+x. f x \<partial>M) < \<infinity>"
  shows "AE x in M. f x < \<infinity>"
proof (rule ccontr, goal_cases)
  case 1
  let ?A = "space M \<inter> {x. f x = \<infinity>}"
  have *: "emeasure M ?A > 0" using 1 assms(1) by (metis (mono_tags, lifting) assms(2) eventually_mono infinity_ennreal_def nn_integral_noteq_infinite top.not_eq_extremum)
  have "(\<integral>\<^sup>+x \<in> ?A. f x \<partial>M) = (\<integral>\<^sup>+x \<in> ?A. \<infinity> \<partial>M)" by (metis (mono_tags, lifting) indicator_inter_arith indicator_simps(2) mem_Collect_eq mult_eq_0_iff)
  also have "... = \<infinity> * emeasure M ?A" using assms(1) by (intro nn_integral_cmult_indicator, simp)
  also have "... = \<infinity>" using * by fastforce
  finally have "(\<integral>\<^sup>+x \<in> ?A. f x \<partial>M) = \<infinity>" .
  moreover have "(\<integral>\<^sup>+x \<in> ?A. f x \<partial>M) \<le> (\<integral>\<^sup>+x. f x \<partial>M)" by (intro nn_integral_mono, simp add: indicator_def)
  ultimately show ?case using assms(2) by simp
qed

lemma cauchy_L1_AE_cauchy_subseq:
  fixes s :: "nat \<Rightarrow> 'a \<Rightarrow> 'b::{banach, second_countable_topology}"
  assumes [measurable]: "\<And>n. integrable M (s n)"
      and "\<And>e. e > 0 \<Longrightarrow> \<exists>N. \<forall>i\<ge>N. \<forall>j\<ge>N. LINT x|M. dist (s i x) (s j x) < e"
  obtains r where "strict_mono r" "AE x in M. Cauchy (\<lambda>i. s (r i) x)"
proof-
  have "\<exists>r. \<forall>n. (\<forall>i\<ge>r n. \<forall>j\<ge> r n. LINT x|M. dist (s i x) (s j x) < (1 / 2) ^ n) \<and> (r (Suc n) > r n)"
  proof (intro dependent_nat_choice, goal_cases)
    case 1
    then show ?case using assms(2) by presburger
  next
    case (2 x n)
    obtain N where *: "LINT x|M. dist (s i x) (s j x) < (1 / 2) ^ Suc n" if "i \<ge> N" "j \<ge> N" for i j using assms(2)[of "(1 / 2) ^ Suc n"] by auto
    {
      fix i j assume "i \<ge> max N (Suc x)" "j \<ge> max N (Suc x)"
      hence "integral\<^sup>L M (\<lambda>x. dist (s i x) (s j x)) < (1 / 2) ^ Suc n" using * by fastforce
    }
    then show ?case by fastforce
  qed
  then obtain r where strict_mono: "strict_mono r" "\<forall>i\<ge>r n. \<forall>j\<ge> r n. LINT x|M. dist (s i x) (s j x) < (1 / 2) ^ n" for n using strict_mono_Suc_iff by blast
  hence r_is: "LINT x|M. dist (s (r (Suc n)) x) (s (r n) x) < (1 / 2) ^ n" for n by (simp add: strict_mono_leD)

  define g where "g = (\<lambda>n x. (\<Sum>i\<le>n. ennreal (dist (s (r (Suc i)) x) (s (r i) x))))"

  have [measurable]: "g n \<in> borel_measurable M" for n unfolding g_def by auto
  have g_nonneg: "g n x \<ge> 0" for n x unfolding g_def by (simp add: sum_nonneg)
  have g_incseq: "incseq (\<lambda>n. g n x)" for x by (intro incseq_SucI, auto simp add: g_def ennreal_leI)
  hence "(\<lambda>n. g n x) \<longlonglongrightarrow> Sup (range (\<lambda>n. g n x))" for x by (intro LIMSEQ_incseq_SUP, auto)
  hence g_convergent: "convergent (\<lambda>n. g n x)" for x using convergent_def by blast

  have integrable_g_n: "(\<integral>\<^sup>+ x. g n x \<partial>M) < 2" for n
  proof -
    (* add beauty *)
    have integrable_dist: "integrable M (\<lambda>x. dist (s i x) (s j x))" for i j
      apply (intro Bochner_Integration.integrable_bound[OF integrable_mult_right[OF integrable_max[OF assms(1,1)[THEN integrable_norm]]], of _ 2 i j], simp)
      by (smt (verit) AE_I2 dist_0_norm dist_triangle3 real_norm_def)

    have "(\<integral>\<^sup>+ x. g n x \<partial>M) = (\<integral>\<^sup>+ x. (\<Sum>i\<le>n. ennreal (dist (s (r (Suc i)) x) (s (r i) x))) \<partial>M)" using g_nonneg g_def by simp
    also have "... = (\<Sum>i\<le>n. (\<integral>\<^sup>+ x. ennreal (dist (s (r (Suc i)) x) (s (r i) x)) \<partial>M))" by (intro nn_integral_sum, simp)
    also have "... = (\<Sum>i\<le>n. LINT x|M. dist (s (r (Suc i)) x) (s (r i) x))" by (subst nn_integral_eq_integral[OF integrable_dist], auto)
    also have "... < ennreal (\<Sum>i\<le>n. (1 / 2) ^ i)" (* add beauty here too *)
      using sum_strict_mono[OF finite_atMost _ r_is, of n "\<lambda>i. i"] by (intro ennreal_lessI, simp) (metis (mono_tags, lifting) AE_I2 integral_nonneg_AE order_trans_rules(21) sum_nonneg zero_le_dist, blast)
    also have "... \<le> ennreal 2" unfolding sum_gp0[of "1 / 2" n] by (intro ennreal_leI, auto)
    finally show "(\<integral>\<^sup>+ x. g n x \<partial>M) < 2" by simp
  qed

  define g' where "g' = (\<lambda>x. \<Sum>i. ennreal (dist (s (r (Suc i)) x) (s (r i) x)))"
  have "(\<lambda>n. g n x) \<longlonglongrightarrow> g' x" for x using g_convergent unfolding g_def g'_def by (intro summable_iff_convergent'[THEN iffD2, THEN summable_LIMSEQ'], blast)
  hence g'_is_lim: "g' = (\<lambda>x. lim (\<lambda>n. g n x))" by (metis limI)
  hence [measurable]: "g' \<in> borel_measurable M" by simp 

  have integrable_g': "(\<integral>\<^sup>+ x. g' x \<partial>M) \<le> 2"
  proof -
    have "(\<integral>\<^sup>+ x. g' x \<partial>M) = (\<integral>\<^sup>+ x. liminf (\<lambda>n. g n x) \<partial>M)" using g'_is_lim by (simp add: convergent_liminf_cl g_convergent)
    also have "... \<le> liminf (\<lambda>n. \<integral>\<^sup>+ x. g n x \<partial>M)" by (intro nn_integral_liminf, simp)
    also have "... \<le> liminf (\<lambda>n. 2)" using integrable_g_n by (intro Liminf_mono) (simp add: order_le_less)
    also have "... = 2" using sequentially_bot tendsto_iff_Liminf_eq_Limsup by blast
    finally show ?thesis .
  qed
  hence "AE x in M. g' x < \<infinity>" by (intro finite_nn_integral_imp_ae_finite) (auto simp add: order_le_less_trans)
  hence "AE x in M. g' x \<noteq> \<infinity>" by force
  moreover have "summable (\<lambda>i. dist (s (r (Suc i)) x) (s (r i) x))" if "g' x \<noteq> \<infinity>" for x using that unfolding g'_def by (intro summable_suminf_not_top, intro zero_le_dist, fastforce) 
  ultimately have ae_summable: "AE x in M. summable (\<lambda>i. dist (s (r (Suc i)) x) (s (r i) x))" by fast
  hence ae_nonneg: "AE x in M. (\<Sum>i. dist (s (r (Suc i)) x) (s (r i) x)) \<ge> 0" using suminf_nonneg by fastforce
  
  have integrable_g'': "integrable M (\<lambda>x. (\<Sum>i. dist (s (r (Suc i)) x) (s (r i) x)))"
  proof (rule integrableI_bounded, simp, goal_cases)
    case 1
    have "AE x in M. ennreal (norm (\<Sum>i. dist (s (r (Suc i)) x) (s (r i) x))) = ennreal (\<Sum>i. dist (s (r (Suc i)) x) (s (r i) x))" using ae_nonneg by force
    moreover have "AE x in M. ennreal (\<Sum>i. dist (s (r (Suc i)) x) (s (r i) x)) = g' x" unfolding g'_def using suminf_ennreal2 ae_summable by fastforce
    ultimately have "AE x in M. ennreal (norm (\<Sum>i. dist (s (r (Suc i)) x) (s (r i) x))) = g' x" by force
    thus ?case using nn_integral_cong_AE integrable_g' using order_le_less_trans by fastforce
  qed

  have ae_summable': "AE x in M. summable (\<lambda>i. s (r (Suc i)) x - s (r i) x)" using ae_summable summable_norm_cancel unfolding dist_norm by fastforce

  define f where "f = (\<lambda>x. (\<Sum>i. s (r (Suc i)) x - s (r i) x) + s (r 0) x)"
  {
    fix x assume "summable (\<lambda>i. s (r (Suc i)) x - s (r i) x)"
    hence "(\<lambda>n. \<Sum>i<n. s (r (Suc i)) x - s (r i) x) \<longlonglongrightarrow> (\<Sum>i. s (r (Suc i)) x - s (r i) x)" using summable_LIMSEQ by blast
    moreover have "(\<lambda>n. (\<Sum>i<n. s (r (Suc i)) x - s (r i) x)) = (\<lambda>n. s (r n) x - s (r 0) x)" using sum_lessThan_telescope by fastforce
    ultimately have "(\<lambda>n. s (r n) x - s (r 0) x) \<longlonglongrightarrow> (\<Sum>i. s (r (Suc i)) x - s (r i) x)" by argo
    hence "(\<lambda>n. s (r n) x - s (r 0) x + s (r 0) x) \<longlonglongrightarrow> f x" unfolding f_def by (intro isCont_tendsto_compose[of _ "\<lambda>z. z + s (r 0) x"], auto)
    hence "Cauchy (\<lambda>n. s (r n) x)" by (simp add: LIMSEQ_imp_Cauchy)
  }
  hence "AE x in M. Cauchy (\<lambda>i. s (r i) x)" using ae_summable' by fast
  thus ?thesis by (rule that[OF strict_mono(1)])
qed

lemma diameter_comp_strict_mono:
  fixes s :: "nat \<Rightarrow> 'a :: real_normed_vector"
  assumes "strict_mono r" "bounded {s i |i. r n \<le> i}"
  shows "diameter {s (r i) | i. n \<le> i} \<le> diameter {s i | i. r n \<le> i}"
proof (rule diameter_subset)
  show "{s (r i) | i. n \<le> i} \<subseteq> {s i | i. r n \<le> i}" using assms(1) monotoneD strict_mono_mono by fastforce
qed (intro assms(2))

lemma diameter_bounded_bound':
  fixes S :: "'a :: metric_space set"
  assumes S: "bdd_above (case_prod dist ` (S\<times>S))" "x \<in> S" "y \<in> S"
  shows "dist x y \<le> diameter S"
proof -
  have "(x,y) \<in> S\<times>S" using S by auto
  then have "dist x y \<le> (SUP (x,y)\<in>S\<times>S. dist x y)" by (rule cSUP_upper2[OF assms(1)]) simp
  with \<open>x \<in> S\<close> show ?thesis by (auto simp: diameter_def)
qed

lemma supremum_limit:
  fixes S :: "real set"
  assumes "S \<noteq> {}" "bdd_above S"
  obtains h where "\<And>i. h i \<in> S" "(\<lambda>i. h i) \<longlonglongrightarrow> Sup S"
proof
  let ?s = "\<lambda>n. Sup S - (1 :: real) / ((n  :: nat) + 1)"
  let ?P = "\<lambda>n y. Sup S \<ge> y \<and> y > ?s n \<and> y \<in> S"
  define h where "h = (\<lambda>n. SOME x. ?P n x)"
  have *: "?P i (h i)" for i
  proof -
    obtain x where "x \<le> Sup S" "Sup S - (1 :: real) / (i + 1) < x" "x \<in> S" using cSup_least[OF assms(1), of "Sup S - 1 / (i + 1)", THEN not_less[THEN iffD2]] cSup_upper[OF _ assms(2)] by force
    then show ?thesis using someI[of "?P i" x] unfolding h_def by (simp add: add.commute)
  qed
  thus "\<And>i. h i \<in> S" by blast

  show "h \<longlonglongrightarrow> Sup S"
  proof (standard, goal_cases)
    case (1 e)
    then obtain n where n_less: "1 / ((n :: nat) + 1) < e" by (metis Suc_eq_plus1 nat_approx_posE)
    moreover have "dist (h i) (Sup S) < 1 / (1 + i)" for i using *[of i] unfolding dist_norm by auto
    ultimately have "dist (h i) (Sup S) < e" if "i \<ge> n" for i using that by (subst order.strict_trans[OF _ order.strict_trans1, of _ "1 / (1 + i)"], auto simp add: frac_le)
    then show ?case by (meson eventually_at_top_linorderI)
  qed
qed

lemma cauchy_iff_diameter_tends_to_zero:
  fixes s :: "nat \<Rightarrow> 'a :: real_normed_vector"
  shows "Cauchy s \<longleftrightarrow> (\<lambda>n. diameter {s i | i. i \<ge> n}) \<longlonglongrightarrow> 0"
proof (standard, goal_cases)
  case 1
  have "\<forall>e>0. \<exists>N. \<forall>n\<ge>N. norm (diameter {s i |i. n \<le> i}) < e"
  proof (clarify, goal_cases)
    case _: (1 e)
    then obtain N where "norm (s n - s m) < e" if "n \<ge> N" "m \<ge> N" for n m using 1 CauchyD by fast
    hence "diameter {s i |i. N \<le> i} \<le> e" by (intro diameter_le) fastforce+
    then show ?case sorry
  qed                 
  thus ?case sorry
next
  case 2
  then show ?case sorry
qed                             

context
  fixes s r :: "nat \<Rightarrow> 'a \<Rightarrow> 'b :: {second_countable_topology, real_normed_vector, banach}" and M
  assumes bdd_seq: "\<And>x. x \<in> space M \<Longrightarrow> bounded (range (\<lambda>i. s i x))"
begin

lemma cauchy_dist_bounded:
  assumes "x \<in> space M"
  shows "bounded ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..}))"
proof-
  have "bounded ((\<lambda>i. s i x) ` UNIV \<times> (\<lambda>i. s i x) ` UNIV)" using bdd_seq bounded_Times assms by blast
  hence "bounded ((\<lambda>p. dist (fst p) (snd p)) ` ((\<lambda>i. s i x) ` UNIV \<times> (\<lambda>i. s i x) ` UNIV))" by (intro bounded_dist_comp[OF bounded_fst bounded_snd])
  moreover have "(\<lambda>p. dist (fst p) (snd p)) ` ((\<lambda>i. s i x) ` UNIV \<times> (\<lambda>i. s i x) ` UNIV) =  ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({0..} \<times> {0..}))" by force
  ultimately have "bounded ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({0..} \<times> {0..}))" by argo
  moreover have "((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..})) \<subseteq> ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({0..} \<times> {0..}))" by force
  ultimately show ?thesis using bounded_subset by blast
qed

lemma borel_measurable_diameter: 
  assumes [measurable]: "\<And>i. (s i) \<in> borel_measurable M"
  shows "(\<lambda>x. diameter {s i x |i. n \<le> i}) \<in> borel_measurable M"
proof (cases "\<forall>i. \<not> n \<le> i")
  case True
  then show ?thesis unfolding diameter_def by simp
next
  case False
  have "case_prod dist ` ({s i x |i. n \<le> i} \<times> {s i x |i. n \<le> i}) = ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..}))" for x by fast
  hence "(\<lambda>x. diameter {s i x |i. n \<le> i}) = (\<lambda>x. Sup ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..})))" unfolding diameter_def using False by force
  hence *: "(\<lambda>x. diameter {s i x |i. n \<le> i}) =  (\<lambda>x. Sup ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..})))" by (simp add: case_prod_beta')

  have "bounded ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..}))" if "x \<in> space M" for x by (rule cauchy_dist_bounded[OF that])
  hence bdd: "bdd_above ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..}))" if "x \<in> space M" for x using that bounded_imp_bdd_above by presburger
  have "fst p \<in> borel_measurable M" "snd p \<in> borel_measurable M" if "p \<in> s ` {n..} \<times> s ` {n..}" for p using that by fastforce+
  hence "(\<lambda>x. fst p x - snd p x) \<in> borel_measurable M" if "p \<in> s ` {n..} \<times> s ` {n..}" for p using that borel_measurable_diff by simp
  hence "(\<lambda>x. case p of (f, g) \<Rightarrow> dist (f x) (g x)) \<in> borel_measurable M" if "p \<in> s ` {n..} \<times> s ` {n..}" for p unfolding dist_norm using that by measurable
  moreover have "countable (s ` {n..} \<times> s ` {n..})" by (intro countable_SIGMA countable_image, auto)
  ultimately show ?thesis unfolding * by (auto intro!: borel_measurable_cSUP bdd)
qed

lemma integrable_bound_diameter:
  fixes f :: "'a \<Rightarrow> real"
  assumes "integrable M f" 
      and [measurable]: "\<And>i. (s i) \<in> borel_measurable M"
      and "\<And>x i. x \<in> space M \<Longrightarrow> norm (s i x) \<le> f x"
    shows "integrable M (\<lambda>x. diameter {s i x |i. n \<le> i})"
proof (cases "\<forall>i. \<not> n \<le> i")
  case True
  then show ?thesis unfolding diameter_def by simp
next
  case False
  {
    fix x assume x: "x \<in> space M"
    let ?S = "(\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..})"
    have "case_prod dist ` ({s i x |i. n \<le> i} \<times> {s i x |i. n \<le> i}) = (\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..})" by fast
    hence "diameter {s i x |i. n \<le> i} = Sup ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..}))" unfolding diameter_def using False by auto
    hence *: "diameter {s i x |i. n \<le> i} =  Sup ?S" by (simp add: case_prod_beta')
    
    have "bounded ?S" by (rule cauchy_dist_bounded[OF x])
    hence Sup_S_nonneg:"0 \<le> Sup ?S" by (auto intro!: cSup_upper2 x bounded_imp_bdd_above)

    have "dist (s i x) (s j x) \<le>  2 * f x" for i j by (intro dist_triangle2[THEN order_trans, of _ 0]) (metis norm_conv_dist assms(3) x add_mono mult_2)
    hence "\<forall>c \<in> ?S. c \<le> 2 * f x" by force
    hence "Sup ?S \<le> 2 * f x" by (intro cSup_least, auto)
    hence "norm (Sup ?S) \<le> 2 * norm (f x)" using Sup_S_nonneg by auto
    also have "... = norm (2 *\<^sub>R f x)" by simp
    finally have "norm (diameter {s i x |i. n \<le> i}) \<le> norm (2 *\<^sub>R f x)" unfolding * .
  }
  hence "AE x in M. norm (diameter {s i x |i. n \<le> i}) \<le> norm (2 *\<^sub>R f x)" by blast
  thus  "integrable M (\<lambda>x. diameter {s i x |i. n \<le> i})" using borel_measurable_diameter by (intro Bochner_Integration.integrable_bound[OF assms(1)[THEN integrable_scaleR_right[of 2]]], measurable)
qed
end


end