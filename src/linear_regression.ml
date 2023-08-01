open! Core

let ordinary_least_squares dataset =
  let x_data, y_data =
    ( Array.of_list (List.map dataset ~f:(fun data_tuple -> fst data_tuple))
    , Array.of_list (List.map dataset ~f:(fun data_tuple -> snd data_tuple))
    )
  in
  let x_mean = Owl_base_stats.std x_data in
  let y_mean = Owl_base_stats.std y_data in 
  
;;