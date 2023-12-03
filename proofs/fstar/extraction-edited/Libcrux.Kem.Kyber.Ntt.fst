module Libcrux.Kem.Kyber.Ntt
#set-options "--fuel 0 --ifuel 1 --z3rlimit 15"
open Core
open FStar.Mul

let v_ZETAS_TIMES_MONTGOMERY_R: t_Array i32 (sz 128) =
  let list =
    [
      (-1044l); (-758l); (-359l); (-1517l); 1493l; 1422l; 287l; 202l; (-171l); 622l; 1577l; 182l;
      962l; (-1202l); (-1474l); 1468l; 573l; (-1325l); 264l; 383l; (-829l); 1458l; (-1602l); (-130l);
      (-681l); 1017l; 732l; 608l; (-1542l); 411l; (-205l); (-1571l); 1223l; 652l; (-552l); 1015l;
      (-1293l); 1491l; (-282l); (-1544l); 516l; (-8l); (-320l); (-666l); (-1618l); (-1162l); 126l;
      1469l; (-853l); (-90l); (-271l); 830l; 107l; (-1421l); (-247l); (-951l); (-398l); 961l;
      (-1508l); (-725l); 448l; (-1065l); 677l; (-1275l); (-1103l); 430l; 555l; 843l; (-1251l); 871l;
      1550l; 105l; 422l; 587l; 177l; (-235l); (-291l); (-460l); 1574l; 1653l; (-246l); 778l; 1159l;
      (-147l); (-777l); 1483l; (-602l); 1119l; (-1590l); 644l; (-872l); 349l; 418l; 329l; (-156l);
      (-75l); 817l; 1097l; 603l; 610l; 1322l; (-1285l); (-1465l); 384l; (-1215l); (-136l); 1218l;
      (-1335l); (-874l); 220l; (-1187l); (-1659l); (-1185l); (-1530l); (-1278l); 794l; (-1510l);
      (-854l); (-870l); 478l; (-108l); (-308l); 996l; 991l; 958l; (-1460l); 1522l; 1628l
    ]
  in
  FStar.Pervasives.assert_norm (Prims.eq2 (List.Tot.length list) 128);
  Rust_primitives.Hax.array_of_list list

let ntt_multiply_binomials (a0, a1: (i32 & i32)) (b0, b1: (i32 & i32)) (zeta: i32) : (i32 & i32) =
  admit(); // Needs preconditions on ranges of all inputs
  Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce ((a0 *! b0 <: i32) +!
      ((Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce (a1 *! b1 <: i32) <: i32) *! zeta <: i32)
      <:
      i32),
  Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce ((a0 *! b1 <: i32) +! (a1 *! b0 <: i32) <: i32)
  <:
  (i32 & i32)

