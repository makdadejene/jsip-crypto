open! Core

let ordinary_least_squares dataset =
  let x_data, y_data =
    ( Array.of_list (List.map dataset ~f:(fun data_tuple -> fst data_tuple))
    , Array.of_list (List.map dataset ~f:(fun data_tuple -> snd data_tuple))
    )
  in
  let x_mean, y_mean =
    Owl_base_stats.mean x_data, Owl_base_stats.mean y_data
  in
  let s_xy, s_xx =
    ( List.fold dataset ~init:0. ~f:(fun sum data_tuple ->
        let x, y = data_tuple in
        ((x -. x_mean) *. (y -. y_mean)) +. sum)
    , List.fold dataset ~init:0. ~f:(fun sum data_tuple ->
        let x, _ = data_tuple in
        ((x -. x_mean) *. (x -. x_mean)) +. sum) )
  in
  let weight = s_xy /. s_xx in
  let bias = y_mean -. (weight *. x_mean) in
  weight, bias
;;

let%expect_test "least_squares1" =
  let dataset = [ 1., 1.; 2., 2.; 3., 3.; 4., 4.; 5., 5.; 6., 6. ] in
  let weight, bias = ordinary_least_squares dataset in
  print_s [%message (weight : float) (bias : float)];
  [%expect {|
    ((weight 1) (bias 0))
      |}]
;;
