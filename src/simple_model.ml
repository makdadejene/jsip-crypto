open! Core
open! Auto_regressor
open! Moving_average

let data = Fetch_data.get_day_data Bitcoin
let calculate_sma _length_of_window = ()

module ArimaModel = struct
  type t =
    { mutable ar_model : AutoRegressor.t
    ; mutable weighted_average : float
    ; mutable mvg_model : MovingAverageModel.t
    ; mutable full_dataset : Types.Total_Data.t
    ; mutable predictions : Prediction.t list
    }
  [@@deriving sexp_of, fields ~getters]

  let update_dateset t dataset = t, dataset
  let fit () = ()

  let predict_next_price t =
    let ar_model_prediction =
      AutoRegressor.predict_next_price (ar_model t)
    in
    let mvg_model_prediction =
      MovingAverageModel.predict_next_price (mvg_model t)
    in
    Prediction.average_predictions
      ~first_prediction:ar_model_prediction
      ~second_prediction:mvg_model_prediction
      ~prediction_coeff:(weighted_average t)
  ;;

  let graph_points t =
    let dataset_points =
      List.map
        (Types.Total_Data.get_all_dates_prices (full_dataset t) ())
        ~f:(fun (date, price) -> Types.Date.to_string date, price)
    in
    let prediction_points =
      List.map (predictions t) ~f:(fun prediction ->
        ( Types.Date.to_string (Prediction.date prediction)
        , Prediction.prediction prediction ))
    in
    dataset_points, prediction_points
  ;;
end

(* let%expect_test "graphing_larger_dataset_ar_model" = let total_data =
   Types.Total_Data.create Types.Crypto.Bitcoin in let days1 = List.init 9
   ~f:(fun int -> Types.Day_Data.create ~date:("2022-07-1" ^ Int.to_string
   (int + 1)) ~close:(Int.to_float (int + 1)) ()) in let days2 = List.init 10
   ~f:(fun int -> Types.Day_Data.create ~date:("2022-07-2" ^ Int.to_string
   int) ~close:(Int.to_float (10 - int)) ()) in
   Types.Total_Data.add_days_data total_data days1;
   Types.Total_Data.add_days_data total_data days2; let model =
   AutoRegressor.create ~dataset:total_data ~p:5 () in let prediction =
   AutoRegressor.predict_next_price model in let gp = Gp.create () in let
   data_points_series = Gp.Series.lines_xy ~color:`Green (List.map
   (Types.Total_Data.get_all_dates_prices total_data ()) ~f:(fun data_tuple
   -> Types.Date.time_to_unix (fst data_tuple), snd data_tuple)) in let
   prediction_series = Gp.Series.points_xy ~color:`Magenta [ (let unix_date =
   Types.Date.time_to_unix (Prediction.date prediction) in let price =
   Prediction.prediction prediction in price, unix_date) ] in Gp.plot_many gp
   ~output: (Gp.Output.create (`Png
   "mvg_predictor_large_window_large_q.png")) [ data_points_series;
   prediction_series ]; Gp.close gp; print_s [%message (prediction :
   Prediction.t)]; [%expect {| (prediction ((date ((year 2022) (month 7) (day
   30))) (prediction 5.2000000000007276)))|}] ;; *)