let invert_ntt_montgomery (v_K: usize) (re: Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement) =
  let _:Prims.unit = () <: Prims.unit in
  let zeta_i:usize = Libcrux.Kem.Kyber.Constants.v_COEFFICIENTS_IN_RING_ELEMENT /! sz 2 in
  let step:usize = sz 1 <<! 1l in
  admit(); // Needs many preconditions and is too big, break it up.
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          assume (zeta_i >. sz 1);
          let round:usize = round in
          let zeta_i:usize = zeta_i -! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let a_minus_b:i32 =
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ] <: i32) -!
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +!
                          (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                            <:
                            i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        (Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce (a_minus_b *!
                              (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                              <:
                              i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let step:usize = sz 1 <<! 2l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i -! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let a_minus_b:i32 =
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ] <: i32) -!
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +!
                          (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                            <:
                            i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        (Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce (a_minus_b *!
                              (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                              <:
                              i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let step:usize = sz 1 <<! 3l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i -! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let a_minus_b:i32 =
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ] <: i32) -!
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +!
                          (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                            <:
                            i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        (Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce (a_minus_b *!
                              (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                              <:
                              i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let step:usize = sz 1 <<! 4l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i -! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let a_minus_b:i32 =
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ] <: i32) -!
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +!
                          (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                            <:
                            i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        (Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce (a_minus_b *!
                              (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                              <:
                              i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let step:usize = sz 1 <<! 5l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i -! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let a_minus_b:i32 =
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ] <: i32) -!
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +!
                          (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                            <:
                            i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        (Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce (a_minus_b *!
                              (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                              <:
                              i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let step:usize = sz 1 <<! 6l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i -! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let a_minus_b:i32 =
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ] <: i32) -!
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +!
                          (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                            <:
                            i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        (Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce (a_minus_b *!
                              (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                              <:
                              i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let step:usize = sz 1 <<! 7l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i -! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let a_minus_b:i32 =
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ] <: i32) -!
                    (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +!
                          (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                            <:
                            i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        (Libcrux.Kem.Kyber.Arithmetic.montgomery_reduce (a_minus_b *!
                              (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                              <:
                              i32)
                          <:
                          i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let _:Prims.unit = () <: Prims.unit in
  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 8
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      re
      (fun re i ->
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
          let i:usize = i in
          {
            re with
            Libcrux.Kem.Kyber.Arithmetic.f_coefficients
            =
            Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              i
              (Libcrux.Kem.Kyber.Arithmetic.barrett_reduce (re
                      .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ i ]
                    <:
                    i32)
                <:
                i32)
            <:
            t_Array i32 (sz 256)
          }
          <:
          Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement)
  in
  re

let ntt_binomially_sampled_ring_element (re: Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement) =
  let _:Prims.unit = () <: Prims.unit in
  let zeta_i:usize = sz 0 in
  let zeta_i:usize = zeta_i +! sz 1 in
  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      re
      (fun re j ->
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
          let j:usize = j in
          assume (range (v #i32_inttype re.f_coefficients.[j +! sz 128] * (-1600)) i32_inttype);
          let t:i32 =
            (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! sz 128 <: usize ] <: i32) *!
            (-1600l)
          in
          assume (range (v #i32_inttype re.f_coefficients.[j] - v t) i32_inttype);
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            {
              re with
              Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              =
              Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                  .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                (j +! sz 128 <: usize)
                ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
            }
            <:
            Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
          in
          assume (range (v #i32_inttype re.f_coefficients.[j] + v t) i32_inttype);
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            {
              re with
              Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              =
              Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                  .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                j
                ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
            }
            <:
            Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
          in
          re)
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 6l in
  admit(); // Too big, break up.
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          assume (v zeta_i < maxint usize_inttype);
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 5l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 4l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 3l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 2l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 1l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = Libcrux.Kem.Kyber.Constants.v_COEFFICIENTS_IN_RING_ELEMENT
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      re
      (fun re i ->
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
          let i:usize = i in
          {
            re with
            Libcrux.Kem.Kyber.Arithmetic.f_coefficients
            =
            Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              i
              (Libcrux.Kem.Kyber.Arithmetic.barrett_reduce (re
                      .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ i ]
                    <:
                    i32)
                <:
                i32)
            <:
            t_Array i32 (sz 256)
          }
          <:
          Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement)
  in
  re

let ntt_multiply (lhs rhs: Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement) =
  let _:Prims.unit = () <: Prims.unit in
  let out:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
    Libcrux.Kem.Kyber.Arithmetic.impl__PolynomialRingElement__ZERO
  in
  let out:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end
              =
              Libcrux.Kem.Kyber.Constants.v_COEFFICIENTS_IN_RING_ELEMENT /! sz 4 <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      out
      (fun out i ->
          let out:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = out in
          let i:usize = i in
          assume (v i * 4 + 4 <= 256);
          let product:(i32 & i32) =
            ntt_multiply_binomials ((lhs.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ sz 4 *! i
                    <:
                    usize ]
                  <:
                  i32),
                (lhs.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ (sz 4 *! i <: usize) +! sz 1
                    <:
                    usize ]
                  <:
                  i32)
                <:
                (i32 & i32))
              ((rhs.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ sz 4 *! i <: usize ] <: i32),
                (rhs.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ (sz 4 *! i <: usize) +! sz 1
                    <:
                    usize ]
                  <:
                  i32)
                <:
                (i32 & i32))
              (v_ZETAS_TIMES_MONTGOMERY_R.[ sz 64 +! i <: usize ] <: i32)
          in
          let out:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            {
              out with
              Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              =
              Rust_primitives.Hax.Monomorphized_update_at.update_at_usize out
                  .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                (sz 4 *! i <: usize)
                product._1
            }
            <:
            Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
          in
          let out:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            {
              out with
              Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              =
              Rust_primitives.Hax.Monomorphized_update_at.update_at_usize out
                  .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                ((sz 4 *! i <: usize) +! sz 1 <: usize)
                product._2
            }
            <:
            Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
          in
          let product:(i32 & i32) =
            ntt_multiply_binomials ((lhs.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ (sz 4 *! i
                      <:
                      usize) +!
                    sz 2
                    <:
                    usize ]
                  <:
                  i32),
                (lhs.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ (sz 4 *! i <: usize) +! sz 3
                    <:
                    usize ]
                  <:
                  i32)
                <:
                (i32 & i32))
              ((rhs.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ (sz 4 *! i <: usize) +! sz 2
                    <:
                    usize ]
                  <:
                  i32),
                (rhs.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ (sz 4 *! i <: usize) +! sz 3
                    <:
                    usize ]
                  <:
                  i32)
                <:
                (i32 & i32))
              (Core.Ops.Arith.Neg.neg (v_ZETAS_TIMES_MONTGOMERY_R.[ sz 64 +! i <: usize ] <: i32)
                <:
                i32)
          in
          let out:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            {
              out with
              Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              =
              Rust_primitives.Hax.Monomorphized_update_at.update_at_usize out
                  .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                ((sz 4 *! i <: usize) +! sz 2 <: usize)
                product._1
            }
            <:
            Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
          in
          let out:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            {
              out with
              Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              =
              Rust_primitives.Hax.Monomorphized_update_at.update_at_usize out
                  .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                ((sz 4 *! i <: usize) +! sz 3 <: usize)
                product._2
            }
            <:
            Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
          in
          out)
  in
  out

let ntt_vector_u
      (v_VECTOR_U_COMPRESSION_FACTOR: usize)
      (re: Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement)
    : Prims.Pure Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
      (requires
        Hax_lib.v_forall (fun i ->
              let i:usize = i in
              Hax_lib.implies (i <.
                  (Core.Slice.impl__len (Rust_primitives.unsize re
                            .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        <:
                        t_Slice i32)
                    <:
                    usize)
                  <:
                  bool)
                (fun _ -> (Core.Num.impl__i32__abs (re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ i ]
                        <:
                        i32)
                    <:
                    i32) <=.
                  3328l
                  <:
                  bool)
              <:
              bool))
      (ensures
        fun result ->
          let result:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = result in
          Hax_lib.v_forall (fun i ->
                let i:usize = i in
                Hax_lib.implies (i <.
                    (Core.Slice.impl__len (Rust_primitives.unsize result
                              .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                          <:
                          t_Slice i32)
                      <:
                      usize)
                    <:
                    bool)
                  (fun _ -> (Core.Num.impl__i32__abs (result.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ i
                          ]
                          <:
                          i32)
                      <:
                      i32) <.
                    Libcrux.Kem.Kyber.Constants.v_FIELD_MODULUS
                    <:
                    bool)
                <:
                bool)) =
  let _:Prims.unit = () <: Prims.unit in
  let zeta_i:usize = sz 0 in
  let step:usize = sz 1 <<! 7l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 6l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 5l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 4l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 3l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 2l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let step:usize = sz 1 <<! 1l in
  let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = sz 128 /! step <: usize
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      (re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
      (fun temp_0_ round ->
          let re, zeta_i:(Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize) = temp_0_ in
          let round:usize = round in
          let zeta_i:usize = zeta_i +! sz 1 in
          let offset:usize = (round *! step <: usize) *! sz 2 in
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
            Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
                      Core.Ops.Range.f_start = offset;
                      Core.Ops.Range.f_end = offset +! step <: usize
                    }
                    <:
                    Core.Ops.Range.t_Range usize)
                <:
                Core.Ops.Range.t_Range usize)
              re
              (fun re j ->
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
                  let j:usize = j in
                  let t:i32 =
                    Libcrux.Kem.Kyber.Arithmetic.montgomery_multiply_sfe_by_fer (re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j +! step <: usize ]
                        <:
                        i32)
                      (v_ZETAS_TIMES_MONTGOMERY_R.[ zeta_i ] <: i32)
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        (j +! step <: usize)
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) -! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
                    {
                      re with
                      Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                      =
                      Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                          .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
                        j
                        ((re.Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ j ] <: i32) +! t <: i32)
                    }
                    <:
                    Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement
                  in
                  re)
          in
          re, zeta_i <: (Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement & usize))
  in
  let _:Prims.unit = () <: Prims.unit in
  let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement =
    Core.Iter.Traits.Iterator.f_fold (Core.Iter.Traits.Collect.f_into_iter ({
              Core.Ops.Range.f_start = sz 0;
              Core.Ops.Range.f_end = Libcrux.Kem.Kyber.Constants.v_COEFFICIENTS_IN_RING_ELEMENT
            }
            <:
            Core.Ops.Range.t_Range usize)
        <:
        Core.Ops.Range.t_Range usize)
      re
      (fun re i ->
          let re:Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement = re in
          let i:usize = i in
          {
            re with
            Libcrux.Kem.Kyber.Arithmetic.f_coefficients
            =
            Rust_primitives.Hax.Monomorphized_update_at.update_at_usize re
                .Libcrux.Kem.Kyber.Arithmetic.f_coefficients
              i
              (Libcrux.Kem.Kyber.Arithmetic.barrett_reduce (re
                      .Libcrux.Kem.Kyber.Arithmetic.f_coefficients.[ i ]
                    <:
                    i32)
                <:
                i32)
            <:
            t_Array i32 (sz 256)
          }
          <:
          Libcrux.Kem.Kyber.Arithmetic.t_PolynomialRingElement)
  in
  re
