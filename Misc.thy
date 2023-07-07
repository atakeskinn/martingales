theory Misc
  imports "HOL-Analysis.Measure_Space" "HOL-Analysis.Bochner_Integration" "HOL-Analysis.Set_Integral" "HOL-Probability.Conditional_Expectation"
begin

subsection \<open>Simple function Lemmas\<close>

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



subsection \<open>Diameter Arguments\<close>


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

lemma bounded_imp_dist_bounded:
  assumes "bounded (range s)"
  shows "bounded ((\<lambda>(i, j). dist (s i) (s j)) ` ({n..} \<times> {n..}))"
  using bounded_dist_comp[OF bounded_fst bounded_snd, OF bounded_Times(1,1)[OF assms(1,1)]] by (rule bounded_subset, force) 

lemma cauchy_iff_diameter_tends_to_zero_and_bounded:
  fixes s :: "nat \<Rightarrow> 'a :: real_normed_vector"
  shows "Cauchy s \<longleftrightarrow> ((\<lambda>n. diameter {s i | i. i \<ge> n}) \<longlonglongrightarrow> 0 \<and> bounded (range s))"
proof -
  have "{s i |i. N \<le> i} \<noteq> {}" for N by blast
  hence diameter_SUP: "diameter {s i |i. N \<le> i} = (SUP (i, j) \<in> {N..} \<times> {N..}. dist (s i) (s j))" for N unfolding diameter_def by (auto intro!: arg_cong[of _ _ Sup])
  show ?thesis 
  proof ((standard ; clarsimp), goal_cases)
    case 1
    have "\<exists>N. \<forall>n\<ge>N. norm (diameter {s i |i. n \<le> i}) < e" if e_pos: "e > 0" for e
    proof -
      obtain N where dist_less: "dist (s n) (s m) < (1/2) * e" if "n \<ge> N" "m \<ge> N" for n m using 1 CauchyD e_pos dist_norm by (metis mult_pos_pos zero_less_divide_iff zero_less_numeral zero_less_one)
      {
        fix r assume "r \<ge> N"
        hence "dist (s n) (s m) < (1/2) * e" if "n \<ge> r" "m \<ge> r" for n m using dist_less that by simp
        hence "(SUP (i, j) \<in> {r..} \<times> {r..}. dist (s i) (s j)) \<le> (1/2) * e" by (intro cSup_least) fastforce+
        also have "... < e" using e_pos by simp
        finally have "diameter {s i |i. r \<le> i} < e" using diameter_SUP by presburger
      }
      moreover have "diameter {s i |i. r \<le> i} \<ge> 0" for r unfolding diameter_SUP using bounded_imp_dist_bounded[OF cauchy_imp_bounded, THEN bounded_imp_bdd_above, OF 1] by (intro cSup_upper2, auto)
      ultimately show ?thesis by auto
    qed                 
    thus ?case using cauchy_imp_bounded[OF 1] by (simp add: LIMSEQ_iff)
  next
    case 2
    have "\<exists>N. \<forall>n\<ge>N. \<forall>m\<ge>N. dist (s n) (s m) < e" if e_pos: "e > 0" for e
    proof -
      obtain N where diam_less: "diameter {s i |i. r \<le> i} < e" if "r \<ge> N" for r using LIMSEQ_D 2(1) e_pos by fastforce
      {
        fix n m assume "n \<ge> N" "m \<ge> N"
        hence "dist (s n) (s m) < e" using cSUP_lessD[OF bounded_imp_dist_bounded[THEN bounded_imp_bdd_above], OF 2(2) diam_less[unfolded diameter_SUP]] by auto
      }
      thus ?thesis by blast
    qed
    then show ?case by (intro CauchyI, simp add: dist_norm)
  qed            
qed

context
  fixes s r :: "nat \<Rightarrow> 'a \<Rightarrow> 'b :: {second_countable_topology, real_normed_vector, banach}" and M
  assumes bounded: "\<And>x. x \<in> space M \<Longrightarrow> bounded (range (\<lambda>i. s i x))"
begin

lemma borel_measurable_diameter: 
  assumes [measurable]: "\<And>i. (s i) \<in> borel_measurable M"
  shows "(\<lambda>x. diameter {s i x |i. n \<le> i}) \<in> borel_measurable M"
