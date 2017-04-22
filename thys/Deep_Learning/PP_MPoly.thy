(* Author: Andreas Lochbihler, ETH Zurich
   Author: Florian Haftmann, TU Muenchen
*)

section \<open>An abstract type for multivariate polynomials\<close>

theory PP_MPoly
imports PP_Poly_Mapping
begin

subsection \<open>Abstract type definition\<close>

typedef (overloaded) 'a mpoly =
  "UNIV :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a::zero) set"
  morphisms mapping_of MPoly
 ..

setup_lifting type_definition_mpoly

(* these theorems are automatically generated by setup_lifting... *)
thm mapping_of_inverse   thm MPoly_inverse
thm mapping_of_inject    thm MPoly_inject
thm mapping_of_induct    thm MPoly_induct
thm mapping_of_cases     thm MPoly_cases


subsection \<open>Additive structure\<close>

instantiation mpoly :: (zero) zero
begin

lift_definition zero_mpoly :: "'a mpoly"
  is "0 :: (nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a" .

instance ..

end

instantiation mpoly :: (monoid_add) monoid_add
begin

lift_definition plus_mpoly :: "'a mpoly \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly"
  is "Groups.plus :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a) \<Rightarrow> _" .

instance
  by intro_classes (transfer, simp add: fun_eq_iff add.assoc)+

end

instance mpoly :: (comm_monoid_add) comm_monoid_add
  by intro_classes (transfer, simp add: fun_eq_iff ac_simps)+

instantiation mpoly :: (cancel_comm_monoid_add) cancel_comm_monoid_add
begin

lift_definition minus_mpoly :: "'a mpoly \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly"
  is "Groups.minus :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a) \<Rightarrow> _" .

instance
  by intro_classes (transfer, simp add: fun_eq_iff diff_diff_add)+

end

instantiation mpoly :: (ab_group_add) ab_group_add
begin

lift_definition uminus_mpoly :: "'a mpoly \<Rightarrow> 'a mpoly"
  is "Groups.uminus :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a) \<Rightarrow> _" .


instance
  by intro_classes (transfer, simp add: fun_eq_iff add_uminus_conv_diff)+

end


subsection \<open>Multiplication by a coefficient\<close>
(* ?do we need inc_power on abstract polynomials? *)

lift_definition smult :: "'a::{times,zero} \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly"
  is "\<lambda>a. PP_Poly_Mapping.map (Groups.times a) :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a) \<Rightarrow> _" .

