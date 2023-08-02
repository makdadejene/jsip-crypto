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
  
  let create () = {weight=0. ; bias=0.}

  let weight t = t.weight
  let bias t = t.bias

  let linear_regression_function = Linear_regression.ordinary_least_squares

  (* let update_sigma (data : Types.Total_Data.t) t =
    let day_prices_data = Types.Total_Data.get_all_dates_prices data () in
    let _dates, prices =
      ( Array.of_list
          (List.map day_prices_data ~f:(fun data_tuple -> fst data_tuple))
      , Array.of_list
          (List.map day_prices_data ~f:(fun data_tuple -> snd data_tuple)) )
    in
    let sigma = Owl_base_stats.std prices in
    t.sigma <- sigma
  ;; *)

  (* let fit t (data : Types.Total_Data.t) = 
    let dataset = Types.Total_Data.get_all_dates_prices data () in
    let dataset = List.map dataset ~f:(fun date, price -> (Types.Date.time_to_unix date), price) in
    let weight, bias = linear_regression_function dataset in  
    t.weight <- weight; 
    t.bias <- bias
    ;;

  let predict t ~x_val = Linear_regression.predict ~weight:(weight t) ~bias:(bias t) ~x_val  *)
end

module AutoRegressor = struct
  type t =
    { p : int
    ; q : int
    ; dataset : Types.Total_Data.t
    }

  let p t = t.p
  let q t = t.q
  let dataset t = t.dataset
  let create_model (data : Types.Total_Data.t) (p : int) = data, p
  let update_parameters t = t

  (* let predict_next_price t = 
    let training_dataset = Types.Total_Data.last_n_days_dataset (dataset t) ~num_of_days:(p t) in
    let model = Model.create () in
    Model.fit model training_dataset;
    Model.predict model 

  let predict_next_n_prices t ~num_predictions =
    let training_dataset = Types.Total_Data.last_n_days_dataset (dataset t) ~num_of_days:(p t) in
    for i = 1 to num_predictions do
      (
        predict_next_price t
      )
    done 
  ;; *)
end
