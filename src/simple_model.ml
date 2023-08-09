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

  let create
    ~coin
    ?(dataset = Types.Total_Data.create coin)
    ?(weighted_average = 0.5)
    ()
    =
    let dataset =
      if Total_Data.is_empty dataset
      then Fetch_data.get_day_data coin
      else dataset
    in
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

  let update_model_training_sets t training_set =
    MovingAverageModel.update_dateset (mvg_model t) ~new_dataset:training_set;
    AutoRegressor.update_dateset (ar_model t) ~new_dataset:training_set
  ;;

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

  let predict_all_prices t window_size =
    let full_dataset = full_dataset t in
    let coin = Total_Data.crypto full_dataset in
    let predictions =
      List.foldi
        (Total_Data.days full_dataset)
        ~init:(List.to_array [])
        ~f:(fun index acc _day_data ->
          if window_size <= index + 1
             && AutoRegressor.p (ar_model t) <= index + 1
             && MovingAverageModel.q (mvg_model t) <= index + 1
             && MovingAverageModel.moving_avereage_window (mvg_model t)
                <= index + 1
          then (
            let training_dataset =
              { Total_Data.crypto = coin
              ; days = List.take (Total_Data.days full_dataset) index
              }
            in
            update_model_training_sets t training_dataset;
            let prediction = predict_next_price t in
            Array.append acc (List.to_array [ prediction ]))
          else acc)
    in
    t.predictions <- predictions
  ;;

  let data_graph_points t =
    List.to_array
      (List.map
         (Total_Data.get_all_dates_prices (full_dataset t) ())
         ~f:(fun (date, price) ->
           Date.to_string date, Float.round_decimal price ~decimal_digits:4))
  ;;

  let predictions_graph_points t =
    Array.map (predictions t) ~f:(fun prediction ->
      ( Date.to_string (Prediction.date prediction)
      , Float.round_decimal
          (Prediction.prediction prediction)
          ~decimal_digits:4 ))
  ;;

  let all_graph_points t =
    let dataset_points = data_graph_points t in
    let prediction_points = predictions_graph_points t in
    dataset_points, prediction_points
  ;;
end