proof -
  have "{s i x |i. N \<le> i} \<noteq> {}" for x N by blast
  hence diameter_SUP: "diameter {s i x |i. N \<le> i} = (SUP (i, j) \<in> {N..} \<times> {N..}. dist (s i x) (s j x))" for x N unfolding diameter_def by (auto intro!: arg_cong[of _ _ Sup])
  
  have "case_prod dist ` ({s i x |i. n \<le> i} \<times> {s i x |i. n \<le> i}) = ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..}))" for x by fast
  hence *: "(\<lambda>x. diameter {s i x |i. n \<le> i}) =  (\<lambda>x. Sup ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..})))" using diameter_SUP by (simp add: case_prod_beta')
  
  have "bounded ((\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..}))" if "x \<in> space M" for x by (rule bounded_imp_dist_bounded[OF bounded, OF that])
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
proof -
  have "{s i x |i. N \<le> i} \<noteq> {}" for x N by blast
  hence diameter_SUP: "diameter {s i x |i. N \<le> i} = (SUP (i, j) \<in> {N..} \<times> {N..}. dist (s i x) (s j x))" for x N unfolding diameter_def by (auto intro!: arg_cong[of _ _ Sup])
  {
    fix x assume x: "x \<in> space M"
    let ?S = "(\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..})"
    have "case_prod dist ` ({s i x |i. n \<le> i} \<times> {s i x |i. n \<le> i}) = (\<lambda>(i, j). dist (s i x) (s j x)) ` ({n..} \<times> {n..})" by fast
    hence *: "diameter {s i x |i. n \<le> i} =  Sup ?S" using diameter_SUP by (simp add: case_prod_beta')
    
    have "bounded ?S" by (rule bounded_imp_dist_bounded[OF bounded[OF x]])
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

subsection \<open>Bochner Integral Lemmas\<close>


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
  have f: "f \<in> borel_measurable M" "(\<integral>\<^sup>+x. norm (f x) \<partial>M) < \<infinity>" using assms(1) unfolding integrable_iff_bounded by auto
  obtain s where s: "\<And>i. simple_function M (s i)" "\<And>x. x \<in> space M \<Longrightarrow> (\<lambda>i. s i x) \<longlonglongrightarrow> f x" "\<And>i x. x \<in> space M \<Longrightarrow> norm (s i x) \<le> 2 * norm (f x)" using borel_measurable_implies_sequence_metric[OF f(1)] unfolding norm_conv_dist by metis

  { 
    fix f A
    have [simp]: "P (\<lambda>x. 0)" using base[of "{}" undefined] by simp
    have "(\<And>i::'b. i \<in> A \<Longrightarrow> integrable M (f i::'a \<Rightarrow> 'b)) \<Longrightarrow> (\<And>i. i \<in> A \<Longrightarrow> P (f i)) \<Longrightarrow> P (\<lambda>x. \<Sum>i\<in>A. f i x)" by (induct A rule: infinite_finite_induct) (auto intro!: add) 
  }
  note sum = this

  define s' where [abs_def]: "s' i z = indicator (space M) z *\<^sub>R s i z" for i z
  hence s'_eq_s: "\<And>i x. x \<in> space M \<Longrightarrow> s' i x = s i x" by simp

  have sf[measurable]: "\<And>i. simple_function M (s' i)" unfolding s'_def using s(1) by (intro simple_function_compose2[where h="(*\<^sub>R)"] simple_function_indicator) auto

  { 
    fix i
    have "\<And>z. {y. s' i z = y \<and> y \<in> s' i ` space M \<and> y \<noteq> 0 \<and> z \<in> space M} = (if z \<in> space M \<and> s' i z \<noteq> 0 then {s' i z} else {})" by (auto simp add: s'_def split: split_indicator)
    then have "\<And>z. s' i = (\<lambda>z. \<Sum>y\<in>s' i`space M - {0}. indicator {x\<in>space M. s' i x = y} z *\<^sub>R y)" using sf by (auto simp: fun_eq_iff simple_function_def s'_def) 
  }
  note s'_eq = this

  show "P f"
  proof (rule lim)
    fix i
    have "(\<integral>\<^sup>+x. norm (s' i x) \<partial>M) \<le> (\<integral>\<^sup>+x. ennreal (2 * norm (f x)) \<partial>M)" using s by (intro nn_integral_mono) (auto simp: s'_eq_s)
    also have "\<dots> < \<infinity>" using f by (simp add: nn_integral_cmult ennreal_mult_less_top ennreal_mult)
    finally have sbi: "Bochner_Integration.simple_bochner_integrable M (s' i)" using sf by (intro simple_bochner_integrableI_bounded) auto
    thus "integrable M (s' i)" "simple_function M (s' i)" "emeasure M {y\<in>space M. s' i y \<noteq> 0} \<noteq> \<infinity>" by (auto intro: integrableI_simple_bochner_integrable simple_bochner_integrable.cases)

    { 
      fix x assume"x \<in> space M" "s' i x \<noteq> 0"
      then have "emeasure M {y \<in> space M. s' i y = s' i x} \<le> emeasure M {y \<in> space M. s' i y \<noteq> 0}" by (intro emeasure_mono) auto
      also have "\<dots> < \<infinity>" using sbi by (auto elim: simple_bochner_integrable.cases simp: less_top)
      finally have "emeasure M {y \<in> space M. s' i y = s' i x} \<noteq> \<infinity>" by simp 
    }
    then show "P (s' i)" by (subst s'_eq) (auto intro!: sum base simp: less_top)

    fix x assume "x \<in> space M" 
    thus "(\<lambda>i. s' i x) \<longlonglongrightarrow> f x" using s by (simp add: s'_eq_s)
    show "norm (s' i x) \<le> 2 * norm (f x)" using \<open>x \<in> space M\<close> s by (simp add: s'_eq_s)
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

lemma set_integral_restrict_space:
  fixes f :: "'a \<Rightarrow> 'b::{banach, second_countable_topology}"
  assumes "\<Omega> \<inter> space M \<in> sets M"
  shows "set_lebesgue_integral (restrict_space M \<Omega>) A f = set_lebesgue_integral M A (\<lambda>x. indicator \<Omega> x *\<^sub>R f x)"
  unfolding set_lebesgue_integral_def 
  by (subst integral_restrict_space, auto intro!: integrable_mult_indicator assms simp: mult.commute)

lemma set_integral_const:
  fixes c :: "'b::{banach, second_countable_topology}"
  assumes "A \<in> sets M" "emeasure M A \<noteq> \<infinity>"
  shows "set_lebesgue_integral M A (\<lambda>_. c) = measure M A *\<^sub>R c"
  unfolding set_lebesgue_integral_def 
  using assms by (metis has_bochner_integral_indicator has_bochner_integral_integral_eq infinity_ennreal_def less_top)

lemma finite_nn_integral_imp_ae_finite:
  fixes f :: "'a \<Rightarrow> ennreal"
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
  then obtain r where strict_mono: "strict_mono r" and "\<forall>i\<ge>r n. \<forall>j\<ge> r n. LINT x|M. dist (s i x) (s j x) < (1 / 2) ^ n" for n using strict_mono_Suc_iff by blast
  hence r_is: "LINT x|M. dist (s (r (Suc n)) x) (s (r n) x) < (1 / 2) ^ n" for n by (simp add: strict_mono_leD)

  define g where "g = (\<lambda>n x. (\<Sum>i\<le>n. ennreal (dist (s (r (Suc i)) x) (s (r i) x))))"
  define g' where "g' = (\<lambda>x. \<Sum>i. ennreal (dist (s (r (Suc i)) x) (s (r i) x)))"

  have integrable_g: "(\<integral>\<^sup>+ x. g n x \<partial>M) < 2" for n
  proof -
    have "(\<integral>\<^sup>+ x. g n x \<partial>M) = (\<integral>\<^sup>+ x. (\<Sum>i\<le>n. ennreal (dist (s (r (Suc i)) x) (s (r i) x))) \<partial>M)" using g_def by simp
    also have "... = (\<Sum>i\<le>n. (\<integral>\<^sup>+ x. ennreal (dist (s (r (Suc i)) x) (s (r i) x)) \<partial>M))" by (intro nn_integral_sum, simp)
    also have "... = (\<Sum>i\<le>n. LINT x|M. dist (s (r (Suc i)) x) (s (r i) x))" unfolding dist_norm using assms(1) by (subst nn_integral_eq_integral[OF integrable_norm], auto)
    also have "... < ennreal (\<Sum>i\<le>n. (1 / 2) ^ i)" by (intro ennreal_lessI[OF sum_pos sum_strict_mono[OF finite_atMost _ r_is]], auto)
    also have "... \<le> ennreal 2" unfolding sum_gp0[of "1 / 2" n] by (intro ennreal_leI, auto)
    finally show "(\<integral>\<^sup>+ x. g n x \<partial>M) < 2" by simp
  qed

  have integrable_g': "(\<integral>\<^sup>+ x. g' x \<partial>M) \<le> 2"
  proof -
    have "incseq (\<lambda>n. g n x)" for x by (intro incseq_SucI, auto simp add: g_def ennreal_leI)
    hence "convergent (\<lambda>n. g n x)" for x unfolding convergent_def using LIMSEQ_incseq_SUP by fast
    hence "(\<lambda>n. g n x) \<longlonglongrightarrow> g' x" for x unfolding g_def g'_def by (intro summable_iff_convergent'[THEN iffD2, THEN summable_LIMSEQ'], blast)
    hence "(\<integral>\<^sup>+ x. g' x \<partial>M) = (\<integral>\<^sup>+ x. liminf (\<lambda>n. g n x) \<partial>M)" by (metis lim_imp_Liminf trivial_limit_sequentially)
    also have "... \<le> liminf (\<lambda>n. \<integral>\<^sup>+ x. g n x \<partial>M)" by (intro nn_integral_liminf, simp add: g_def)
    also have "... \<le> liminf (\<lambda>n. 2)" using integrable_g by (intro Liminf_mono) (simp add: order_le_less)
    also have "... = 2" using sequentially_bot tendsto_iff_Liminf_eq_Limsup by blast
    finally show ?thesis .
  qed
  hence "AE x in M. g' x < \<infinity>" by (intro finite_nn_integral_imp_ae_finite) (auto simp add: order_le_less_trans g'_def)
  moreover have "summable (\<lambda>i. dist (s (r (Suc i)) x) (s (r i) x))" if "g' x \<noteq> \<infinity>" for x using that unfolding g'_def by (intro summable_suminf_not_top, intro zero_le_dist, fastforce) 
  ultimately have ae_summable: "AE x in M. summable (\<lambda>i. s (r (Suc i)) x - s (r i) x)" using summable_norm_cancel unfolding dist_norm by force

  {
    fix x assume "summable (\<lambda>i. s (r (Suc i)) x - s (r i) x)"
    hence "(\<lambda>n. \<Sum>i<n. s (r (Suc i)) x - s (r i) x) \<longlonglongrightarrow> (\<Sum>i. s (r (Suc i)) x - s (r i) x)" using summable_LIMSEQ by blast
    moreover have "(\<lambda>n. (\<Sum>i<n. s (r (Suc i)) x - s (r i) x)) = (\<lambda>n. s (r n) x - s (r 0) x)" using sum_lessThan_telescope by fastforce
    ultimately have "(\<lambda>n. s (r n) x - s (r 0) x) \<longlonglongrightarrow> (\<Sum>i. s (r (Suc i)) x - s (r i) x)" by argo
    hence "(\<lambda>n. s (r n) x - s (r 0) x + s (r 0) x) \<longlonglongrightarrow> (\<Sum>i. s (r (Suc i)) x - s (r i) x) + s (r 0) x" by (intro isCont_tendsto_compose[of _ "\<lambda>z. z + s (r 0) x"], auto)
    hence "Cauchy (\<lambda>n. s (r n) x)" by (simp add: LIMSEQ_imp_Cauchy)
  }

  hence "AE x in M. Cauchy (\<lambda>i. s (r i) x)" using ae_summable by fast
  thus ?thesis by (rule that[OF strict_mono(1)])
qed

(* Eneglking's book General Topology *)
lemma balls_countable_basis:
  obtains D :: "'a :: {metric_space, second_countable_topology} set" 
  where "topological_basis (case_prod ball ` (D \<times> (\<rat> \<inter> {0<..})))"
    and "countable D"
    and "D \<noteq> {}"    
proof -
  obtain D :: "'a set" where dense_subset: "countable D" "D \<noteq> {}" "\<lbrakk>open U; U \<noteq> {}\<rbrakk> \<Longrightarrow> \<exists>y \<in> D. y \<in> U" for U using countable_dense_exists by blast
  have "topological_basis (case_prod ball ` (D \<times> (\<rat> \<inter> {0<..})))"
  proof (intro topological_basis_iff[THEN iffD2], fast, clarify)
    fix U and x :: 'a assume asm: "open U" "x \<in> U"
    obtain e where e: "e > 0" "ball x e \<subseteq> U" using asm openE by blast
    obtain y where y: "y \<in> D" "y \<in> ball x (e / 3)" using dense_subset(3)[OF open_ball, of x "e / 3"] centre_in_ball[THEN iffD2, OF divide_pos_pos[OF e(1), of 3]] by force
    obtain r where r: "r \<in> \<rat> \<inter> {e/3<..<e/2}" unfolding Rats_def using of_rat_dense[OF divide_strict_left_mono[OF _ e(1)], of 2 3] by auto

    have "x \<in> ball y r" using r y by (simp add: dist_commute)
    moreover have "ball y r \<subseteq> U" using r by (intro order_trans[OF _ e(2)], intro ball_trans[OF y(2)], simp)
    moreover have "ball y r \<in> (case_prod ball ` (D \<times> (\<rat> \<inter> {0<..})))" using y(1) r by force
    ultimately show "\<exists>B'\<in>(case_prod ball ` (D \<times> (\<rat> \<inter> {0<..}))). x \<in> B' \<and> B' \<subseteq> U" by meson
  qed
  thus ?thesis using that dense_subset by blast
qed

context sigma_finite_measure
begin

lemma sigma_finite_measure_induct[case_names finite_measure, consumes 0]:
  assumes "\<And>(N :: 'a measure) \<Omega>. finite_measure N 
                              \<Longrightarrow> N = restrict_space M \<Omega>
                              \<Longrightarrow> \<Omega> \<in> sets M 
                              \<Longrightarrow> emeasure N \<Omega> \<noteq> \<infinity> 
                              \<Longrightarrow> emeasure N \<Omega> \<noteq> 0 
                              \<Longrightarrow> almost_everywhere N Q"
      and [measurable]: "Measurable.pred M Q"
  shows "almost_everywhere M Q"
proof -
  have *: "almost_everywhere N Q" if "finite_measure N" "N = restrict_space M \<Omega>" "\<Omega> \<in> sets M" "emeasure N \<Omega> \<noteq> \<infinity>" for N \<Omega> using that by (cases "emeasure N \<Omega> = 0", auto intro: emeasure_0_AE assms(1))

  obtain A :: "nat \<Rightarrow> 'a set" where A: "range A \<subseteq> sets M" "(\<Union>i. A i) = space M" and emeasure_finite: "emeasure M (A i) \<noteq> \<infinity>" for i using sigma_finite by metis
  note A(1)[measurable]
  have space_restr: "space (restrict_space M (A i)) = A i" for i unfolding space_restrict_space by simp
  {
    fix i    
    have *: "{x \<in> A i \<inter> space M. Q x} = {x \<in> space M. Q x} \<inter> (A i)" by fast
    have "Measurable.pred (restrict_space M (A i)) Q" using A by (intro measurableI, auto simp add: space_restr intro!: sets_restrict_space_iff[THEN iffD2], measurable, auto)
  }
  note this[measurable]
  {
    fix i
    have "finite_measure (restrict_space M (A i))" using emeasure_finite by (intro finite_measureI, subst space_restr, subst emeasure_restrict_space, auto)
    hence "emeasure (restrict_space M (A i)) {x \<in> A i. \<not>Q x} = 0" using emeasure_finite by (intro AE_iff_measurable[THEN iffD1, OF _ _ *], measurable, subst space_restr[symmetric], intro sets.top, auto simp add: emeasure_restrict_space)
    hence "emeasure M {x \<in> A i. \<not> Q x} = 0" by (subst emeasure_restrict_space[symmetric], auto)
  }
  hence "emeasure M (\<Union>i. {x \<in> A i. \<not> Q x}) = 0" by (intro emeasure_UN_eq_0, auto)
  moreover have "(\<Union>i. {x \<in> A i. \<not> Q x}) = {x \<in> space M. \<not> Q x}" using A by auto
  ultimately show ?thesis by (intro AE_iff_measurable[THEN iffD2], auto)
qed

(* Real Functional Analysis - Lang*)
lemma averaging_theorem:
  fixes f::"_ \<Rightarrow> 'b::{second_countable_topology, banach}"
  assumes [measurable]:"integrable M f" 
      and closed: "closed S"
      and "\<And>A. A \<in> sets M \<Longrightarrow> measure M A > 0 \<Longrightarrow> (1 / measure M A) *\<^sub>R set_lebesgue_integral M A f \<in> S"
    shows "AE x in M. f x \<in> S"
proof (induct rule: sigma_finite_measure_induct)
  case (finite_measure N \<Omega>)

  interpret finite_measure N by (rule finite_measure)
  
  have integrable[measurable]: "integrable N f" using assms finite_measure by (auto simp: integrable_restrict_space integrable_mult_indicator)
  have average: "(1 / Sigma_Algebra.measure N A) *\<^sub>R set_lebesgue_integral N A f \<in> S" if "A \<in> sets N" "measure N A > 0" for A
  proof -
    have *: "A \<in> sets M" using that by (simp add: sets_restrict_space_iff finite_measure)
    have "A = A \<inter> \<Omega>" by (metis finite_measure(2,3) inf.orderE sets.sets_into_space space_restrict_space that(1))
    hence "set_lebesgue_integral N A f = set_lebesgue_integral M A f" unfolding finite_measure by (subst set_integral_restrict_space, auto simp add: finite_measure set_lebesgue_integral_def indicator_inter_arith[symmetric])
    moreover have "measure N A = measure M A" using that by (auto intro!: measure_restrict_space simp add: finite_measure sets_restrict_space_iff)
    ultimately show ?thesis using that * assms(3) by presburger
  qed

  obtain D :: "'b set" where balls_basis: "topological_basis (case_prod ball ` (D \<times> (\<rat> \<inter> {0<..})))" and countable_D: "countable D" using balls_countable_basis by blast
  have countable_balls: "countable (case_prod ball ` (D \<times> (\<rat> \<inter> {0<..})))" using countable_rat countable_D by blast

  obtain B where B_balls: "B \<subseteq> case_prod ball ` (D \<times> (\<rat> \<inter> {0<..}))" "\<Union>B = -S" using topological_basis[THEN iffD1, OF balls_basis] open_Compl[OF assms(2)] by meson
  hence countable_B: "countable B" using countable_balls countable_subset by fast
  define b where "b = from_nat_into (B \<union> {{}})"
  have "B \<union> {{}} \<noteq> {}" by simp
  have range_b: "range b = B \<union> {{}}" using countable_B by (auto simp add: b_def intro!: range_from_nat_into)
  have open_b: "open (b i)" for i unfolding b_def using B_balls open_ball from_nat_into[of "B \<union> {{}}" i] by force
  have Union_range_b: "\<Union>(range b) = -S" using B_balls range_b by simp

  {
    fix v r assume "r > 0" "ball v r \<subseteq> -S"
    define A where "A = f -` ball v r \<inter> space N"
    have dist_less: "dist (f x) v < r" if "x \<in> A" for x using that unfolding A_def vimage_def by (simp add: dist_commute)
    have *: "A \<in> sets N" unfolding A_def by simp
    have "emeasure N A = 0" 
    proof -
      {
        assume "emeasure N A > 0"
        hence asm: "measure N A > 0" unfolding emeasure_eq_measure by simp
        hence "(1 / measure N A) *\<^sub>R set_lebesgue_integral N A f - v = (1 / measure N A) *\<^sub>R set_lebesgue_integral N A (\<lambda>x. f x - v)" using integrable integrable_const * by (subst set_integral_diff(2), auto simp add: set_integrable_def set_integral_const[OF *] algebra_simps intro!: integrable_mult_indicator)
        moreover have "norm (\<integral>x\<in>A. (f x - v)\<partial>N) \<le> (\<integral>x\<in>A. norm (f x - v)\<partial>N)" using * by (auto intro!: set_integral_norm_bound integrable_mult_indicator integrable simp add: set_integrable_def)
        ultimately have "norm ((1 / measure N A) *\<^sub>R set_lebesgue_integral N A f - v) \<le>  set_lebesgue_integral N A (\<lambda>x. norm (f x - v)) / measure N A" using asm by (auto intro: divide_right_mono)
        also have "... < set_lebesgue_integral N A (\<lambda>x. r) / measure N A" 
          unfolding set_lebesgue_integral_def
          using asm finite_measure * integrable integrable_const
          apply (intro divide_strict_right_mono integral_less_AE_space, auto simp add: integrable_restrict_space intro: integrable_mult_indicator)
          sorry
        have "False" sorry
      }
      thus ?thesis by fastforce
    qed
  }
  note * = this
  {
    fix b' assume "b' \<in> B"
    hence ball_subset_Compl: "b' \<subseteq> -S" and ball_radius_pos: "\<exists>v \<in> D. \<exists>r>0. b' = ball v r" using B_balls by (blast, fast)
  }
  note ** = this
  hence "emeasure N (f -` b i \<inter> space N) = 0" for i by (cases "b i = {}", simp) (metis UnE singletonD  * range_b[THEN eq_refl, THEN range_subsetD])
  hence "emeasure N (\<Union>i. f -` b i \<inter> space N) = 0" using open_b by (intro emeasure_UN_eq_0) fastforce+
  moreover have "(\<Union>i. f -` b i \<inter> space N) = f -` (\<Union>(range b)) \<inter> space N" by blast
  ultimately have "emeasure N (f -` (-S) \<inter> space N) = 0" using Union_range_b by argo
  hence "AE x in N. f x \<notin> -S" using open_Compl[OF assms(2)] by (intro AE_iff_measurable[THEN iffD2], auto)
  thus ?case by force
qed (simp add: pred_sets2[OF borel_closed] assms(2))

lemma density_nonneg_AE:
  fixes f::"_ \<Rightarrow> 'b::{second_countable_topology, banach, ordered_euclidean_space}"
  assumes "integrable M f" 
      and "\<And>A. A \<in> sets M \<Longrightarrow> set_lebesgue_integral M A f \<ge> 0"
  shows "AE x in M. f x \<ge> 0"
  using averaging_theorem[OF assms(1), of "{0..}", OF closed_eucl_atLeast] assms(2)
  sorry

lemma density_0_AE:
  fixes f::"_ \<Rightarrow> 'b::{second_countable_topology, banach}"
  assumes "integrable M f"
      and density_0: "\<And>A. A \<in> sets M \<Longrightarrow> set_lebesgue_integral M A f = 0"
  shows "AE x in M. f x = 0"
  using averaging_theorem[OF assms(1), of "{0}"] assms(2) sorry

lemma density_unique:
  fixes f f'::"_ \<Rightarrow> 'b::{second_countable_topology, banach}"
  assumes "integrable M f" "integrable M f'"
      and density_eq: "\<And>A. A \<in> sets M \<Longrightarrow> set_lebesgue_integral M A f = set_lebesgue_integral M A f'"
  shows "AE x in M. f x = f' x"
proof-
  { 
    fix A assume asm: "A \<in> sets M"
    hence "LINT x|M. indicat_real A x *\<^sub>R (f x - f' x) = 0" using density_eq assms(1,2) by (simp add: set_lebesgue_integral_def algebra_simps Bochner_Integration.integral_diff[OF integrable_mult_indicator(1,1)])
  }
  thus ?thesis using density_0_AE[OF Bochner_Integration.integrable_diff[OF assms(1,2)]] by (simp add: set_lebesgue_integral_def)
qed

end

(* Versions of \<^thm>\<open>Bochner_Integration.integral_mono_AE\<close> for arbitrary orders *)

lemma integral_nonneg_AE_ordered_real_vector:                        
  fixes f :: "'a \<Rightarrow> 'b :: {second_countable_topology, banach, ordered_real_vector}"
  assumes "integrable M f" and nonneg: "AE x in M. 0 \<le> f x"
  shows "0 \<le> integral\<^sup>L M f"
  sorry

lemma integral_mono_AE_ordered_real_vector:
  fixes f :: "'a \<Rightarrow> 'b :: {second_countable_topology, banach, ordered_real_vector}"
  assumes "integrable M f" "integrable M g" "AE x in M. f x \<le> g x"
  shows "integral\<^sup>L M f \<le> integral\<^sup>L M g"
  using integral_nonneg_AE sorry


end