(* left lemmas in subsection \<open>Pseudo-division of polynomials\<close>,
   because I couldn't disentangle them and the notion of monomials. *)

subsection \<open>Multiplicative structure\<close>

instantiation mpoly :: (zero_neq_one) zero_neq_one
begin

lift_definition one_mpoly :: "'a mpoly"
  is "1 :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a)" .

instance
  by intro_classes (transfer, simp)

end

instantiation mpoly :: (semiring_0) semiring_0
begin

lift_definition times_mpoly :: "'a mpoly \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly"
  is "Groups.times :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a) \<Rightarrow> _" .

instance
  by intro_classes (transfer, simp add: algebra_simps)+

end

instance mpoly :: (comm_semiring_0) comm_semiring_0
  by intro_classes (transfer, simp add: algebra_simps)+

instance mpoly :: (semiring_0_cancel) semiring_0_cancel
  ..

instance mpoly :: (comm_semiring_0_cancel) comm_semiring_0_cancel
  ..

instance mpoly :: (semiring_1) semiring_1
  by intro_classes (transfer, simp)+

instance mpoly :: (comm_semiring_1) comm_semiring_1
  by intro_classes (transfer, simp)+

instance mpoly :: (semiring_1_cancel) semiring_1_cancel
  ..

(*instance mpoly :: (comm_semiring_1_cancel) comm_semiring_1_cancel
  .. FIXME unclear whether this holds *)

instance mpoly :: (ring) ring
  ..

instance mpoly :: (comm_ring) comm_ring
  ..

instance mpoly :: (ring_1) ring_1
  ..

instance mpoly :: (comm_ring_1) comm_ring_1
  ..


subsection \<open>Monomials\<close>

text \<open>
  Terminology is not unique here, so we use the notions as follows:
  A "monomial" and a "coefficient" together give a "term".
  These notions are significant in connection with "leading",
  "leading term", "leading coefficient" and "leading monomial",
  which all rely on a monomial order.
\<close>

lift_definition monom :: "(nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow> 'a::zero \<Rightarrow> 'a mpoly"
  is "PP_Poly_Mapping.single :: (nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow> _" .
    
lemma mapping_of_monom [simp]:
  "mapping_of (monom m a) = PP_Poly_Mapping.single m a"
  by(fact monom.rep_eq)

lemma monom_zero [simp]:
  "monom 0 0 = 0"
  by transfer simp

lemma monom_one [simp]:
  "monom 0 1 = 1"
  by transfer simp

lemma monom_add:
  "monom m (a + b) = monom m a + monom m b"
  by transfer (simp add: single_add)

lemma monom_uminus:
  "monom m (- a) = - monom m a"
  by transfer (simp add: single_uminus)

lemma monom_diff:
  "monom m (a - b) = monom m a - monom m b"
  by transfer (simp add: single_diff)

lemma monom_numeral [simp]:
  "monom 0 (numeral n) = numeral n"
  by (induct n) (simp_all only: numeral.simps numeral_add monom_zero monom_one monom_add)

lemma monom_of_nat [simp]:
  "monom 0 (of_nat n) = of_nat n"
  by (induct n) (simp_all add: monom_add)

lemma of_nat_monom:
  "of_nat = monom 0 \<circ> of_nat"
  by (simp add: fun_eq_iff)

lemma inj_monom [iff]:
  "inj (monom m)"
proof (rule injI, transfer)
  fix a b :: 'a and m :: "nat \<Rightarrow>\<^sub>0 nat"
  assume "PP_Poly_Mapping.single m a = PP_Poly_Mapping.single m b"
  with injD [of "PP_Poly_Mapping.single m" a b]
  show "a = b" by simp
qed

lemma mult_monom: "monom x a * monom y b = monom (x + y) (a * b)"
by transfer (simp add: PP_Poly_Mapping.mult_single)
  -- \<open>FIXME: why does transfer need so much backtracking until it finds the right goal?\<close>

instance mpoly :: (semiring_char_0) semiring_char_0
  by intro_classes (auto simp add: of_nat_monom inj_of_nat intro: inj_comp)

instance mpoly :: (ring_char_0) ring_char_0
  ..

lemma monom_of_int [simp]:
  "monom 0 (of_int k) = of_int k"
  apply (cases k)
  apply simp_all
  unfolding monom_diff monom_uminus
  apply simp
  done


subsection \<open>Integral domains\<close>

instance mpoly :: (ring_no_zero_divisors) ring_no_zero_divisors
  by intro_classes (transfer, simp)

instance mpoly :: (ring_1_no_zero_divisors) ring_1_no_zero_divisors
  ..

instance mpoly :: (idom) idom
  ..


subsection \<open>Monom coefficient lookup\<close>

definition coeff :: "'a::zero mpoly \<Rightarrow> (nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow> 'a"
where
  "coeff p = PP_Poly_Mapping.lookup (mapping_of p)"


subsection \<open>Insertion morphism\<close>

definition insertion_fun_natural :: "(nat \<Rightarrow> 'a) \<Rightarrow> ((nat \<Rightarrow> nat) \<Rightarrow> 'a) \<Rightarrow> 'a::comm_semiring_1"
where
  "insertion_fun_natural f p = (\<Sum>m. p m * (\<Prod>v. f v ^ m v))"

definition insertion_fun :: "(nat \<Rightarrow> 'a) \<Rightarrow> ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow> 'a) \<Rightarrow> 'a::comm_semiring_1"
where
  "insertion_fun f p = (\<Sum>m. p m * (\<Prod>v. f v ^ PP_Poly_Mapping.lookup m v))"

text \<open>N.b. have been unable to relate this to @{const insertion_fun_natural} using lifting!\<close>

lift_definition insertion_aux :: "(nat \<Rightarrow> 'a) \<Rightarrow> ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a) \<Rightarrow> 'a::comm_semiring_1"
  is "insertion_fun" .

lift_definition insertion :: "(nat \<Rightarrow> 'a) \<Rightarrow> 'a mpoly \<Rightarrow> 'a::comm_semiring_1"
  is "insertion_aux" .

lemma aux:
  "PP_Poly_Mapping.lookup f = (\<lambda>_. 0) \<longleftrightarrow> f = 0"
  apply transfer apply simp done

lemma insertion_trivial [simp]:
  "insertion (\<lambda>_. 0) p = coeff p 0"
proof -
  { fix f :: "(nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a"
    have "insertion_aux (\<lambda>_. 0) f = PP_Poly_Mapping.lookup f 0"
      apply (simp add: insertion_aux_def insertion_fun_def power_Sum_any [symmetric])
      apply (simp add: zero_power_eq mult_when aux)
      done
  }
  then show ?thesis by (simp add: coeff_def insertion_def)
qed

lemma insertion_zero [simp]:
  "insertion f 0 = 0"
  by transfer (simp add: insertion_aux_def insertion_fun_def)

lemma insertion_fun_add:
  fixes f p q
  shows "insertion_fun f (PP_Poly_Mapping.lookup (p + q)) =
    insertion_fun f (PP_Poly_Mapping.lookup p) +
      insertion_fun f (PP_Poly_Mapping.lookup q)"
  unfolding insertion_fun_def
  apply (subst Sum_any.distrib [symmetric])
  apply (simp_all add: plus_poly_mapping.rep_eq algebra_simps)
  apply (rule finite_mult_not_eq_zero_rightI)
  apply simp
  apply (rule finite_mult_not_eq_zero_rightI)
  apply simp
  done

lemma insertion_add:
  "insertion f (p + q) = insertion f p + insertion f q"
  by transfer (simp add: insertion_aux_def insertion_fun_add)

lemma insertion_one [simp]:
  "insertion f 1 = 1"
  by transfer (simp add: insertion_aux_def insertion_fun_def one_poly_mapping.rep_eq when_mult)

lemma insertion_fun_mult:
  fixes f p q
  shows "insertion_fun f (PP_Poly_Mapping.lookup (p * q)) =
    insertion_fun f (PP_Poly_Mapping.lookup p) *
      insertion_fun f (PP_Poly_Mapping.lookup q)"
proof -
  { fix m :: "nat \<Rightarrow>\<^sub>0 nat"
    have "finite {v. PP_Poly_Mapping.lookup m v \<noteq> 0}"
      by simp
    then have "finite {v. f v ^ PP_Poly_Mapping.lookup m v \<noteq> 1}"
      by (rule rev_finite_subset) (auto intro: ccontr)
  }
  moreover def g \<equiv> "\<lambda>m. (\<Prod>v. f v ^ PP_Poly_Mapping.lookup m v)"
  ultimately have *: "\<And>a b. g (a + b) = g a * g b"
    by (simp add: plus_poly_mapping.rep_eq power_add Prod_any.distrib)
  have bij: "bij (\<lambda>(l, n, m). (m, l, n))"
    by (auto intro!: bijI injI simp add: image_def)
  let ?P = "{l. PP_Poly_Mapping.lookup p l \<noteq> 0}"
  let ?Q = "{n. PP_Poly_Mapping.lookup q n \<noteq> 0}"
  let ?PQ = "{l + n | l n. l \<in> PP_Poly_Mapping.keys p \<and> n \<in> PP_Poly_Mapping.keys q}"
  have "finite {l + n | l n. PP_Poly_Mapping.lookup p l \<noteq> 0 \<and> PP_Poly_Mapping.lookup q n \<noteq> 0}"
    by (rule finite_not_eq_zero_sumI) simp_all
  then have fin_PQ: "finite ?PQ"
    by simp
  have "(\<Sum>m. PP_Poly_Mapping.lookup (p * q) m * g m) =
    (\<Sum>m. (\<Sum>l. PP_Poly_Mapping.lookup p l * (\<Sum>n. PP_Poly_Mapping.lookup q n when m = l + n)) * g m)"
    by (simp add: times_poly_mapping.rep_eq prod_fun_def)
  also have "\<dots> = (\<Sum>m. (\<Sum>l. (\<Sum>n. g m * (PP_Poly_Mapping.lookup p l * PP_Poly_Mapping.lookup q n) when m = l + n)))"
    apply (subst Sum_any_left_distrib)
    apply (auto intro: finite_mult_not_eq_zero_rightI)
    apply (subst Sum_any_right_distrib)
    apply (auto intro: finite_mult_not_eq_zero_rightI)
    apply (subst Sum_any_left_distrib)
    apply (auto intro: finite_mult_not_eq_zero_leftI)
    apply (simp add: ac_simps mult_when)
    done
  also have "\<dots> = (\<Sum>m. (\<Sum>(l, n). g m * (PP_Poly_Mapping.lookup p l * PP_Poly_Mapping.lookup q n) when m = l + n))"
    apply (subst (2) Sum_any.cartesian_product [of "?P \<times> ?Q"])
    apply (auto dest!: mult_not_zero)
    done
  also have "\<dots> = (\<Sum>(m, l, n). g m * (PP_Poly_Mapping.lookup p l * PP_Poly_Mapping.lookup q n) when m = l + n)"
    apply (subst Sum_any.cartesian_product [of "?PQ \<times> (?P \<times> ?Q)"])
    apply (auto dest!: mult_not_zero simp add: fin_PQ)
    apply auto
    done
  also have "\<dots> = (\<Sum>(l, n, m). g m * (PP_Poly_Mapping.lookup p l * PP_Poly_Mapping.lookup q n) when m = l + n)"
    using bij by (rule Sum_any.reindex_cong [of "\<lambda>(l, n, m). (m, l, n)"]) (simp add: fun_eq_iff)
  also have "\<dots> = (\<Sum>(l, n). \<Sum>m. g m * (PP_Poly_Mapping.lookup p l * PP_Poly_Mapping.lookup q n) when m = l + n)"
    apply (subst Sum_any.cartesian_product2 [of "(?P \<times> ?Q) \<times> ?PQ"])
    apply (auto dest!: mult_not_zero simp add: fin_PQ )
    apply auto
    done
  also have "\<dots> = (\<Sum>(l, n). (g l * g n) * (PP_Poly_Mapping.lookup p l * PP_Poly_Mapping.lookup q n))"
    by (simp add: *)
  also have "\<dots> = (\<Sum>l. \<Sum>n. (g l * g n) * (PP_Poly_Mapping.lookup p l * PP_Poly_Mapping.lookup q n))"
    apply (subst Sum_any.cartesian_product [of "?P \<times> ?Q"])
    apply (auto dest!: mult_not_zero)
    done
  also have "\<dots> = (\<Sum>l. \<Sum>n. (PP_Poly_Mapping.lookup p l * g l) * (PP_Poly_Mapping.lookup q n * g n))"
    by (simp add: ac_simps)
  also have "\<dots> =
    (\<Sum>m. PP_Poly_Mapping.lookup p m * g m) *
    (\<Sum>m. PP_Poly_Mapping.lookup q m * g m)"
    by (rule Sum_any_product [symmetric]) (auto intro: finite_mult_not_eq_zero_rightI)
  finally show ?thesis by (simp add: insertion_fun_def g_def)
qed

lemma insertion_mult:
  "insertion f (p * q) = insertion f p * insertion f q"
  by transfer (simp add: insertion_aux_def insertion_fun_mult)


subsection \<open>Degree\<close>

lift_definition degree :: "'a::zero mpoly \<Rightarrow> nat \<Rightarrow> nat"
is "\<lambda>p v. Max (insert 0 ((\<lambda>m. PP_Poly_Mapping.lookup m v) ` PP_Poly_Mapping.keys p))" .


lift_definition total_degree :: "'a::zero mpoly \<Rightarrow> nat"
is "\<lambda>p. Max (insert 0 ((\<lambda>m. sum (PP_Poly_Mapping.lookup m) (PP_Poly_Mapping.keys m)) ` PP_Poly_Mapping.keys p))" .

lemma degree_zero [simp]:
  "degree 0 v = 0"
  by transfer simp

lemma total_degree_zero [simp]:
  "total_degree 0 = 0"
  by transfer simp
(*
value [code] "total_degree (0 :: int mpoly)" (***)
*)

lemma degree_one [simp]:
  "degree 1 v = 0"
  by transfer simp

lemma total_degree_one [simp]:
  "total_degree 1 = 0"
  by transfer simp

subsection \<open>Pseudo-division of polynomials\<close>

lemma smult_conv_mult: "smult s p = monom 0 s * p"
by transfer (simp add: mult_map_scale_conv_mult)

lemma smult_monom [simp]:
  fixes c :: "_ :: mult_zero"
  shows "smult c (monom x c') = monom x (c * c')"
by transfer simp

lemma smult_0 [simp]:
  fixes p :: "_ :: mult_zero mpoly"
  shows "smult 0 p = 0"
by transfer(simp add: map_eq_zero_iff)

lemma mult_smult_left: "smult s p * q = smult s (p * q)"
by(simp add: smult_conv_mult mult.assoc)

lift_definition sdiv :: "'a::ring_div \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly"
  is "\<lambda>a. PP_Poly_Mapping.map (\<lambda>b. b div a) :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a) \<Rightarrow> _"
.
text \<open>
  \qt{Polynomial division} is only possible on univariate polynomials @{text "K[x]"}
  over a field @{text K}, all other kinds of polynomials only allow pseudo-division
  [1]p.40/41":

  @{text "\<forall>x y :: 'a mpoly. y \<noteq> 0 \<Rightarrow> \<exists>a q r. smult a x = q * y + r"}

  The introduction of pseudo-division below generalises @{file "~~/src/HOL/Computational_Algebra/Polynomial.thy"}.
  [1] Winkler, Polynomial Algorithms, 1996.
  The generalisation raises issues addressed by Wenda Li and commented below.
  Florian replied to the issues conjecturing, that the abstract mpoly needs not
  be aware of the issues, in case these are only concerned with executability.
\<close>

definition pseudo_divmod_rel
  :: "'a::ring_div => 'a mpoly => 'a mpoly => 'a mpoly => 'a mpoly => bool"
where
  "pseudo_divmod_rel a x y q r \<longleftrightarrow>
    smult a x = q * y + r \<and> (if y = 0 then q = 0 else r = 0 \<or> degree r < degree y)"
(* the notion of degree resigns a main variable in multivariate polynomials;
   also, there are infinitely many tuples (a,q,r) such that a x = q y + r *)

definition pdiv :: "'a::ring_div mpoly \<Rightarrow> 'a mpoly \<Rightarrow> ('a \<times> 'a mpoly)" (infixl "pdiv" 70)
where
  "x pdiv y = (THE (a, q). \<exists>r. pseudo_divmod_rel a x y q r)"

definition pmod :: "'a::ring_div mpoly \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly" (infixl "pmod" 70)
where
  "x pmod y = (THE r. \<exists>a q. pseudo_divmod_rel a x y q r)"

definition pdivmod :: "'a::ring_div mpoly \<Rightarrow> 'a mpoly \<Rightarrow> ('a \<times> 'a mpoly) \<times> 'a mpoly"
where
  "pdivmod p q = (p pdiv q, p pmod q)"

(* "_code" seems inappropriate, since "THE" in definitions pdiv and pmod is not unique,
   see comment to definition pseudo_divmod_rel; so this cannot be executable ... *)
lemma pdiv_code:
  "p pdiv q = fst (pdivmod p q)"
  by (simp add: pdivmod_def)

lemma pmod_code:
  "p pmod q = snd (pdivmod p q)"
  by (simp add: pdivmod_def)

(*TODO ERROR: Ambiguous input produces n parse trees ???...*)
definition div :: "'a::{ring_div,field} mpoly \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly" (infixl "div" 70)
where
  "x div y = (THE q'. \<exists>a q r. (pseudo_divmod_rel a x y q r) \<and> (q' = smult (inverse a) q))"

definition mod :: "'a::{ring_div,field} mpoly \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly" (infixl "mod" 70)
where
  "x mod y = (THE r'. \<exists>a q r. (pseudo_divmod_rel a x y q r) \<and> (r' = smult (inverse a) r))"

definition divmod :: "'a::{ring_div,field} mpoly \<Rightarrow> 'a mpoly \<Rightarrow> 'a mpoly \<times> 'a mpoly"
where
  "divmod p q = (p div q, p mod q)"

lemma div_poly_code:
  "p div q = fst (divmod p q)"
  by (simp add: divmod_def)

lemma mod_poly_code:
  "p mod q = snd (divmod p q)"
  by (simp add: divmod_def)

subsection \<open>Primitive poly, etc\<close>

lift_definition coeffs :: "'a :: zero mpoly \<Rightarrow> 'a set"
is "PP_Poly_Mapping.range :: ((nat \<Rightarrow>\<^sub>0 nat) \<Rightarrow>\<^sub>0 'a) \<Rightarrow> _" .

lemma finite_coeffs [simp]: "finite (coeffs p)"
by transfer simp

text \<open>[1]p.82
  A "primitive'" polynomial has coefficients with GCD equal to 1.
  A polynomial is factored into "content" and "primitive part"
  for many different purposes.\<close>

definition primitive :: "'a::{ring_div,semiring_Gcd} mpoly \<Rightarrow> bool"
where
  "primitive p \<longleftrightarrow> Gcd (coeffs p) = 1"

definition content_primitive :: "'a::{ring_div,GCD.Gcd} mpoly \<Rightarrow> 'a \<times> 'a mpoly"
where
  "content_primitive p = (
    let d = Gcd (coeffs p)
    in (d, sdiv d p))"

value "let p = M [1,2,3] (4::int) + M [2,0,4] 6 + M [2,0,5] 8
  in content_primitive p"


end
