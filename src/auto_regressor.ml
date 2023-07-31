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
    ; mutable sigma : float
    }

  let linear_regression_function = (fun x_values y_values -> List.hd_exn x_values, List.hd_exn y_values)

  (* let update_sigma (data : Types.Total_Data.t) t =
    let day_values = Types.Total_Data.get_all_day_data data in
    let day_values = Array.of_list day_values in
    let sigma = Owl_base_stats.std day_values in
    t.sigma <- sigma
  ;;

  let fit (data : Types.Total_Data.t) t =
    let x, y = Types.Total_Data.get_all_times data in
    let weight, bias = linear_regression_function x y in
    t.weight <- weight;
    t.bias <- bias *)
  ;;
end

module AutoRegressor = struct
  type t =
    { time_steps : int
    ; prediction : Prediction.t list
    ; hyperparameters : Hyperparameters.t
    ; model : Model.t
    }

  let create_hyperparameters (_data : Types.Total_Data.t) = ()
  let calculate_model_residual (_data : Types.Total_Data.t) = ()
  let create_model (_data : Types.Total_Data.t) (_time_steps : int) = ()
  let update_parameters t = t
  let predict_next_price () = ()
end
