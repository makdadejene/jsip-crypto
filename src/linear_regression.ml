open! Core

let ordinary_least_squares dataset =
  let x_data, y_data =
    ( Array.of_list (List.map dataset ~f:(fun data_tuple -> fst data_tuple))
    , Array.of_list (List.map dataset ~f:(fun data_tuple -> snd data_tuple))
    )
  in
  let x_mean, y_mean = Owl_base_stats.mean x_data, Owl_base_stats.mean y_data in 
  let x_std, y_std = Owl_base_stats.std ~mean:x_mean x_data, Owl_base_stats.std ~mean:y_mean y_data in
  let r = () in
  let weight = y_std /. x_std in 
  let bias = () in 
  weight, bias
;;