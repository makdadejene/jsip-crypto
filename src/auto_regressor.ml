open! Core
open! Owl_base

module Prediction = struct
  type t =
    { date : Types.Date.t
    ; price : int
    }
end

module Hyperparameters = struct
  type t =
    { constant_term : int
    ; regression_of_previous_val : int
    ; model_residual : int
    }

  let get_constant_term t = t.constant_term
  let get_regression_of_previous_val t = t.regression_of_previous_val
  let get_model_residual t = t.model_residual
end

module Model = struct
  type t =
    { mutable weight : float
    ; mutable bias : float
    }

  let create () = { weight = 0.; bias = 0. }
  let weight t = t.weight
  let bias t = t.bias
  let linear_regression_function = Linear_regression.ordinary_least_squares

  let fit t (data : Types.Total_Data.t) =
    let dataset = Types.Total_Data.get_all_dates_prices data () in
    let dataset =
      List.map dataset ~f:(fun data_tuple ->
        Types.Date.time_to_unix (fst data_tuple), snd data_tuple)
    in
    let weight, bias = linear_regression_function dataset in
    t.weight <- weight;
    t.bias <- bias
  ;;

  let predict t ~x_val =
    Linear_regression.predict ~weight:(weight t) ~bias:(bias t) ~x_val
  ;;
end

module AutoRegressor = struct
  type t =
    { mutable p : int
    ; mutable q : int
    ; mutable dataset : Types.Total_Data.t
    }

  let p t = t.p
  let q t = t.q
  let dataset t = t.dataset
  let create_model (data : Types.Total_Data.t) (p : int) = data, p

  let update_parameters t p q =
    t.p <- p;
    t.q <- q
  ;;

  let predict_next_price t =
    let training_dataset =
      Types.Total_Data.last_n_days_dataset (dataset t) ~num_of_days:(p t)
    in
    let model = Model.create () in
    Model.fit model training_dataset;
    Model.predict model
  ;;

  (* let predict_next_n_prices t ~num_predictions = let training_dataset =
     Types.Total_Data.last_n_days_dataset (dataset t) ~num_of_days:(p t) in
     for i = 1 to num_predictions do ( predict_next_price t ) done ;; *)
end

(* let%expect_test "last_n_days_dataset2" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~open_:0.
        ~high:0.
        ~low:0.
        ~close:(Int.to_float int)
        ~volume:0)
  in
  Total_Data.add_days_data total_data days;
  let last_n_days =
    Total_Data.last_n_days_dataset total_data ~num_of_days:5
  in
  print_s [%message (last_n_days : Total_Data.t)];
  [%expect
    {|
    (last_n_days
     ((crypto Bitcoin)
      (days
       (((date ((year 2022) (month 7) (day 25))) (open_ 0) (high 0) (low 0)
         (close 5) (volume 0))
        ((date ((year 2022) (month 7) (day 26))) (open_ 0) (high 0) (low 0)
         (close 6) (volume 0))
        ((date ((year 2022) (month 7) (day 27))) (open_ 0) (high 0) (low 0)
         (close 7) (volume 0))
        ((date ((year 2022) (month 7) (day 28))) (open_ 0) (high 0) (low 0)
         (close 8) (volume 0))
        ((date ((year 2022) (month 7) (day 29))) (open_ 0) (high 0) (low 0)
         (close 9) (volume 0))))))
      |}]
;; *)
