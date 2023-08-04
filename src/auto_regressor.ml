open! Core
open! Owl_base
open! Types
module Gp = Gnuplot

module AutoRegressor = struct
  type t =
    { mutable p : int
    ; mutable dataset : Total_Data.t
    }
  [@@deriving sexp_of, fields ~getters]

  let create ~dataset ?(p = 3) () = { p; dataset }
  let update_parameters t p = t.p <- p
  let update_dateset t ~new_dataset = t.dataset <- new_dataset

  let predict_next_price t =
    let training_dataset =
      Total_Data.last_n_days_dataset (dataset t) ~num_of_days:(p t)
    in
    let next_date = Total_Data.next_day_date training_dataset in
    let next_date_unix = Date.time_to_unix next_date in
    let model = Model.create () in
    Model.fit model training_dataset;
    let prediction = Model.predict model ~x_val:next_date_unix in
    Prediction.create next_date prediction
  ;;
end

let%expect_test "predict_next_price" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~close:(Int.to_float int)
        ())
  in
  Total_Data.add_days_data total_data days;
  let autoregressor_model = AutoRegressor.create ~dataset:total_data () in
  let predicted_price =
    AutoRegressor.predict_next_price autoregressor_model
  in
  print_s [%message (predicted_price : Prediction.t)];
  [%expect
    {| 
   (predicted_price ((date ((year 2022) (month 7) (day 30))) (prediction 10))) |}]
;;

let%expect_test "predict_next_price" =
  let total_data = Types.Total_Data.create Types.Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Types.Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~close:(Int.to_float (int + (int % 2 * 2) - 1))
        ())
  in
  Types.Total_Data.add_days_data total_data days;
  let autoregressor_model =
    AutoRegressor.create ~dataset:total_data ~p:3 ()
  in
  let predicted_price =
    AutoRegressor.predict_next_price autoregressor_model
  in
  print_s [%message (predicted_price : Prediction.t)];
  [%expect
    {| 
   (predicted_price
    ((date ((year 2022) (month 7) (day 30))) (prediction 10.333333333332121))) |}]
;;

let%expect_test "graphing_larger_dataset_ar_model" =
  let total_data = Types.Total_Data.create Types.Crypto.Bitcoin in
  let days1 =
    List.init 9 ~f:(fun int ->
      Types.Day_Data.create
        ~date:("2022-07-1" ^ Int.to_string (int + 1))
        ~close:(Int.to_float (int + 1))
        ())
  in
  let days2 =
    List.init 10 ~f:(fun int ->
      Types.Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~close:(Int.to_float (10 - int))
        ())
  in
  Types.Total_Data.add_days_data total_data days1;
  Types.Total_Data.add_days_data total_data days2;
  let model = AutoRegressor.create ~dataset:total_data ~p:5 () in
  let prediction = AutoRegressor.predict_next_price model in
  print_s [%message (prediction : Prediction.t)];
  [%expect
    {|
    (prediction ((date ((year 2022) (month 7) (day 30))) (prediction 0)))|}]
;;
