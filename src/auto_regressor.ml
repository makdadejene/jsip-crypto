open! Core
open! Owl_base

module Prediction = struct
  type t =
    { date : Types.Date.t
    ; prediction : float
    }
  [@@deriving sexp_of]

  let create date prediction = { date; prediction }
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
  let create ~dataset ?(p = 3) ?(q = 3) () = { p; q; dataset }

  let update_parameters t p q =
    t.p <- p;
    t.q <- q
  ;;

  let update_dateset t ~new_dataset = t.dataset <- new_dataset

  let predict_next_price t =
    let training_dataset =
      Types.Total_Data.last_n_days_dataset (dataset t) ~num_of_days:(p t)
    in
    let next_date = Types.Total_Data.next_day_date training_dataset in
    let next_date_unix = Types.Date.time_to_unix next_date in
    let model = Model.create () in
    Model.fit model training_dataset;
    let prediction = Model.predict model ~x_val:next_date_unix in
    Prediction.create next_date prediction
  ;;

  (* let predict_next_n_prices t ~num_predictions = let training_dataset =
     Types.Total_Data.last_n_days_dataset (dataset t) ~num_of_days:(p t) in
     for i = 1 to num_predictions do ( predict_next_price t ) done ;; *)
end

let%expect_test "predict_next_price" =
  let total_data = Types.Total_Data.create Types.Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Types.Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~open_:0.
        ~high:0.
        ~low:0.
        ~close:(Int.to_float int)
        ~volume:0)
  in
  Types.Total_Data.add_days_data total_data days;
  let autoregressor_model = AutoRegressor.create ~dataset:total_data () in
  let predicted_price =
    AutoRegressor.predict_next_price autoregressor_model
  in
  print_s [%message (predicted_price : Prediction.t)];
  [%expect
    {| 
   (predicted_price ((date ((year 2022) (month 7) (day 30))) (prediction 10))) |}]
;;
