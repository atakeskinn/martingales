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

lemma tendsto_L1_AE_cauchy:
  assumes "\<And>e. e > 0 \<Longrightarrow> \<exists>N. \<forall>i\<ge>N. \<forall>j\<ge>N. integral\<^sup>L M (\<lambda>x. dist (s i x) (s j x)) < e"
  obtains r where "strict_mono r" "AE x in M. Cauchy (\<lambda>i. s (r i) x)"
  sorry

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

lemma sequence_bounded_implies_dist_bounded:
  assumes "x \<in> space M"
  shows "bounded ((\<lambda>p. dist (fst p x) (snd p x)) ` (s ` UNIV \<times> s ` UNIV))"
proof-
  have "bounded ((\<lambda>i. s i x) ` UNIV \<times> (\<lambda>i. s i x) ` UNIV)" using bdd_seq bounded_Times assms by blast
  hence "bounded ((\<lambda>p. dist (fst p) (snd p)) ` ((\<lambda>i. s i x) ` UNIV \<times> (\<lambda>i. s i x) ` UNIV))" by (intro bounded_dist_comp[OF bounded_fst bounded_snd])
  moreover have "(\<lambda>p. dist (fst p) (snd p)) ` ((\<lambda>i. s i x) ` UNIV \<times> (\<lambda>i. s i x) ` UNIV) = (\<lambda>p. dist (fst p x) (snd p x)) ` (s ` UNIV \<times> s ` UNIV)" by force
  ultimately show "bounded ((\<lambda>p. dist (fst p x) (snd p x)) ` (s ` UNIV \<times> s ` UNIV))" by argo
qed

lemma borel_measurable_diameter: 
  assumes [measurable]: "\<And>i. (s i) \<in> borel_measurable M"
  shows "(\<lambda>x. diameter {s i x |i. n \<le> i}) \<in> borel_measurable M"
proof (cases "\<forall>i. \<not> n \<le> i")
  case True
  then show ?thesis unfolding diameter_def by simp
next
  case False
  {
    fix x
    have "case_prod dist ` ({s i x |i. n \<le> i} \<times> {s i x |i. n \<le> i}) = case_prod (\<lambda>f g. dist (f x) (g x)) ` ({s i |i. n \<le> i} \<times> {s i |i. n \<le> i})" by fast
    hence "case_prod dist ` ({s i x |i. n \<le> i} \<times> {s i x |i. n \<le> i}) = case_prod (\<lambda>f g. dist (f x) (g x)) ` (s ` {n..} \<times> s ` {n..})" by blast
  }
  hence "(\<lambda>x. diameter {s i x |i. n \<le> i}) = (\<lambda>x. Sup (case_prod (\<lambda>f g. dist (f x) (g x)) ` (s ` {n..} \<times> s ` {n..})))" unfolding diameter_def using False by force
  hence *: "(\<lambda>x. diameter {s i x |i. n \<le> i}) =  (\<lambda>x. Sup ((\<lambda>p. dist (fst p x) (snd p x)) ` (s ` {n..} \<times> s ` {n..})))" by (simp add: case_prod_beta')

  have "bounded ((\<lambda>p. dist (fst p x) (snd p x)) ` (s ` {n..} \<times> s ` {n..}))" if "x \<in> space M" for x using sequence_bounded_implies_dist_bounded[OF that] by (rule bounded_subset, auto)
  hence bdd: "bdd_above ((\<lambda>p. dist (fst p x) (snd p x)) ` (s ` {n..} \<times> s ` {n..}))" if "x \<in> space M" for x using that bounded_imp_bdd_above by presburger
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
    let ?S = "(\<lambda>p. dist (fst p x) (snd p x)) ` (s ` {n..} \<times> s ` {n..})"
    have "case_prod dist ` ({s i x |i. n \<le> i} \<times> {s i x |i. n \<le> i}) = case_prod (\<lambda>f g. dist (f x) (g x)) ` ({s i |i. n \<le> i} \<times> {s i |i. n \<le> i})" by fast
    hence "case_prod dist ` ({s i x |i. n \<le> i} \<times> {s i x |i. n \<le> i}) = case_prod (\<lambda>f g. dist (f x) (g x)) ` (s ` {n..} \<times> s ` {n..})" by blast
    hence "diameter {s i x |i. n \<le> i} = Sup (case_prod (\<lambda>f g. dist (f x) (g x)) ` (s ` {n..} \<times> s ` {n..}))" unfolding diameter_def using False by auto
    hence *: "diameter {s i x |i. n \<le> i} =  Sup ?S" by (simp add: case_prod_beta')
    
    have "bounded ?S" using sequence_bounded_implies_dist_bounded[OF x] by (rule bounded_subset, auto)
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