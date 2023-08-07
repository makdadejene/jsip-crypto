open! Core
open! Auto_regressor
open! Moving_average
open! Types

module ArimaModel = struct
  type t =
    { mutable ar_model : AutoRegressor.t
    ; mutable weighted_average : float
    ; mutable mvg_model : MovingAverageModel.t
    ; mutable full_dataset : Total_Data.t
    ; mutable predictions : Prediction.t array
    }
  [@@deriving sexp_of, fields ~getters]

  let create ~dataset ?(weighted_average = 0.5) () =
    let ar_model = AutoRegressor.create ~dataset () in
    let mvg_model = MovingAverageModel.create ~dataset () in
    { ar_model
    ; weighted_average
    ; mvg_model
    ; full_dataset = dataset
    ; predictions = List.to_array []
    }
  ;;

  let update_dateset t dataset = t, dataset

  let update_predictions t prediction =
    let new_predictions =
      Array.append t.predictions (List.to_array [ prediction ])
    in
    Array.sort new_predictions ~compare:Prediction.compare;
    t.predictions <- new_predictions
  ;;

  let predict_next_price t =
    let ar_model_prediction =
      AutoRegressor.predict_next_price (ar_model t)
    in
    let mvg_model_prediction =
      MovingAverageModel.predict_next_price (mvg_model t)
    in
    let prediction =
      Prediction.average_predictions
        ~first_prediction:ar_model_prediction
        ~second_prediction:mvg_model_prediction
        ~prediction_coeff:(weighted_average t)
    in
    update_predictions t prediction;
    prediction
  ;;

  let data_graph_points t =
    List.map
      (Total_Data.get_all_dates_prices (full_dataset t) ())
      ~f:(fun (date, price) -> Date.to_string date, price)
  ;;

  let predictions_graph_points t =
    Array.map (predictions t) ~f:(fun prediction ->
      ( Date.to_string (Prediction.date prediction)
      , Prediction.prediction prediction ))
  ;;

  let all_graph_points t =
    let dataset_points =
      List.map
        (Total_Data.get_all_dates_prices (full_dataset t) ())
        ~f:(fun (date, price) -> Date.to_string date, price)
    in
    let prediction_points =
      Array.map (predictions t) ~f:(fun prediction ->
        ( Date.to_string (Prediction.date prediction)
        , Prediction.prediction prediction ))
    in
    dataset_points, prediction_points
  ;;
end

let%expect_test "simple_model_test" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days1 =
    List.init 9 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-1" ^ Int.to_string (int + 1))
        ~close:(Int.to_float (int + 1))
        ())
  in
  let days2 =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~close:(Int.to_float (10 - int))
        ())
  in
  Total_Data.add_days_data total_data days1;
  Total_Data.add_days_data total_data days2;
  let model = ArimaModel.create ~dataset:total_data () in
  let prediction = ArimaModel.predict_next_price model in
  let gp = Gp.create () in
  let data_points_series =
    Gp.Series.lines_xy
      ~color:`Green
      (List.map
         (Total_Data.get_all_dates_prices total_data ())
         ~f:(fun data_tuple ->
           Date.time_to_unix (fst data_tuple), snd data_tuple))
  in
  let prediction_series =
    Gp.Series.points_xy
      ~color:`Magenta
      [ (let unix_date = Date.time_to_unix (Prediction.date prediction) in
         let price = Prediction.prediction prediction in
         price, unix_date)
      ]
  in
  Gp.plot_many
    gp
    ~output:(Gp.Output.create (`Png "arima_predictor_test.png"))
    [ data_points_series; prediction_series ];
  Gp.close gp;
  print_s [%message (prediction : Prediction.t)];
  [%expect
    {| 
   (prediction ((date ((year 2022) (month 7) (day 30))) (prediction 1)))|}]
;;
